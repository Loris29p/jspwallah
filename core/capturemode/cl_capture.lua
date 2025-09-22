local captureZone = {
    active = false,
    position = vector3(0.0, 0.0, 0.0),
    radius = 50.0,
    progress = 0,
    currentPlayer = nil,
    playerInZone = false
}

local isCurrentPlayer = false

-- Variables pour l'interface
local screenW, screenH = GetActiveScreenResolution()
local progressBarWidth = 300
local progressBarHeight = 20
local progressBarX = (screenW - progressBarWidth) / 2
local progressBarY = screenH - 100

-- Initialisation
CreateThread(function()
    -- Demander les informations de la zone au serveur
    TriggerServerEvent('capture:requestZoneInfo')
    
    while true do
        if captureZone.active then
            -- Vérifier si le joueur est dans la zone
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - captureZone.position)
            
            local wasInZone = captureZone.playerInZone
            captureZone.playerInZone = distance <= captureZone.radius
            isCurrentPlayer = captureZone.currentPlayer == GetPlayerServerId(PlayerId())
            
            -- Notifier le serveur si le statut a changé
            if wasInZone ~= captureZone.playerInZone then
                TriggerServerEvent('capture:playerStatusChanged', captureZone.playerInZone)
            end
        end
        
        Wait(500) -- Vérifier toutes les 500ms
    end
end)

-- Thread principal pour le rendu
CreateThread(function()
    while true do
        if captureZone.active then
            -- Dessiner le marqueur de zone
            DrawCaptureZone()
            
            -- Dessiner la barre de progression
            DrawProgressBar()
            
            -- Afficher les informations de la zone
            DrawZoneInfo()
        end
        
        Wait(0)
    end
end)

-- Dessiner la zone de capture
function DrawCaptureZone()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - captureZone.position)
    
    -- Couleur de la zone selon le statut
    local r, g, b, a = 255, 255, 255, 100 -- Blanc par défaut
    
    if captureZone.playerInZone then
        if isCurrentPlayer then
            r, g, b = 0, 255, 0 -- Vert si c'est le joueur actuel
        else
            r, g, b = 255, 255, 0 -- Jaune si un autre joueur
        end
        a = 150
    end
    
    -- Dessiner le marqueur cylindrique
    DrawMarker(
        1, -- Type: cylindre
        captureZone.position.x, captureZone.position.y, captureZone.position.z - 1.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        captureZone.radius, captureZone.radius, 2.0,
        r, g, b, a,
        false, false, 2, false, nil, nil, false
    )
    
    -- Dessiner le marqueur au sol
    DrawMarker(
        2, -- Type: marqueur au sol
        captureZone.position.x, captureZone.position.y, captureZone.position.z + 0.1,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.0, 1.0, 1.0,
        r, g, b, 200,
        false, false, 2, false, nil, nil, false
    )
    
    -- Afficher la distance si proche
    if distance <= captureZone.radius * 1.5 then
        local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(captureZone.position.x, captureZone.position.y, captureZone.position.z + 2.0)
        if onScreen then
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextProportional(true)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            SetTextCentre(true)
            AddTextComponentString(string.format("Zone de Capture\n%.0fm", distance))
            DrawText(screenX, screenY)
        end
    end
end

-- Dessiner la barre de progression
function DrawProgressBar()
    if not captureZone.active then return end
    
    -- Fond de la barre
    DrawRect(progressBarX + progressBarWidth/2, progressBarY + progressBarHeight/2, progressBarWidth, progressBarHeight, 0, 0, 0, 150)
    
    -- Bordure de la barre
    DrawRect(progressBarX + progressBarWidth/2, progressBarY + progressBarHeight/2, progressBarWidth, progressBarHeight, 255, 255, 255, 255)
    
    -- Barre de progression
    local progressWidth = (progressBarWidth - 4) * (captureZone.progress / 100)
    if progressWidth > 0 then
        local progressColor = {0, 255, 0} -- Vert par défaut
        
        if captureZone.playerInZone then
            if isCurrentPlayer then
                progressColor = {0, 255, 0} -- Vert si c'est le joueur actuel
            else
                progressColor = {255, 255, 0} -- Jaune si un autre joueur
            end
        else
            progressColor = {255, 0, 0} -- Rouge si personne
        end
        
        DrawRect(progressBarX + 2 + progressWidth/2, progressBarY + progressBarHeight/2, progressWidth, progressBarHeight, progressColor[1], progressColor[2], progressColor[3], 200)
    end
    
    -- Texte de progression
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(true)
    
    local statusText = "Zone de Capture"
    if captureZone.playerInZone then
        if isCurrentPlayer then
            statusText = string.format("Capture en cours: %.1f%%", captureZone.progress)
        else
            statusText = "Zone contestée - Capture en pause"
        end
    else
        statusText = "Zone inoccupée - Capture en pause"
    end
    
    AddTextComponentString(statusText)
    DrawText(progressBarX + progressBarWidth/2, progressBarY - 10)
end

-- Dessiner les informations de la zone
function DrawZoneInfo()
    if not captureZone.active then return end
    
    local yOffset = 50
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(true)
    
    -- Position de la zone
    AddTextComponentString(string.format("Position: %.0f, %.0f, %.0f", captureZone.position.x, captureZone.position.y, captureZone.position.z))
    DrawText(screenW/2, progressBarY - yOffset)
    
    yOffset = yOffset + 20
    
    -- Statut du joueur
    if captureZone.playerInZone then
        if isCurrentPlayer then
            AddTextComponentString("Vous capturez cette zone!")
        else
            AddTextComponentString("Zone contestée par un autre joueur")
        end
    else
        AddTextComponentString("Entrez dans la zone pour commencer la capture")
    end
    DrawText(screenW/2, progressBarY - yOffset)
end

-- Événements reçus du serveur
RegisterNetEvent('capture:createZone')
AddEventHandler('capture:createZone', function(position, radius)
    captureZone.active = true
    captureZone.position = position
    captureZone.radius = radius
    captureZone.progress = 0
    captureZone.currentPlayer = nil
    captureZone.playerInZone = false
    
    -- Notification
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"Système de Capture", "Une nouvelle zone de capture est apparue! Allez-y pour commencer la capture."}
    })
    
    -- Son de notification (optionnel)
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
end)

RegisterNetEvent('capture:updateProgress')
AddEventHandler('capture:updateProgress', function(progress, currentPlayer)
    captureZone.progress = progress
    captureZone.currentPlayer = currentPlayer
end)

RegisterNetEvent('capture:removeZone')
AddEventHandler('capture:removeZone', function()
    captureZone.active = false
    captureZone.progress = 0
    captureZone.currentPlayer = nil
    captureZone.playerInZone = false
end)

RegisterNetEvent('capture:complete')
AddEventHandler('capture:complete', function()
    -- Récompenses et effets pour le joueur qui a terminé la capture
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"Système de Capture", "Félicitations! Vous avez capturé la zone avec succès!"}
    })
    
    -- Son de victoire
    PlaySoundFrontend(-1, "MP_AWARD", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    
    -- Effet visuel (optionnel)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Créer une explosion visuelle (sans dégâts)
    AddExplosion(playerCoords.x, playerCoords.y, playerCoords.z, 'EXPLOSION_MOLOTOV', 0.0, true, false, 1.0)
end)

RegisterNetEvent('capture:notifyComplete')
AddEventHandler('capture:notifyComplete', function(playerName)
    if playerName ~= GetPlayerName(PlayerId()) then
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"Système de Capture", playerName .. " a capturé la zone!"}
        })
    end
end)

-- Commande pour afficher les informations de la zone
RegisterCommand('captureinfo', function()
    if captureZone.active then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - captureZone.position)
        
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 255},
            multiline = true,
            args = {"Info Capture", string.format("Zone active à %.0fm de vous. Progression: %.1f%%", distance, captureZone.progress)}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"Info Capture", "Aucune zone de capture active actuellement."}
        })
    end
end, false)
