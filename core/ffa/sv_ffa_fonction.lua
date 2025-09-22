ListFFA = {} 

-- Table pour stocker les joueurs FFA actifs
local ActiveFFAPlayers = {}

-- Fonction pour nettoyer toutes les armes FFA d'un joueur
function CleanAllFFAWeapons(source)
    if not source then return end
    
    -- Parcourir tous les FFA actifs
    for k, v in pairs(ListFFA) do
        if v.ffaSessions and v.ffaSessions[source] then
            v:CleanPlayerFFAWeapons(source)
        end
    end
    
    -- Retirer le joueur de la liste des joueurs FFA actifs
    ActiveFFAPlayers[source] = nil
end

-- Fonction pour nettoyer les armes FFA en dehors du mode de jeu
function CleanFFAWeaponsOutsideGame(source)
    if not source then return false end
    
    local player = GetPlayerId(source)
    if not player then return false end
    
    -- Vérifier si le joueur est dans un mode FFA
    local isInFFA = false
    for k, v in pairs(ListFFA) do
        if v:GetPlayer(source) then
            isInFFA = true
            break
        end
    end
    
    -- Si le joueur n'est pas en FFA, nettoyer ses armes FFA
    if not isInFFA then
        local inventory = exports["gamemode"]:GetInventory(source, "inventory")
        if inventory then
            local itemsToRemove = {}
            
            -- Identifier tous les items avec un badge FFA
            for i = 1, #inventory do
                local item = inventory[i]
                if item.info and item.info.ffa_badge and string.find(item.info.ffa_badge, "FFA_") then
                    table.insert(itemsToRemove, {
                        name = item.name,
                        count = item.count,
                        index = i
                    })
                end
            end
            
            -- Supprimer les items FFA identifiés
            for _, itemData in ipairs(itemsToRemove) do
                exports["gamemode"]:RemoveItem(source, "inventory", itemData.name, itemData.count)
            end
            
            if #itemsToRemove > 0 then
                Logger:trace("FFA", "Cleaned " .. #itemsToRemove .. " FFA weapons from player " .. source .. " (outside FFA mode)")
                return true
            end
        end
    end
    
    return false
end

-- Fonction pour vérifier la validité des badges FFA
function ValidateFFABadges()
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local playerId = tonumber(playerId)
        if playerId then
            local inventory = exports["gamemode"]:GetInventory(playerId, "inventory")
            if inventory then
                for i = 1, #inventory do
                    local item = inventory[i]
                    if item.info and item.info.ffa_badge and string.find(item.info.ffa_badge, "FFA_") then
                        -- Vérifier si le badge FFA est valide
                        local badgeParts = {}
                        for part in string.gmatch(item.info.ffa_badge, "[^_]+") do
                            table.insert(badgeParts, part)
                        end
                        
                        if #badgeParts >= 4 then
                            local ffaId = tonumber(badgeParts[2])
                            local timestamp = tonumber(badgeParts[3])
                            local playerSource = tonumber(badgeParts[4])
                            
                            -- Vérifier si le FFA existe encore
                            local ffaExists = false
                            for k, v in pairs(ListFFA) do
                                if v.id == ffaId then
                                    ffaExists = true
                                    break
                                end
                            end
                            
                            -- Vérifier si le badge n'est pas trop ancien (plus de 24h)
                            local currentTime = os.time()
                            local maxAge = 24 * 60 * 60 -- 24 heures
                            
                            if not ffaExists or (currentTime - timestamp) > maxAge or playerSource ~= playerId then
                                -- Badge invalide, supprimer l'item
                                exports["gamemode"]:RemoveItem(playerId, "inventory", item.name, item.count)
                                Logger:trace("FFA", "Removed invalid FFA badge item " .. item.name .. " from player " .. playerId)
                            end
                        end
                    end
                end
            end
        end
    end
end


function RandomFFAMaps()
    local randomMap = FFA_Config.listMaps[math.random(1, #FFA_Config.listMaps)]
    return randomMap
end

_RegisterNetEvent('FFAGetData', function()
    _TriggerClientEvent('ffa:sendingdata', source, "mass_update", ListFFA)
end)

function GetFFAPlayer(source)
    for k, v in pairs(ListFFA) do
        for k2, v2 in pairs(v.players) do
            if v2.source == source then
                return v
            end
        end
    end
    return false
end

function GetFFA(id)
    return ListFFA[id]
end

function CreateFFA(tblData, random)
    if not tblData then return end
    if type(tblData) ~= "table" then return end

    local map = nil
    if random then
        ::maps:: 

        map = RandomFFAMaps()
        for k, v in pairs(ListFFA) do
            if v.maps == map then
                goto maps
            end
        end
    end

    map = tblData.map

    if #ListFFA >= 3 then
        return Logger:trace("FFA", "You can't create more than 3 FFA")
    end

    local id = #ListFFA + 1

    ListFFA[id] = ClassFFA:new({
        id = id,
        name = (map and map.name or "FFA #" .. id),
        map = map,
    })

    Logger:trace("FFA", "A FFA has been created with the id " .. ListFFA[id].id)
end

Citizen.CreateThread(function()
    Wait(2000)
    CreateFFA({
        map = FFA_Config.listMaps[1],
    })
    Wait(1000)
    CreateFFA({
        map = FFA_Config.listMaps[2],
    })
end)

AddEventHandler("playerDropped", function(reason)
    local FFA_DATA = GetFFAPlayer(source)
    if FFA_DATA then 
        -- Nettoyer les armes FFA avant de retirer le joueur
        FFA_DATA:CleanPlayerFFAWeapons(source)
        FFA_DATA:RemovePlayer({
            source = source,
        })
    end
    
    -- Nettoyer toutes les armes FFA du joueur déconnecté
    CleanAllFFAWeapons(source)
end)

_RegisterServerEvent("ffa:join", function(id)
    local FFA_DATA = GetFFA(tonumber(id))
    if not FFA_DATA then return end 
    FFA_DATA:AddPlayer({
        source = source,
    })
end)

RegisterCommand("joinffa", function(source, args, rawCommand)
    if GetFFAPlayer(source) then return end
    local FFA_DATA = GetFFA(tonumber(args[1]))
    if not FFA_DATA then return end 

    FFA_DATA:AddPlayer({
        source = source,
    })

end)

-- Événement pour nettoyer les armes FFA lors de la sortie du mode
_RegisterServerEvent("ffa:leave", function()
    local FFA_DATA = GetFFAPlayer(source)
    if FFA_DATA then 
        -- Nettoyer les armes FFA avant de retirer le joueur
        FFA_DATA:CleanPlayerFFAWeapons(source)
        FFA_DATA:RemovePlayer({
            source = source,
        })
    end
end)

-- Événement pour gérer les changements de gamemode
_RegisterServerEvent("gamemode:ConnectToGame", function(gamemode)
    if gamemode ~= "FFA" then
        -- Le joueur change de gamemode, vérifier s'il a des armes FFA
        local FFA_DATA = GetFFAPlayer(source)
        if FFA_DATA then
            -- Le joueur est encore en FFA, le retirer
            FFA_DATA:RemovePlayer({
                source = source,
            })
        end
        
        -- Nettoyer les armes FFA en dehors du mode
        CleanFFAWeaponsOutsideGame(source)
    end
end)

-- Commande pour quitter le FFA
RegisterCommand("leaveffa", function(source, args, rawCommand)
    local FFA_DATA = GetFFAPlayer(source)
    if not FFA_DATA then return end  

    FFA_DATA:RemovePlayer({
        source = source,
    })
end)

-- -- Commande admin pour nettoyer toutes les armes FFA
-- RegisterCommand("cleanffaweapons", function(source, args, rawCommand)
--     local player = GetPlayerId(source)
--     if not player or player.group ~= "owner" then return end
    
--     local target = tonumber(args[1])
--     if not target then
--         -- Nettoyer pour tous les joueurs
--         local players = GetPlayers()
--         local totalCleaned = 0
        
--         for _, playerId in ipairs(players) do
--             local playerId = tonumber(playerId)
--             if playerId then
--                 local cleaned = CleanFFAWeaponsOutsideGame(playerId)
--                 if cleaned then totalCleaned = totalCleaned + 1 end
--             end
--         end
        
--         DoNotif(source, "~g~Cleaned FFA weapons for " .. totalCleaned .. " players")
--         Logger:trace("FFA", "Admin " .. source .. " cleaned all FFA weapons")
--     else
--         -- Nettoyer pour un joueur spécifique
--         CleanFFAWeaponsOutsideGame(target)
--         DoNotif(source, "~g~Cleaned FFA weapons for player " .. target)
--         Logger:trace("FFA", "Admin " .. source .. " cleaned FFA weapons for player " .. target)
--     end
-- end)

-- Commande admin pour vérifier les badges FFA
-- RegisterCommand("validateffa", function(source, args, rawCommand)
--     local player = GetPlayerId(source)
--     if not player or player.group ~= "owner" then return end
    
--     ValidateFFABadges()
--     DoNotif(source, "~g~FFA badges validation completed")
--     Logger:trace("FFA", "Admin " .. source .. " triggered FFA badges validation")
-- end)

-- Thread pour nettoyer périodiquement les armes FFA en dehors du mode
Citizen.CreateThread(function()
    while true do
        Wait(30000) -- Vérifier toutes les 30 secondes
        
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local playerId = tonumber(playerId)
            if playerId then
                CleanFFAWeaponsOutsideGame(playerId)
            end
        end
    end
end)

-- Thread pour vérifier les joueurs FFA déconnectés
Citizen.CreateThread(function()
    while true do
        Wait(60000) -- Vérifier toutes les minutes
        
        for k, v in pairs(ListFFA) do
            if v.players then
                for i = #v.players, 1, -1 do
                    local player = v.players[i]
                    if player and player.source then
                        -- Vérifier si le joueur est toujours connecté
                        local ping = GetPlayerPing(player.source)
                        if ping == 0 then
                            -- Joueur déconnecté, nettoyer ses armes FFA
                            v:CleanPlayerFFAWeapons(player.source)
                            -- Retirer le joueur du FFA
                            v:RemovePlayer({
                                source = player.source,
                            })
                            Logger:trace("FFA", "Removed disconnected player " .. player.source .. " from FFA " .. v.id)
                        end
                    end
                end
            end
        end
    end
end)

-- Thread pour valider les badges FFA
Citizen.CreateThread(function()
    while true do
        Wait(300000) -- Vérifier toutes les 5 minutes
        
        ValidateFFABadges()
    end
end)

-- Événement pour gérer l'arrêt du script (crash)
_RegisterServerEvent("ffa:resourceStop", function(ffaId)
    local FFA_DATA = GetFFA(tonumber(ffaId))
    if FFA_DATA then
        -- Nettoyer tous les joueurs de ce FFA
        for k, v in pairs(FFA_DATA.players) do
            if v.source then
                FFA_DATA:CleanPlayerFFAWeapons(v.source)
                -- Retirer le joueur du FFA
                FFA_DATA:RemovePlayer({
                    source = v.source,
                })
            end
        end
        Logger:trace("FFA", "Cleaned all players from FFA " .. ffaId .. " due to resource stop")
    end
end)

-- Événement pour vérifier le statut FFA d'un joueur
_RegisterServerEvent("ffa:checkStatus", function()
    local FFA_DATA = GetFFAPlayer(source)
    if not FFA_DATA then
        -- Le joueur n'est plus en FFA, nettoyer ses armes FFA
        CleanFFAWeaponsOutsideGame(source)
    end
end)

-- Fonction pour nettoyer les armes FFA lors des redémarrages de serveur
function CleanAllFFAWeaponsOnRestart()
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local playerId = tonumber(playerId)
        if playerId then
            CleanFFAWeaponsOutsideGame(playerId)
        end
    end
    Logger:trace("FFA", "Cleaned all FFA weapons on server restart")
end

-- Nettoyer les armes FFA lors du redémarrage du script
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanAllFFAWeaponsOnRestart()
    end
end)