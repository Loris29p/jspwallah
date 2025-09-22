_AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() and not ResourceStart then 
        ResourceStart = true
        StartSaveLoop()
        StartSavePlayerData()
    end
end)

RegisterCommand("getallbans", function(source, args)
    if source ~= 0 then return end
    local result = MySQL.query.await("SELECT * FROM bans")
    local bansCount = 0 

    local blacklistCount = 0
    for _, ban in ipairs(result) do
        bansCount = bansCount + 1

        if ban.reason == "blacklist" then 
            blacklistCount = blacklistCount + 1 
        end
    end
    print("GUILD PVP IDENTIFIER BANS: " .. bansCount)
    print("GUILD PVP BLACKLIST BANS: " .. blacklistCount)
end)

RegisterCommand("unban_season2", function(source, args)
    if source ~= 0 then return end
    local result = MySQL.query.await("SELECT * FROM bans")

    local unbannedCount = 0
    local notUnbannedCount = 0
    for _, ban in ipairs(result) do
        if ban.reason ~= "blacklist" then 
            unbannedCount = unbannedCount + 1

            print(json.encode(ban, {indent = true}))
            UnbanId(tonumber(ban.banId))
        else
            notUnbannedCount = notUnbannedCount + 1
        end
    end
    print("UNBANNED " .. unbannedCount .. " BANS")
    print("NOT UNBANNED " .. notUnbannedCount .. " BANS")
end)

RegisterCommand("getallbans_2", function(source, args)
    if source ~= 0 then return end
    local result = MySQL.query.await("SELECT * FROM bans")
    local bansCount = 0 
    local banMessage = ""
    local currentTime = os.time()
    local weekAndHalf = 60 * 60 * 24 * 8 -- 1.5 semaines en secondes (10.5 jours)
    
    for _, ban in ipairs(result) do
        local banDate = ban.date
        local year, month, day, hour, min, sec = string.match(banDate, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
        local banTimestamp = os.time({
            year = tonumber(year),
            month = tonumber(month),
            day = tonumber(day),
            hour = tonumber(hour),
            min = tonumber(min),
            sec = tonumber(sec)
        })
        
        if (currentTime - banTimestamp) > weekAndHalf then
            banMessage = banMessage .. "" .. ban.banId..", "
            bansCount = bansCount + 1
        end
    end
    print("GUILD PVP BANS OLDER 3 DAYS: " .. bansCount)
    print(banMessage)
end)


local webhookDiscord = 'https://discord.com/api/webhooks/1375411011217129484/xT4vOY3TUWr_DbJdnwlByPPXa9UCX6uMn-4cBK0P_gkX_dSD7dNJsg7SMZqHVLQGfYIA'
function SendWebhookStaffDiscord(tblData)
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
        username = "Ban Info",
        embeds = embed
    }

    -- Envoyer la requête HTTP
    PerformHttpRequest(webhookDiscord, function(err, text, headers) 
        if err == 204 then
            print("Message envoyé avec succès au webhook Discord")
        else
            print("Erreur lors de l'envoi au webhook Discord: " .. tostring(err))
        end
    end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end

RegisterCommand('baninfo', function(source, args)
    local banId = tonumber(args[1])
    local isGood = false 
    if source == 0 then 
        isGood = true 
    end
    if GetPlayerId(source).group ~= "moderator" then 
        isGood = true 
    end
    if not isGood then 
        return 
    end
    if not banId then 
        return
    end

    local result = MySQL.query.await("SELECT * FROM `bans-history`")
    for _, ban in ipairs(result) do
        if tonumber(ban.banId) == tonumber(banId) then
            SendWebhookStaffDiscord({
                title = "Ban Info",
                description = "```Requesting ban info for " .. ban.uuid .. "```",
                footer = "Ban ID: " .. ban.banId,
                fields = {
                    {name = "UUID", value = ban.uuid, inline = false},
                    {name = "REASON", value = ban.reasons, inline = false},
                    {name = "DATE", value = ban.date, inline = false},
                    {name = "EXPIRATION", value = ban.expiration, inline = false},
                    {name = "STAFF", value = ban.author, inline = false}
                }
            })
        end
    end
end)