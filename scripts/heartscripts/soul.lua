TL.RegisterHeartHandler(HeartSubType.HEART_SOUL, {
    onMorph = function(pickup, meta)
        if not pickup or not pickup:Exists() then return nil end
        local rng = pickup:GetDropRNG()
        local isFirst = meta and meta.isFirst

        local isTLost = Isaac.GetPlayer(0):GetPlayerType() == PlayerType.PLAYER_THELOST_B

        if isFirst and isTLost then
            return {
                action  = "morph",
                type    = EntityType.ENTITY_PICKUP,
                variant = PickupVariant.PICKUP_TAROTCARD,
                subtype = Card.CARD_HOLY
            }
        else
            local roll = rng:RandomFloat()
            if roll < 0.05 then
                return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_KEY, subtype = KeySubType.KEY_GOLDEN }
            elseif roll < 0.10 then
                return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_BOMB, subtype = BombSubType.BOMB_GOLDEN }
            elseif roll < 0.50 then
                local coinRoll = rng:RandomFloat()
                if coinRoll < 0.8 then
                    return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_PENNY }
                elseif coinRoll < 0.95 then
                    return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_NICKEL }
                else
                    return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_DIME }
                end
            else
                if rng:RandomInt(2) == 0 then
                    return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_KEY, subtype = 0 }
                else
                    return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_BOMB, subtype = 0 }
                end
            end
        end
    end
})
