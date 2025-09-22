--[[
    Modern Notification System
    Server-side script for triggering notifications
]]

-- Function to show a notification to a specific player
function ShowNotificationToPlayer(playerId, message, type, duration, sound)
    -- Default values
    type = type or "default"
    duration = duration or 5000
    sound = sound or "notification.ogg"
    
    -- Trigger client event
    TriggerClientEvent("ShowNotification", playerId, message, type, duration, sound)
end

-- Function to show a notification to all players
function ShowNotificationToAll(message, type, duration, sound)
    -- Default values
    type = type or "default"
    duration = duration or 5000
    sound = sound or "notification.ogg"
    
    -- Trigger client event for all players
    TriggerClientEvent("ShowNotification", -1, message, type, duration, sound)
end

-- Register command to send notification to specific player (admin only)
RegisterCommand("adminnotify", function(source, args, rawCommand)
    -- Check if the source is the server console or an admin player
    if source == 0 then -- Console
        local playerId = tonumber(args[1])
        if not playerId then return print("^1Error: Player ID required^0") end
        
        table.remove(args, 1)
        local message = table.concat(args, " ")
        if message == "" then return print("^1Error: Message required^0") end
        
        ShowNotificationToPlayer(playerId, message, "info", 5000, "notification.ogg")

    else
        -- Here you would add your admin check logic
        -- For example: if IsPlayerAdmin(source) then
        -- For demonstration, we'll just allow it
        local playerId = tonumber(args[1])
        if not playerId then return end
        
        table.remove(args, 1)
        local message = table.concat(args, " ")
        if message == "" then return end
        
        ShowNotificationToPlayer(playerId, message, "info", 5000, "notification.ogg")
    end
end, false)

-- Register command to send notification to all players (admin only)
RegisterCommand("notifyall", function(source, args, rawCommand)
    -- Check if the source is the server console or an admin player
    if source == 0 then -- Console
        local message = table.concat(args, " ")
        if message == "" then return print("^1Error: Message required^0") end
        
        ShowNotificationToAll(message, "info", 5000, "notification.ogg")

    else
        -- Here you would add your admin check logic
        -- For example: if IsPlayerAdmin(source) then
        -- For demonstration, we'll just allow it
        local message = table.concat(args, " ")
        if message == "" then return end
        
        ShowNotificationToAll(message, "info", 5000, "notification.ogg")
    end
end, false)

-- Export the functions so they can be called from other resources
exports('ShowNotificationToPlayer', ShowNotificationToPlayer)
exports('ShowNotificationToAll', ShowNotificationToAll)

-- Example usage:
--[[
    -- From server scripts:
    ShowNotificationToPlayer(1, "Welcome to the server!", "info", 5000, "notification.ogg")
    ShowNotificationToAll("Server will restart in 5 minutes!", "warning", 10000, "warning.ogg")
    
    -- From exported functions in other resources:
    exports["gamemode"]:ShowNotificationToPlayer(playerId, "Item received!", "success", 3000, "success.ogg")
    exports["gamemode"]:ShowNotificationToAll("Event starting in 2 minutes!", "info", 5000, "notification.ogg")
]]