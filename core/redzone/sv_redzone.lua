local RedzoneRandomItems = {
    "weapon_sniperrifle",
    "oppressor",
    "buzzard2",
    "scarab",
    "nightshark",
}


function GetRandomRedzoneItem()
    return RedzoneRandomItems[math.random(1, #RedzoneRandomItems)]
end

local function GenerateRedZone()
    if #RedzoneConfig.CurrentRedZoneInfo > 0 then
        for _, redzone in pairs(RedzoneConfig.CurrentRedZoneInfo) do
            local leaderboard = redzone.redzoneLeaderboard
            
            local filteredLeaderboard = {}
            for _, entry in pairs(leaderboard) do
                if entry and entry.source and entry.kills then
                    table.insert(filteredLeaderboard, entry)
                end
            end
            
            table.sort(filteredLeaderboard, function(a, b) return a.kills > b.kills end)
            local firstLeaderboard = filteredLeaderboard[1]
            
            if firstLeaderboard then
                local PLAYER_DATA <const> = GetPlayerId(firstLeaderboard.source)
                if PLAYER_DATA then
                    local item = GetRandomRedzoneItem()
                    exports["gamemode"]:AddItem(firstLeaderboard.source, "protected", item, 1, nil, true)
                    DoNotif(firstLeaderboard.source, "~g~You have been rewarded with "..Items[item].label.." for being the first to kill in the redzone")
                end
            end
        end
    end
    RedzoneConfig.CurrentRedZoneInfo = {}
    local tblData = {
        redzoneId = math.random(0, 30),
        redzonePos = RedzoneConfig.RedzonePosition[math.random(1, #RedzoneConfig.RedzonePosition)],
        redzoneLeaderboard = {},
    }
    table.insert(RedzoneConfig.CurrentRedZoneInfo, tblData)


    if #PlayersListSafeMode > 40 then 
        ::continue::
        local tblData_SECOND = {
            redzoneId = math.random(0, 30),
            redzonePos = RedzoneConfig.RedzonePosition[math.random(1, #RedzoneConfig.RedzonePosition)],
            redzoneLeaderboard = {},
        }
        if tblData_SECOND.redzonePos == tblData.redzonePos then
            goto continue
        end
        table.insert(RedzoneConfig.CurrentRedZoneInfo, tblData_SECOND)
    end

    _TriggerClientEvent('redzone:loadRedzoneInfo', -1, RedzoneConfig.CurrentRedZoneInfo)   
end

_RegisterServerEvent("redzone:GetRedzoneInfo", function()
    _TriggerClientEvent('redzone:loadRedzoneInfo', source, RedzoneConfig.CurrentRedZoneInfo) 
end)

function GetRedzoneInformations(id)
    for k, v in pairs(RedzoneConfig.CurrentRedZoneInfo) do
        if v.redzoneId == id then
            return v
        end
    end
end

function GetFirstLeaderboard(redzoneId)
    local redzonedata = GetRedzoneInformations(redzoneId)
    if redzonedata == nil then
        return nil
    end
    
    local topPlayer = nil
    local maxKills = 0
    
    for srcId, playerData in pairs(redzonedata.redzoneLeaderboard) do
        if playerData.kills > maxKills then
            maxKills = playerData.kills
            topPlayer = playerData
        end
    end
    
    return topPlayer
end

function AddKillsPlayerRedzone(redzoneId, src)
    local redzonedata = GetRedzoneInformations(redzoneId)
    if redzonedata == nil then
        return
    end

    if redzonedata.redzoneLeaderboard[src] == nil then
        redzonedata.redzoneLeaderboard[src] = {
            username = ReturnUsernameWithTagAndColor(src),
            kills = 1,
            source = src,
        }
    else
        redzonedata.redzoneLeaderboard[src].kills = redzonedata.redzoneLeaderboard[src].kills + 1
    end

    -- table.sort(redzonedata.redzoneLeaderboard, function(a, b) return a.kills > b.kills end)

    for k, v in pairs(redzonedata.redzoneLeaderboard) do
        _TriggerClientEvent("redzone:UpdateLeaderboard", v.source, redzoneId, redzonedata.redzoneLeaderboard)
    end
end

_RegisterServerEvent("redzone:AddKillerKills", function(redzoneId, killerId)
    local intKillerid = killerId
    AddKillsPlayerRedzone(redzoneId, intKillerid)
end)

_RegisterServerEvent("redzone:joinRedzone", function(redzoneId)

    local intSource = source
    local RedzoneData = GetRedzoneInformations(redzoneId)

    if RedzoneData == nil then
        return
    end

    if RedzoneData.redzoneLeaderboard[source] == nil then
        RedzoneData.redzoneLeaderboard[source] = {
            username = ReturnUsernameWithTagAndColor(intSource),
            kills = 0,
            source = intSource,
        }
    end

    -- table.sort(RedzoneData.redzoneLeaderboard, function(a, b) return a.kills > b.kills end)

    for k, v in pairs(RedzoneData.redzoneLeaderboard) do
        _TriggerClientEvent("redzone:UpdateLeaderboard", v.source, redzoneId, RedzoneData.redzoneLeaderboard)
    end
end)

Citizen.CreateThread(function()
    Wait(5000)
    GenerateRedZone()
end)

-- RegisterCommand("gen_redzone", function()
--     GenerateRedZone()
-- end)

local redzoneTimes = {
    ["00:00:00"] = true,
    ["01:00:00"] = true,
    ["02:00:00"] = true,
    ["03:00:00"] = true,
    ["04:00:00"] = true,
    ["05:00:00"] = true,
    ["06:00:00"] = true,
    ["07:00:00"] = true,
    ["08:00:00"] = true,
    ["09:00:00"] = true,
    ["10:00:00"] = true,
    ["11:00:00"] = true,
    ["12:00:00"] = true,
    ["13:00:00"] = true,
    ["14:00:00"] = true,
    ["15:00:00"] = true,
    ["16:00:00"] = true,
    ["17:00:00"] = true,
    ["18:00:00"] = true,
    ["19:00:00"] = true,
    ["20:00:00"] = true,
    ["21:00:00"] = true,
    ["22:00:00"] = true,
    ["23:00:00"] = true,
}

_RegisterServerEvent("admin:changeRedzone", function()
    local intSource = source

    if GetPlayerId(intSource).group == "user" then
        return DropPlayer(intSource, "TGGGGGGGGGGGGGG")
    end
    GenerateRedZone()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(900)
        local utcTime = os.date('%X')

        if redzoneTimes[utcTime] then
            GenerateRedZone()
        end
    end
end)

function GetTopPlayerAllRedzones()
    local topPlayer = nil
    local maxKills = 0
    
    -- Parcourir toutes les redzones actives
    for _, redzoneData in pairs(RedzoneConfig.CurrentRedZoneInfo) do
        -- Parcourir le leaderboard de chaque redzone
        for _, playerData in pairs(redzoneData.redzoneLeaderboard) do
            if playerData.kills > maxKills then
                maxKills = playerData.kills
                topPlayer = playerData
            end
        end
    end
    
    return topPlayer
end