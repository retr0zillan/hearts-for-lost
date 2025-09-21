-- bone.lua
local mod = _G.mod
local TL  = _G.TL

TL.RegisterHeartHandler(HeartSubType.HEART_BONE, {
    onMorph = function(pickup, meta)
        if not pickup or not pickup:Exists() then return nil end

        return {
            action = "custom",
            exec = function(entry)
                local p = entry.pickup
                if not p or not p:Exists() then return end
                local player = Isaac.GetPlayer(0)
                if not player then return end

                local basePos = player.Position
                for i = 1, 3 do
                    local famEnt = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_ORBITAL, 0, basePos, Vector.Zero, player)
                    if famEnt and famEnt:Exists() then
                        local fam = famEnt:ToFamiliar()
                        if fam then
                            fam.Player = player
                            fam.OrbitDistance = Vector(60 + (i-1)*6, 60 + (i-1)*6)
                            fam.OrbitAngleOffset = (i-1) * (2 * math.pi / 3)
                            pcall(function() fam:AddToOrbit(1) end) 
                        end
                    end
                end

                p:Remove()
            end
        }
    end
})
