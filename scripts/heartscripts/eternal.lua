local mod = _G.mod 
local TL = _G.TL

TL.RegisterHeartHandler(HeartSubType.HEART_ETERNAL, {
    onMorph = function(pickup, meta)
        if not pickup or not pickup:Exists() then return nil end
        local rng = pickup:GetDropRNG()
        local roll = rng:RandomFloat()
        local variant = roll < 0.85 and PickupVariant.PICKUP_LOCKEDCHEST or PickupVariant.PICKUP_CHEST
        return { action = "spawn_chest", variant = variant, subtype = 0 }
    end
})
