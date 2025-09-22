ListGunrace = {}

function FoundPlayerInGunrace(source)
    for k, v in pairs(ListGunrace) do
        if v:GetPlayer(source) then
            return v
        end
    end
    return false
end

function RandomGunraceMap()
    local randomMap = Gunrace.maps[math.random(1, #Gunrace.maps)]
    return randomMap
end

AddEventHandler("playerDropped", function(reason)
    if FoundPlayerInGunrace(source) then
        FoundPlayerInGunrace(source):RemovePlayer({source = source})
    end
end)

_RegisterServerEvent("gunrace:GetData", function()
    _TriggerClientEvent("gunrace:sendingdata", source, "mass_update", ListGunrace)
end)

function GetGunrace(gunraceId)
    return ListGunrace[gunraceId]
end

function CreateGunrace(tblData)
    if type(tblData) ~= "table" then return end 
    local gunraceId = #ListGunrace + 1
    ListGunrace[gunraceId] = ClassGunrace:new({
        id = gunraceId,
        name = (tblData.name and tblData.name or "Gunrace #" .. gunraceId),
        map = (tblData.map and tblData.map or Gunrace.maps[1]),
    })
end

Citizen.CreateThread(function()
    Wait(500)
    CreateGunrace({
        name = "Gunrace #" .. #ListGunrace + 1,
        map = RandomGunraceMap(),
    })
end)

_RegisterServerEvent("gunrace:joinGunrace", function(gunraceId)
    local gunrace = GetGunrace(gunraceId)
    if not gunrace then return end
    if gunrace:GetPlayer(source) then return end
    gunrace:AddPlayer({
        source = source,
        uuid = GetPlayerId(source).uuid,
        username = GetPlayerId(source).username,
    })
end)

RegisterCommand("leave_gunrace", function(source, args, rawCommand)
    if not FoundPlayerInGunrace(source) then return end
    local gunrace = FoundPlayerInGunrace(source)
    if not gunrace then return end
    gunrace:RemovePlayer({
        source = source,
    })
end)

-- RegisterCommand("dev_add_kills", function(source, args, rawCommand)
--     local playerInGunrace = FoundPlayerInGunrace(source)
--     if not playerInGunrace then 
--         DoNotif(source, "~r~Vous n'êtes pas dans une gunrace!")
--         return 
--     end
    
--     local killsToAdd = tonumber(args[1]) or 1
    
--     for i = 1, killsToAdd do
--         playerInGunrace:AddKills({
--             source = source,
--         })
--     end
    
--     DoNotif(source, "~g~" .. killsToAdd .. " kills ajoutés!")
-- end, true) -- true pour commande admin/dev
