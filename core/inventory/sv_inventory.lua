Discord.Register("trade_log", "Trade Log", "logs-trade");


_RegisterServerEvent("inventory:GiveItemToPlayer", function(data)
    local giver = source 
    local receiver = data.playerId
    local item = data.item
    local count = data.count
    
    -- Check if either player is in FFA mode
    local giverFFA = GetFFAPlayer(giver)
    local receiverFFA = GetFFAPlayer(receiver)
    
    if giverFFA or receiverFFA then
        -- Disable item transfer when in FFA mode
        DoNotif(giver, "~r~Item transfer disabled while in FFA mode")
        return
    end
    
    local giverInventory = exports["gamemode"]:GetInventory(giver, "inventory")
    local receiverInventory = exports["gamemode"]:GetInventory(receiver, "inventory")
    if giverInventory and receiverInventory then 
        if exports["gamemode"]:HasItem(giver, "inventory", item, count) then 
            if exports["gamemode"]:RemoveItem(giver, "inventory", item, count) then 
                exports["gamemode"]:AddItem(receiver, "inventory", item, count, nil, true)
                _TriggerClientEvent("updatedInv", receiver)
                _TriggerClientEvent("updatedInv", giver)
                DoNotif(receiver, "You received ~r~"..count.."x ~g~"..Items[item].label.." ~s~by ~r~"..GetPlayerId(giver).username)
                local message = DiscordMessage(); 
                local returnMessage = ""

                local giverMessage = "" 
                local receiverMessage = ""
                if DiscordId(giver) then  
                    giverMessage = GetPlayerId(giver).username.." ("..GetPlayerId(giver).uuid..") | Discord ID: <@"..DiscordId(giver)..">"
                else
                    giverMessage = GetPlayerId(giver).username.." ("..GetPlayerId(giver).uuid..")"
                end
                if DiscordId(receiver) then  
                    receiverMessage = GetPlayerId(receiver).username.." ("..GetPlayerId(receiver).uuid..") | Discord ID: <@"..DiscordId(receiver)..">"
                else
                    receiverMessage = GetPlayerId(receiver).username.." ("..GetPlayerId(receiver).uuid..")"
                end
                message:AddField()
                    :SetName("Giver")
                    :SetValue(giverMessage);
                message:AddField()
                    :SetName("Receiver")
                    :SetValue(receiverMessage);
                message:AddField()
                    :SetName("Item")
                    :SetValue("`"..Items[item].label.." "..count.."x`");
                Discord.Send("trade_log", message); 
            end
        end
    end
end)

_RegisterServerEvent("gamemode:server:deleteItem", function(data)
    local src = source
    local item = data.item
    local inventory = exports["gamemode"]:HasItem(src, "inventory", item, 1)
    if inventory then
        exports["gamemode"]:RemoveItem(src, "inventory", item, 1)
        _TriggerClientEvent("updatedInv", src)
    end
end)