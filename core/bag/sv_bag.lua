Discord.Register("bag_log", "Bag Log", "logs-bag")
Discord.Register("bag_loot_take", "Bag Loot Take", "logs-takebag")
ListBags = {}

function GenerateIdBags()
    local id = math.random(0, 10000)
    if ListBags["bags-"..id] ~= nil then 
        id = math.random(0, 10000)
    end
    return "bags-"..id
end

local legendaryItems = {
    ["weapon_heavysniper"] = true,
    ["weapon_heavysniper_mk2"] = true,
    ["weapon_hominglauncher"] = true,
    ["weapon_rpg"] = true,
    ["weapon_marksmanrifle_mk2"] = true,
    ["weapon_marksmanrifle"] = true,
    ["weapon_compactlauncher"] = true,
    ["weapon_sniperrifle"] = true,

    -- vehicles
    ["deluxo"] = true,
    ["oppressor"] = true,
    ["scarab"] = true,
    ["nightshark"] = true,
    ["dukes2"] = true,
    ["oppressor2"] = true,
    ["weapon_precisionrifle"] = true,

}

_RegisterServerEvent("gamemode:createBags", function(coords)
    local src = source 
    local idBags = GenerateIdBags()
    local myInventory = exports["gamemode"]:GetInventory(src, "inventory")
    local isLegendary = false


    local inBags = {}
    
    for k, v in pairs(myInventory) do
        if legendaryItems[v.name] then 
            isLegendary = true
        end
        table.insert(inBags, v)
    end

    ListBags[idBags] = {
        id = idBags,
        inventory = inBags,
        username = GetPlayerName(src),
        uuid = GetPlayerId(src).uuid,
        deadId = source,
        deadName = GetPlayerName(source),
    }

    ClearInventory(src, "inventory")
    local message = DiscordMessage(); 
    local returnMessage = ""
    if DiscordId(src) then 
        local PLAYER_DATA <const> = GetPlayerId(src)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..") | Discord ID: <@"..DiscordId(src)..">"
    else
        local PLAYER_DATA <const> = GetPlayerId(src)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..")"
    end
    message:AddField()
        :SetName("Bags created")
        :SetValue(returnMessage);
    message:AddField()
        :SetName("Legendary")
        :SetValue(isLegendary);
    message:AddField()
        :SetName("Items")
        :SetValue(json.encode(inBags));
    message:AddField()
        :SetName("ID BAGS")
        :SetValue(idBags);
    message:AddField()
    Discord.Send("bag_log", message);
    _TriggerClientEvent("gamemode:createBags", -1, coords, idBags, isLegendary)
end)

_RegisterServerEvent("gamemode:DeleteBags", function(id)
    ListBags[id] = nil
    _TriggerClientEvent("gamemode:DeleteProp", -1, id)
end)    


_RegisterServerEvent("gamemode:LootBagInterface", function(bagId)
    if ListBags[bagId] == nil then return end
    local bagsInventory = ListBags[bagId].inventory
    if ListBags[bagId].looted then DoNotif(source, "~r~This bag has already been looted") return end
    _TriggerClientEvent("inventory:OpenContainer", source, bagsInventory, bagId, "bags")
end)


_RegisterServerEvent("gamemode:LootBag", function(bagId)
    if ListBags[bagId] == nil then return end
    local src = source
    local player = GetPlayerId(src)
    if not player then return end
    if ListBags[bagId].looted then DoNotif(src, "~r~This bag has already been looted") return end
    local returnItemList = ""
    for k, v in pairs(ListBags[bagId].inventory) do 
        exports["gamemode"]:AddItem(src, "inventory", v.name, v.count, nil, true)
        DoNotif(src, "You loot ~g~"..Items[v.name].label.." "..v.count.."x")
        returnItemList = returnItemList..Items[v.name].label.." "..v.count.."x, "
        _TriggerClientEvent("updatedInv", src)
        _TriggerClientEvent("guild:updateWeight", src)
    end
    ListBags[bagId].looted = true


    DoNotif(source, "You looted the ~r~"..ListBags[bagId].deadName.."'s ["..ListBags[bagId].uuid.."] ~s~death bag.")
    DoNotif(ListBags[bagId].deadId, "Your bag has been looted by ~r~"..player.username.." ["..player.uuid.."]")

    local message = DiscordMessage(); 
    local returnMessage = ""
    if DiscordId(src) then 
        local PLAYER_DATA <const> = GetPlayerId(src)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..") | Discord ID: <@"..DiscordId(src)..">"
    else
        local PLAYER_DATA <const> = GetPlayerId(src)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..")"
    end
    message:AddField()
        :SetName("Bags created")
        :SetValue(returnMessage);
    message:AddField()
        :SetName("Legendary")
        :SetValue(isLegendary);
    message:AddField()
        :SetName("Items")
        :SetValue(returnItemList);
    message:AddField()
        :SetName("ID BAGS")
        :SetValue(bagId);
    message:AddField()
    Discord.Send("bag_log", message);

    _TriggerClientEvent("gamemode:DeleteProp", -1, bagId)
    ListBags[bagId] = nil
end)

_RegisterServerEvent("gamemode:TakeItemsFromBag", function(bagId, item)
    if ListBags[bagId] == nil then return end

    local src = source
    local player = GetPlayerId(src)
    if not player then return end
    if ListBags[bagId].looted then DoNotif(src, "~r~This bag has already been looted") return end

    if RemoveBagsItem(bagId, item, 1) then
        AddItem(src, "inventory", item, 1)
        _TriggerClientEvent("guild:updateWeight", src)
        _TriggerClientEvent("ShowAboveRadarMessage", src, "You loot ~g~1x ~r~"..Items[item].label)
        local message = DiscordMessage(); 
        local returnMessage = ""
        if DiscordId(src) then 
            local PLAYER_DATA <const> = GetPlayerId(src)
            returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..") | Discord ID: <@"..DiscordId(src)..">"
        else
            local PLAYER_DATA <const> = GetPlayerId(src)
            returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..")"
        end
        message:AddField()
            :SetName("Username")
            :SetValue(returnMessage);
        message:AddField()
            :SetName("Bag ID")
            :SetValue(bagId);
        message:AddField()
            :SetName("Item Taked")
            :SetValue(Items[item].label);
        Discord.Send("bag_loot_take", message);

        if (#ListBags[bagId].inventory <= 0) then 
            ListBags[bagId].looted = true
            DoNotif(ListBags[bagId].deadId, "Your bag has been looted by ~r~"..player.username.." ["..player.uuid.."]")
            ListBags[bagId] = nil
            _TriggerClientEvent("gamemode:DeleteProp", -1, bagId)
        end

    end
end)

_RegisterServerEvent("gamemode:TakeItemFromInvForBag", function(bagId, item)
    if ListBags[bagId] == nil then return end
    local src = source
    local myInventory = exports["gamemode"]:GetInventory(src, "inventory")


    for k, v in pairs(myInventory) do 
        if v.name == item then 
            if RemoveItem(src, "inventory", item, 1) then
                if AddItemsBag(bagId, item, 1) then 
                    _TriggerClientEvent("guild:updateWeight", src)
                end
            end
        end
    end
end)

function RemoveBagsItem(bagId, item, count)
    if ListBags[bagId] == nil then return end
    local bagsInventory = ListBags[bagId].inventory

    for i = #bagsInventory, 1, -1 do
        local v = bagsInventory[i]
        if v.name == item then 
            if v.count > count then
                v.count = v.count - count
                return true
            else
                table.remove(bagsInventory, i)
                return true
            end
        end
    end
end

function AddItemsBag(bagId, item, count)
    if ListBags[bagId] == nil then return end
    local bagsInventory = ListBags[bagId].inventory

    for i = #bagsInventory, 1, -1 do
        local v = bagsInventory[i]
        if v.name == item then 
            v.count = v.count + count
            return true
        end
    end
    table.insert(bagsInventory, {name = item, count = count})
    return true
end