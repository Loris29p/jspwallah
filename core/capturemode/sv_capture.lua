local captureZone = {
    active = false,
    position = vector3(0.0, 0.0, 0.0), -- Position par défaut, à modifier selon vos besoins
    radius = 50.0,
    progress = 0,
    currentPlayer = nil,
    timer = 0,
    lastCaptureTime = 0
}

local CAPTURE_INTERVAL = 40 * 60 * 1000 -- 40 minutes en millisecondes
local PROGRESS_SPEED = 1.0 -- % par seconde
local PROGRESS_STANDBY = 0.5 -- % par seconde quand en standby

-- Initialisation du système
CreateThread(function()
    while true do
        local currentTime = GetGameTimer()
        
        -- Vérifier si c'est le moment de créer une nouvelle zone
        if not captureZone.active and (currentTime - captureZone.lastCaptureTime) >= CAPTURE_INTERVAL then
            CreateNewCaptureZone()
        end
        
        -- Mettre à jour la progression si la zone est active
        if captureZone.active then
            UpdateCaptureProgress()
        end
        
        Wait(1000) -- Vérifier toutes les secondes
    end
end)

-- Créer une nouvelle zone de capture
function CreateNewCaptureZone()
    captureZone.active = true
    captureZone.progress = 0
    captureZone.currentPlayer = nil
    captureZone.timer = GetGameTimer()
    
    -- Position aléatoire (à adapter selon votre map)
    local x = math.random(-1000, 1000)
    local y = math.random(-1000, 1000)
    local z = 0.0
    
    -- Trouver le Z correct
    local ground, groundZ = GetGroundZFor_3dCoord(x, y, 1000.0, false)
    if ground then
        z = groundZ + 1.0
    end
    
    captureZone.position = vector3(x, y, z)
    
    -- Notifier tous les clients
    TriggerClientEvent('capture:createZone', -1, captureZone.position, captureZone.radius)
    print("Nouvelle zone de capture créée à: " .. captureZone.position.x .. ", " .. captureZone.position.y .. ", " .. captureZone.position.z)
end)

-- Mettre à jour la progression de capture
function UpdateCaptureProgress()
    if not captureZone.active then return end
    
    local playersInZone = GetPlayersInZone()
    
    if #playersInZone == 0 then
        -- Aucun joueur dans la zone, progression en standby
        captureZone.progress = math.max(0, captureZone.progress - PROGRESS_STANDBY)
        captureZone.currentPlayer = nil
    elseif #playersInZone == 1 then
        local playerId = playersInZone[1]
        
        if captureZone.currentPlayer ~= playerId then
            -- Nouveau joueur dans la zone, recommencer à 0
            captureZone.progress = 0
            captureZone.currentPlayer = playerId
        end
        
        -- Augmenter la progression
        captureZone.progress = math.min(100, captureZone.progress + PROGRESS_SPEED)
        
        -- Vérifier si la capture est terminée
        if captureZone.progress >= 100 then
            CompleteCapture(playerId)
        end
    else
        -- Plusieurs joueurs dans la zone, progression en standby
        captureZone.progress = math.max(0, captureZone.progress - PROGRESS_STANDBY)
        captureZone.currentPlayer = nil
    end
    
    -- Mettre à jour tous les clients
    TriggerClientEvent('capture:updateProgress', -1, captureZone.progress, captureZone.currentPlayer)
end

-- Obtenir les joueurs dans la zone
function GetPlayersInZone()
    local playersInZone = {}
    
    for _, playerId in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(playerId)
        if playerPed and playerPed ~= 0 then
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - captureZone.position)
            
            if distance <= captureZone.radius then
                table.insert(playersInZone, playerId)
            end
        end
    end
    
    return playersInZone
end

-- Terminer la capture
function CompleteCapture(playerId)
    local playerName = GetPlayerName(playerId) or "Joueur inconnu"
    
    -- Récompenses (à adapter selon vos besoins)
    TriggerClientEvent('capture:complete', playerId)
    
    -- Notifier tous les clients
    TriggerClientEvent('capture:notifyComplete', -1, playerName)
    
    -- Réinitialiser la zone
    captureZone.active = false
    captureZone.progress = 0
    captureZone.currentPlayer = nil
    captureZone.lastCaptureTime = GetGameTimer()
    
    -- Supprimer la zone pour tous les clients
    TriggerClientEvent('capture:removeZone', -1)
    
    print("Zone de capture terminée par: " .. playerName)
end

-- Événements reçus des clients
RegisterNetEvent('capture:requestZoneInfo')
AddEventHandler('capture:requestZoneInfo', function()
    local source = source
    if captureZone.active then
        TriggerClientEvent('capture:createZone', source, captureZone.position, captureZone.radius)
        TriggerClientEvent('capture:updateProgress', source, captureZone.progress, captureZone.currentPlayer)
    end
end)

-- Commande pour forcer la création d'une zone (pour les admins)
RegisterCommand('forcecapture', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, 'capture.admin') then
        if captureZone.active then
            captureZone.active = false
            captureZone.lastCaptureTime = GetGameTimer() - CAPTURE_INTERVAL
            TriggerClientEvent('capture:removeZone', -1)
            print("Zone de capture forcée supprimée")
        else
            CreateNewCaptureZone()
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Système", "Vous n'avez pas la permission d'utiliser cette commande."}
        })
    end
end, false)

-- Commande de test pour spawner une zone immédiatement (pour tous les joueurs)
RegisterCommand('testcapture', function(source, args)
    if captureZone.active then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            multiline = true,
            args = {"Test Capture", "Une zone de capture est déjà active!"}
        })
        return
    end
    
    -- Créer une zone de test
    captureZone.active = true
    captureZone.progress = 0
    captureZone.currentPlayer = nil
    captureZone.timer = GetGameTimer()
    
    -- Position de test (centre de la map par défaut)
    local x = 0.0
    local y = 0.0
    local z = 0.0
    
    -- Si des coordonnées sont fournies en argument
    if args[1] and args[2] then
        x = tonumber(args[1]) or 0.0
        y = tonumber(args[2]) or 0.0
        z = tonumber(args[3]) or 0.0
    else
        -- Position aléatoire pour le test
        x = math.random(-500, 500)
        y = math.random(-500, 500)
    end
    
    -- Trouver le Z correct
    local ground, groundZ = GetGroundZFor_3dCoord(x, y, 1000.0, false)
    if ground then
        z = groundZ + 1.0
    end
    
    captureZone.position = vector3(x, y, z)
    
    -- Notifier tous les clients
    TriggerClientEvent('capture:createZone', -1, captureZone.position, captureZone.radius)
    
    -- Message de confirmation
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = true,
        args = {"Test Capture", string.format("Zone de test créée à: %.0f, %.0f, %.0f", x, y, z)}
    })
    
    print("Zone de test créée par " .. GetPlayerName(source) .. " à: " .. captureZone.position.x .. ", " .. captureZone.position.y .. ", " .. captureZone.position.z)
end, false)

-- Commande pour supprimer la zone de test
RegisterCommand('stopcapture', function(source, args)
    if not captureZone.active then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            multiline = true,
            args = {"Test Capture", "Aucune zone de capture active actuellement."}
        })
        return
    end
    
    -- Supprimer la zone
    captureZone.active = false
    captureZone.progress = 0
    captureZone.currentPlayer = nil
    captureZone.lastCaptureTime = GetGameTimer()
    
    -- Notifier tous les clients
    TriggerClientEvent('capture:removeZone', -1)
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 0, 0},
        multiline = true,
        args = {"Test Capture", "Zone de capture supprimée."}
    })
    
    print("Zone de test supprimée par " .. GetPlayerName(source))
end, false)
