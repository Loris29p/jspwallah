ListBox = {}
BoxData = {}

_RegisterNetEvent("event-manager:createBox", function(type, boxData)

    if type == "init" then 
        BoxData = boxData
        InitBoxModule(boxData)
        exports["kUI"]:NewNotification("🎁 GIFT BOX | YOU HAVE 2 MINUTES TO FIND THEM", 8000)
    elseif type == "delete" then 
        exports["kUI"]:NewNotification("🎁 GIFT BOX | FINISHED", 8000)
    end

end)

_RegisterNetEvent("event-manager:deleteBox", function(id)
    BoxData[id] = nil
    DeleteObject(ListBox[id].object)
    ListBox[id] = nil
end)

local function DrawText3D(data)
    SetTextScale(0.50, 0.50)
    SetTextFont(2)
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

function InitBoxModule(boxData)
    CreateBox(boxData)
    Wait(1000)
    Citizen.CreateThread(function()
        while ListBox do 
            for k, v in pairs(ListBox) do 

                local time = 1000
                local boxCoords = v.coords
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = GetDistanceBetweenCoords(boxCoords.x, boxCoords.y, boxCoords.z, playerCoords.x, playerCoords.y, playerCoords.z, true) -- TODO : Sois mettre dans eau ou dans bas.

                if distance < 30.0 then 
                    time = 0
                    if distance < 10.0 then 
                        if not GM.Player.InFarm and not GM.Player.Afk and not GM.Player.InLeague and not GM.Player.MilitaryZone then
                            DrawText3D({
                                coords = vec3(boxCoords.x, boxCoords.y, boxCoords.z + 1.0),
                                text = "~HUD_COLOUR_NET_PLAYER3~GIFT BOX ~s~- ~HUD_COLOUR_NET_PLAYER3~" .. v.id .. "~s~",
                            })
                            if distance < 1.5 then 
                                DrawTopNotification("Press ~INPUT_PICKUP~ to open the box.")
                                if IsControlJustPressed(0, 38) then 
                                    Tse("event-manager:TakeBox", v.id)
                                end
                            end
                        else 
                            DrawText3D({
                                coords = vec3(boxCoords.x, boxCoords.y, boxCoords.z + 1.0),
                                text = "~HUD_COLOUR_RED~GO IN PVP OR LEAVE YOUR GAMEMODE",
                            })
                        end
                    end
                end

            end
            Wait(time)
        end
    end)
end

function CreateBox(boxData)
    if boxData then 
        EventManagerGlobalTitle = "~r~Event Manager - ~r~ GIFT BOX"
    end
    for k, v in pairs(boxData) do 
        local entityBox = CreateObject(GetHashKey(v.model), v.coords.x, v.coords.y, v.coords.z  - 1.0, false, false, false)
        SetEntityInvincible(entityBox, true)
        SetEntityVisible(entityBox, true)
        PlaceObjectOnGroundProperly(entityBox)
        SetEntityCollision(entityBox, false, false)
        SetEntityLodDist(entityBox, 9999)
        local blip = AddBlipForEntity(entityBox)
        SetBlipSprite(blip, 161)
        SetBlipColour(blip, 48)
        SetBlipScale(blip, 1.6)
        SetBlipAlpha(blip, 120)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("~HUD_COLOUR_NET_PLAYER3~BOX GIFT - ~s~" .. v.id)
        EndTextCommandSetBlipName(blip)
        ListBox[v.id] = {
            object = entityBox,
            id = v.id, 
            coords = v.coords,
        }
        print("BOX CREATED " .. v.id)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then 
        for k, v in pairs(ListBox) do 
            DeleteObject(v.object)
        end
    end
end)