AirdropData = {}

_RegisterNetEvent("gamemode:updateDrop", function(value, index, key, dropId)
    if index then
        if key then
            if not AirdropData[index] then
                AirdropData[index] = {}
            end
            AirdropData[index][key] = value
        else
            if value == nil then
                table.remove(AirdropData, index)
            else
                AirdropData[index] = value
            end
        end
    else
        AirdropData = value
    end

    local myInventory = FormatItems(PlayerItems["inventory"])
    local containerinv = FormatDrop(AirdropData)

    if inDropInventory then
        SendNUIMessage({
            type = "side",
            bool = true,
            inventory = myInventory,
            baginventory = containerinv,
            id = dropId,
        })
    end
end)

function FormatDrop(inventory, key)
    local returnTable = {}
    local totalWeight = 0
    if inventory ~= nil then
        for k, v in pairs(inventory) do
            if v ~= nil then
                local itemData = Items[v.name]
                if itemData then
                    v.image = itemData.image
                    v.label = itemData.label
                    v.rarity = itemData.rarity
                    v.type = itemData.type
                    v.weight = itemData.weight
                    totalWeight = totalWeight + (v.count * v.weight)
                end
            end
        end
    end
    return inventory, totalWeight
end