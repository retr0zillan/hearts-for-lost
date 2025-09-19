local mod = _G.mod 
local TL  = _G.TL

local rottenHandler = {
    onMorph = function(pickup, meta)
        return {
            action = "custom",
            exec = function(entry)
                local p = entry.pickup
                if not p or not p:Exists() then return end

                local rng = p:GetDropRNG()
                local player = Isaac.GetPlayer()

                local count = 6
                if rng:RandomInt(2) == 0 then
                    for i = 1, count do
                        player:AddBlueFly(p.Position, player)
                    end
                else
                    for i = 1, count do
                        player:AddBlueSpider(p.Position, player)
                    end
                end

                p:Remove()
            end
        }
    end
}

TL.RegisterHeartHandler(HeartSubType.HEART_ROTTEN, rottenHandler)
