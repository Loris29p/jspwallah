function AddPedAccess(source, item) 
    local PLAYER <const> = GetPlayerId(source)
    if PLAYER then 
        local dataPlayer = PLAYER.GetData()
        if not dataPlayer["ped_access"] then 
            if item == "ped_access1week" then 
                PLAYER.AddNewData("ped_access", {access = true, time = os.time() + 60 * 60 * 24 * 7})
                DoNotif(source, "Ped access granted ~g~(" .. os.date("%d/%m/%Y %H:%M:%S", os.time() + 60 * 60 * 24 * 7) .. ")")
            elseif item == "ped_access1month" then 
                PLAYER.AddNewData("ped_access", {access = true, time = os.time() + 60 * 60 * 24 * 30})
                DoNotif(source, "Ped access granted ~g~(" .. os.date("%d/%m/%Y %H:%M:%S", os.time() + 60 * 60 * 24 * 30) .. ")")
            elseif item == "ped_access" then 
                PLAYER.AddNewData("ped_access", {access = true, time = os.time() + 60 * 60 * 24 * 30})
                DoNotif(source, "Ped access granted ~g~(" .. os.date("%d/%m/%Y %H:%M:%S", os.time() + 60 * 60 * 24 * 30) .. ")")
            end
            return true, "~g~Ped access granted"
        end
        return false, "~r~Ped access already granted"
    end
    return false, "~r~Player not found"
end

RegisterCommand("tebex_add_pedaccess", function(source, args, rawCommand)
    if source ~= 0 then return end
    
    -- Vérifier qu'il y a des arguments
    if not args[1] then
        print("ERROR: No JSON data provided")
        print("Usage: tebex_add_pedaccess '{\"uuid\": \"1\", \"packageName\": \"Ped Access 1 Month\"}'")
        return
    end
    
    local success, tblData_tebex = pcall(function() 
        return json.decode(args[1]) 
    end)

    if not success or not tblData_tebex then
        print("ERROR: Failed to parse JSON data:", args[1])
        print("Make sure to use valid JSON format with double quotes:")
        print("Example: tebex_add_pedaccess '{\"uuid\": \"1\", \"packageName\": \"Ped Access 1 Month\"}'")
        return
    end

    -- Vérifier que les données requises sont présentes
    if not tblData_tebex.uuid or not tblData_tebex.packageName then
        print("ERROR: Missing required fields 'uuid' or 'packageName' in JSON data")
        print("Received data:", json.encode(tblData_tebex))
        return
    end

    local time = 0
    if tonumber(tblData_tebex.uuid) then 
        if tblData_tebex.packageName == "Ped Access 1 Month" then 
            time = 60 * 60 * 24 * 30
        elseif tblData_tebex.packageName == "Ped Access 3 Months" then 
            time = 60 * 60 * 24 * 90
        else
            print("ERROR: Invalid package name. Valid options: 'Ped Access 1 Month' or 'Ped Access 3 Months'")
            print("Received packageName:", tblData_tebex.packageName)
            return
        end

        local result = MySQL.query.await("SELECT * FROM `players` WHERE `uuid` = @uuid", {["@uuid"] = tblData_tebex.uuid})
        if result[1] then
            if PlayersIsOnlineUUID(tonumber(tblData_tebex.uuid)) then
                if PlayersIsOnlineUUID(tonumber(tblData_tebex.uuid)).data.ped_access and PlayersIsOnlineUUID(tonumber(tblData_tebex.uuid)).data.ped_access.access then 
                    local currentExpiry = PlayersIsOnlineUUID(tonumber(tblData_tebex.uuid)).data.ped_access.time
                    local newExpiry = math.max(currentExpiry, os.time()) + time
                    PlayersIsOnlineUUID(tonumber(tblData_tebex.uuid)).data.ped_access.time = newExpiry
                    DoNotif(tonumber(tblData_tebex.uuid), "~g~Ped access extended (Expires: " .. os.date("%d/%m/%Y %H:%M:%S", newExpiry) .. ")")
                    print("SUCCESS: Ped access extended for online player " .. tblData_tebex.uuid .. " (new expiry: " .. os.date("%d/%m/%Y %H:%M:%S", newExpiry) .. ")")
                else
                    PlayersIsOnlineUUID(tonumber(tblData_tebex.uuid)).AddNewData("ped_access", {access = true, time = os.time() + time})
                    DoNotif(tonumber(tblData_tebex.uuid), "~g~Ped access granted (Expires: " .. os.date("%d/%m/%Y %H:%M:%S", os.time() + time) .. ")")
                    print("SUCCESS: Ped access granted to online player " .. tblData_tebex.uuid)
                end
            else
                local dataPlayer = json.decode(result[1].data)
                if not dataPlayer.ped_access then 
                    dataPlayer.ped_access = {access = true, time = os.time() + time}
                    MySQL.update("UPDATE `players` SET `data` = @data WHERE `uuid` = @uuid", {["@data"] = json.encode(dataPlayer), ["@uuid"] = tonumber(tblData_tebex.uuid)})
                    DoNotif(tonumber(tblData_tebex.uuid), "~g~Ped access granted (Expires: " .. os.date("%d/%m/%Y %H:%M:%S", os.time() + time) .. ")")
                    Logger:trace("TEBEX", "Ped access granted to offline player " .. tblData_tebex.uuid .. " (expires: " .. os.date("%d/%m/%Y %H:%M:%S", os.time() + time) .. ")")
                    print("SUCCESS: Ped access granted to offline player " .. tblData_tebex.uuid)
                else 
                    local currentExpiry = dataPlayer.ped_access.time
                    local newExpiry = math.max(currentExpiry, os.time()) + time
                    dataPlayer.ped_access.time = newExpiry
                    MySQL.update("UPDATE `players` SET `data` = @data WHERE `uuid` = @uuid", {["@data"] = json.encode(dataPlayer), ["@uuid"] = tonumber(tblData_tebex.uuid)})
                    DoNotif(tonumber(tblData_tebex.uuid), "~g~Ped access extended (Expires: " .. os.date("%d/%m/%Y %H:%M:%S", newExpiry) .. ")")
                    Logger:trace("TEBEX", "Ped access extended for offline player " .. tblData_tebex.uuid .. " (expires: " .. os.date("%d/%m/%Y %H:%M:%S", newExpiry) .. ")")
                    print("SUCCESS: Ped access extended for offline player " .. tblData_tebex.uuid .. " (new expiry: " .. os.date("%d/%m/%Y %H:%M:%S", newExpiry) .. ")")
                end
            end
        else
            print("ERROR: Player with UUID " .. tblData_tebex.uuid .. " not found in database")
        end
    else
        print("ERROR: Invalid UUID format - must be a number")
        print("Received UUID:", tblData_tebex.uuid)
    end
end, true)

_RegisterServerEvent("CheckPedAccess", function()
    CheckPedAccess(source)
end)

function CheckPedAccess(source)
    local PLAYER <const> = GetPlayerId(source)
    if PLAYER then 
        local dataPlayer = PLAYER.GetData()
        if dataPlayer["ped_access"] and dataPlayer["ped_access"].access then 
            if dataPlayer["ped_access"].time and dataPlayer["ped_access"].time > os.time() then 
                DoNotif(source, "Ped access granted ~g~(" .. os.date("%d/%m/%Y %H:%M:%S", dataPlayer["ped_access"].time) .. ")")
                return true
            else 
                PLAYER.RemoveData("ped_access")
                DoNotif(source, "~r~Ped access expired")
                PLAYER.skin.model = "mp_f_freemode_01"
                MySQL.update("UPDATE players SET skin = @skin WHERE uuid = @uuid", {["@skin"] = json.encode(PLAYER.skin), ["@uuid"] = PLAYER.uuid})
                _TriggerClientEvent('skin:SetSkin', source, PLAYER.skin)
                return false
            end
        end
    end
    return false
end



function AddPedAccesAll()
    local result = MySQL.query.await("SELECT * FROM players")
    for k, v in pairs(result) do
        print(json.encode(v.data))
        local data = json.decode(v.data)
        if not data.ped_access then
            data.ped_access = {access = true, time = os.time() + 60 * 60 * 24}
            MySQL.update("UPDATE players SET data = @data WHERE uuid = @uuid", {["@data"] = json.encode(data), ["@uuid"] = v.uuid})
            print(v.username, "^8PED ACCESS GRANTED", data.ped_access.time)
        else 
            print(v.username, "^2PED ACCESS ALREADY GRANTED", data.ped_access.time)
        end
    end
end

RegisterCommand("add_pedaccess_every", function(source, args)
    if source == 0 then
        AddPedAccesAll()
    end
end)

RegisterCommand("check_pedaccess", function(source, args)
    local src = source
    CheckPedAccess(src)
end)

RegisterCommand("reset_all_data", function(source, args)
    local src = source
    if source == 0 then 
      local players = MySQL.query.await("SELECT * FROM players")
      for k, v in pairs(players) do 
        v.data = {}  
        MySQL.update("UPDATE players SET data = @data WHERE uuid = @uuid", {["@data"] = json.encode(v.data), ["@uuid"] = v.uuid})
        print(v.username, "DATA RESET")
      end
    end
end, true)


_RegisterServerEvent("guildpvpustom:PedAccess", function(item)
    local success, message = AddPedAccess(source, item)
    if success then 
        print("PED ACCESS GRANTED")
    end
end)

_RegisterServerEvent('pedaccess:PutModel', function(model)
    local PLAYER <const> = GetPlayerId(source)
    if PLAYER then
        local hasPedAccess = PLAYER.data.ped_access and PLAYER.data.ped_access.access == true
        print(hasPedAccess, "hasPedAccess")
        print(PLAYER.data.ped_access, "PLAYER.data.ped_access")
        print(PLAYER.data.ped_access.access, "PLAYER.data.ped_access.access")
        print(json.encode(PLAYER.data), "PLAYER.data")
        local hasVipRole = PLAYER.role == "vip" or PLAYER.role == "vip+" or PLAYER.role == "mvp" or PLAYER.role == "boss"
        print(hasVipRole, "hasVipRole")

        if not hasVipRole and not hasPedAccess then
            return DoNotif(source, "~r~You don't have access to this model")
        end
        PLAYER.skin.model = model
        MySQL.update("UPDATE players SET skin = @skin WHERE uuid = @uuid", {["@skin"] = json.encode(PLAYER.skin), ["@uuid"] = PLAYER.uuid})
        -- DoNotif(source, "~g~Ped set to " .. model)
    end
end)