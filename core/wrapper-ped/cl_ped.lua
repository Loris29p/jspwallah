ListPedAction = {}
WrapperPedInit = false


Citizen.CreateThread(function()
    WrapperPedInit = true
end)

function GetAllPedAction()
    return ListPedAction
end

function CheckIfPedActionExist(ped)
    return ListPedAction[ped] and true or false
end

local function GetLineCountAndMaxLenght(text)
    local count = 0
    local maxLenght = 0
    for line in text:gmatch("([^\n]*)\n?") do
        count = count + 1
        local lenght = string.len(line)
        if lenght > maxLenght then maxLenght = lenght end
    end
    return count, maxLenght
end

local function DrawText3D(data)
    SetTextScale(0.40, 0.40)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
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


function CreatePedAction(tblData)
    if type(tblData) ~= "table" then return end
    local ped = nil
    if tblData then 
        if tblData.pedType then 
            RequestModel(tblData.model)
            while not HasModelLoaded(tblData.model) do
                Wait(5)
            end

            ped = CreatePed(tblData.pedType or 4, tblData.model, vec3(tblData.pos.x, tblData.pos.y, tblData.pos.z - 1.0), tblData.pos.w, false, false)
            SetEntityAsMissionEntity(ped, true, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedHearingRange(ped, 0.0)
            SetPedSeeingRange(ped, 0.0)
            SetEntityInvincible(ped, true)
            if tblData.invisible then
                SetEntityVisible(ped, false, false)
            end
            SetPedAlertness(ped, 0.0)
            FreezeEntityPosition(ped, true) 
            SetPedCombatAttributes(ped, 46, true)
            SetPedFleeAttributes(ped, 0, 0)
            SetModelAsNoLongerNeeded(tblData.model)
            SetEntityCollision(ped, false, false)

            if tblData.animDict and tblData.animName then
                RequestAnimDict(tblData.animDict)
                while not HasAnimDictLoaded(tblData.animDict) do
                    Citizen.Wait(0)
                end

                TaskPlayAnim(ped, tblData.animDict, tblData.animName, 8.0, 8.0, -1, 1, 0, false, false, false) 
            end

            if tblData.weapon then
                local weapon = GetHashKey(tblData.weapon)
                GiveWeaponToPed(ped, weapon, 999, false, true)

                SetCurrentPedWeapon(ped, weapon, true)
            end
            
            if tblData.drawText then 
                Citizen.CreateThread(function()
                    while DoesEntityExist(ped) do 
                        local timer = 1000 
                        local near = false 
                        local player = PlayerPedId()
                        local playerPos = GetEntityCoords(player)
                        local pedPos = tblData.pos
                        local distance = #(vector2(playerPos.x, playerPos.y) - vector2(pedPos.x, pedPos.y))
                        if distance < tblData.distanceLimit + 30.0  and tblData.marker then 
                            DrawMarker(tblData.marker.type, pedPos.x, pedPos.y, pedPos.z + 1.0, 0, 0, 0, 0, 0, 0, tblData.marker.size.x, tblData.marker.size.y, tblData.marker.size.z, tblData.marker.color.r, tblData.marker.color.g, tblData.marker.color.b, tblData.marker.color.a, 0, 0, 0, true)
                        end
                        if distance < tblData.distanceShowText then 
                            
                            local displayText = tblData.drawText
                            if type(displayText) == "function" then
                                displayText = displayText()
                            end
                            
                            DrawText3D({
                                text = displayText,
                                coords = tblData.pos + vector4(0.0, 0.0, (tblData.drawTextOffset and tblData.drawTextOffset or 1.13), 0.0),
                            })
                            near = true 
                            timer = 1 
                            if distance < tblData.distanceLimit then 
                                HelpNotification("Press ~INPUT_CONTEXT~ to open "..displayText, true)
                                if IsControlJustPressed(0, 38) and tblData.action then 
                                    tblData.action()
                                end
                            end
                        else 
                            near = false 
                            timer = 1000 
                        end
                        Citizen.Wait(timer)
                    end
                end)
            end

            ListPedAction[ped] = tblData
            return ped
        end
    end
end

function ChangeDrawText(ped, text)
    if not ListPedAction[ped] then return end
    ListPedAction[ped].drawText = text
end

function DestroyPedAction(ped)
    if not ListPedAction[ped] then return end
    DeletePed(ped)
    ListPedAction[ped] = nil
end