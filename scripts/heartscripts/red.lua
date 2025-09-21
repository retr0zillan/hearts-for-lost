-- red.lua
local mod = _G.mod 
local TL = _G.TL

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
        local player = Isaac.GetPlayer(0)

        if sub2 == HeartSubType.HEART_HALF or sub2 == HeartSubType.HEART_HALF_SOUL then
            return {
                action  = "morph",
                type    = EntityType.ENTITY_PICKUP,
                variant = PickupVariant.PICKUP_COIN,
                subtype = CoinSubType.COIN_PENNY
            }
        end

        if sub2 == HeartSubType.HEART_FULL then
            local roll = rng:RandomFloat()

            local dimeChance   = TL.LuckChance(player, 0.03, 0.07)   -- base 3%, 
            local nickelChance = TL.LuckChance(player, 0.12, 0.18)   -- base 12%, 
    
            if roll < dimeChance then
                return { action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_DIME }
            elseif roll < dimeChance + nickelChance then
                return { action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_NICKEL }
            else
                return { action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_PENNY }
            end
        end

        -- doublepack or scared → Penny / Nickel / Dime / Lucky
        if sub2 == HeartSubType.HEART_DOUBLEPACK or sub2 == HeartSubType.HEART_SCARED then
            local roll = rng:RandomFloat()

            local luckyChance  = TL.LuckChance(player, 0.05, 0.15)
            local dimeChance   = TL.LuckChance(player, 0.25, 0.25)  
            local nickelChance = TL.LuckChance(player, 0.30, 0.20)  
            if roll < luckyChance then
                return { action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_LUCKYPENNY }
            elseif roll < luckyChance + dimeChance then
                return { action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_DIME }
            elseif roll < luckyChance + dimeChance + nickelChance then
                return { action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_NICKEL }
            else
                return { action="morph", type=EntityType.ENTITY_PICKUP, variant=PickupVariant.PICKUP_COIN, subtype=CoinSubType.COIN_PENNY }
            end
        end

        return nil
    end
})
