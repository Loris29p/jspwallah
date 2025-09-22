NPC_DATA = nil


_RegisterNetEvent('npc_reward:updateNPCData', function(data)
    NPC_DATA = data
end)

_RegisterNetEvent('npc_reward:CreatePeds', function(data)
    for i, npc in pairs(data) do
        RequestModel(npc.model)
        while not HasModelLoaded(npc.model) do
            Citizen.Wait(100)
        end
        local ped = CreatePed(4, GetHashKey(npc.model), npc.coords.x, npc.coords.y, npc.coords.z - 1.0, npc.coords.w, false, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 17, false)
        FreezeEntityPosition(ped, true)
        SetPedCanRagdoll(ped, false)
        SetEntityInvincible(ped, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetModelAsNoLongerNeeded(npc.model  )
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskSetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityLodDist(ped, 2000)
        local blips = AddBlipForEntity(ped)
        SetBlipSprite(blips, 546)
        SetBlipColour(blips, 24)
        SetBlipScale(blips, 0.8)
        SetBlipAsShortRange(blips, true)
        SetBlipDisplay(blips, 2)
        BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("NPC Reward")
		EndTextCommandSetBlipName(blips)
        print("NPC CREATED " .. npc.model.. " NPC ID " .. i)
    end
end)

-- Remplace la variable globale par une table pour suivre l'état de chaque NPC
local inCaptureZones = {}

function DrawText3D(data)
    SetTextScale(0.50, 0.50)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextDropShadow()
    local totalLenght = string.len(data.text)
    local textMaxLenght = data.textMaxLenght or 99 -- max 99
    local text = totalLenght > textMaxLenght and data.text:sub(1, totalLenght - (totalLenght - textMaxLenght)) or data.text
    AddTextComponentString(text)
    SetDrawOrigin(data.coords.x, data.coords.y, data.coords.z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end


Citizen.CreateThread(function()
    while true do 
        local timer = 2000 
        local playerInAnyZone = false

        if NPC_DATA then 
            for k, v in pairs(NPC_DATA) do
                local pCoords = GetEntityCoords(PlayerPedId()) 
                local npcCoords = v.coords
                local distance = GetDistanceBetweenCoords(vector3(pCoords.x, pCoords.y, pCoords.z), vector3(npcCoords.x, npcCoords.y, npcCoords.z), true)
                
                if distance <= 20.0 then 
                    timer = 0
                    playerInAnyZone = true
                    
                    if not inCaptureZones[k] then
                        inCaptureZones[k] = true
                    end

                    if v.locked then
                        DrawText3D({
                            coords = vec3(npcCoords.x, npcCoords.y, npcCoords.z + 1.0),
                            text = "[ ~r~NPC REWARD ~s~] - ~r~" .. v.captureinfo.playerUsername.."~s~ is capturing this NPC ( ~r~" .. v.captureinfo.progress .. "% ~s~)",
                        })
                    elseif v.cooldown > 0 then
                        DrawText3D({
                            coords = vec3(npcCoords.x, npcCoords.y, npcCoords.z + 1.0),
                            text = "[ ~r~NPC REWARD ~s~] - ~r~Cooldown: ~s~" ..v.cooldown .. " seconds",
                        })
                    else
                        DrawText3D({
                            coords = vec3(npcCoords.x, npcCoords.y, npcCoords.z + 1.0),
                            text = "[ ~r~NPC REWARD ~s~] - ~r~"..v.location.."~s~",
                        })
                    end
                    
                    if distance <= 2.5 then
                        if v.locked then
                            DrawTopNotification("This NPC is being captured by ~r~" .. v.captureinfo.playerUsername)
                        elseif v.cooldown > 0 then
                            DrawTopNotification("This NPC is on cooldown for ~r~" .. v.cooldown.. " seconds")
                        else
                            DrawTopNotification("Press ~INPUT_CONTEXT~ to capture the NPC")
                            if IsControlJustPressed(0, 51) then
                                -- Limite la fréquence d'envoi d'événements
                                Citizen.Wait(100)
                                Tse('npc_reward:StartCapture', k)
                            end
                        end
                    end
                else 
                    -- Si le joueur était dans cette zone et en sort maintenant
                    if inCaptureZones[k] then
                        inCaptureZones[k] = false
                        -- N'envoie l'événement qu'une seule fois lorsque le joueur sort de la zone
                        Tse('npc_reward:RemoveCapture', k)
                        Citizen.Wait(200) -- Petit délai pour éviter les envois multiples
                    end
                end
            end
        end
        
        Citizen.Wait(timer)
    end
end)