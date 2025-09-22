-- Gestionnaire de téléportation côté serveur

-- Liste des téléporteurs disponibles (doit correspondre à celle dans teleporter.js)
local teleporterList = {
    { teleporterName = "Ville", teleporterCoords = vector3(100.0, 200.0, 30.0) },
    { teleporterName = "Plage", teleporterCoords = vector3(200.0, 300.0, 40.0) },
    { teleporterName = "Montagne", teleporterCoords = vector3(300.0, 400.0, 50.0) },
    { teleporterName = "Aéroport", teleporterCoords = vector3(400.0, 500.0, 60.0) },
    { teleporterName = "Port", teleporterCoords = vector3(500.0, 600.0, 70.0) },
    { teleporterName = "Centre Commercial", teleporterCoords = vector3(600.0, 700.0, 80.0) },
    { teleporterName = "Parc", teleporterCoords = vector3(700.0, 800.0, 90.0) },
    { teleporterName = "Stade", teleporterCoords = vector3(800.0, 900.0, 100.0) },
    { teleporterName = "Casino", teleporterCoords = vector3(900.0, 1000.0, 110.0) }
}

-- Event pour ouvrir l'interface de téléportation
-- RegisterCommand('teleporter', function(source, args, rawCommand)
--     local _source = source
--     TriggerClientEvent('gamemode:openTeleporter', _source)
-- end, false)

-- Event pour téléporter un joueur
RegisterServerEvent('gamemode:teleportPlayer')
AddEventHandler('gamemode:teleportPlayer', function(teleporterName)
    local _source = source
    
    -- Rechercher le téléporteur par son nom
    for _, teleporter in ipairs(teleporterList) do
        if teleporter.teleporterName == teleporterName then
            -- Téléporter le joueur
            TriggerClientEvent('gamemode:doTeleport', _source, teleporter.teleporterCoords)
            return
        end
    end
    
    -- Si le téléporteur n'est pas trouvé
    TriggerClientEvent('chat:addMessage', _source, {
        args = {"^1Erreur", "Destination de téléportation non trouvée!"}
    })
end) 