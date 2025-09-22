ListBans = {}
ListWarns = {}
ListReports = {}


Discord.Register("report_log", "Report Log", "logs-report");
Discord.Register("warn_log", "Warn Log", "logs-warn");
Discord.Register("ban_log", "Ban Log", "logs-ban");
Discord.Register("kick_log", "Kick Log", "logs-kick");
Discord.Register("unban_log", "Unban Log", "logs-unban");
Discord.Register("already_banned", "Already Banned", "logs-already-banned");
Discord.Register('logs_noclip', 'Noclip Log', 'logs-noclip');


_RegisterServerEvent('logs', function(messagelogs)
    local src = source 
    local PLAYER = GetPlayerId(src) 
    local message = DiscordMessage(); 
    local returnMessage = ""
    if DiscordId(src) then  
        returnMessage = GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..") | Discord ID: <@"..DiscordId(src)..">"
    else
        returnMessage = GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..")"
    end
    message:AddField()
        :SetName("Username")
        :SetValue(returnMessage);
    message:AddField()
        :SetName("Reason")
        :SetValue("`"..messagelogs.."` @here");
    Discord.Send("logs_noclip", message);
end)

_RegisterServerEvent("admin:getPing", function(target)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then return end
    local PLAYER_TARGET = GetPlayerId(tonumber(target))
    if not PLAYER_TARGET then return end
    local ping = GetPlayerPing(tonumber(target))
    _TriggerClientEvent("ShowAboveRadarMessage", src, "~b~"..PLAYER_TARGET.username.."~s~\nPing: ~g~"..ping)
end)

_RegisterServerEvent("admin:getStats", function(target)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then return end
    local PLAYER_TARGET = GetPlayerId(tonumber(target))
    if not PLAYER_TARGET then return end
    local playerKills = (PLAYER_TARGET.kills_global) or 0
    local playerDeath = (PLAYER_TARGET.death_global) or 0
    if playerKills == 0 and playerDeath == 0 then 
        playerKd = 1.0
    else
        playerKd = (math.floor((tonumber(playerKills / playerDeath) * 10^2) + 0.5) / (10^2)) or 1.0
    end
    _TriggerClientEvent("ShowAboveRadarMessage", src, "Kills: ~g~"..playerKills.."~s~ Deaths: ~g~"..playerDeath.."~s~ K/D: ~g~"..playerKd)
end)

_RegisterServerEvent("admin:FreezePlayer", function(target)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then return end
    _TriggerClientEvent("FreezePlayer", target)
end)

_RegisterServerEvent("admin:recordPlayer", function(target)
    local PLAYER = GetPlayerId(source)
    if PLAYER.group == "user" then return end
    exports["guild-data"]:recordPlayerScreen(tonumber(target), 9000, function(url, err)
        if err then
            return print("failed to take video: "..err)
        end
        print("recorded video: "..url)
    end, "https://discord.com/api/webhooks/1375410572484411465/Np6y9zyWO-zKMufCW0gqZpgcz0fuaAQDLy00AEQS-zRefW6jmUyuR4RtdhUwHPSGrwgn")
end)

RegisterCommand("record", function(source, args, rawCommand)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then return end
    exports["guild-data"]:recordPlayerScreen(args[1], 9000, function(url, err)
        if err then
            return print("failed to take video: "..err)
        end
        print("recorded video: "..url)
    end, "https://discord.com/api/webhooks/1375410572484411465/Np6y9zyWO-zKMufCW0gqZpgcz0fuaAQDLy00AEQS-zRefW6jmUyuR4RtdhUwHPSGrwgn")
end)


_RegisterServerEvent("admin:screenshot", function(target)
    local PLAYER = GetPlayerId(source)
    if PLAYER.group == "user" then return end
    exports["guild-data"]:screenshotPlayer(tonumber(target), function(url, err)
        if err then
            return print("failed to take screenshot: "..err)
        end
        print("screenshot: "..url)
    end, "https://discord.com/api/webhooks/1375410761068712016/tV-37NxVPPwvgqGQR9HZ1a0DK99oSHcELrep4Y_Hx0RFz73wMhB7AoF0Jvh-zYXLw9-K")
end)
    

RegisterCommand('screenshot', function(source, args, rawCommand)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then return end
    exports["guild-data"]:screenshotPlayer(tonumber(args[1]), function(url, err)
        if err then
            return print("failed to take screenshot: "..err)
        end
        print("screenshot: "..url)
    end, "https://discord.com/api/webhooks/1375410761068712016/tV-37NxVPPwvgqGQR9HZ1a0DK99oSHcELrep4Y_Hx0RFz73wMhB7AoF0Jvh-zYXLw9-K")
end)

function ListAllReports()
    return ListReports
end

function GetReportPlayer(uuid)
    return ListReports[uuid] 
end


function StaffChatSend(src, message)
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then return end
    for k, v in pairs(Players) do 
        if v.group ~= "user" then 
            _TriggerClientEvent('chat:addMessage', v.source, { args = { "^8SC: ^*"..PLAYER.username, "^*"..message }, color = 200, 0, 0 })
        end
    end
end

RegisterCommand('sc', function(source, args)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then return end
    local message = table.concat({table.unpack(args, 1)}, " ")
    StaffChatSend(src, message)
end)


function AddReportPlayer(src, uuid, data)
    if type(data) ~= "table" then return end 
    if ListReports[uuid] then return DoNotif(src, "You have a report in progress.") end
    if not GetPlayerId(src) then return end
    ListReports[uuid] = {
        uuid = uuid,
        source = src,
        message = (data.message and data.message or "No reason provided"),
        author = GetPlayerId(src).username,
        date = os.date("%Y-%m-%d %H:%M:%S"),
        taken = false,
        takenBy = nil
    }

    for k, v in pairs(Players) do 
        if v.group ~= "user" and v.source ~= nil then 
            if GetPlayerId(v.source) then
                DoNotif(v.source, "A new report has been created by "..GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..")")
            end
        end
    end

    local message = DiscordMessage(); 
    local returnMessage = ""
    if DiscordId(src) then  
        returnMessage = GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..") | Discord ID: <@"..DiscordId(src)..">"
    else
        returnMessage = GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..")"
    end
    message:AddField()
        :SetName("Username")
        :SetValue(returnMessage);
    message:AddField()
        :SetName("Reason")
        :SetValue("`"..data.message.."`");
    message:AddField()
        :SetName("License")
        :SetValue(GetPlayerId(src).license);
    Discord.Send("report_log", message);
end

function TakeReportPlayer(uuid, takenBy)
    ListReports[uuid].taken = true
    ListReports[uuid].takenBy = takenBy
end

_RegisterServerEvent("admin:TeleportToPlayerReport", function(uuidReport)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then 
        return
    end
    local report = GetReportPlayer(uuidReport)
    if report then 
        local target = report.source
        local PLAYER_TARGET = GetPlayerId(tonumber(target))
        if PLAYER_TARGET then 
            SetEntityCoords(GetPlayerPed(src), GetEntityCoords(GetPlayerPed(tonumber(target))))
            DoNotif(src, "You have been teleported to the player: "..PLAYER_TARGET.username)
        end
    end
end)

_RegisterServerEvent("admin:TakeReport", function(uuid)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then 
        return
    end
    DoNotif(ListReports[uuid].source, "~g~Your report has been taken by a staff member.")
    DoNotif(src, "You have taken the report of the player: "..GetPlayerId(ListReports[uuid].source).username)
    TakeReportPlayer(uuid, PLAYER.uuid)
end)

_RegisterServerEvent("admin:CloseReport", function(uuid)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then 
        return
    end
    RemoveReportPlayer(uuid)
end)

function RemoveReportPlayer(uuid)
    DoNotif(ListReports[uuid].source, "~g~Your report has been closed.")
    ListReports[uuid] = nil
end

RegisterCommand("report", function(source, ars)
    local src = source
    local PLAYER = GetPlayerId(src)
    local message = table.concat({table.unpack(ars, 1)}, " ")
    if not message then 
        return DoNotif(src, "Usage: /report [reason]")
    end
    AddReportPlayer(src, PLAYER.uuid, {message = message})
    DoNotif(src, "You have reported for the reason: "..message)
end)

RegisterCallback("admin:GetReports", function(source)
    local PLAYER = GetPlayerId(source)
    if PLAYER.group ~= "user" then 
        return ListReports
    end
end)

function GetReportStatus(uuid)
    local report = ListReports[uuid]
    if not report or not report.date then
        return "❌" -- Retourne une erreur si le rapport ou la date est introuvable
    end

    -- Convertir la date du rapport en timestamp
    local year, month, day, hour, min, sec = string.match(report.date, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if not year then
        return "❌" -- Retourne une erreur si le format de la date est incorrect
    end

    local reportTimestamp = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    })

    -- Obtenir le timestamp actuel
    local currentTimestamp = os.time()

    -- Calculer la différence en secondes
    local timeDifference = currentTimestamp - reportTimestamp

    -- Comparer la différence et retourner l'indicateur approprié
    if timeDifference <= 600 then -- Moins de 10 minutes
        return "🔵"
    elseif timeDifference > 600 and timeDifference <= 1200 then -- Entre 11 et 20 minutes
        return "🟡"
    else -- Plus de 21 minutes
        return "🟠"
    end
end

RegisterCallback("admin:GetStatusReport",  function(source, uuid)
    local PLAYER = GetPlayerId(source)
    if PLAYER.group ~= "user" then 
        local statusReport = GetReportStatus(uuid)
        return statusReport
    end
end)

RegisterCallback("admin:GetReportInfo",  function(source, uuid)
    local PLAYER = GetPlayerId(source)
    if PLAYER.group ~= "user" then 
        local statusReport = GetReportStatus(uuid)
        return ListReports[uuid], statusReport
    end
end)

AddEventHandler("playerDropped", function(reason)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER then 
        if ListReports[PLAYER.uuid] then 
            ListReports[PLAYER.uuid] = nil
        end
    end
end)

function LoadAllWarns()
    ListWarns = {}

    MySQL.Async.fetchAll("SELECT * FROM warns", {}, function(result)
        if result[1] then 
            for k, v in pairs(result) do 
                table.insert(ListWarns, {
                    identifier = v.identifier,
                    reason = v.reason,
                    date = v.date,
                    author = v.author
                })
            end
            Logger:trace("WARNS", "All warns has been loaded.")
        end
    end)
end

_AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then 
        LoadAllWarns()
    end
end)


_RegisterServerEvent("admin:openMenu", function()
    local PLAYER = GetPlayerId(source)
    if PLAYER.group ~= "user" then 
        _TriggerClientEvent("admin:openMenu", source, Players)
    else
    end
end)


_RegisterServerEvent("admin:sendMessage", function(target, message)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group ~= "user" then 
        _TriggerClientEvent("ShowAboveRadarMessage", target, "~HUD_COLOUR_RADAR_DAMAGE~Moderator:~s~ "..message)
    else
    end
end)

_RegisterServerEvent("admin:GoToPlayer", function(target)
    local src = source 
    local PLAYER = GetPlayerId(src)
    local PLAYER_SELEC = GetPlayerId(tonumber(target))

    if PLAYER.group ~= "user" then 
        local BucketPlayer = GetPlayerRoutingBucket(tonumber(target))
        if BucketPlayer ~= 0 then 
            SetPlayerRoutingBucket(src, BucketPlayer)
        end
        SetEntityCoords(GetPlayerPed(src), GetEntityCoords(GetPlayerPed(tonumber(target))))
        PLAYER.sendTrigger("ShowAboveRadarMessage", "~HUD_COLOUR_NET_PLAYER7~ You have been teleported to ~HUD_COLOUR_NET_PLAYER8~"..PLAYER_SELEC.username)
    else
    end
end)

_RegisterServerEvent("admin:BringPlayer", function(target)
    local src = source 
    local PLAYER = GetPlayerId(src)
    local PLAYER_SELEC = GetPlayerId(tonumber(target))

    if PLAYER.group ~= "user" then 
        local BucketPlayer = GetPlayerRoutingBucket(src)
        if BucketPlayer ~= 0 then 
            SetPlayerRoutingBucket(tonumber(target), BucketPlayer)
        end
        SetEntityCoords(GetPlayerPed(tonumber(target)), GetEntityCoords(GetPlayerPed(src)))
        PLAYER.sendTrigger("ShowAboveRadarMessage", PLAYER_SELEC.username.." ~HUD_COLOUR_NET_PLAYER7~have been teleport to you.")
    else
    end
end)


function AddWarn(src, target, reason)

    MySQL.Async.execute("INSERT INTO warns (identifier, reason, date, author) VALUES (@identifier, @reason, @date, @author)", {
        ["@identifier"] = GetPlayerId(tonumber(target)).license,
        ["@reason"] = reason,
        ["@date"] = os.date("%Y-%m-%d %H:%M:%S"),
        ["@author"] = GetPlayerId(tonumber(src)).username
    }, function(rowsChanged)
        if rowsChanged > 0 then 
            _TriggerClientEvent("ShowAboveRadarMessage", src, "~HUD_COLOUR_NET_PLAYER7~You have warned ~HUD_COLOUR_NET_PLAYER8~"..GetPlayerId(tonumber(target)).username)
            local message = DiscordMessage(); 
            local returnMessage = ""
            if DiscordId(src) then 
                returnMessage = GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..") | Discord ID: <@"..DiscordId(src)..">"
            else
                returnMessage = GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..")"
            end
            message:AddField()
                :SetName("Staff")
                :SetValue(returnMessage);
            message:AddField()
                :SetName("Username")
                :SetValue(GetPlayerId(tonumber(target)).username.." ("..GetPlayerId(tonumber(target)).uuid..")");
            message:AddField()
                :SetName("Reason")
                :SetValue("`"..reason.."`");
            Discord.Send("warn_log", message);
            LoadAllWarns()
        end
    end)
end

RegisterCallback("admin:GetWarnsUUID", function(source, uuid)
    local searchData = SearchUuidInDatabase(uuid)
    if searchData then 
        local returnValue = {}
        for k, v in pairs(ListWarns) do 
            if v.identifier == searchData.license then 
                -- Convert the timestamp to a formatted strin
                table.insert(returnValue, {
                    reason = v.reason,
                    date = v.date,
                    author = v.author,
                    identifier = v.identifier
                })
            end
        end
        return returnValue
    else
        return false
    end
end)

RegisterCallback("admin:GetBansHistoryUUID", function(source, uuid)
    local searchData = SearchUuidInDatabase(uuid)
    if searchData then 
        local banHistory = MySQL.Sync.fetchAll("SELECT * FROM `bans-history` WHERE license = @license", {
            ["@license"] = searchData.license
        })
        local returnValue = {}
        for k, v in pairs(banHistory) do 
            table.insert(returnValue, {
                reason = v.reasons,
                date = v.date,
                author = v.author,
                expiration = v.expiration,
                banId = v.banId
            })
        end
        return returnValue
    end
end)

RegisterCallback("admin:GetWarns", function(source, target)
    local PLAYER = GetPlayerId(source)

    local returnValue = {}
    -- LoadAllWarns()
    -- Wait(200)

    for k, v in pairs(ListWarns) do 
        if v.identifier == GetPlayerId(tonumber(target)).license then 
            -- Convert the timestamp to a formatted strin
            table.insert(returnValue, {
                reason = v.reason,
                date = v.date,
                author = v.author,
                identifier = v.identifier
            })
        end
    end
    return returnValue
end)

RegisterCallback("admin:searchPlayer", function(source, uuid)
    local PLAYER = GetPlayerId(source)
    local searchData = SearchUuidInDatabase(uuid)
    local tags = GetAllTagPlayerWithUUID(uuid)
    if searchData then 
        if tags then 
            searchData.tags = tags
        end
        return searchData
    else
        return false
    end
end)

_RegisterServerEvent('admin:WarnPlayer', function(target, reason)
    local src = source 
    local PLAYER = GetPlayerId(src)
    local PLAYER_SELEC = GetPlayerId(tonumber(target))

    if PLAYER.group ~= "user" then 
        AddWarn(src, target, reason)

        if not reason then
            reason = "No reason provided"
        end

    else
    end
end)

_RegisterServerEvent('admin:kickPlayer', function(target, reason)
    local src = source 
    local PLAYER = GetPlayerId(src)
    local PLAYER_SELEC = GetPlayerId(tonumber(target))

    if PLAYER.group ~= "user" then 
        DropPlayer(target, reason)

        if not reason then
            reason = "No reason provided"
        end

        local message = DiscordMessage(); 
        message:AddField()
            :SetName("Staff")
            :SetValue(GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..")");
        message:AddField()
            :SetName("Username")
            :SetValue(GetPlayerId(tonumber(target)).username.." ("..GetPlayerId(tonumber(target)).uuid..")");
        message:AddField()
            :SetName("Reason")
            :SetValue("`"..reason.."`");
        Discord.Send("kick_log", message);
    else
    end
end)

_RegisterServerEvent("admin:banPlayer", function(target, reason, duration)
    local src = source 
    local PLAYER = GetPlayerId(src)
    local PLAYER_SELEC = GetPlayerId(tonumber(target))

    if PLAYER.group ~= "user" then 
        if duration == nil then 
            duration = "99y"
        end
        BanUUID(src, PLAYER_SELEC.uuid, reason, duration)
    else
    end
end)

function LoadAllBans()
    ListBans = {}

    MySQL.Async.fetchAll("SELECT * FROM bans", {}, function(result)
        if result[1] then 
            for k, v in pairs(result) do 
                -- Vérifier si le ban est expiré
                local isExpired = false
                if v.expiration ~= nil and v.expiration ~= "0000-00-00 00:00:00" then
                    local year, month, day, hour, min, sec = string.match(v.expiration, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
                    if year then
                        local expirationTime = os.time({
                            year = tonumber(year),
                            month = tonumber(month),
                            day = tonumber(day),
                            hour = tonumber(hour),
                            min = tonumber(min),
                            sec = tonumber(sec)
                        })
                        local currentTime = os.time()
                        if currentTime > expirationTime then
                            -- Le ban est expiré, on le supprime
                            MySQL.Async.execute("DELETE FROM bans WHERE banId = @banId", {
                                ["@banId"] = v.banId
                            })
                            isExpired = true
                        end
                    end
                end

                -- N'ajouter que les bans non expirés
                if not isExpired then
                    table.insert(ListBans, {
                        license = v.license,
                        identifiers1 = json.decode(v.identifiers1),
                        identifiers2 = json.decode(v.identifiers2),
                        reason = v.reason,
                        date = v.date,
                        expiration = v.expiration,
                        author = v.author,
                        tokens = json.decode(v.tokens),
                        ip = (v and v.ip) or nil,
                        banId = v.banId
                    })
                end
            end
            Logger:trace("BANS", "All bans has been loaded.")
        end
    end)
end

MySQL.ready(function()
    LoadAllBans()
end)

function GetIfPlayerIsBanned(source, license, data)
    local PLAYER = GetPlayerId(source)
    for k, v in pairs(ListBans) do 
        if v.expiration ~= nil and v.expiration ~= "0000-00-00 00:00:00" then
            local year, month, day, hour, min, sec = string.match(v.expiration, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
            if year then
                local expirationTime = os.time({
                    year = tonumber(year),
                    month = tonumber(month),
                    day = tonumber(day),
                    hour = tonumber(hour),
                    min = tonumber(min),
                    sec = tonumber(sec)
                })
                local currentTime = os.time()
                if currentTime > expirationTime then
                    UnbanId(v.banId)
                    goto continue
                end
            end
        end

        if v.license == license then 
            return true, v.banId, v.reason, v.date, v.expiration
        end

        if v.identifiers1.license == license then 
            return true, v.banId, v.reason, v.date, v.expiration
        end

        if v.identifiers2.license == license then 
            return true, v.banId, v.reason, v.date, v.expiration
        end

        if v and v.ip ~= nil and v.ip == data.ip then 
            return true, v.banId, v.reason, v.date, v.expiration
        end
        for i = 1, #data.identifiers1 do 
            if v.identifiers1[i] == data.identifiers1[i] then 
                return true, v.banId, v.reason, v.date, v.expiration
            end
        end

        for i = 1, #data.identifiers1 do 
            if v.identifiers2[i] == data.identifiers1[i] then 
                return true, v.banId, v.reason, v.date, v.expiration
            end
        end

        if data.tokens then 
            if v.tokens then 
                for i = 1, #data.tokens do 
                    if v.tokens[i] == data.tokens[i] then 
                        return true, v.banId, v.reason, v.date, v.expiration
                    end
                end
            end
        end

        ::continue::
    end
    return false
end

function UnbanId(banId)
    -- On vérifie que banId est un nombre
    if not banId or type(banId) ~= "number" then
        return
    end
    
    MySQL.Async.execute("DELETE FROM bans WHERE banId = @banId", {
        ["@banId"] = banId
    }, function(rowsChanged)
        if rowsChanged > 0 then 
            LoadAllBans()
        else
        end
    end)
end

function ParseBanDuration(duration)
    if not duration or duration == "" or duration == "0" then
        return os.time() + 31536000
    end
    
    local value = tonumber(string.match(duration, "%d+"))
    local unit = string.match(duration, "%a+")
    
    if not value or not unit then
        return nil
    end
    
    local currentTime = os.time()
    local expirationTime
    
    if unit == "h" or unit == "H" then
        -- Hours: 1 hour = 3600 seconds
        expirationTime = currentTime + (value * 3600)
    elseif unit == "d" or unit == "D" then
        -- Days: 1 day = 86400 seconds
        expirationTime = currentTime + (value * 86400)
    elseif unit == "w" or unit == "W" then
        -- Weeks: 1 week = 604800 seconds
        expirationTime = currentTime + (value * 604800)
    elseif unit == "m" or unit == "M" then
        if value == 12 then
            expirationTime = currentTime + 31536000
        else
            if value > 11 then
                value = 11
            end
            expirationTime = currentTime + (value * 2592000)
        end
    elseif unit == "y" or unit == "Y" then
        expirationTime = currentTime + (value * 31536000)
    else
        return nil
    end
    
    return os.date("%Y-%m-%d %H:%M:%S", expirationTime)
end

function FormatDateString(dateString)
    if not dateString or dateString == "0000-00-00 00:00:00" then
        return "Permanent"
    end
    
    if type(dateString) == "number" or tonumber(dateString) then
        local timestamp = tonumber(dateString)
        if timestamp > 9999999999 then
            timestamp = math.floor(timestamp / 1000)
        end
        return os.date("%d/%m/%Y %H:%M:%S", timestamp)
    end
    
    local year, month, day, hour, min, sec = string.match(dateString, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if year then
        return string.format("%02d/%02d/%04d %02d:%02d:%02d", 
            tonumber(day), tonumber(month), tonumber(year), 
            tonumber(hour), tonumber(min), tonumber(sec))
    end
    
    return "Permanent"
end

function FormatBanDuration(expirationDatetime)
    if not expirationDatetime then
        return "Permanent"
    end
    
    return FormatDateString(expirationDatetime)
end

_RegisterServerEvent("admin:announce", function(message)
    local STAFF = GetPlayerId(source)
    if STAFF.group == "user" or STAFF.group == "refund" then 
        return
    end

    local message = (message and message or "REBOOT SERVER")
    TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Announcement", message, 10000)
end)

_RegisterServerEvent('admin:changeName', function(target, name)
    local STAFF = GetPlayerId(source)
    if STAFF.group == "user" or STAFF.group == "refund" or STAFF.group == "moderator" then 
        return
    end
    
    local target = GetPlayerId(tonumber(target))
    if not target then 
        return
    end

    target.setNickname(name)
    DoNotif(target, "Your username has been changed to "..name..".")
end)

RegisterCommand("announce", function(source, args)
    local STAFF = GetPlayerId(source)
    if STAFF.group == "user" or STAFF.group == "refund" or STAFF.group == "moderator" then 
        return
    end
    local message = (message and message or "REBOOT SERVER")
    TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Announcement", message, 10000)
end)
    

function BanPlayerAdmin(source, target, reason, duration)
    local STAFF = GetPlayerId(source) 
    local TARGET_P = GetPlayerId(tonumber(target))

    if not STAFF or not TARGET_P then 
        return
    end

    local reason = reason or "No reason specified"
    
    local expirationDatetime = ParseBanDuration(duration)
    local expirationDisplay = expirationDatetime and FormatBanDuration(expirationDatetime) or "Permanent"

    local identifiers1 = TARGET_P.identifiers
    local identifiers2 = GetPlayerIdentifiers(tonumber(target))

    local GetTokens = GetNumPlayerTokens(tonumber(target))
    local AllTokens = {}
    for i = 1, GetTokens do 
        table.insert(AllTokens, GetPlayerToken(tonumber(target), i))
    end 
    
    -- Modification de la requête pour s'assurer que les IDs peuvent aller bien au-delà de 10
    -- Utilisation de CAST pour garantir que les valeurs sont traitées comme des nombres entiers
    local banId = MySQL.Sync.fetchScalar("SELECT CAST(GREATEST(COALESCE((SELECT MAX(CAST(banId AS SIGNED)) FROM bans), 0), COALESCE((SELECT MAX(CAST(banId AS SIGNED)) FROM `bans-history`), 0)) AS SIGNED)")
    if banId == nil then 
        banId = math.random(500, 80000)
    end
    -- Assurons-nous que banId est traité comme un nombre
    banId = tonumber(banId) + 1

    MySQL.Async.execute("INSERT INTO `bans-history` (license, uuid, reasons, date, author, banId, expiration) VALUES (@license, @uuid, @reasons, @date, @author, @banId, @expiration)", {
        ["@license"] = TARGET_P.license,
        ["@uuid"] = TARGET_P.uuid,
        ["@reasons"] = reason,
        ["@date"] = os.date("%Y-%m-%d %H:%M:%S"),
        ["@author"] = STAFF.username,
        ["@banId"] = banId,
        ["@expiration"] = expirationDatetime,
    })

    MySQL.Async.execute("INSERT INTO bans (license, identifiers1, identifiers2, reason, date, expiration, author, tokens, ip, banId) VALUES (@license, @identifiers1, @identifiers2, @reason, @date, @expiration, @author, @tokens, @ip, @banId)", {
        ["@license"] = TARGET_P.license,
        ["@identifiers1"] = json.encode(identifiers1),
        ["@identifiers2"] = json.encode(identifiers2),
        ["@reason"] = reason,
        ["@date"] = os.date("%Y-%m-%d %H:%M:%S"),
        ["@expiration"] = expirationDatetime,
        ["@author"] = STAFF.username,
        ["@tokens"] = json.encode(AllTokens),
        ["@ip"] = identifiers1 and identifiers1.ip or "",
        ["@banId"] = banId
    }, function(rowsChanged)
        if rowsChanged > 0 then 
            local banMessage = "You have been banned from the server.\nReason: " .. reason
            if expirationDatetime then
                banMessage = banMessage .. "\nExpires: " .. FormatDateString(expirationDatetime)
            end
            
            DropPlayer(tonumber(target), banMessage)
            
            local durationText = expirationDatetime and ("\nDuration: " .. duration .. " (Until: " .. FormatDateString(expirationDatetime) .. ")") or "\nDuration: Permanent"
            writeLog(source, "https://discord.com/api/webhooks/1293319855612624926/2XSAn-Ccll2zFQ6T-nR6kz_mtWvvKYHx2UpITjZV_mA2eN4Cdv3rF_kNnpGvNws-Qo7P", false, 
                "The staff **"..STAFF.username.." ("..STAFF.uuid..")** banned the player **"..TARGET_P.username.." ("..TARGET_P.uuid..")**\n\nReason: `"..reason.."`"..durationText.."\nBan Id: `"..banId.."`\n")
            
            LoadAllBans()

            local chatMessage = ""..TARGET_P.username.."^0 was banned from the server for the reason: "..reason..""
            if expirationDatetime then
                chatMessage = chatMessage .. " (Duration: " .. duration .. ")"
            end

            _TriggerClientEvent("chat:addMessage", -1, {
                color = { 255, 255, 255 },
                multiline = false,
                args = { "^#FF3333Guild", chatMessage }
            })
        end
    end)
end

RegisterCallback("admin:GetBanListGuild", function(source, target)
    local PLAYER = GetPlayerId(source)
    local result = MySQL.query.await("SELECT * FROM bans")
    if result then 
        return result
    else
        return {}
    end
end)

RegisterCallback("admin:GetBansHistory", function(source, target)
    local PLAYER = GetPlayerId(source)
    local banHistory = MySQL.Sync.fetchAll("SELECT * FROM `bans-history` WHERE license = @license", {
        ["@license"] = GetPlayerId(tonumber(target)).license
    })
    local returnValue = {}
    for k, v in pairs(banHistory) do 
        table.insert(returnValue, {
            reason = v.reasons,
            date = v.date,
            author = v.author,
            expiration = v.expiration,
            banId = v.banId
        })
    end
    return returnValue
end)

function TransferTokens(uuid)
    local uuidData = SearchUuidInDatabase(uuid)
    if not uuidData then return end
    local license = uuidData.license
    if not license then return end
    local tokens = MySQL.Sync.fetchScalar("SELECT tokensId FROM players WHERE license = @license", {
        ["@license"] = license,
    })
    return json.decode(tokens)
end


function BanUUID(source, uuid, reason, duration)
    if source ~= 0 then 
        STAFF = GetPlayerId(source)
        if STAFF.group == "user" then 
            return
        end
    end

    ::restart::
    local uuidData = SearchUuidInDatabase(uuid)
    if uuidData then 
        local tokens = TransferTokens(uuid)
        if GetPlayerUUID(tonumber(uuid)) then 
            local playerUUID = GetPlayerUUID(tonumber(uuid))
            if not tokens then 
                saveTokens(playerUUID.source)
                goto restart
            end
        end
        local identifiers1 = json.decode(uuidData.identifiers)
        
        -- Modification de la requête pour s'assurer que les IDs peuvent aller bien au-delà de 10
        -- Utilisation de CAST pour garantir que les valeurs sont traitées comme des nombres entiers
        local banId = MySQL.Sync.fetchScalar("SELECT CAST(GREATEST(COALESCE((SELECT MAX(CAST(banId AS SIGNED)) FROM bans), 0), COALESCE((SELECT MAX(CAST(banId AS SIGNED)) FROM `bans-history`), 0)) AS SIGNED)")
        if banId == nil then 
            banId = math.random(500, 80000)
        end
        
        -- Assurons-nous que banId est traité comme un nombre
        banId = tonumber(banId) + 1
        
        local reason = reason or "No reason specified"
        if duration == nil then 
            duration = "99y"
        end
    
        local expirationDatetime = ParseBanDuration(duration)
        local expirationDisplay = expirationDatetime and FormatBanDuration(expirationDatetime) or "Permanent"

        MySQL.Async.execute("INSERT INTO `bans-history` (license, uuid, reasons, date, author, banId, expiration) VALUES (@license, @uuid, @reasons, @date, @author, @banId, @expiration)", {
            ["@license"] = uuidData.license,
            ["@uuid"] = uuid,
            ["@reasons"] = reason,
            ["@date"] = os.date("%Y-%m-%d %H:%M:%S"),
            ["@author"] = (STAFF and STAFF.username) or "Console",
            ["@banId"] = banId,
            ["@expiration"] = expirationDatetime,
        })
        
        MySQL.Async.execute("INSERT INTO bans (license, identifiers1, identifiers2, reason, date, expiration, author, tokens, ip, banId) VALUES (@license, @identifiers1, @identifiers2, @reason, @date, @expiration, @author, @tokens, @ip, @banId)", {
            ["@license"] = uuidData.license,
            ["@identifiers1"] = json.encode(identifiers1),
            ["@identifiers2"] = json.encode(identifiers1),
            ["@reason"] = reason,
            ["@date"] = os.date("%Y-%m-%d %H:%M:%S"),
            ["@expiration"] = expirationDatetime,
            ["@author"] = (STAFF and STAFF.username) or "Console",
            ["@tokens"] = json.encode(tokens),
            ["@ip"] = uuidData.identifiers and uuidData.identifiers.ip or "",
            ["@banId"] = banId
        }, function(rowsChanged)
            if rowsChanged > 0 then 
                local banMessage = "You have been banned from the server.\nReason: " .. reason
                if expirationDatetime then
                    banMessage = banMessage .. "\nExpires: " .. FormatDateString(expirationDatetime)
                end


                
                if GetPlayerUUID(tonumber(uuid)) then 
                    -- exports["guild-data"]:recordPlayerScreen(GetPlayerUUID(tonumber(uuid)).source, 3000, function(url, err)
                    --     if err then
                    --         DropPlayer(GetPlayerUUID(tonumber(uuid)).source, banMessage)
                    --         return print("failed to take video: "..err)
                    --     end
                    --     DropPlayer(GetPlayerUUID(tonumber(uuid)).source, banMessage)
                    -- end, "https://discordapp.com/api/webhooks/1372687333681397811/we_PdGnAeXV6Ety_sJtbgYcYhF020tBjBJrBATrcE1mgVhd-2QOQ2aoQOLFlUHE3pFhM")
                    DropPlayer(GetPlayerUUID(tonumber(uuid)).source, banMessage)
                end
                
                local durationText = expirationDatetime and ("\nDuration: " .. duration .. " (Until: " .. FormatDateString(expirationDatetime) .. ")") or "\nDuration: Permanent"
                local authorBan = (STAFF and STAFF.username) or "Console"

                local authorUUID = (STAFF and STAFF.uuid) or "Console"
                
                LoadAllBans()
                
                local message = DiscordMessage();
                local returnMessage = ""
                if authorBan == "Console" then
                    returnMessage = "Console"
                else
                    if DiscordId(STAFF.source) then
                        returnMessage = authorBan.." ("..authorUUID..") | Discord ID: <@"..DiscordId(STAFF.source)..">"
                    else
                        returnMessage = authorBan.." ("..authorUUID..")"
                    end
                end

                local returnUsernameBanned = ""
                if GetPlayerUUID(tonumber(uuid)) then
                    if DiscordId(GetPlayerUUID(tonumber(uuid)).source) then
                        returnUsernameBanned = uuidData.username.." ("..uuid..") | Discord ID: <@"..DiscordId(GetPlayerUUID(tonumber(uuid)).source)..">"
                    else
                        returnUsernameBanned = uuidData.username.." ("..uuid..")"
                    end
                else 
                    returnUsernameBanned = uuidData.username.." ("..uuid..")"
                end

                message:AddField()
                    :SetName("Staff")
                    :SetValue(authorBan.." ("..authorUUID..")");
                message:AddField()
                    :SetName("Username")
                    :SetValue(uuidData.username.." ("..uuid..")");  
                message:AddField()
                    :SetName("Reason")
                    :SetValue("`"..reason.."`");
                message:AddField()
                    :SetName("Duration")
                    :SetValue(durationText);
                message:AddField()
                    :SetName("Ban ID")
                    :SetValue(banId);
                Discord.Send("ban_log", message);
                
                local chatMessage = ""..uuidData.username.."^0 was banned from the server for the reason: "..reason..""
                if expirationDatetime then
                    chatMessage = chatMessage .. " (Duration: " .. duration .. ")"
                end
    
                _TriggerClientEvent("chat:addMessage", -1, {
                    color = { 255, 255, 255 },
                    multiline = false,
                    args = { "^#FF3333Guild", chatMessage }
                })
            end
        end)

    else
        if source ~= 0 then 
            return DoNotif(source, "This UUID does not exist in the database.")
        else
            return print("This UUID does not exist in the database.")
        end
    end
end

RegisterCommand('ban_uuid', function(source, args)
    local src = source
    local target = args[1]
    local reasonParts = {}
    local duration = nil
    
    for i = 2, #args do
        if string.match(args[i], "^%d+[mMYyhHdDwW]$") then
            duration = args[i]
        else
            table.insert(reasonParts, args[i])
        end
    end
    
    local reason = table.concat(reasonParts, " ")
    if reason == "" then reason = "No reason specified" end

    if duration == nil then 
        duration = "99y"
    end
    
    BanUUID(src, target, reason, duration)
end)

function UnbanAll()
    -- Supprimer tous les bans directement avec une seule requête SQL
    MySQL.Async.execute("DELETE FROM bans", {}, function(rowsChanged)
        if rowsChanged > 0 then
            
            -- Envoi du message Discord pour l'action UnbanAll
            local message = DiscordMessage()
            message:AddField()
                :SetName("Staff Action")
                :SetValue("Mass Unban (All Bans Removed)");
            message:AddField()
                :SetName("Total Unbanned")
                :SetValue(rowsChanged .. " player(s)");
            Discord.Send("unban_log", message);
            
            -- Recharger la liste des bans en mémoire
            LoadAllBans()
            return rowsChanged
        else
            return 0
        end
    end)
    
    -- Renvoyer 0 par défaut, la valeur sera mise à jour par le callback
    return 0
end

RegisterCommand("unban_all", function(source, args)
    local src = source
    local PLAYER = GetPlayerId(src)
    if source == 0 or PLAYER.group == "owner" then 
        -- Appel de la fonction UnbanAll qui est maintenant asynchrone
        UnbanAll()
        
        -- Message de confirmation immédiat
        if source ~= 0 then
            _TriggerClientEvent("ShowAboveRadarMessage", src, "~g~Débanissement de tous les joueurs en cours...")
            
            -- Annonce globale pour informer les joueurs
            TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Mass Unban", "Tous les joueurs bannis ont été débanni.", 10000)
        end
    else
        if source ~= 0 then
            _TriggerClientEvent("ShowAboveRadarMessage", src, "~r~Vous n'avez pas la permission d'utiliser cette commande.")
        end
    end
end)

-- RegisterCommand("ban", function(source, args)
--     local src = source
--     local PLAYER = GetPlayerId(src)
--     if PLAYER.group ~= "user" then 
--         if #args < 1 then
--             _TriggerClientEvent("ShowAboveRadarMessage", src, "~r~Usage: /ban [id] [reason] [duration (optional)]")
--             return
--         end
        
--         local target = args[1]
--         local reasonParts = {}
--         local duration = nil
        
--         for i = 2, #args do
--             if string.match(args[i], "^%d+[mMYyhHdDwW]$") then
--                 duration = args[i]
--             else
--                 table.insert(reasonParts, args[i])
--             end
--         end
        
--         local reason = table.concat(reasonParts, " ")
--         if reason == "" then reason = "No reason specified" end
        
--         BanPlayerAdmin(src, target, reason, duration)
--     else
--     end
-- end)

RegisterCommand("unban", function(source, args)
    local src = source
    local PLAYER = GetPlayerId(src)
    if source == 0 or PLAYER.group == "owner" then 
        if #args < 1 then
            if source ~= 0 then
                _TriggerClientEvent("ShowAboveRadarMessage", src, "~r~Usage: /unban [banId]")
            else
                
            end
            return
        end
        
        local banId = tonumber(args[1])
        if not banId then
            if source ~= 0 then
                _TriggerClientEvent("ShowAboveRadarMessage", src, "~r~L'ID de ban doit être un nombre")
            else
                
            end
            return
        end
        
        local returnMessage = ""
        if source ~= 0 then 
            if DiscordId(src) then  
                returnMessage = GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..") | Discord ID: <@"..DiscordId(src)..">"
            else
                returnMessage = GetPlayerId(src).username.." ("..GetPlayerId(src).uuid..")"
            end
        else 
            returnMessage = "Console"
        end
        
        UnbanId(banId)
        
        local message = DiscordMessage(); 
        message:AddField()
            :SetName("Ban ID")
            :SetValue(banId);
        message:AddField()
            :SetName("Staff")
            :SetValue(returnMessage);
        Discord.Send("unban_log", message);
    else
    end
end)

InVerification = {}

_RegisterServerEvent('verification:Finish', function(target)
    local STAFF = GetPlayerId(source)
    if STAFF.group == "user" then 
        return
    end

    local target = GetPlayerId(tonumber(target))
    if not target then 
        return
    end

    if InVerification[target.uuid] then 
        InVerification[target.uuid] = nil
        _TriggerClientEvent('verification:Finish', target.source)
    end
end)

_RegisterServerEvent('verification:Banned', function()
    local target = GetPlayerId(source)
    if InVerification[target.uuid] then 
        BanUUID(source, target.uuid, "Dodge Verification", "1m")
        InVerification[target.uuid] = nil
    end
end)

AddEventHandler('playerDropped', function()
    local target = GetPlayerId(source)
    if target then 
        if InVerification[target.uuid] then 
            BanUUID(InVerification[target.uuid].staff_source, target.uuid, "Dodge Verification", "1m")
            InVerification[target.uuid] = nil
        end
    end
end)

_RegisterServerEvent('admin:PutVerifPlayer', function(target)
    local STAFF = GetPlayerId(source)
    if STAFF.group == "user" then 
        return
    end

    local target = GetPlayerId(tonumber(target))
    if not target then 
        return
    end

    if InVerification[target.uuid] then return DoNotif(source, "~r~This player is already in verification.") end
    if not InVerification[target.uuid] then 
        InVerification[target.uuid] = { 
            username = target.username,
            staff = STAFF.username,
            source = target.source,
            staff_source = source,
        }
    end

    _TriggerClientEvent('verification:Start', target.source, GetEntityCoords(GetPlayerPed(source)))
end)

RegisterCommand("stopverif", function(source, args)
    local STAFF = GetPlayerId(source)
    if STAFF.group == "user" then 
        return
    end

    local target = GetPlayerId(tonumber(args[1]))
    if not target then 
        return
    end

    if InVerification[target.uuid] then 
        InVerification[target.uuid] = nil
        _TriggerClientEvent('verification:Finish', target.source)
    end
end)

RegisterCommand("recent_bans", function(source, args)
    local src = source
    local PLAYER = GetPlayerId(src)
    
    -- Vérifier les permissions (staff uniquement)
    if source ~= 0 and PLAYER.group == "user" then 
        return DoNotif(src, "~r~You don't have permission to use this command.")
    end
    
    -- Calculer le timestamp d'il y a 10 heures
    local currentTime = os.time()
    local tenHoursAgo = currentTime - (13 * 3600) -- 10 heures * 3600 secondes
    local tenHoursAgoFormatted = os.date("%Y-%m-%d %H:%M:%S", tenHoursAgo)
    
    -- Requête SQL pour récupérer les bans des 10 dernières heures
    MySQL.Async.fetchAll("SELECT banId, license, reason, date, author FROM bans WHERE date >= @tenHoursAgo ORDER BY date DESC", {
        ["@tenHoursAgo"] = tenHoursAgoFormatted
    }, function(result)
        if result and #result > 0 then
            print("^2=== BANS DES 10 DERNIÈRES HEURES ===^0")
            print("^3Nombre total de bans récents: " .. #result .. "^0")
            print("^3Période: depuis " .. os.date("%d/%m/%Y %H:%M:%S", tenHoursAgo) .. "^0")
            print("^2=====================================^0")
            
            for k, v in pairs(result) do
                -- Convertir la date en format lisible
                local year, month, day, hour, min, sec = string.match(v.date, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
                local formattedDate = ""
                if year then
                    formattedDate = string.format("%02d/%02d/%04d %02d:%02d:%02d", 
                        tonumber(day), tonumber(month), tonumber(year), 
                        tonumber(hour), tonumber(min), tonumber(sec))
                else
                    formattedDate = v.date
                end
                
                print("^1Ban ID: ^3" .. v.banId .. "^0")
                print("^1License: ^7" .. v.license .. "^0")
                print("^1Raison: ^7" .. v.reason .. "^0")
                print("^1Date: ^7" .. formattedDate .. "^0")
                print("^1Staff: ^7" .. v.author .. "^0")
                print("^2---------------------------^0")
            end
            
            -- Message pour le joueur si c'est exécuté en jeu
            if source ~= 0 then
                DoNotif(src, "~g~" .. #result .. " ban(s) trouvé(s) dans les 10 dernières heures. Voir la console pour les détails.")
            end
        else
            print("^3Aucun ban trouvé dans les 10 dernières heures.^0")
            if source ~= 0 then
                DoNotif(src, "~y~Aucun ban trouvé dans les 10 dernières heures.")
            end
        end
    end)
end)

webhookFocusConnect = "https://discordapp.com/api/webhooks/1376216688315334678/GoIfl2Z0CBMoqwdjzKZJmuHX7-vPWhPVjV9usJu3wFFf3eRc6nPC2nqzx7_DTKnjqOZS"
webhookFocusAdded = "https://discordapp.com/api/webhooks/1376217803400413435/p72ZuhXp1iq1riTZZA0yb8EP57fcnwYgBbppV5WOLmfc_vm3uyxQgrXW-Z-rv3XwX5qZ"

function SendWebhookFocus(tblData)
    local embed = {
        {
            ["color"] = 3447003, -- Couleur bleu en code décimal
            ["title"] = tblData.title,
            ["description"] = tblData.description,
            ["fields"] = {}, -- Initialize empty fields array
            ["footer"] = {
                ["text"] = tblData.footer
            },
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%S')
        }
    }

    if tblData.fields and #tblData.fields > 0 then
        for _, field in ipairs(tblData.fields) do
            table.insert(embed[1].fields, {
                ["name"] = field.name,
                ["value"] = field.value,
                ["inline"] = (field.inline and true or false)
            })
        end
    end

    local message = {
        username = "Focus Info",
        embeds = embed
    }

    -- Envoyer la requête HTTP
    PerformHttpRequest(tblData.webhook, function(err, text, headers)
        if err == 204 then
            print("Message envoyé avec succès au webhook Discord")
        else
            print("Erreur lors de l'envoi au webhook Discord: " .. tostring(err))
        end
    end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end


function GetUUIDFocus()
    local uuid = json.decode(LoadResourceFile(GetCurrentResourceName(), "data/uuid_focus.json"))
    return uuid
end

function AddUUIDFocus(tblData)
    local uuid = json.decode(LoadResourceFile(GetCurrentResourceName(), "data/uuid_focus.json"))
    table.insert(uuid, {
        uuid = tblData.uuid,
        reason = tblData.reason,
        staffUUID = tblData.staffUUID,
        staffName = tblData.staffName,
        date = os.date("%Y-%m-%d %H:%M:%S"),
    })
    local player = SearchUuidInDatabase(tonumber(tblData.uuid))
    if player then  
        username = player.username
    else
        username = "NOT FOUND USERNAME"
    end
    SendWebhookFocus({
        webhook = webhookFocusAdded,
        title = "Focus Added",
        description = "A new focus has been added to the database.",
        fields = {
            { name = "UUID", value = tblData.uuid, inline = true },
            { name = "Username", value = username, inline = true },
            { name = "Reason", value = tblData.reason, inline = true },
            { name = "Staff UUID", value = tblData.staffUUID, inline = true },
            { name = "Staff Name", value = tblData.staffName, inline = true },
            { name = "Date", value = os.date("%Y-%m-%d %H:%M:%S"), inline = true },
        },
        footer = "Focus Added",
    })
    
    SaveResourceFile(GetCurrentResourceName(), "data/uuid_focus.json", json.encode(uuid))
end

function RemoveUUIDFocus(uuid)
    local uuid = json.decode(LoadResourceFile(GetCurrentResourceName(), "data/uuid_focus.json"))
    for k, v in pairs(uuid) do
        if v.uuid == uuid then
            table.remove(uuid, k)
            SaveResourceFile(GetCurrentResourceName(), "data/uuid_focus.json", json.encode(uuid))
            return true
        end
    end
    return false
end

function GetUUIDFocusByUUID(uuid)
    local uuid = json.decode(LoadResourceFile(GetCurrentResourceName(), "data/uuid_focus.json"))
    for k, v in pairs(uuid) do
        if v.uuid == uuid then
            return v
        end
    end
    return false
end

RegisterCommand("focus", function(source, args)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then 
        return DoNotif(src, "~r~You don't have permission to use this command.")
    end

    local uuid = tonumber(args[1])
    if not uuid then 
        return DoNotif(src, "~r~You need to specify a UUID. (/focus [uuid] [reason])")
    end

    local reason = table.concat(args, " ", 2)
    if reason == "" then 
        return DoNotif(src, "~r~You need to specify a reason. (/focus [uuid] [reason])")
    end

    local staffUUID = PLAYER.uuid
    local staffName = PLAYER.username

    AddUUIDFocus({
        uuid = uuid,
        reason = reason,
        staffUUID = staffUUID,
        staffName = staffName,
    })
end)


RegisterCommand("un_focus", function(source, args)
    local src = source
    local PLAYER = GetPlayerId(src)
    if PLAYER.group == "user" then 
        return DoNotif(src, "~r~You don't have permission to use this command.")
    end

    local uuid = tonumber(args[1])
    if not uuid then 
        return DoNotif(src, "~r~You need to specify a UUID. (/un_focus [uuid])")
    end

    RemoveUUIDFocus(uuid)
    
end)