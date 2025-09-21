TL.RegisterHeartHandler(HeartSubType.HEART_SOUL, {
    onMorph = function(pickup, meta)
        if not pickup or not pickup:Exists() then return nil end
        local rng = pickup:GetDropRNG()
        local player = Isaac.GetPlayer(0)
        local roll = rng:RandomFloat()
        local isTLost = player:GetPlayerType() == PlayerType.PLAYER_THELOST_B

        local function ChestSubtypeChance(baseGoldenChance)
            local chance = TL.LuckChance(player, baseGoldenChance, 0.5)
            return rng:RandomFloat() < chance and PickupVariant.PICKUP_LOCKEDCHEST or PickupVariant.PICKUP_CHEST
        end

        if isTLost then
            if roll < TL.LuckChance(player, 0.02, 0.25) then
                return {action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_TAROTCARD, subtype=Card.CARD_HOLY}
            elseif roll < TL.LuckChance(player, 0.08, 0.35) then
                return {action="spawn_chest", variant=ChestSubtypeChance(0.4)}
            end
        else
            if roll < TL.LuckChance(player, 0.12, 0.45) then
                return {action="spawn_chest", variant=ChestSubtypeChance(0.6)}
            end
        end

        if roll < TL.LuckChance(player, 0.40, 0.20) then
            local coinRoll = rng:RandomFloat()
            if coinRoll < 0.8 then
                return {action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_PENNY}
            elseif coinRoll < 0.95 then
                return {action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_NICKEL}
            else
                return {action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_DIME}
            end
        else
            if rng:RandomInt(2) == 0 then
                return {action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_KEY, subtype=0}
            else
                return {action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_BOMB, subtype=0}
            end
        end
    end
})
