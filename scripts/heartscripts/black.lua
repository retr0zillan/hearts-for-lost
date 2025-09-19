local mod = _G.mod 
local TL = _G.TL

-- stat config
local STAT_LIST = { "damage", "tears", "speed", "shotspeed", "range", "luck" }
local INCREMENTS = {
    damage    = 0.50,
    tears     = -0.20,
    speed     = 0.12,
    shotspeed = 0.18,
    range     = 1,
    luck      = 1
}
local CACHE_MAP = {
    damage    = CacheFlag and CacheFlag.CACHE_DAMAGE or 1,
    tears     = CacheFlag and CacheFlag.CACHE_FIREDELAY or 2,
    shotspeed = CacheFlag and CacheFlag.CACHE_SHOTSPEED or 4,
    range     = CacheFlag and CacheFlag.CACHE_RANGE or 8,
    speed     = CacheFlag and CacheFlag.CACHE_SPEED or 16,
    luck      = CacheFlag and CacheFlag.CACHE_LUCK or 1024,
}

local function ensurePlayerBoostTable(player)
    local d = player:GetData()
    d._blackHeartBoosts = d._blackHeartBoosts or { damage=0, tears=0, speed=0, shotspeed=0, range=0, luck=0 }
    return d._blackHeartBoosts
end

-- onCollision handler
local function onBlackCollision(pickup, player)
    if not pickup or not pickup:Exists() then return end
    if not player then return end

    local rng = pickup:GetDropRNG()
    local idx = (rng:RandomInt(#STAT_LIST) + 1)
    local chosen = STAT_LIST[idx]
    local inc = INCREMENTS[chosen] or 0

    local boosts = ensurePlayerBoostTable(player)
    boosts[chosen] = (boosts[chosen] or 0) + inc

    local sfx = SFXManager()
    sfx:Play(SoundEffect.SOUND_POWERUP1, 1.0, 0, false, 1.0)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)

    local cacheFlag = CACHE_MAP[chosen] or CacheFlag.CACHE_ALL
    player:AddCacheFlags(cacheFlag)
    player:EvaluateItems()
end

-- register handler
TL.RegisterHeartHandler(HeartSubType.HEART_BLACK, {
    onCollision = onBlackCollision
})

-- keep evaluate cache from original to apply boosts
function mod:OnEvaluateCache(player, cacheFlag)
    local d = player:GetData()
    if not d or not d._blackHeartBoosts then return end
    local b = d._blackHeartBoosts

    if (cacheFlag & (CacheFlag and CacheFlag.CACHE_DAMAGE or 1)) ~= 0 then
        player.Damage = player.Damage + (b.damage or 0)
    end
    if (cacheFlag & (CacheFlag and CacheFlag.CACHE_FIREDELAY or 2)) ~= 0 then
        player.MaxFireDelay = player.MaxFireDelay + (b.tears or 0)
    end
    if (cacheFlag & (CacheFlag and CacheFlag.CACHE_SPEED or 16)) ~= 0 then
        player.MoveSpeed = player.MoveSpeed + (b.speed or 0)
    end
    if (cacheFlag & (CacheFlag and CacheFlag.CACHE_SHOTSPEED or 4)) ~= 0 then
        player.ShotSpeed = player.ShotSpeed + (b.shotspeed or 0)
    end
    if (cacheFlag & (CacheFlag and CacheFlag.CACHE_RANGE or 8)) ~= 0 then
        player.TearRange = player.TearRange + ((b.range or 0) * 40)
    end
    if (cacheFlag & (CacheFlag and CacheFlag.CACHE_LUCK or 1024)) ~= 0 then
        player.Luck = player.Luck + (b.luck or 0)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.OnEvaluateCache)
