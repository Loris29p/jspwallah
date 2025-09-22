SetConvarReplicated("guild_d9wsdfg86468jfsd6tf428DF4DW", os.time())

_AddEventHandler('guild:kickProtectTr', function(args, second_arg)
    local _src = source

    DropPlayer(_src, "Non authorized")
end)

function GetTime()
    local date = os.date('*t')
    if date.day < 10 then date.day = '0' .. tostring(date.day) end
    if date.month < 10 then date.month = '0' .. tostring(date.month) end
    if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
    if date.min < 10 then date.min = '0' .. tostring(date.min) end
    if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end
    local date = date.day .. "/" .. date.month .. "/" .. date.year .. " - " .. date.hour .. "h " .. date.min .. "m " .. date.sec .. "sec "
    return date
end

function writeLog(source, webhook, screenshot, title, message, ...)
    if (source == nil) then return end

    if (webhook == nil) then return end

    if (title == nil) then return end

    if (message == nil) then return end

    if (screenshot == nil) then return end

    local currentVersion = "v1"
    if not currentVersion then return end

    webrequest = webhook

    if (not string.find(webhook, "https://discord.com/api/")) then
        webrequest = webhook
        if webhook == nil or webhook == "" then return print("the webhook %s ^1dont^0 have a config value"..webhook) end
    end

    if source == 0 then
        description = (message):format(...)
    else
        description = (message):format(...).."\r\n\n"
    end

    if (screenshot == false) then
        PerformHttpRequest(webrequest, function(err, text, headers) end, 'POST', json.encode({
            username = "Guild Logs" ,
            embeds = {{
                ["color"] = 5763719,
                ["author"] = {
                    ["name"] = "",
                    ["icon_url"] = ""
                },
                ["title"] = title,
                ["description"] = description,
                ["footer"] = {
                    ["text"] =  "Guild - "..GetTime(),
                    ["icon_url"] = "",
                },
            }},
            avatar_url = "https://cdn.discordapp.com/attachments/1281709254184800348/1293315730019848274/guild_logo.png?ex=6706eda2&is=67059c22&hm=78f851afb86135ea8e9e2bab4b682777bf5e90240fca3ef5324a33a41d6c74ff&"
        }), {
            ['Content-Type'] = 'application/json'
        })
    end
end

exports("writeLog", writeLog)

-- _RegisterServerEvent("enter_safe")
-- _AddEventHandler("enter_safe", function(data)
--     if data then
--         if data.vehicleNetId then
--             print("vehicleNetId", data.vehicleNetId)
--             local vehicle = NetworkGetEntityFromNetworkId(data.vehicleNetId)
--             if DoesEntityExist(vehicle) then
--                 print("vehicle exist", vehicle)
--                 SetEntityRoutingBucket(vehicle, tonumber(data.buck))
--                 TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, (data.seat or -1))
--             else
--                 print("Vehicle does not exist on the server.")
--             end
--         end
        
--         print("set bucket", tonumber(data.buck))
--         SetEntityRoutingBucket(GetPlayerPed(source), tonumber(data.buck))
        
--     end
-- end)

--------------------------------------
------Created By Whit3Xlightning------
--https://github.com/Whit3XLightning--
--------------------------------------

-- RegisterCommand("dvall", function(source, args, rawCommand, user)
--     if GetPlayerId(source).group == "user" then return end
--     _TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Delete All Vehicles", "Delete vehicles in 30 seconds", 30000)
--     Wait(15000)
--     _TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Delete All Vehicles", "Delete vehicles in 15 seconds", 3000)
--     Wait(15000) 
--     _TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Delete All Vehicles", "Delete vehicles completed !", 5000)
--     Wait(1)
--     _TriggerClientEvent("wld:delallveh", -1) 
-- end, false)
    
    
local delay = 1000 * 60 * 30 -- just edit this to your needed delay (30 minutes in this example)
Citizen.CreateThread(function()
    for i = 1, 2 do 
        Citizen.Wait(delay)
        _TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Delete All Vehicles", "Delete vehicles in 30 seconds", 30000)
        Wait(15000)
        _TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Delete All Vehicles", "Delete vehicles in 15 seconds", 3000)
        Wait(15000) 
        _TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Delete All Vehicles", "Delete vehicles completed !", 5000)
        Wait(1)
        _TriggerClientEvent("wld:delallvehauto", -1)
    end
end)

local DeluxoTricks = {
    -- ["Highway"] = {
    --     pos = vector4(754.9131, -1196.499, 45.01652, 5.672297),
    --     name = "Highway",
    --     radius = 150.0
    -- },
    -- ["Square"] = {
    --     pos = vector4(336.2416, -1641.544, 98.49354, 333.5577),
    --     name = "Square",
    --     radius = 150.0
    -- },
    -- ["Maze Bank"] = {
    --     pos = vector4(-75.25626, -813.435, 326.1716, 166.5162),
    --     name = "Maze Bank",
    --     radius = 150.0,
    --     highdetect = true,
    -- },
    -- ["Mirror Park"] = {
    --     pos = vector4(1078.201, -690.668, 57.62122, 260.6537),
    --     name = "Mirror Park",
    --     radius = 150.0,
    --     highdetect = true,
    -- },
}

local CurrentDeluxoTricks = nil

function ChangeDeluxoTricks()
    -- Collect all keys into a table
    local keys = {}
    for k in pairs(DeluxoTricks) do
        table.insert(keys, k)
    end
    
    -- Get a random key
    local randomKey = keys[math.random(1, #keys)]
    local randomMap = DeluxoTricks[randomKey]
    
    CurrentDeluxoTricks = randomMap
    print("changeDeluxoTricks", randomMap.name, randomMap.pos)
    _TriggerClientEvent("changeDeluxoTricks", -1, randomMap)
    _TriggerClientEvent('ShowAboveRadarMessage', -1, "The solo tricks zone has been changed to ~r~" .. randomMap.name)
    return randomMap
end

-- Citizen.CreateThread(function()
--     while true do 
--         Citizen.Wait(2000) -- Initial delay
--         ChangeDeluxoTricks()
--         Citizen.Wait(900000)
--     end
-- end)

_RegisterServerEvent("getDeluxoTricks", function()
    local src = source
    _TriggerClientEvent("changeDeluxoTricks", src, CurrentDeluxoTricks)
end)

_RegisterServerEvent("safezone:action", function(action)
    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if action == "join" then
        SetPlayerRoutingBucket(source, 5626)
        if vehicle and vehicle ~= 0 then
            SetEntityRoutingBucket(vehicle, 5626)
        end
    elseif action == "leave" then
        SetPlayerRoutingBucket(source, 0)
        if vehicle and vehicle ~= 0 then
            SetEntityRoutingBucket(vehicle, 0)
        end
    end
end)

local explosionCount = 0

AddEventHandler('explosionEvent', function(sender, ev)
    explosionCount = explosionCount + 1
    
    -- CancelEvent()
    
    if sender and sender ~= "" then
        local playerName = GetPlayerName(sender)
        local playerIdentifier = GetPlayerIdentifier(sender, 0)
        
        _TriggerClientEvent('ShowAboveRadarMessage', sender, "~r~Canceled explosion (" .. ev.explosionType .. ")")
    end
end)