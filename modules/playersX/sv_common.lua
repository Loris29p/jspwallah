ResourceStart = false 

-- Cache pour stocker l'état précédent des joueurs
local PlayerCache = {}

MySQL.ready(function()
    Discord.Login();
end)

Discord.Register("disconnect_log", "Player Disconnect", "logs-disconnect");

-- Fonction utilitaire pour comparer deux tables
local function isDifferent(old, new)
    if type(old) ~= type(new) then return true end
    if type(old) ~= "table" then return old ~= new end
    
    for k, v in pairs(old) do
        if type(v) == "table" then
            if not new[k] or isDifferent(v, new[k]) then return true end
        elseif new[k] ~= v then
            return true
        end
    end
    
    for k, v in pairs(new) do
        if old[k] == nil then return true end
    end
    
    return false
end

-- Fonction pour créer une copie profonde d'une table
local function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

function SavePlayer(src, disconnect)
    local PLAYER = GetPlayerId(src)
    if not PLAYER then return end

    -- Récupérer les tokens actuels
    local listTokensPlayer = TokenSetterDisconnect(src)
    
    -- Préparer les données du joueur (SANS l'inventaire qui est géré séparément)
    local playerData = {
        username = PLAYER.username,
        rank = PLAYER.rank,
        token = PLAYER.token,
        group = PLAYER.group,
        permissions = PLAYER.permissions,
        informations = PLAYER.informations,
        kills_global = PLAYER.kills_global,
        death_global = PLAYER.death_global,
        data = PLAYER.data or {},
        cosmetics = PLAYER.cosmetics,
        xp = PLAYER.xp,
        coins = PLAYER.coins,
        crewId = PLAYER.crewId,
        prestige = PLAYER.prestige,
        tokens = listTokensPlayer
    }
    local hasChanged = disconnect or not PlayerCache[src] or isDifferent(PlayerCache[src], playerData)
    
    if hasChanged then
        -- Début de la transaction (SANS inventory)
        MySQL.Async.transaction({
            {
                query = "UPDATE players SET username = @username, rank = @rank, token = @token, `group` = @group, permissions = @permissions, informations = @informations, kills_global = @kills_global, death_global = @death_global, flag = @flag, data = @data, cosmetics = @cosmetics, xp = @xp, coins = @coins, crewId = @crewId, prestige = @prestige, tokensId = @tokensId WHERE license = @license",
                values = {
                    ["@username"] = playerData.username,
                    ["@rank"] = playerData.rank,
                    ["@token"] = playerData.token,
                    ["@group"] = playerData.group,
                    ["@permissions"] = playerData.permissions,
                    ["@informations"] = json.encode(playerData.informations),
                    ["@kills_global"] = playerData.kills_global,
                    ["@death_global"] = playerData.death_global,
                    ["@flag"] = "FR",
                    ["@data"] = json.encode(playerData.data),
                    ["@cosmetics"] = json.encode(playerData.cosmetics),
                    ["@xp"] = playerData.xp,
                    ["@coins"] = playerData.coins,
                    ["@crewId"] = playerData.crewId,
                    ["@prestige"] = playerData.prestige,
                    ["@tokensId"] = json.encode(playerData.tokens),
                    ["@license"] = PLAYER.license,
                }
            }
        }, function(success)
            if success then
                Logger:trace("Player data saved successfully for " .. PLAYER.username)
                -- Mettre à jour le cache seulement si la sauvegarde a réussi
                if not disconnect then
                    PlayerCache[src] = deepCopy(playerData)
                end
            else
                Logger:error("Failed to save player data for " .. PLAYER.username)
            end
        end)

        -- Sauvegarder l'inventaire séparément lors de la déconnexion
        if disconnect then
            local identifier = GetPlayerIdentifiers(src)[1]
            if identifier then
                SavePlayerInventories(identifier)
            end
            
            local message = DiscordMessage()
            message:SetMessage(("The player **%s** just disconnect to the server"):format(Players[src].username))
            message:AddField()
                :SetName("UUID")
                :SetValue(Players[src].uuid)
                :SetInline(true)
            message:AddField()
                :SetName("License")
                :SetValue(Players[src].license)
                :SetInline(true)
            message:AddField()
                :SetName("Group")
                :SetValue(Players[src].group)
                :SetInline(true)
            message:AddField()
                :SetName("Rank")
                :SetValue(Players[src].rank)
                :SetInline(true)
            message:AddField()
                :SetName("ID")
                :SetValue(src)
                :SetInline(true)
            message:AddField()
                :SetName("Tokens")
                :SetValue(Players[src].token)
                :SetInline(true)
            message:AddField()
                :SetName("Prestige")
                :SetValue(Players[src].prestige)
                :SetInline(true)
            Discord.Send("disconnect_log", message)
            
            -- Nettoyer le cache et la table des joueurs
            PlayerCache[src] = nil
            Players[src] = nil
        end
    end
end

function TokenSetterDisconnect(src)
    local listTokensPlayer = {}
    local numTokens = GetNumPlayerTokens(src)
    for i = 0, numTokens - 1 do
        local token = GetPlayerToken(src, i)
        table.insert(listTokensPlayer, token)
    end
    return listTokensPlayer
end

-- Événement de déconnexion
AddEventHandler("playerDropped", function()
    SavePlayer(source, true)
end)

function StartSaveLoop()
    Wait(10000)
    Citizen.CreateThread(function()
        while true do 
            for k, v in pairs(Players) do 
                _TriggerClientEvent("player:UpdateTable", k, v)
            end
            Wait(5000)
        end
    end)
end

function StartSavePlayerData()
    Wait(10000)
    Citizen.CreateThread(function()
        while true do 
            -- Créer une liste des joueurs à sauvegarder
            local playersToSave = {}
            for k, _ in pairs(Players) do 
                table.insert(playersToSave, k)
            end
            
            -- Sauvegarder chaque joueur avec un délai
            for _, playerId in ipairs(playersToSave) do
                if Players[playerId] then  -- Vérifier si le joueur est toujours connecté
                    SavePlayer(playerId)
                    Wait(1000)  -- Attendre 1 seconde entre chaque sauvegarde
                end
            end
            
            -- Attendre avant le prochain cycle de sauvegarde (2 minutes)
            Wait(1000*60*2)
        end
    end)
end