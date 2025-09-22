lbStats = {}

_RegisterNetEvent("gamemode:setLeaderboard", function(GlobalKills, GlobalDeath, GlobalToken, playerRanking)
    lbStats = {
        kills = GlobalKills,
        death = GlobalDeath,
        token = GlobalToken,
        playerRanking = playerRanking or {killsRank = nil, deathRank = nil, tokenRank = nil}
    }
    Wait(200)
    LoadStatsInventory()
    Logger:trace("LEADERBOARD", "Leaderboard stats reloaded") 
end)

_RegisterNetEvent("gamemode:receivePlayerRanking", function(playerRanking)
    if lbStats then
        lbStats.playerRanking = playerRanking
        LoadStatsInventory() -- Refresh the stats display
        Logger:trace("LEADERBOARD", "Player ranking updated")
    end
end)

function GetCountryFlag(country)
    for k, v in pairs(CountryFlag) do 
        if v == country then 
            return k
        end
    end
    return "GB"
end

function LoadStatsInventory()
    -- Use server-provided rankings if available, otherwise fallback to client-side calculation
    local myPlaces = {}
    
    if lbStats.playerRanking and lbStats.playerRanking.killsRank then
        table.insert(myPlaces, {type = "kills", place = lbStats.playerRanking.killsRank})
    else
        -- Fallback: search in top 100 leaderboard
        for k, v in pairs(lbStats.kills) do 
            if v.uuid == GM.Player.UUID then 
                table.insert(myPlaces, {type = "kills", place = k})
                break
            end
        end
        -- If not found in top 100, add a placeholder
        if #myPlaces == 0 then
            table.insert(myPlaces, {type = "kills", place = "100+"})
        end
    end

    if lbStats.playerRanking and lbStats.playerRanking.deathRank then
        table.insert(myPlaces, {type = "death", place = lbStats.playerRanking.deathRank})
    else
        -- Fallback: search in top 100 leaderboard
        local foundDeath = false
        for k, v in pairs(lbStats.death) do 
            if v.uuid == GM.Player.UUID then 
                table.insert(myPlaces, {type = "death", place = k})
                foundDeath = true
                break
            end
        end
        if not foundDeath then
            table.insert(myPlaces, {type = "death", place = "100+"})
        end
    end

    if lbStats.playerRanking and lbStats.playerRanking.tokenRank then
        table.insert(myPlaces, {type = "token", place = lbStats.playerRanking.tokenRank})
    else
        -- Fallback: search in top 100 leaderboard
        local foundToken = false
        for k, v in pairs(lbStats.token) do 
            if v.uuid == GM.Player.UUID then 
                table.insert(myPlaces, {type = "token", place = k})
                foundToken = true
                break
            end
        end
        if not foundToken then
            table.insert(myPlaces, {type = "token", place = "100+"})
        end
    end

    local playerKills = (GM and GM.Player and GM.Player.Kills_Global) or 0
    local playerDeath = (GM and GM.Player and GM.Player.Death_Global) or 0
    if playerKills == 0 and playerDeath == 0 then 
        playerKd = 1.0
    else
        playerKd = (math.floor((tonumber(playerKills / playerDeath) * 10^2) + 0.5) / (10^2)) or 1.0
    end

    SendNUIMessage({
        type = "stats",
        playerData = json.encode({
            username = (CrewData and CrewData.crewName and GetTextWithGameColors(CrewData.crewTag, false).." "..GetTextWithGameColors(GM.Player.Username, false) or GetTextWithGameColors(GM.Player.Username, false)),
            crewName = (CrewData and CrewData.crewName or "None"),
            uuid = GM.Player.UUID,
            country = (GetCountryFlag(GM.Player.Flag) or "GB"),
            tokens = GM.Player.Token,
            coins = GM.Player.Coins,
            kd = playerKd,
            kills = GM.Player.Kills_Global,
            death = GM.Player.Death_Global,
            placeKill = myPlaces[1] and myPlaces[1].place or "N/A",
            placeDeath = myPlaces[2] and myPlaces[2].place or "N/A",
            placeToken = myPlaces[3] and myPlaces[3].place or "N/A",
            prestige = GM.Player.Prestique,
        }),
    })
end

RegisterNUICallback("GetPlayerStats", function(data, cb)
    LoadStatsInventory()
    cb("ok")
end)

RegisterKeyMapping("openInventory", "Open Inventory", "keyboard", "TAB")



_RegisterNetEvent("inventory:OpenContainer", function(containerinventory, id, type)
    local myInventory = FormatItems(PlayerItems["inventory"])
    if type ~= "airdrop" then
        containerinv = FormatItems(containerinventory)
    else
        containerinv = FormatDrop(containerinventory)
    end

    if not itemLoaded then 

        table.sort(Items, function(a, b) return a.price > b.price end)
        SendNUIMessage({
            type = "importItemTbl",
            tbl = Items
        })
        itemLoaded = true 
    end
    if type == "bags" then 
        isOpened = true
        ArrangeControls(true)
        SendNUIMessage({ 
            type = "side",
            bool = true,
            inventory = myInventory,
            baginventory = containerinv,
            id = id,
        })
    elseif type == "container" then 
        isOpened = true
        ArrangeControls(true)
        SendNUIMessage({ 
            type = "side",
            bool = true,
            inventory = myInventory,
            baginventory = containerinv,
            id = id,
        })
    elseif type == "airdrop" then 
        isOpened = true
        ArrangeControls(true)
        SendNUIMessage({ 
            type = "side",
            bool = true,
            inventory = myInventory,
            baginventory = containerinv,
            id = id,
        })
    end
end)

_RegisterNetEvent("inventory:OpenContainerStaff", function(containerInventory, id, type, inventory)
    local hisInventory = FormatItems(inventory)
    local containerinv = FormatItems(containerInventory)


    if not itemLoaded then 
        table.sort(Items, function(a, b) return a.price > b.price end)
        SendNUIMessage({
            type = "importItemTbl",
            tbl = Items
        })
        itemLoaded = true 
    end

    if type == "container" then 
        isOpened = true
        ArrangeControls(true)
        SendNUIMessage({ 
            type = "side",
            bool = true,
            inventory = hisInventory,
            baginventory = containerinv,
            id = id,
        })
    end
end)

function GetListPlayers()
    local result = ListPlayersServerGlobal
    if result then 
        return result
    end
    return {}
end

function ListPlayersNearby()
    local players = GetListPlayers()
    local players2 = GetNearbyPlayers(10)
    local returnTable = {}
    print(json.encode(players2))
    for k, v in pairs(players) do 
        print(v.username, v.source)
        for k2, v2 in pairs(players2) do 
            print(v2, k2, GetPlayerServerId(v2))
            if v.source == GetPlayerServerId(v2) then 
                table.insert(returnTable, {
                    username = v.username,
                    id = GetPlayerServerId(v2),
                    uuid = v.uuid,
                })
            end
        end
    end
    return returnTable
end

RegisterCommand("listplayers", function()
    ListPlayersNearby()
end)

RegisterNUICallback("GetListPlayers", function(data, cb)
    local result = ListPlayersNearby()
    if result and #result > 0 then 
        cb(result)
    else
        cb({})
    end
end)

RegisterNUICallback("GiveItemToPlayer", function(data, cb)
    if data.item and data.count and data.playerId then
        -- Forward the request to the server
        Tse("inventory:GiveItemToPlayer", data)
        cb({status = "success"})
    else
        cb({status = "error", message = "Missing required data"})
    end
end)

-- Function to request current player ranking
function RequestPlayerRanking()
    Tse("gamemode:requestPlayerRanking")
end

-- Export the function so it can be called from other scripts
exports("RequestPlayerRanking", RequestPlayerRanking)
