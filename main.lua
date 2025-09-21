_G.mod = RegisterMod("Hearts for Lost and Tainted Lost", 1)
local mod = _G.mod

_G.TL = {}
local TL = _G.TL

-- registry / state / queue
TL.heartRegistry = {}         -- subtype -> handlerTable
TL.pendingMorphs = {}         -- queue entries
TL.currentFrame = -1

-- helpers
function TL.HasTaintedLost()
    local game = Game()
    for i = 0, game:GetNumPlayers()-1 do
        local p = Isaac.GetPlayer(i)
        if p and (p:GetPlayerType() == PlayerType.PLAYER_THELOST or p:GetPlayerType() == PlayerType.PLAYER_THELOST_B) then
            return true
        end
    end
    return false
end

-- utils
function TL.LuckChance(player, baseChance, scale)
    local luck = player.Luck
    local luckFactor
    if luck >= 0 then
        luckFactor = math.log(1 + luck) / 5
    else
        luckFactor = luck / 50
    end
    local chance = baseChance + (scale * luckFactor)
    if chance < 0 then chance = 0 end
    if chance > 1 then chance = 1 end

    return chance
end

-- Register a handler for one or many heart subtypes.
-- handlerTable may contain:
--  onMorph(entry) -> returns plan table (see ExecutePlan)
--  onCollision(pickup, player) -> immediate effect on collision
function TL.RegisterHeartHandler(subtypes, handlerTable)
    if type(subtypes) == "number" then subtypes = { subtypes } end
    for _, st in ipairs(subtypes) do
        TL.heartRegistry[st] = handlerTable
    end
end

-- Queue a morph entry
function TL.QueueMorph(pickup, delayFrames, handler, meta)
    if not pickup or not pickup:Exists() then return end
    if pickup:IsShopItem() then return end
    local pData = pickup:GetData()
    if pData._tl_queued then return end
    pData._tl_queued = true

    local game = Game()
    local frame = game:GetFrameCount()
    if frame ~= TL.currentFrame then TL.currentFrame = frame end

    table.insert(TL.pendingMorphs, {
        pickup = pickup,
        triggerFrame = frame + (delayFrames or 30),
        handler = handler,
        meta = meta or {}
    })
end

-- Execute plan produced by a handler
function TL.ExecutePlan(entry, plan)
    if not plan then return end
    local p = entry.pickup
    if not p or not p:Exists() then return end

    if plan.action == "morph" then
        p:Morph(plan.type or EntityType.ENTITY_PICKUP, plan.variant or PickupVariant.PICKUP_COIN, plan.subtype or 0, plan.keepPrice or false)
    elseif plan.action == "spawn_chest" then
        local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, plan.variant or PickupVariant.PICKUP_CHEST, plan.subtype or 0, p.Position, Vector.Zero, nil):ToPickup()
        if chest and chest:Exists() then
            chest:TryOpenChest(nil)
        end
        p:Remove()
    elseif plan.action == "custom" and type(plan.exec) == "function" then
        plan.exec(entry)
    end
end

-- Process queue every update
function TL.ProcessPendingMorphs()
    if #TL.pendingMorphs == 0 then return end
    local game = Game()
    local frame = game:GetFrameCount()
    local sfx = SFXManager()

    for i = #TL.pendingMorphs, 1, -1 do
        local entry = TL.pendingMorphs[i]
        local p = entry.pickup

        if not p or not p:Exists() then
            if p and p:GetData() then p:GetData()._tl_queued = nil end
            table.remove(TL.pendingMorphs, i)
        elseif frame >= entry.triggerFrame then
            local plan = nil
            if entry.handler and type(entry.handler.onMorph) == "function" then
                local ok, result = pcall(entry.handler.onMorph, entry.pickup, entry.meta)
                if ok then plan = result end
            end

            if plan then
                local effEnt = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, p.Position, Vector.Zero, nil)
                if effEnt and effEnt:Exists() then
                    local eff = effEnt:ToEffect()
                    if eff then
                        eff.CollisionDamage = 0
                        eff:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
                        eff.Parent = p
                    end
                end
                sfx:Play(SoundEffect.SOUND_HOLY, 1.0, 0, false, 1.0)

                TL.ExecutePlan(entry, plan)
            end

            if p and p:GetData() then p:GetData()._tl_queued = nil end
            table.remove(TL.pendingMorphs, i)
        end
    end
end

function TL.ClearPendingMorphs()
    for _, entry in ipairs(TL.pendingMorphs) do
        local p = entry.pickup
        if p and p:Exists() and p:GetData() then
            p:GetData()._tl_queued = nil
        end
    end
    TL.pendingMorphs = {}
    TL.currentFrame = -1
end

-- Handle a pickup when it spawns or when scanning a room.
-- fromScan: boolean (true if called during room scan)
function TL.HandlePickupInit(pickup, fromScan)
    if not pickup or not pickup:Exists() then return end
    if pickup.Variant ~= PickupVariant.PICKUP_HEART then return end
    if pickup:IsShopItem() then return end
    if not TL.HasTaintedLost() then return end

    local handler = TL.heartRegistry[pickup.SubType]
    if not handler then return end
    if fromScan then
        local pData = pickup:GetData()
        if pData._tl_roomChecked then return end
        pData._tl_roomChecked = true

        -- Only queue morphs when scanning; do NOT call onCollision here.
        if type(handler.onMorph) == "function" then
            local meta = {}

            TL.QueueMorph(pickup, 30, handler, meta)
        end

        return
    end

    -- non-scan (normal spawn) behavior:
    -- if handler has onMorph, queue it
    if type(handler.onMorph) == "function" then
        local meta = {}
        TL.QueueMorph(pickup, 30, handler, meta)
    end
end

-- Scan current room for hearts
function TL.ScanRoomHearts()
    if not TL.HasTaintedLost() then return end
    local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, -1, true, false)
    for _, e in ipairs(pickups) do
        local p = e:ToPickup()
        if p and p:Exists() then
            TL.HandlePickupInit(p, true)
        end
    end
end

-- Callbacks
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function() TL.ProcessPendingMorphs() end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
    TL.HandlePickupInit(pickup, false)
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    TL.ClearPendingMorphs()
    TL.ScanRoomHearts()
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider, low)
    if not pickup or not pickup:Exists() then return end
    if pickup.Variant ~= PickupVariant.PICKUP_HEART then return end
    local handler = TL.heartRegistry[pickup.SubType]
    if not handler or type(handler.onCollision) ~= "function" then return end
    if not TL.HasTaintedLost() then return end
    local player = collider and collider:ToPlayer()
    if not player then return end

    local pData = pickup:GetData()
    if pData._tl_blackHandled then return end
    pData._tl_blackHandled = true

    pcall(handler.onCollision, pickup, player)
end)

-- includes
include("scripts/heartscripts/soul")
include("scripts/heartscripts/black")
include("scripts/heartscripts/red")
include("scripts/heartscripts/eternal")
include("scripts/shopscript/lostshop")
include("scripts/heartscripts/rotten")
include("scripts/heartscripts/bone")
include("scripts/heartscripts/blended")
