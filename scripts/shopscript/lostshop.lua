local mod = _G.mod
local TL  = _G.TL

local SHOP_OPTIONS = {
    {variant = PickupVariant.PICKUP_KEY, subtype = KeySubType.KEY_NORMAL},
    {variant = PickupVariant.PICKUP_BOMB, subtype = BombSubType.BOMB_NORMAL},
    {variant = PickupVariant.PICKUP_PILL, subtype = PillColor.PILL_NULL},
    {variant = PickupVariant.PICKUP_TAROTCARD, subtype = 0},
}

local function ConvertShopHeart(pickup)
    if not pickup or not pickup:Exists() or not pickup:IsShopItem() or pickup.Variant ~= PickupVariant.PICKUP_HEART then return end
    if not TL.HasTaintedLost() then return end

    local d = pickup:GetData()
    if d._tl_shopConverted then return end
    d._tl_shopConverted = true

    local rng = pickup:GetDropRNG()
    local choice = SHOP_OPTIONS[rng:RandomInt(#SHOP_OPTIONS) + 1]

    pickup:Morph(EntityType.ENTITY_PICKUP, choice.variant, choice.subtype, false, false, true)
    pickup.Price = 5
    pickup.AutoUpdatePrice = false
    pickup.ShopItemId = -1
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
    ConvertShopHeart(pickup)
end)
