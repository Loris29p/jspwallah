BoxData = {}

_RegisterServerEvent("event-manager:GetEventBox", function()
    if BoxData and #BoxData > 0 then 
        _TriggerClientEvent('event-manager:createBox', source, "init", BoxData)
    end
end)

_RegisterServerEvent('event-manager:TakeBox', function(id)
    if BoxData[id] then 
        if BoxData[id].taked then return DoNotif(source, "~r~This box has already been taken") end
        BoxData[id].taked = true
        local coords = BoxData[id].coords 
        local player = source
        local ped = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(ped)
        if (#(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(coords.x, coords.y, coords.z)) < 2.0) then 
            local itemsList = BoxData[id].items
            for k, v in pairs(itemsList) do 
                exports["gamemode"]:AddItem(source, "inventory", v.name, v.amount, nil, true)

                DoNotif(source, "You received ~g~" .. v.amount .. "x ~r~" .. Items[v.name].label)
            end
            _TriggerClientEvent('event-manager:deleteBox', -1, id)

            TriggerClientEvent('chat:addMessage', -1, { 
                template = '<div style="padding: 0.2vw; margin: 0.2vw; background-color: rgba(81, 81, 81, 0.6); border-radius: 3px;"><i class="fas fa-user-crown"></i> {0} </div>',
                args = { "^#ff7bc4GIFT BOX: ^7The Box ^#ff7bc4"..id.." ^7has been taken by ^#ff7bc4"..GetPlayerId(player).username}, color = { 255, 123, 196  } 
            })
            BoxData[id] = nil
        end
    end
end)

function CreateEventBox(tblData)
    for k, v in pairs(tblData) do 
        BoxData[v.id] = {
            id = v.id,
            coords = v.coords,
            model = v.model,
            items = v.items,
        }
    end

    local timer = 1000*60*2
    Citizen.CreateThread(function()
        while #BoxData > 0 do 
            Wait(timer)
            for k, v in pairs(BoxData) do 
                BoxData[k] = nil
                _TriggerClientEvent('event-manager:deleteBox', -1, k)
            end
            _TriggerClientEvent("event-manager:createBox", -1, "delete")
        end
    end)
    _TriggerClientEvent('event-manager:createBox', -1, "init", BoxData)
end

local tableRandomItems = {
    {name = "weapon_rpg", amount = 1},
    {name = "weapon_marksmanrifle", amount = 1},
    {name = "weapon_marksmanrifle_mk2", amount = 1},
    {name = "deluxo", amount = 1},
    {name = "oppressor", amount = 1},
}

function CreateRandomEventBoxes(count)
    -- Tableau pour stocker les indices déjà sélectionnés
    local selectedIndices = {}
    local boxesData = {}
    
    for i = 1, count do
        local randomIndex
        local attempts = 0
        local maxAttempts = 50 -- Pour éviter une boucle infinie si count > nombre de positions disponibles
        
        -- Trouve un index qui n'a pas encore été utilisé
        repeat
            randomIndex = math.random(1, #EventManager.ListPositionBox)
            attempts = attempts + 1
        until (not selectedIndices[randomIndex] or attempts >= maxAttempts)
        
        -- Marque cet index comme utilisé
        selectedIndices[randomIndex] = true
        
        -- Sélectionne 2 items aléatoires de la table tableRandomItems
        local randomItems = {}
        for j = 1, 1 do
            local randomItemIndex = math.random(1, #tableRandomItems)
            table.insert(randomItems, tableRandomItems[randomItemIndex])
        end
        
        -- Ajoute la boîte avec la position aléatoire
        table.insert(boxesData, {
            id = i,
            coords = EventManager.ListPositionBox[randomIndex],
            model = "ba_prop_battle_crate_m_jewellery",
            items = randomItems,
        })
    end
    
    -- Crée les boîtes avec les données générées
    CreateEventBox(boxesData)
    return boxesData
end

_RegisterServerEvent('eventmanger:CreateEventBox', function(count)
    local PLAYER_DATA <const> = GetPlayerId(source)
    if #PlayersListSafeMode <= 30 then return DoNotif(source, "~r~This event require more than 30 players ("..#PlayersListSafeMode.."/30)") end
    if (PLAYER_DATA.role == "vip" or PLAYER_DATA.role == "vip+" or PLAYER_DATA.role == "mvp" or PLAYER_DATA.role == "boss") or PLAYER_DATA.group ~= "user" then 
        -- Si count n'est pas spécifié, utiliser 3 par défaut
        count = count or 3
        -- S'assurer que count est un nombre entre 1 et 10
        count = math.min(math.max(count, 1), 10)
        
        CreateRandomEventBoxes(count)
    end
end)