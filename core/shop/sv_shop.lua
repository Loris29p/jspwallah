Discord.Register("buy_item", "Buy Item", "logs-buy");
Discord.Register("sell_item", "Sell Item", "logs-sell");

HeavyWeapon = {}


function IsHeavyWeapon(items, src)
    local PLAYER = GetPlayerId(src)
    if HeavyWeapon[PLAYER.uuid] then
        for k, v in pairs(HeavyWeapon[PLAYER.uuid]) do
            if v == items then
                return true
            end
        end
    end
    return false
end

function AddHeavyWeapon(items, src)
    local PLAYER = GetPlayerId(src)
    if not HeavyWeapon[PLAYER.uuid] then
        HeavyWeapon[PLAYER.uuid] = {}
    end
    table.insert(HeavyWeapon[PLAYER.uuid], items)
end

Citizen.CreateThread(function()
    while true do 
        Wait(1000*60*60)
        for k, v in pairs(HeavyWeapon) do
            HeavyWeapon[k] = nil
        end 
    end
end)

_RegisterServerEvent("shop:buyItems", function(items, price, shift)
    local src = source


    local PLAYER = GetPlayerId(src)
    if IsHeavyWeapon(items, source) then
        PLAYER.sendTrigger("ShowAboveRadarMessage", "~r~You can buy this item 1x per hour.")
        return
    end
    if items == "weapon_heavysniper" or items == "weapon_heavysniper_mk2" or items == "weapon_marksmanrifle_mk2" or items == "weapon_marksmanrifle" or items == "weapon_compactlauncher" or items == "weapon_sniperrifle" then
        AddHeavyWeapon(items, source)
    end

    if not shift then 
        if PLAYER.RemoveTokens(Items[items].price) then 
            if AddItem(src, "protected", items, 1, nil, true) then 
                PLAYER.sendTrigger("ShowAboveRadarMessage", ("You bought ~g~1x ~s~%s"):format(Items[items].label))
                local message = DiscordMessage(); 
                local returnMessage = ""
                if DiscordId(src) then 
                    returnMessage = PLAYER.username.." ("..PLAYER.uuid..") | Discord ID: <@"..DiscordId(src)..">"
                else
                    returnMessage = PLAYER.username.." ("..PLAYER.uuid..")"
                end
                message:AddField()
                    :SetName("Player")
                    :SetValue(returnMessage);
                message:AddField()
                    :SetName("Item")
                    :SetValue(Items[items].label);  
                message:AddField()
                    :SetName("Price")
                    :SetValue(Items[items].price);
                message:AddField()
                    :SetName("Count")
                    :SetValue(1);
                Discord.Send("buy_item", message);
            end
        else 
            PLAYER.sendTrigger("ShowAboveRadarMessage", "~r~You don't have enough money.")
        end
    else
        if PLAYER.RemoveTokens((Items[items].price*5)) then 
            if AddItem(src, "protected", items, 5, nil, true) then 
                PLAYER.sendTrigger("ShowAboveRadarMessage", ("You bought ~g~5x ~s~%s"):format(Items[items].label))
                local message = DiscordMessage(); 
                local returnMessage = ""
                if DiscordId(src) then 
                    returnMessage = PLAYER.username.." ("..PLAYER.uuid..") | Discord ID: <@"..DiscordId(src)..">"
                else
                    returnMessage = PLAYER.username.." ("..PLAYER.uuid..")"
                end
                message:AddField()
                    :SetName("Player")
                    :SetValue(returnMessage);
                message:AddField()
                    :SetName("Item")
                    :SetValue(Items[items].label);  
                message:AddField()
                    :SetName("Price")
                    :SetValue((Items[items].price*5));
                message:AddField()
                    :SetName("Count")
                    :SetValue(5);
                Discord.Send("buy_item", message);
            end
        else 
            PLAYER.sendTrigger("ShowAboveRadarMessage", "~r~You don't have enough money.")
        end
    end
end)

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
    ["vigilante"] = true,
    ["weapon_musket"] = true,
}


_RegisterServerEvent("shop:SellAll", function()
    local src = source
    local PLAYER = GetPlayerId(src)
    local myInventory = exports["gamemode"]:GetInventory(src, "inventory")
    
    local totalMoney = 0
    local totalItemsSold = 0
    local totalItemCount = 0
    
    if not myInventory or next(myInventory) == nil then
        PLAYER.sendTrigger("ShowAboveRadarMessage", "~r~Your inventory is empty.")
        return
    end

    local listItemsSell = {}
    
    for k, v in pairs(myInventory) do
        if v and v.name and v.count and v.count > 0 then
            if RemoveItem(src, "inventory", v.name, v.count) then
                local sell_price = 0
                if Items and Items[v.name] then
                    if Items[v.name].sell_price then
                        sell_price = Items[v.name].sell_price * v.count
                    elseif Items[v.name].price then
                        sell_price = (Items[v.name].price * v.count) * 0.8
                    end
                end
                
                if sell_price > 0 then
                    sell_price = math.floor(sell_price)
                    PLAYER.AddTokens(sell_price)
                    totalMoney = totalMoney + sell_price
                    totalItemsSold = totalItemsSold + 1
                    totalItemCount = totalItemCount + v.count
                    local message = DiscordMessage(); 
                    local returnMessage = ""
                    if DiscordId(src) then 
                        returnMessage = PLAYER.username.." ("..PLAYER.uuid..") | Discord ID: <@"..DiscordId(src)..">"
                    else
                        returnMessage = PLAYER.username.." ("..PLAYER.uuid..")"
                    end
                    message:AddField()
                        :SetName("Player")
                        :SetValue(returnMessage);
                    message:AddField()
                        :SetName("Item")
                        :SetValue(Items[v.name].label.. " ("..v.count.."x) "..sell_price.."$");
                    Discord.Send("sell_item", message);  
                    table.insert(listItemsSell, v.label)
                end
            end
        end
    end
    
    if totalItemsSold > 0 then 
        PLAYER.sendTrigger("ShowAboveRadarMessage", ("You sold ~b~%s ~s~different items (~b~%s ~s~total) for ~g~%s ~s~tokens."):format(totalItemsSold, totalItemCount, totalMoney))
    else
        PLAYER.sendTrigger("ShowAboveRadarMessage", "~r~No items could be sold.")
    end
end)


RegisterCallback('BuyOthersItem', function(source, tblData)
    if tblData.item == "Kill Effect" then 
        itemName = "kill_effect1month"
    elseif tblData.item == "Ped Access" then 
        itemName = "ped_access1month"
    elseif tblData.item == "Unban League" then 
        itemName = "unban_league"
    end
    local itemPrice = 0
    if tblData.item == "Unban League" then 
        itemPrice = 500 
    else 
        itemPrice = tonumber(Items[itemName].price_coins)
    end
    local PLAYER = GetPlayerId(source)
    if PLAYER.GetCoins() >= itemPrice then  
        if itemName == "kill_effect1month" then 
            if exports["gamemode"]:AddItem(source, "inventory", "kill_effect1month", 1, nil, true) then 
                PLAYER.RemoveCoins(itemPrice)
            end
        elseif itemName == "ped_access1month" then
            if exports["gamemode"]:AddItem(source, "inventory", "ped_access1month", 1, nil, true) then 
                PLAYER.RemoveCoins(itemPrice)
            end
        elseif itemName == "unban_league" then 
            if RemoveUnbanLeague(source) then 
                PLAYER.RemoveCoins(itemPrice)
            end
        end
        return true, PLAYER.GetCoins()
    else
        DoNotif(source, "~r~You don't have enough coins to buy this item")
        return false
    end
    return false
end)