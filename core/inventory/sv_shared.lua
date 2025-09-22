function CreateNewPlayerInventory(source, identifier)


    MySQL.Async.execute("INSERT INTO inventory (identifier, inventory, stash, protected, hotbar) VALUES (@identifier, @inventory, @stash, @protected, @hotbar)", {
        ["@identifier"] = identifier,
        ["@inventory"] = json.encode({}),
        ["@stash"] = json.encode({}),
        ["@protected"] = json.encode({}),
        ["@hotbar"] = json.encode({}),
    }, function(rowsChanged)
        if rowsChanged > 0 then 
            PlayerItems[identifier] = {
                ["inventory"] = {},
                ["stash"] = {},
                ["protected"] = {},
            }
            Hotbars[identifier] = {}
            Wait(1000)
            LoadPlayerItems(source, identifier)
        end
    end)
end

-- La fonction SavePlayerInventories a été déplacée vers sv_events.lua pour éviter les conflits
-- et utiliser la version optimisée avec cache