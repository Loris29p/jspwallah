local devVersion = true
RegisterCommand('host', function()
    if devVersion then return end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showHostMenu'
    })
end)

RegisterCommand('hidehost', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideHostMenu'
    })
end)

-- Gérer les callbacks NUI
RegisterNUICallback('startGame', function(data, cb)
    -- data.map et data.time sont disponibles ici
    -- Votre logique pour démarrer le jeu
    cb('ok')
end)

RegisterNUICallback('stopGame', function(data, cb)
    -- Votre logique pour arrêter le jeu
    cb('ok')
end)

RegisterNUICallback('kickPlayer', function(data, cb)
    -- data.playerId est disponible ici
    -- Votre logique pour kick un joueur
    cb('ok')
end)

RegisterNUICallback('acceptInvite', function(data, cb)
    -- data.inviteId est disponible ici
    -- Votre logique pour accepter une invitation
    cb('ok')
end)

RegisterNUICallback('declineInvite', function(data, cb)
    -- data.inviteId est disponible ici
    -- Votre logique pour refuser une invitation
    cb('ok')
end)

RegisterNUICallback('showPlayerList', function(data, cb)
    -- Votre logique pour afficher la liste des joueurs
    cb('ok')
end)

-- Exemple d'envoi de données vers l'UI
function UpdatePlayerList(players)
    SendNUIMessage({
        action = 'sendPlayerList',
        players = players
    })
end

function UpdateHostStatus(isHost)
    SendNUIMessage({
        action = 'updateUI',
        isHost = isHost
    })
end

function SendInvite(invite)
    SendNUIMessage({
        action = 'receiveInvite',
        invite = invite
    })
end

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
 
RegisterNUICallback('createGame', function(data, cb)
    -- Votre logique pour créer la partie
    -- data.map et data.time sont disponibles ici
    
    -- Une fois la partie créée avec succès
    SendNUIMessage({
        action = 'gameCreated'
    })
    
    cb('ok')
end)

-- Quand la partie se termine
function OnGameEnd()
    SendNUIMessage({
        action = 'gameEnded'
    })
end