ListRobberyActive = {}

_RegisterNetEvent("PREFIX_PLACEHOLDER:rh:SetRobberyInfos", function(typeA, tblData)
    if typeA == "add" then 
        ListRobberyActive[tblData.id] = tblData
        ListRobberyActive[tblData.id].blip = AddBlipForCoord(tblData.pos.x, tblData.pos.y, tblData.pos.z)
        SetBlipScale(ListRobberyActive[tblData.id].blip, 0.9)
        SetBlipSprite(ListRobberyActive[tblData.id].blip,  40)
        SetBlipColour(ListRobberyActive[tblData.id].blip,  30)
        SetBlipAlpha(ListRobberyActive[tblData.id].blip, 255)
        SetBlipAsShortRange(ListRobberyActive[tblData.id].blip, true)
        BeginTextCommandSetBlipName("STRING") 
        AddTextComponentString("House Robbery")
        EndTextCommandSetBlipName(ListRobberyActive[tblData.id].blip)
        SetBlipAsShortRange(ListRobberyActive[tblData.id].blip, 1)
        ShowAboveRadarMessage("robberyhouse_spawn")
        PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    elseif typeA == "remove" then 
        if ListRobberyActive[tblData.id].blip then 
            RemoveBlip(ListRobberyActive[tblData.id].blip) 
        end
        ListRobberyActive[tblData.id] = nil 
    elseif typeA == "modifyAccess" then 
        ListRobberyActive[tblData.id].canAcces = tblData.canAcces
        if tblData.canAcces == true then 
            SetBlipColour(ListRobberyActive[tblData.id].blip,  30)
        else
            SetBlipColour(ListRobberyActive[tblData.id].blip,  1)
        end
    elseif typeA == "event_debug" then
        SetEntityCoords(PlayerPedId(), ListRobberyActive[tblData.id].pos.x, ListRobberyActive[tblData.id].pos.y, ListRobberyActive[tblData.id].pos.z)
        inRobbery = false
    end
end)

local inRobbery = false
local PropsPoser = {}
local PropsAll = 0
function JoinHouse(id) 
    inRobbery = true
    Tse("PREFIX_PLACEHOLDER:rh:SetBucket", id)
    TeleportPlayerCoords(ListRobberyActive[id].enterPos, PlayerPedId(), false)
    local props = ListRobberyActive[id].robList
    for k, v in pairs(props) do 
        local model = GetHashKey(v.propsName)
        RequestModel(model)
        while not HasModelLoaded(model) do 
            Citizen.Wait(0)
        end
        local object = CreateObject(model, v.propsPos.x, v.propsPos.y, v.propsPos.z, true, true, true)
        SetEntityHeading(object, v.propsPos.w)
        SetEntityCoordsNoOffset(object, v.propsPos.x, v.propsPos.y, v.propsPos.z, 0, 0, 0)
        if v.onGround then 
            PlaceObjectOnGroundProperly(object)
        end
        SetEntityHeading(object, v.propsPos.w)
        FreezeEntityPosition(object, true)
        SetEntityAsMissionEntity(object, true, true)
        table.insert(PropsPoser, {object = object})
    end

    Citizen.CreateThread(function()
        while inRobbery do 
            Citizen.Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(PropsPoser) do 
                local dist = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - GetEntityCoords(v.object))

                local entityCoords = GetEntityCoords(v.object)
                local dist = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, entityCoords.x, entityCoords.y, entityCoords.z)

                if dist < 1.6 then 
                    DrawTopNotification("~INPUT_PICKUP~ to take the item.")
                    if IsControlJustPressed(0, 38) then 
                        PropsAll = PropsAll + 1
                        if PropsAll == #PropsPoser then 
                            inRobbery = false 
                            Tse("PREFIX_PLACEHOLDER:rh:LeaveHouse", id)
                            DeleteEntity(v.object)
                            DoScreenFadeOut(1000)
                            Citizen.Wait(1000)
                            TeleportPlayerCoords(vector3(ListRobberyActive[id].pos.x, ListRobberyActive[id].pos.y, ListRobberyActive[id].pos.z), PlayerPedId(), true)
                            DoScreenFadeIn(1000)
                            Tse("PREFIX_PLACEHOLDER:rh:HouseFinish", id)
                        end
                        if v.taked then 
                            DeleteEntity(v.object)
                        else
                            DeleteEntity(v.object)
                            ShowAboveRadarMessage("~r~ You found nothing in this box. Try again !")
                        end
                    end
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while inRobbery do 
            local timer = 1000
            local pCoords = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(ListRobberyActive[id].enterPos.x, ListRobberyActive[id].enterPos.y, ListRobberyActive[id].enterPos.z, pCoords.x, pCoords.y, pCoords.z)
            if dist < 10 then 
                timer = 1
                DrawMarker(0, ListRobberyActive[id].enterPos.x, ListRobberyActive[id].enterPos.y, ListRobberyActive[id].enterPos.z, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 1.2, 255, 0, 0, 150, 0, 0, 0, true)
            end

            if dist < 1.2 then 
                DrawTopNotification("~INPUT_PICKUP~ to leave the house.")
                if IsControlJustPressed(0, 51) then 
                    inRobbery = false 
                    for k, v in pairs(PropsPoser) do 
                        DeleteEntity(v.object)
                    end
                    Tse("PREFIX_PLACEHOLDER:rh:LeaveHouse", id)
                    DoScreenFadeOut(1000)
                    Citizen.Wait(1000)
                    TeleportPlayerCoords(vector3(ListRobberyActive[id].pos.x, ListRobberyActive[id].pos.y, ListRobberyActive[id].pos.z), PlayerPedId(), true)
                    DoScreenFadeIn(1000)
                end
            end
            Wait(timer)
        end
    end)
end

Citizen.CreateThread(function()
    while true do 
        local timer = 1000
        if ListRobberyActive ~= "{}" then 
            local pCoords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(ListRobberyActive) do 
                local dist = GetDistanceBetweenCoords(pCoords.x, pCoords.y, pCoords.z, v.pos.x, v.pos.y, v.pos.z)
                if dist < 10 then 
                    timer = 1 
                    if v.canAcces then 
                        DrawMarker(0, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 1.2, 0, 0, 255, 150, 0, 0, 0, true)
                    else
                        DrawMarker(0, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 1.2, 200, 0, 0, 150, 0, 0, 0, true)
                    end
                end
                if dist < 1.2 then 
                    DrawTopNotification("~INPUT_PICKUP~ to enter in the house.")
                    if IsControlJustPressed(0, 51) and v.canAcces then 
                        JoinHouse(v.id)
                    elseif IsControlJustPressed(0, 51) and v.canAcces == false then
                        ShowAboveRadarMessage("robberyhouse_canacces")
                    end
                end
            end
        end
        Wait(timer)
    end
end)


AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then 
        for k, v in pairs(PropsPoser) do 
            DeleteEntity(v.object)
            RemoveBlip(v.blip)
        end
    end
end)