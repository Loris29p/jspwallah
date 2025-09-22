DarkzonePlayers = {}

_RegisterNetEvent("darkzone:GetData", function()
    _TriggerClientEvent("darkzone:update", source, DarkzonePlayers)
end)

function AddDarkzonePlayer(source)
    for k, v in pairs(DarkzonePlayers) do 
        if v.source == source then 
            return 
        end
    end
    table.insert(DarkzonePlayers, {
        source = source,
        uuid = GetPlayerId(source).uuid,
    })
    _TriggerClientEvent("darkzone:update", -1, DarkzonePlayers)
end

function InDarkZone(source)
    for k, v in pairs(DarkzonePlayers) do 
        if v.source == source then 
            return true
        end
    end
    return false
end

function RemoveDarkzonePlayer(source)
    for k, v in pairs(DarkzonePlayers) do 
        if v.source == source then 
            table.remove(DarkzonePlayers, k)
            _TriggerClientEvent("darkzone:update", -1, DarkzonePlayers)
            return true
        end
    end
    return false
end

_RegisterServerEvent('darkzone:instance', function(type)
    if type == "join" then 
        SetPlayerRoutingBucket(source, 600)
        AddDarkzonePlayer(source)
    elseif type == "leave" then 
        SetPlayerRoutingBucket(source, 0)
        RemoveDarkzonePlayer(source)
    end
end)

AddEventHandler('playerDropped', function()
    if InDarkZone(source) then 
        RemoveDarkzonePlayer(source)
        local inventory = exports["gamemode"]:GetInventory(source, "inventory")
        if inventory then 
            exports["gamemode"]:ClearInventory(source, "inventory")
        end
    end
end)