function GetStashItemInfo(source, item)
    local PLAYER = GetPlayerId(source)
    if PLAYER then 
    end
    local Stash = PLAYER.inventory
    for k, v in pairs(Stash) do 
        if v.name == item then
            return v, k
        end
    end
    return false, nil
end

function AddItemStash(source, item, count)
    local itemInfo, index = GetStashItemInfo(source, item)
    if itemInfo then
        itemInfo.count = itemInfo.count + count
        _TriggerClientEvent("gamemode:UpdateStash", source, itemInfo, index, "count")
        return true
    else
        local PLAYER = GetPlayerId(source)
        table.insert(PLAYER.inventory, {name = item, count = count})
        _TriggerClientEvent("gamemode:UpdateStash", source, PLAYER.inventory, nil)
        return true
    end
    return false
end

function RemoveItemStash(source, item, count)
    local itemInfo, index = GetStashItemInfo(source, item)
    if itemInfo then
        itemInfo.count = itemInfo.count - count
        _TriggerClientEvent("gamemode:UpdateStash", source, itemInfo, index, "count")
        if itemInfo.count <= 0 then
            local PLAYER = GetPlayerId(source)
            table.remove(PLAYER.inventory, index)
            _TriggerClientEvent("gamemode:UpdateStash", source, PLAYER.inventory, nil)
        end
        return true
    end
    return false
end

_RegisterServerEvent("gamemode:OpenStash", function()
    local PLAYER = GetPlayerId(source)

    _TriggerClientEvent("inventory:OpenContainer", source, PLAYER.inventory, "container-"..PLAYER.uuid, "container")
end)

_RegisterServerEvent("gamemode:TakeItemFromInvForStash", function(item)
    local src = source 
    local myInventory = exports["gamemode"]:GetInventory(src, "inventory")

    for k, v in pairs(myInventory) do 
        if v.name == item then 
            if RemoveItem(src, "inventory", item, 1) then
                if AddItemStash(src, item, 1) then 
                    -- print("GOOD ADD STASH")
                    _TriggerClientEvent("guild:updateWeight", src)
                end
            end
        end
    end
end)

_RegisterServerEvent("gamemode:TakeItemsFromStash", function(item)
    local src = source
    if RemoveItemStash(src, item, 1) then
        AddItem(src, "inventory", item, 1)
        _TriggerClientEvent("guild:updateWeight", src)
        _TriggerClientEvent("ShowAboveRadarMessage", src, "You took ~g~1x ~s~"..Items[item].label)
    end
end)