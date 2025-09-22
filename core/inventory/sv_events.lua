_RegisterServerEvent("gamemode:server:OpenInventory", function(inventoryType, identifierInput, items)
    -- getGm()
    local src = source
    local identifier = GetPlayerIdentifiers(src)[1]
    local PLAYER = GetPlayerId(src)
    if not identifier then return end
    if identifierInput then
        if PLAYER.group == "user" then
            -- banPlayer(src, identifier)
            return
        else
            identifier = identifierInput
            if not PlayerItems[identifier] then
                -- Notify(source, Locales["inventory_not_found"])
                return
            end
        end
    end

    _TriggerClientEvent("gamemode:OpenInventory", src, {
        inventoryInfo = Config.InventoryTypes[inventoryType]
    })
end)

_RegisterServerEvent("gamemode:server:ItemDragToSafe", function(data)
    local src = source 
    local identifier = GetPlayerIdentifiers(src)[1]
    if not identifier then return end
    local bool, removed = RemoveItem(source, 'inventory', data.item, 1)
    if bool then
        AddItem(source, 'protected', data.item, 1)
    end
    _TriggerClientEvent("guild:updateWeight", src)
end)

_RegisterServerEvent("gamemode:server:ItemDragToInventory", function(data)
    local src = source 
    local identifier = GetPlayerIdentifiers(src)[1]
    if not identifier then return end
    local bool, removed = RemoveItem(source, 'protected', data.item, 1)
    if bool then
        AddItem(source, 'inventory', data.item, 1)
    end

    _TriggerClientEvent("guild:updateWeight", src)
end)


_RegisterServerEvent("gamemode:RemoveItem", function(data)
    local src = source
    local identifier = GetPlayerIdentifiers(src)[1]
    if not identifier then return end
    if Config.DeleteBlockedItems[data.itemName] then return end
    local bool, removed = RemoveItem(source, data.fromType, data.itemName, data.count)
end)

_RegisterServerEvent("gamemode:server:GiveItem", function(data)
    local src = source
    local identifier = GetPlayerIdentifiers(src)[1]
    if not identifier then return end
    AddItem(source, data.toType, data.itemName, data.count)
end)

_RegisterServerEvent("gamemode:UpdateHotbar", function(data)
    local src = source
    local identifier = GetPlayerIdentifiers(src)[1]
    if not identifier then return end
    UpdateHotbar(src, identifier, data)
end)

-- Cache pour stocker l'état précédent des inventaires
local InventoryCache = {}

-- Fonction pour vérifier si l'inventaire a changé
local function hasInventoryChanged(identifier, currentData)
    if not InventoryCache[identifier] then return true end
    
    local cache = InventoryCache[identifier]
    return json.encode(currentData.inventory) ~= cache.inventory
        or json.encode(currentData.stash) ~= cache.stash
        or json.encode(currentData.protected) ~= cache.protected
        or json.encode(Hotbars[identifier] or {}) ~= cache.hotbar
end

function SavePlayerInventories(identifier)
    local v = PlayerItems[identifier]
    if not v then 
        print("^1[INVENTORY] Aucune donnée PlayerItems trouvée pour " .. identifier)
        return 
    end

    -- Préparer les données actuelles
    local currentData = {
        inventory = v["inventory"] or {},
        stash = v["stash"] or {},
        protected = v["protected"] or {},
    }

    -- Nettoyer Hotbars
    local hotbar_cleaned = {}
    if Hotbars[identifier] then
        for k, v in pairs(Hotbars[identifier]) do
            if v.name then
                local cleanedItem = {
                    name = v.name,
                    slot = v.slot
                }
                hotbar_cleaned[k] = cleanedItem
            end
        end
    end

    -- Vérifier si les données ont changé
    if not hasInventoryChanged(identifier, currentData) then
        -- print("^5[INVENTORY] Aucun changement détecté pour " .. identifier .. " - sauvegarde ignorée")
        return
    end

    -- Encoder les données une seule fois
    local inventory_json = json.encode(currentData.inventory)
    local stash_json = json.encode(currentData.stash)
    local protected_json = json.encode(currentData.protected)
    local hotbar_json = json.encode(hotbar_cleaned)

    -- Mettre à jour le cache
    InventoryCache[identifier] = {
        inventory = inventory_json,
        stash = stash_json,
        protected = protected_json,
        hotbar = hotbar_json
    }

    -- print("^3[INVENTORY] Sauvegarde en cours pour " .. identifier .. " (inv:" .. #currentData.inventory .. ", safe:" .. #currentData.protected .. ", stash:" .. #currentData.stash .. ")")

    -- Sauvegarder dans la base de données
    MySQL.Async.execute("UPDATE inventory SET inventory = @inventory, stash = @stash, protected = @protected, hotbar = @hotbar WHERE identifier = @identifier", {
        ["@identifier"] = identifier,
        ["@inventory"] = inventory_json,
        ["@stash"] = stash_json,
        ["@protected"] = protected_json,
        ["@hotbar"] = hotbar_json,
    }, function(rowsChanged)
        if rowsChanged == 0 then
            print("^1[INVENTORY] ERREUR: Aucune ligne mise à jour pour " .. identifier .. " - Vérifiez que l'entrée existe dans la DB")
            -- Essayer de créer l'entrée si elle n'existe pas
            MySQL.Async.execute("INSERT INTO inventory (identifier, inventory, stash, protected, hotbar) VALUES (@identifier, @inventory, @stash, @protected, @hotbar)", {
                ["@identifier"] = identifier,
                ["@inventory"] = inventory_json,
                ["@stash"] = stash_json,
                ["@protected"] = protected_json,
                ["@hotbar"] = hotbar_json,
            }, function(insertRows)
                if insertRows > 0 then
                    -- print("^2[INVENTORY] Entrée créée avec succès pour " .. identifier)
                else
                    -- print("^1[INVENTORY] ERREUR: Impossible de créer l'entrée pour " .. identifier)
                end
            end)
        else 
            -- print("^2[INVENTORY] ✓ Sauvegardé avec succès pour " .. identifier)
        end
    end)
end

-- Optimisation de la boucle de sauvegarde
Citizen.CreateThread(function()
    local saveInterval = 1000 * 30  -- Sauvegarde toutes les 10 secondes
    local playersPerBatch = 10      -- Nombre de joueurs par lot (réduit pour moins de charge)
    
    while true do
        local players = {}
        for k in pairs(PlayerItems) do
            table.insert(players, k)
        end
        
        if #players > 0 then
            print("^3[INVENTORY] Début de sauvegarde pour " .. #players .. " joueurs...")
            
            -- Sauvegarder par lots
            for i = 1, #players, playersPerBatch do
                local endIndex = math.min(i + playersPerBatch - 1, #players)
                
                -- Sauvegarder ce lot de joueurs
                for j = i, endIndex do
                    local identifier = players[j]
                    if identifier and PlayerItems[identifier] then
                        SavePlayerInventories(identifier)
                    end
                end
                
                -- Attendre un peu entre chaque lot pour répartir la charge
                if i + playersPerBatch <= #players then
                    Wait(500)
                end
            end
            
            print("^2[INVENTORY] Sauvegarde terminée pour " .. #players .. " joueurs")
        end
        
        Wait(saveInterval)
    end
end)

-- Nettoyer le cache quand un joueur se déconnecte
AddEventHandler("playerDropped", function()
    local identifier = GetPlayerIdentifiers(source)[1]
    if identifier then
        -- print("^3[INVENTORY] Sauvegarde finale pour " .. identifier .. " lors de la déconnexion")
        SavePlayerInventories(identifier)
        Wait(300)
        InventoryCache[identifier] = nil
        PlayerItems[identifier] = nil
        -- print("^2[INVENTORY] Données nettoyées pour " .. identifier)
    end
end)

_AddEventHandler("playerJoining", function()
    local identifier = GetPlayerIdentifiers(source)[1]
    if not identifier then return end
    LoadPlayerItems(source, identifier)
end)

_AddEventHandler("onResourceStart", function()
    Wait(750)
    local players = GetPlayers()
    for i = 1, #players do
        local identifier = GetPlayerIdentifiers(players[i])[1]
        if identifier then
            LoadPlayerItems(players[i], identifier)
        end
    end
end)

CustomVehicles = {}

function LoadVehiclesCustomPlayer(source, identifier)
    MySQL.Async.fetchAll("SELECT * FROM vehicles WHERE identifier = @identifier", {["@identifier"] = identifier}, function(result)
        if result[1] then 
            if not CustomVehicles[identifier] then
                CustomVehicles[identifier] = {}
            end
            
            for k, v in pairs(result) do
                CustomVehicles[identifier][tonumber(v.model)] = {
                    model = v.model,
                    vehicleProps = json.decode(v.vehicleProps)
                }
            end
        end
    end)
end

function GetCustomVehicle(source, model)
    local identifier = GetPlayerIdentifiers(source)[1]
    if identifier and CustomVehicles[identifier] and CustomVehicles[identifier][tonumber(model)] then
        return CustomVehicles[identifier][tonumber(model)]
    end
    return false
end

_AddEventHandler('playerJoining', function()
    local identifier = GetPlayerIdentifiers(source)[1]
    if identifier then
        LoadVehiclesCustomPlayer(source, identifier)
    end
end)

_AddEventHandler("onResourceStart", function()
    Wait(750)
    local players = GetPlayers()
    for i = 1, #players do
        local identifier = GetPlayerIdentifiers(players[i])[1]
        if identifier then
            LoadVehiclesCustomPlayer(players[i], identifier)
        end
    end
end)

CooldownVehicleSpawn = {}

function SetCooldownVehicleSpawn(source)
    CooldownVehicleSpawn[source] = true
    Citizen.SetTimeout(3000, function()
        CooldownVehicleSpawn[source] = nil
    end)
end

function GetCooldownVehicleSpawn(source)
    if not CooldownVehicleSpawn[source] then return false end
    return true
end

_RegisterServerEvent("gamemode:OnItemUsed", function(itemName)
    local info 
    local item = GetItemByName(source, "inventory", itemName)
    local src = source 
    local PLAYER = GetPlayerId(src)

    if item then
        if Items[itemName].useItemInfo then
            if Items[itemName].type == "weapon" then
                info = item.info[math.random(#item.info)]
            else
                info = item.info
            end
        end
        if Items[itemName].type == "vehicle" then 
            local playerInVeh = GetVehiclePedIsIn(GetPlayerPed(src), false)
            if playerInVeh ~= 0 then 
               if itemName ~= "bmx" then 
                    return 
               end
            end
            if GetPlayerPing(source) > 150 then 
                return DoNotif(src, "You can't spawn a vehicle with your current ping.")
            end

                        -- Génère un ID unique pour le véhicule
            ::vehIdLoop::
            local vehId = math.random(100, 50000)
            if (vehList[vehId] and vehIdAlreadySpawned[vehId]) or vehIdAlreadySpawned[vehId] then 
                goto vehIdLoop
            end

            if vehIdAlreadySpawned[vehId] then
                return DoNotif(src, "This vehicle is already spawned.")
            end
            vehIdAlreadySpawned[vehId] = true

            -- Vérifie si le joueur est en cooldown
            if GetCooldownVehicleSpawn(src) then
                return DoNotif(src, "Please wait before spawning another vehicle.")
            end
            
            -- Vérifie si le joueur a un véhicule en cours de création
            if PLAYER.vehicleSpawning then
                return 
            end
            
            -- Active le cooldown
            SetCooldownVehicleSpawn(src)
            
            -- Marquer le joueur comme ayant un véhicule en cours de création
            PLAYER.vehicleSpawning = true
            
            -- Retire l'item AVANT d'envoyer l'événement pour éviter les duplications
            if not RemoveItem(src, "inventory", itemName, 1) then
                PLAYER.vehicleSpawning = false
                return DoNotif(src, "You don't have this vehicle in your inventory.")
            end
            
            
            -- Enregistre immédiatement le véhicule dans la liste des véhicules
            if not vehList then vehList = {} end
            vehList[vehId] = {
                id = vehId,
                model = itemName,
            }
            
            -- Envoi de l'événement avec les données du véhicule
            if GetCustomVehicle(source, GetHashKey(itemName)) then 
                _TriggerClientEvent("vehicle:VehicleUsed", src, itemName, vehId, GetCustomVehicle(source, GetHashKey(itemName)).vehicleProps)
            else 
                _TriggerClientEvent("vehicle:VehicleUsed", src, itemName, vehId, false)
            end
            
            -- Définit un timer pour réinitialiser l'état de création de véhicule après 2 secondes
            Citizen.SetTimeout(5000, function()
                if PLAYER and PLAYER.vehicleSpawning then
                    PLAYER.vehicleSpawning = false
                end
            end)
        end

        if Items[itemName].type == "item" then 
            RemoveItem(src, "inventory", itemName, 1)
        end
        
        _TriggerClientEvent("gamemode:client:OnItemUsed", src, itemName, info)
    end
end)



_RegisterServerEvent("inventory:OpenContainerByStaff", function(idPlayer)
    if GetPlayerId(source).group ~= "user" then 
        local PLAYER_SELEC = GetPlayerId(tonumber(idPlayer))
        local inventory = exports["gamemode"]:GetInventory(PLAYER_SELEC.source, "inventory")

        
        _TriggerClientEvent("inventory:OpenContainerStaff", source, PLAYER_SELEC.inventory, "container-"..PLAYER_SELEC.uuid, "container", inventory)
    end
end)


_RegisterServerEvent("inventory:OpenInventoryByStaff", function(idPlayer)
    if GetPlayerId(source).group ~= "user" then 
        local PLAYER_SELEC = GetPlayerId(tonumber(idPlayer))
        local inventory = exports["gamemode"]:GetInventory(PLAYER_SELEC.source, "inventory")
        local safeinv = exports["gamemode"]:GetInventory(PLAYER_SELEC.source, "protected")
        _TriggerClientEvent("inventory:openInventoryStaff", source,  inventory, safeinv, {
            username = PLAYER_SELEC.username,
            uuid = PLAYER_SELEC.uuid,
            tokens = PLAYER_SELEC.token,
        })
    end

end)

-- Commande pour forcer la sauvegarde d'un joueur
RegisterCommand("force_save_inventory", function(source, args)
    local PLAYER = GetPlayerId(source)
    if PLAYER.group ~= "owner" then return end
    
    local targetId = tonumber(args[1]) or source
    local identifier = GetPlayerIdentifiers(targetId)[1]
    
    if not identifier then
        print("^1[DEBUG] Impossible de récupérer l'identifier pour le joueur " .. targetId)
        return
    end
    
    -- print("^3[DEBUG] Sauvegarde forcée pour " .. identifier)
    -- Forcer la sauvegarde en supprimant le cache
    InventoryCache[identifier] = nil
    SavePlayerInventories(identifier)
end)