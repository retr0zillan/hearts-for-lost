local mod = _G.mod
local TL = _G.TL

TL.RegisterHeartHandler(HeartSubType.HEART_ETERNAL, {
    onMorph = function(pickup, meta)
        if not pickup or not pickup:Exists() then return nil end
        local rng = pickup:GetDropRNG()
        local player = Isaac.GetPlayer(0)
        local roll = rng:RandomFloat()

        local chestChance = TL.LuckChance(player, 0.05, 0.15)
        if roll < chestChance then
            return {action="spawn_chest", variant=PickupVariant.PICKUP_ETERNALCHEST}
        else
            return {action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_TAROTCARD, subtype=Card.CARD_HOLY}
        end
    end
})
