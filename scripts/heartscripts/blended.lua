local mod = _G.mod 
local TL  = _G.TL

TL.RegisterHeartHandler(HeartSubType.HEART_BLENDED, {
    onMorph = function(pickup, meta)
        if not pickup or not pickup:Exists() then return nil end
        local rng = pickup:GetDropRNG()

        
        local maxCardId = Card.CARD_JOKER  -- Repentance 78
        local cardId

        repeat
            cardId = rng:RandomInt(maxCardId + 1) 
        until cardId ~= TL.HOLY_CARD_ID  

        return {
            action  = "morph",
            type    = EntityType.ENTITY_PICKUP,
            variant = PickupVariant.PICKUP_TAROTCARD,
            subtype = cardId
        }
    end
})
