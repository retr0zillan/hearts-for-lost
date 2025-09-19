local mod = _G.mod 
local TL = _G.TL

-- handler returns a plan table for main to execute
TL.RegisterHeartHandler({
    HeartSubType.HEART_FULL,
    HeartSubType.HEART_HALF,
    HeartSubType.HEART_DOUBLEPACK,
    HeartSubType.HEART_SCARED,
    HeartSubType.HEART_HALF_SOUL
}, {
    onMorph = function(pickup, meta)
        if not pickup or not pickup:Exists() then return nil end
        local rng = pickup:GetDropRNG()
        local sub2 = pickup.SubType

        if sub2 == HeartSubType.HEART_HALF or sub2 == HeartSubType.HEART_HALF_SOUL then
            return {
                action = "morph",
                type = EntityType.ENTITY_PICKUP,
                variant = PickupVariant.PICKUP_COIN,
                subtype = CoinSubType.COIN_PENNY
            }
        end

        if sub2 == HeartSubType.HEART_FULL then
            local roll = rng:RandomFloat()
            if roll < 0.85 then
                return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_PENNY }
            elseif roll < 0.97 then
                return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_NICKEL }
            else
                return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_DIME }
            end
        end

        if sub2 == HeartSubType.HEART_DOUBLEPACK or sub2 == HeartSubType.HEART_SCARED then
            local roll = rng:RandomFloat()
            if roll < 0.20 then
                return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_PENNY }
            elseif roll < 0.60 then
                return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_NICKEL }
            elseif roll < 0.90 then
                return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_DIME }
            else
                return { action = "morph", type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_LUCKYPENNY }
            end
        end

        return nil
    end
})
