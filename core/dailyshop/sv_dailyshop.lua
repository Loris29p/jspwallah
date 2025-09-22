function CreateShopDay()
    local newShop = {}

    newShop.List = {}
    newShop.expired = os.date("%d/%m/%Y %H:%M:%S", os.time() + 86400)


    -- Get all available packs
    local availablePacks = {}
    for key, value in pairs(dailyshop.ListAvailable) do
        table.insert(availablePacks, value)
    end

    -- Shuffle the available packs
    math.randomseed(os.time())
    for i = #availablePacks, 2, -1 do
        local j = math.random(i)
        availablePacks[i], availablePacks[j] = availablePacks[j], availablePacks[i]
    end

    -- Select the first 3 packs
    for i = 1, 7 do
        table.insert(newShop.List, availablePacks[i])
    end

    return newShop
end


function GetShop()

    MySQL.Async.fetchAll("SELECT * FROM dailyshop", {}, function(result)
        if result[1] then 
            
            if result[1].expired < os.date("%d/%m/%Y %H:%M:%S") then
                local newShop = CreateShopDay()
                MySQL.Async.execute("DELETE FROM dailyshop", {}, function(rowsChanged)
                    if rowsChanged > 0 then 
                        MySQL.Async.execute("INSERT INTO dailyshop (List, expired) VALUES (@List, @expired)", {
                            ["@List"] = json.encode(newShop.List),
                            ["@expired"] = newShop.expired
                        }, function(rowsChanged)
                            if rowsChanged > 0 then 
                                dailyshop.ActualShop = newShop
                            end
                        end)
                    end
                end)
            else 
                result[1].List = json.decode(result[1].List)
                dailyshop.ActualShop = result[1]
            end
        else
            local newShop = CreateShopDay()
            MySQL.Async.execute("INSERT INTO dailyshop (List, expired) VALUES (@List, @expired)", {
                ["@List"] = json.encode(newShop.List),
                ["@expired"] = newShop.expired
            }, function(rowsChanged)
                if rowsChanged > 0 then 
                    dailyshop.ActualShop = newShop
                end
            end)
        end
    end)
end

-- Citizen.CreateThread(function()

--     GetShop()

--     while true do 
--         Wait(10000)
--         if (dailyshop and dailyshop.ActualShop and dailyshop.ActualShop.expired and dailyshop.ActualShop.expired < os.date("%d/%m/%Y %H:%M:%S")) then
--             GetShop()
--             Wait(1000)
--             _TriggerClientEvent("dailyshop:setInformations", -1, dailyshop.ActualShop)
--         end
--     end
-- end)

_AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        GetShop()
    end
end)

_RegisterServerEvent("dailyshop:getShopInfo", function()
    _TriggerClientEvent("dailyshop:setInformations", source, dailyshop.ActualShop)
end)




-- _RegisterServerEvent("dailyshop:BuyDaily", function(name)
--     local item = dailyshop.ListAvailable[name]
--     local PLAYER = GetPlayerId(source)

--     if PLAYER then 
--         if item.type == "ped" then
--             if ifPlayerHavePed(source, item.model) then 
--                 _TriggerClientEvent("ShowAboveRadarMessage", source, "~r~You already have this ped")
--                 return
--             end
--         end
--         if PLAYER.RemoveTokens(item.price) then
--             if item.type == "items" then
--                 for k, v in pairs(item.items) do
--                     AddItem(source, "inventory", v.name, v.count, nil, true)
--                 end
--             end
            
--             if item.type == "ped" then
--                 GivePeds(source, item.model, item.id, item)
--             end

--             _TriggerClientEvent("ShowAboveRadarMessage", source, "You bought ~HUD_COLOUR_PINK~" .. item.label)
--         else 
--             _TriggerClientEvent("ShowAboveRadarMessage", source, "~r~You don't have enough tokens")
--         end
--     end
-- end)


function ifPlayerHavePed(source, model)
    local PLAYER = GetPlayerId(source)

    if PLAYER then 
        local dataPlayer = PLAYER.GetData()
        if dataPlayer["peds"] then 
            for k, v in pairs(dataPlayer.peds) do
                if v.model == model then 
                    return true
                end
            end
        end
    end
    return false
end

function GivePeds(souce, model, id, data)
    local PLAYER = GetPlayerId(source)

    if PLAYER then 
        local dataPlayer = PLAYER.GetData()
        if dataPlayer["peds"] then 
            -- table.insert(dataPlayer.peds, {model = model, id = id})
            PLAYER.AddDataToKey("peds", data)

            MySQL.Async.execute("UPDATE players SET data = @data WHERE license = @license", {
                ["@data"] = json.encode(PLAYER.GetData()),
                ["@license"] = PLAYER.license
            }, function(rowsChanged)
                if rowsChanged > 0 then 

                end
            end)

        else
            PLAYER.AddNewData("peds", {})
            PLAYER.AddDataToKey("peds", data)

            MySQL.Async.execute("UPDATE players SET data = @data WHERE license = @license", {
                ["@data"] = json.encode(PLAYER.GetData()),
                ["@license"] = PLAYER.license
            }, function(rowsChanged)
                if rowsChanged > 0 then 
                end
            end)
        end
    end
end

-- function ClearDataUUID(uuid)
--     local PLAYER = SearchUuidInDatabase(uuid)
--     if PLAYER then 
--         MySQL.Async.execute("UPDATE players SET data = @data WHERE license = @license", {
--             ["@data"] = json.encode({}),
--             ["@license"] = PLAYER.license
--         }, function(rowsChanged)
--             if rowsChanged > 0 then 
--             end
--         end)
--     end
-- end

-- RegisterCommand("reset_all_data", function(source, args)
--     local src = source
--     if source == 0 then 
--       local players = MySQL.query.await("SELECT * FROM players")
--       for k, v in pairs(players) do 
--         MySQL.update("UPDATE players SET data = @data WHERE uuid = @uuid", {["@data"] = json.encode({}), ["@uuid"] = v.uuid})
--       end
--     end
--   end, true)

_RegisterServerEvent("PREFIX_PLACEHOLDER:custom:Skin", function(typeA)
    if typeA == "enter" then 
        SetPlayerRoutingBucket(source, math.random(0, 50000))
    elseif typeA == "leave" then 
        SetPlayerRoutingBucket(source, 0)
    end
end)