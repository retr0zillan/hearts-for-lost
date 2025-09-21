local mod = _G.mod 
local TL = _G.TL


local function onBlackCollision(pickup, player)
    if not pickup or not pickup:Exists() then return end
    if not player then return end

    local room = Game():GetRoom()
    if not room:IsClear() then
        player:UseCard (Card.CARD_DEATH, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        pickup:Remove()
    end
end

local function onBlackMorph(pickup, meta)
    local roomClear =  Game():GetRoom():IsClear()

    if roomClear then
        return {
            action = "morph",
            type = EntityType.ENTITY_PICKUP,
            variant = PickupVariant.PICKUP_TAROTCARD,
            subtype = Card.CARD_DEATH
        }
    end

    return nil
end

TL.RegisterHeartHandler(HeartSubType.HEART_BLACK, {
    onCollision = onBlackCollision,
    onMorph = onBlackMorph
})
