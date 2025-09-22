
isAdmin = function(source) -- your admin check
    local PLAYER = GetPlayerId(source)
    if PLAYER.group == "user" then return false end
    return true
end

banEvent = function(source, reason)
    -- ban code here
end


function jointext(message, text)
    return string.format(message, text)
end

MagicTestDiscordLog = function(source, type, detected)
    if ConfigAI.Discord.LogActive then
        local playersource = source
        local data = GetId(playersource)
        PlayerDetails = "**Temp ID:** " .. (playersource or "N/A") .. "\n**Username:** " .. (GetPlayerName(playersource) and GetPlayerName(playersource) or "N/A") .. "\n**Player Steam:** " .. (data.steam or "N/A") .. "\n**Player Discord:** " .. (data.discord or "N/A") .. "\n**Player UUID:** " .. (GetPlayerId(playersource) and GetPlayerId(playersource).uuid or "N/A") .. "\n**Player License:** ".. (data.license or "N/A")

        local embeds = {
            {
                ["color"] = detected and ConfigAI.LogMessages[type].detectedColor or ConfigAI.LogMessages[type].notDetectedColor,
                ["author"] = {
                    ["name"] = ConfigAI.Discord.BotName,
                    ["icon_url"] = ConfigAI.Discord.BotAuthorURL
                },
                ["title"] = "Magic Test",
                ["description"] = "" .. jointext(ConfigAI.LogMessages[type].message, detected and ConfigAI.LogMessages[type].detected or ConfigAI.LogMessages[type].notdetected) .. "",
                ["footer"] = {
                    ["text"] = ConfigAI.Discord.BotName .. " • " .. os.date("%x %X %p"),
                    ["icon_url"] = ConfigAI.Discord.BotFooterURL
                },
                ["fields"] = {
                    -- {
                    --     ["name"] = "field.title",
                    --     ["value"] = "fieldValue",
                    --     ["inline"] = true
                    -- },
                    {
                        ["name"] = "Player Details",
                        ["value"] = PlayerDetails,
                        ["inline"] = true
                    }
                }
            }
        }
        PerformHttpRequest(ConfigAI.Discord.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({ username = ConfigAI.Discord.BotName, embeds = embeds, avatar_url = ConfigAI.Discord.BotAvatar }),{ ['Content-Type'] = 'application/json' })
    end
end


function GetId(source)
    local identifier = {}
    local identifiers = {}
    identifiers = GetPlayerIdentifiers(source)
    for i = 1, #identifiers do
        if string.match(identifiers[i], "discord:") then
            identifier["discord"] = string.sub(identifiers[i], 9)
            identifier["discord"] = "<@" .. identifier["discord"] .. ">"
        end
        if string.match(identifiers[i], "steam:") then
            identifier["steam"] = identifiers[i]
        end
        if string.match(identifiers[i], "license:") then
            identifier["license"] = identifiers[i]
        end
        if string.match(identifiers[i], "fivem:") then
            identifier["fivem"] = identifiers[i]
        end
        if string.match(identifiers[i], "ip:") then
            identifier["ip"] = identifiers[i]
        end
    end
    if identifier["discord"] == nil then
        identifier["discord"] = "Unknow"
    end
    return identifier
end