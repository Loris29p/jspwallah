vehList = {}
vehIdAlreadySpawned = {}

Discord.Register("vehicle_log", "Vehicle Log", "logs-spawnveh")
Discord.Register("vehicle_stock", "Vehicle Stock", "logs-takevehicle")

RegisterCallback("vehicle:spawn", function(source, model, vehId)
    if GetPlayerPing(source) > 270 then 
        return false
    end
    if not vehList[vehId] then 
        return false 
    end
    return true
end)

_RegisterServerEvent("vehicle:setVehId", function(vehId, model)
    if not vehList[vehId] then return end
    
    local message = DiscordMessage(); 
    local returnMessage = ""
    if DiscordId(source) then 
        local PLAYER_DATA <const> = GetPlayerId(source)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..") | Discord ID: <@"..DiscordId(source)..">"
    else
        local PLAYER_DATA <const> = GetPlayerId(source)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..")"
    end
    message:AddField()
        :SetName("Username")
        :SetValue(returnMessage);
    message:AddField()
        :SetName("Spawn vehicle")
        :SetValue(model);
    message:AddField()
        :SetName("Vehicle ID")
        :SetValue(vehId);
    Discord.Send("vehicle_log", message);
    
    -- Réinitialiser l'état de création de véhicule
    local PLAYER = GetPlayerId(source)
    if PLAYER and PLAYER.vehicleSpawning then
        PLAYER.vehicleSpawning = false
        DoNotif(source, "Spawning ~b~"..model.."\n~s~ID: ~b~"..vehId)
    end
end)

-- TODO : Faire un fix avec le NetworkGetEntityOwner & NetworkGetEntityFromNetworkId
_RegisterServerEvent("vehicle:StockVeh", function(vehId, veh)
    local PLAYER = GetPlayerId(source)
    if vehList[vehId] == nil then 
        return
    end 

    if tonumber(vehList[vehId].id) == tonumber(vehId) then 
        exports["gamemode"]:AddItem(source, "inventory", vehList[vehId].model, 1, nil, true)
        _TriggerClientEvent("ShowAboveRadarMessage", source, "~b~You stored your vehicle.", 25)
        _TriggerClientEvent("updatedInv", source)
        
        -- Réinitialiser l'état de création de véhicule
        if PLAYER and PLAYER.vehicleSpawning then
            PLAYER.vehicleSpawning = false
        end

        
        -- Enregistrer le moment où le véhicule a été stocké
        -- PLAYER.lastVehicleStoreTime = os.time()
        
        local message = DiscordMessage(); 
        local returnMessage = ""
        if DiscordId(source) then 
            local PLAYER_DATA <const> = GetPlayerId(source)
            returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..") | Discord ID: <@"..DiscordId(source)..">"
        else
            local PLAYER_DATA <const> = GetPlayerId(source)
            returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..")"
        end
        message:AddField()
            :SetName("Username")
            :SetValue(returnMessage);
        message:AddField()
            :SetName("Take vehicle")
            :SetValue(vehList[vehId].model);
        Discord.Send("vehicle_stock", message);
        vehList[vehId] = nil
    end
end)
