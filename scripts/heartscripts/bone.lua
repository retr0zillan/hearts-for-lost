local mod = _G.mod 
local TL  = _G.TL

TL.RegisterHeartHandler(HeartSubType.HEART_BONE, {
    onMorph = function(pickup, meta)
        if not pickup or not pickup:Exists() then return nil end
        local rng = pickup:GetDropRNG()

        -- le 50% 50%
        if rng:RandomInt(2) == 0 then
            return {
                action  = "morph",
                type    = EntityType.ENTITY_PICKUP,
                variant = PickupVariant.PICKUP_KEY,
                subtype = KeySubType.KEY_NORMAL
            }
        else
            return {
                action  = "morph",
                type    = EntityType.ENTITY_PICKUP,
                variant = PickupVariant.PICKUP_BOMB,
                subtype = BombSubType.BOMB_NORMAL
            }
        end
    end
})
