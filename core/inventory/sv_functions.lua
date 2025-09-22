function LoadPlayerItems(source, identifier)


    MySQL.Async.fetchAll("SELECT * FROM inventory WHERE identifier = @identifier", {["@identifier"] = identifier}, function(result)
        if result[1] then 
            PlayerItems[identifier] = {}
            for k,v in pairs(result[1]) do
                if Config.InventoryTypes[k] then
                    PlayerItems[identifier][k] = json.decode(v)
                
                end
            end
            Hotbars[identifier] = json.decode(result[1].hotbar)
            for k, v in pairs(Hotbars[identifier]) do
                v.hasItem = GetItemByName(source, "inventory", v.name) ~= false
            end
            _TriggerClientEvent("gamemode:UpdateInventory", source, PlayerItems[identifier])
            _TriggerClientEvent("gamemode:SetHotbar", source, Hotbars[identifier])
        else
            CreateNewPlayerInventory(source, identifier)
        end
    end)
end

function GetInventoryWeight(source, inventoryType)
    local identifier = GetPlayerIdentifiers(source)[1]
    if not identifier then return end
    local totalWeight = 0
    if PlayerItems[identifier] and PlayerItems[identifier][inventoryType] then
        for k,v in pairs(PlayerItems[identifier][inventoryType]) do
            totalWeight = totalWeight + (v.count * Items[v.name].weight)
        end
    end
    return totalWeight
end

function HasItem(source, inventoryType, itemName, itemCount)
    local identifier = GetPlayerIdentifiers(source)[1]
    if not identifier then return end
    if PlayerItems[identifier] and PlayerItems[identifier][inventoryType] then
        local item = GetItemByName(source, inventoryType, itemName)
        local index = GetItemByName(source, inventoryType, itemName)
        if itemCount then
            if item ~= false then 
                local good = item.count >= itemCount
                return good
            else
                return false 
            end
        else
            return item
        end
    else 
        return false
    end
end

function GetItemByName(source, inventoryType, itemName)
    local identifier = GetPlayerIdentifiers(source)[1]
    if not identifier then return false end
    if PlayerItems[identifier] and PlayerItems[identifier][inventoryType] then
        for i = 1, #PlayerItems[identifier][inventoryType] do
            if PlayerItems[identifier][inventoryType][i].name == itemName then
                return PlayerItems[identifier][inventoryType][i], i
            end
        end
    end
    return false
end

function GetItemByNameUUID(uuid, inventoryType, itemName)
    local uuidData = SearchUuidInDatabase(uuid)
    if not uuidData then return false end
    local identifier = uuidData.license
    if not identifier then return false end
    if PlayerItems[identifier] and PlayerItems[identifier][inventoryType] then
        for i = 1, #PlayerItems[identifier][inventoryType] do
            if PlayerItems[identifier][inventoryType][i].name == itemName then
                return PlayerItems[identifier][inventoryType][i], i
            end
        end
    end
    return false
end

function UpdateHotbar(source, identifier, data, hasItem)
    if data.id == nil and data.itemName then
        for k,v in pairs(Hotbars[identifier]) do
            if v.name == data.itemName then
                if data.type == "remove" then
                    table.remove(Hotbars[identifier], k)
                elseif data.type == "hasItem" then
                    Hotbars[identifier][k]["hasItem"] = data.value
                else
                    Hotbars[identifier][k] = data.value
                end
                _TriggerClientEvent("gamemode:SetHotbar", source, Hotbars[identifier][k], k)
            end
        end
    else
        Hotbars[identifier][data.id] = data.itemName == false and nil or {
            name = data.itemName,
            hasItem = hasItem or GetItemByName(source, "inventory", data.itemName) ~= false
        }    
        _TriggerClientEvent("gamemode:SetHotbar", source, Hotbars[identifier][data.id], data.id)
    end
end

function CanStackItem(source, invType, itemData)
    local player = GetPlayerId(source)
    if not player then return true end
    local currentWeight = GetInventoryWeight(source, invType)

    if invType == "inventory" then 
        maxWeight = player.maxWeight 
    elseif invType == "protected" then 
        maxWeight = player.maxSafeWeight 
    else 
        maxWeight = Config.InventoryTypes[invType].maxWeight 
    end



    return (currentWeight + (itemData.count * Items[itemData.name].weight)) <= maxWeight
end

function AddItem(source, inventoryType, itemName, itemCount, info, forceAdd)
    local infoTypes = {
        ["weapon"] = {ammo=0}
    }
    local identifier = GetPlayerIdentifiers(source)[1]
    if not identifier then return false end
    if not Items[itemName] then return false end


    if not forceAdd and not CanStackItem(source, inventoryType, { name = itemName, count = itemCount, info = info }) then
        _TriggerClientEvent("ShowAboveRadarMessage", source, "~r~You don't have enough space to carry this item.")
        return false
    end

    local itemData, index = GetItemByName(source, inventoryType, itemName)
    if itemData then
        PlayerItems[identifier][inventoryType][index].count = PlayerItems[identifier][inventoryType][index].count + itemCount
        if Items[itemName].useItemInfo then
            for i = 1, itemCount do
                table.insert(PlayerItems[identifier][inventoryType][index].info, info ~= nil and info[i] or infoTypes[Items[itemName].type])
            end
            _TriggerClientEvent("gamemode:UpdateInventory", source, PlayerItems[identifier][inventoryType][index].info, inventoryType, index, "info")
        end
        _TriggerClientEvent("gamemode:UpdateInventory", source, PlayerItems[identifier][inventoryType][index].count, inventoryType, index, "count")
    else
        local infoData = {}
        if Items[itemName].useItemInfo then
            if info then
                infoData = info
            else
                for i = 1, itemCount do
                    table.insert(infoData, infoTypes[Items[itemName].type])
                end
            end
        else
            infoData = nil
        end
        table.insert(PlayerItems[identifier][inventoryType], {
            name = itemName,
            count = itemCount,
            info = infoData
        })
        if inventoryType == "inventory" then
            UpdateHotbar(source, identifier, {itemName = itemName, type = "hasItem", value = true}, false)
        end
        _TriggerClientEvent("gamemode:UpdateInventory", source, PlayerItems[identifier][inventoryType][#PlayerItems[identifier][inventoryType]], inventoryType, #PlayerItems[identifier][inventoryType])
    end

    _TriggerClientEvent("guild:updateWeight", source)


    return true
end

function RefreshInventory(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    if not identifier then return end
    _TriggerClientEvent("gamemode:UpdateInventory", source, PlayerItems[identifier]["protected"], "protected")
end

RegisterCommand("additem", function(source, args)
    local count = 1 
    if not tonumber(args[4]) then  
        count = 1 
    else 
        count = tonumber(args[4]) 
    end
    local PLAYER = GetPlayerId(source)
    if PLAYER.group == "owner" then 
        local target, inventoryType, itemName, itemCount = tonumber(args[1]), args[2], args[3], count
        AddItem(target, inventoryType, itemName, itemCount, nil, true)
    end
end)

RegisterCommand("clearinv", function(source, args)
    local PLAYER = GetPlayerId(source)
    if PLAYER.group == "owner" then 
        local target, inventoryType = tonumber(args[1]), args[2]
        ClearInventory(target, inventoryType)
    end
end)

function RemoveItem(source, inventoryType, itemName, itemCount)
    local identifier = GetPlayerIdentifiers(source)[1]
    if not identifier then return false end
    local removedInfo = {}
    local itemData, index = GetItemByName(source, inventoryType, itemName)
    if itemData then
        if Items[itemName].useItemInfo then
            for i = PlayerItems[identifier][inventoryType][index].count, (PlayerItems[identifier][inventoryType][index].count - itemCount + 1), -1 do
                table.insert(removedInfo, PlayerItems[identifier][inventoryType][index].info[i])
                table.remove(PlayerItems[identifier][inventoryType][index].info, i)
            end
            _TriggerClientEvent("gamemode:UpdateInventory", source, PlayerItems[identifier][inventoryType][index].info, inventoryType, index, "info")
        end
        if itemCount > PlayerItems[identifier][inventoryType][index].count then
            itemCount = PlayerItems[identifier][inventoryType][index].count
        end
        PlayerItems[identifier][inventoryType][index].count = PlayerItems[identifier][inventoryType][index].count - itemCount
        if PlayerItems[identifier][inventoryType][index].count == 0 then
            table.remove(PlayerItems[identifier][inventoryType], index)
            if inventoryType == "inventory" then
                UpdateHotbar(source, identifier, {itemName = itemName, type = "hasItem", value = false}, false)
                if Items[itemName].type == "weapon" then
                    _TriggerClientEvent("gamemode:client:RemoveWeapon", source, itemName)
                end
                if Items[itemName].type == "vehicle" then 
                end
            end
            _TriggerClientEvent("gamemode:UpdateInventory", source, nil, inventoryType, index)
        else
            _TriggerClientEvent("gamemode:UpdateInventory", source, PlayerItems[identifier][inventoryType][index].count, inventoryType, index, "count")
        end

        _TriggerClientEvent("guild:updateWeight", source)

        return true, removedInfo
    end
    _TriggerClientEvent("guild:updateWeight", source)

    return false
end

function GetInventory(source, inventoryType)
    inventoryType = inventoryType == nil and "inventory" or inventoryType
    local identifier = GetPlayerIdentifiers(source)[1]
    if not identifier then return end
    return PlayerItems[identifier] and PlayerItems[identifier][inventoryType]
end

function ClearInventory(source, inventoryType)
    inventoryType = inventoryType == nil and "inventory" or inventoryType
    local identifier = GetPlayerIdentifiers(source)[1]
    if not identifier then return end
    PlayerItems[identifier][inventoryType] = {}
    for k, v in pairs(Hotbars[identifier]) do
        v.hasItem = false
    end
    _TriggerClientEvent("gamemode:UpdateInventory", source, {}, "inventory")
    _TriggerClientEvent("gamemode:SetHotbar", source, Hotbars[identifier])
end

function CreateId()
    local id = math.random(999999)
    if CommonInventories[id] then
        Citizen.Wait(1)
        CreateId()
    else
        return id
    end
end

RegisterCallback("GetListPlayers", function(source)
    local players = PlayersListSafeMode
    return players
end)
