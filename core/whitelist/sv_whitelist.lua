local Config = {
    DiscordToken = "...",
    GuildId = 1349955944766902343,
    Roles = {
        ["user"] = 1354431662750171228,
        ["support"] = 1353464866383331330,
        ["invite"] = 1361275547686015097,
        ["vip"] = 1350093939885215784,
        ["vip+"] = 1360353201601253467,
        ["mvp"] = 1360353246639820881,     -- ["player"] = 1262329182646702081,
        ["god"] = 1388568135258345482,
        ["streamer"] = 1363658945482461184,
    },
    VoiceChannels = {
        ["support"] = 1350103422665494588 -- Remplacer par l'ID réel du canal
    }
}

local FormattedToken = "Bot "..Config.DiscordToken

CreateThread(function()
    local guild = DiscordRequest("GET", "guilds/"..Config.GuildId, {})
    if guild.code == 200 then
        local data = json.decode(guild.data)
        
        print("^5[Guild Utils] ^7Connectée au discord \""..data.name.."\".")
    else
        print("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
    end
end)


-- Option 1
function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
        data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})
    while data == nil do
        Wait(0)
    end
    return data
end

cache = {}
function DiscordId(src)
    if src == nil then
        return
    end
    cache[src] = 0
    while GetPlayerIdentifiers(src) == nil do
        if cache[src] == 3 then
            DropPlayer(src, "erreur lors de la recuperation de l'identifiant discord.")
        else
            cache[src] = cache[src] + 1
            print("check cache["..src.."] time: "..cache[src])
        end
        Wait(0)
    end
    for k, v in pairs(GetPlayerIdentifiers(src)) do    
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            return string.sub(v, string.len("discord:") + 1)
        end
    end
end

PlayerTag = {}
function DiscordTag(discordId) 
    if PlayerTag[discordId] == nil then
        local endpoint = ("users/%s"):format(discordId)
        local member = DiscordRequest("GET", endpoint, {})

        if member.code ~= 200 then
            if member.code == 429 then
                Wait(1.5 * 1000)
                return DiscordTag(discordId)
            else
                return false
            end
        end
        local data = json.decode(member.data)
        if data ~= nil then 
            local discordTag = data.username
            PlayerTag[discordId] = {
                Name = discordTag
            }
            return discordTag
        end
    else
        return PlayerTag[discordId].Name
    end
end

PlayerRoles = {}
function DiscordRole(discordId, role)
    if PlayerRoles[discordId] == nil or (math.floor(os.time()) - math.floor(PlayerRoles[discordId].wait)) > 5 then
        local member = DiscordRequest("GET", "guilds/"..Config.GuildId.."/members/"..discordId, {})
        if member.code ~= 200 then
            if member.code == 429 then
                Wait(1.5 * 1000)
                return DiscordRole(discordId, role)
            else
                return false
            end
        end

        local data = json.decode(member.data)
        local roles = data.roles

        PlayerRoles[discordId] = {
            wait = os.time(),
            roles = roles
        }

        if type(role) ~= "number" then
            role = Config.Roles[role]
        end

        for _, role_id in ipairs(roles) do
            if tostring(role_id) == tostring(role) then
                return true
            end
        end

        return false
    else
        if type(role) ~= "number" then
            role = Config.Roles[role]
        end

        for _, role_id in ipairs(PlayerRoles[discordId].roles) do
            if tostring(role_id) == tostring(role) then
                return true
            end
        end

        return false
    end
end

-- Fonction pour vérifier si un joueur est dans un canal vocal spécifique
-- discordId: ID Discord du joueur
-- channelName: Nom du canal vocal dans Config.VoiceChannels OU ID direct du canal
-- Retourne: true si le joueur est dans le canal, false sinon
PlayerVoiceStatus = {}
function DiscordVoiceChannel(discordId, channelName)
    -- Rafraîchir le statut vocal si plus de 5 secondes se sont écoulées
    if PlayerVoiceStatus[discordId] == nil or (math.floor(os.time()) - math.floor(PlayerVoiceStatus[discordId].wait)) > 5 then
        local member = DiscordRequest("GET", "guilds/"..Config.GuildId.."/members/"..discordId, {})
        print(json.encode(member))
        if member.code ~= 200 then
            if member.code == 429 then
                Wait(1.5 * 1000)
                return DiscordVoiceChannel(discordId, channelName)
            else
                return false
            end
        end

        local data = json.decode(member.data)
        local voiceState = data.voice_state
        
        -- Si l'utilisateur n'est pas en vocal ou les données sont invalides
        if not voiceState or not voiceState.channel_id then
            PlayerVoiceStatus[discordId] = {
                wait = os.time(),
                channelId = nil
            }
            return false
        end
        
        -- Stocker l'ID du canal vocal actuel
        PlayerVoiceStatus[discordId] = {
            wait = os.time(),
            channelId = voiceState.channel_id
        }
        
        -- Vérifier si le canal correspond à celui recherché
        local targetChannelId
        if type(channelName) == "string" and Config.VoiceChannels[channelName] then
            targetChannelId = Config.VoiceChannels[channelName]
        else
            targetChannelId = channelName -- Utiliser directement l'ID si fourni
        end
        
        return PlayerVoiceStatus[discordId].channelId == tostring(targetChannelId)
    else
        -- Utiliser les données en cache
        local targetChannelId
        if type(channelName) == "string" and Config.VoiceChannels[channelName] then
            targetChannelId = Config.VoiceChannels[channelName]
        else
            targetChannelId = channelName -- Utiliser directement l'ID si fourni
        end
        
        return PlayerVoiceStatus[discordId].channelId == tostring(targetChannelId)
    end
end


RegisterCommand("verifdiscord", function(source, args)
    local inVoice = checkVoiceChannel(source, DiscordId(source))

    if inVoice then
        print("Le joueur est en vocal mais pas dans le canal spécifié")
    else
        print("Le joueur n'est pas en vocal du tout")
    end
end)

function checkVoiceChannel(src, discordId)
    local data = nil
    local url = ('https://discord.com/api/v10/guilds/%s/members/%s'):format(Config.GuildId, discordId)
    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, "PATCH", json.encode{mute = false}, {["Content-Type"] = "application/json", ["Authorization"] = "Bot "..Config.DiscordToken})

    repeat Wait(0) until data ~= nil

    -- If the player is not connected to a voice channel, return false
    if data.code == 400 then
        return false
    end
    -- In any other case, return true
    return true
end