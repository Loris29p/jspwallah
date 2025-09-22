MilitaryZonePlayers = {}
CasesMilitaryZone = {
    [1] = {
        time = nil,
    },
    [2] = {
        time = nil,
    },
    [3] = {
        time = nil,
    },
    [4] = {
        time = nil,
    },
    [5] = {
        time = nil,
    },
}

function AlreadyInMilitaryZone(src)
    for k, v in pairs(MilitaryZonePlayers) do
        if src == v.source then
            return true
        end
    end
    return false
end

-- RegisterCommand("go", function(source, args)
--     if source == 0 then return end
    
--     local playerPed = GetPlayerPed(source)
--     if playerPed then
--         SetEntityCoords(playerPed, 1539.191650, 3203.449219, 40.409435, false, false, false, true)
--         SetEntityHeading(playerPed, 102.036514)
--         TriggerClientEvent('chat:addMessage', source, {
--             color = {0, 255, 0},
--             multiline = true,
--             args = {"Système", "Vous avez été téléporté aux coordonnées spécifiées."}
--         })
--     end
-- end)

_RegisterServerEvent('GetMilitaryZonePlayers', function()
    local src = source
    _TriggerClientEvent("militaryzone:getPlayers", src, MilitaryZonePlayers)
end)

function AddPlayerMilitaryZone(src, tblData)
    if type(tblData) ~= "table" then return end
    local PLAYER <const> = GetPlayerId(src)
    if not PLAYER then return end 
    for k, v in pairs(MilitaryZonePlayers) do
        if v.uuid == PLAYER.uuid then
            return 
        end
    end
    MilitaryZonePlayers[#MilitaryZonePlayers + 1] = {
        uuid = PLAYER.uuid,
        username = PLAYER.username,
        source = src,
    }
    _TriggerClientEvent("militaryzone:join", src)
    _TriggerClientEvent("militaryzone:broadcastAll", -1, MilitaryZonePlayers)
end

function RemovePlayerMilitazyZone(src)
    if AlreadyInMilitaryZone(src) then
        for k, v in pairs(MilitaryZonePlayers) do 
            table.remove(MilitaryZonePlayers, k)
            print("LEAVE MILITARY ZONE", v.uuid, v.username, src)
            _TriggerClientEvent("militaryzone:broadcastAll", -1, MilitaryZonePlayers)
            _TriggerClientEvent("militaryzone:leave", src)
            print("leave military zone")
        end
    end
end

_RegisterServerEvent("militaryzone:join", function()
    local src = source
    local PLAYER <const> = GetPlayerId(src)
    if not PLAYER then return end
    if #PlayersListSafeMode <= 10 then return DoNotif(src, "~r~The military zone is open when there are 10 players in the server") end
    AddPlayerMilitaryZone(src, {})
end)

_RegisterServerEvent("militaryzone:leave", function()
    local src = source
    RemovePlayerMilitazyZone(src)
end)

AddEventHandler("playerDropped", function(reason)
    RemovePlayerMilitazyZone(source)
end)

_RegisterServerEvent("militaryzone:lootCase", function(tblData)
    if type(tblData) ~= "table" then return end
    local src = source
    local PLAYER <const> = GetPlayerId(src)

    if PLAYER then 

    end
end)


function CreateCooldownMilitaryZone(id, time)
    CasesMilitaryZone[id].time = time
    Citizen.CreateThread(function()
        while CasesMilitaryZone[id].time >= 0 do
            CasesMilitaryZone[id].time = CasesMilitaryZone[id].time - 1
            Citizen.Wait(1000)
        end
    end)
end

function RemoveCooldownMilitaryZone(id)
    CasesMilitaryZone[id].time = nil
end

function GetCooldownMilitaryZone(id)
    if not CasesMilitaryZone[id].time then
        return false
    end
    return CasesMilitaryZone[id].time
end

function GetRandomItem()
    local items = MilitaryZoneConfig.listItems
    local randomIndex = math.random(1, #items)
    return items[randomIndex]
end

_RegisterServerEvent("militaryzone:openCase", function(id)

    local src = source 

    local PLAYER <const> = GetPlayerId(src)
    if not PLAYER then return end

    if #MilitaryZonePlayers < 0 then return DoNotif(src, "~r~You can loot the case when there are 0 players in the military zone") end

    if not CasesMilitaryZone[id] then return end
    if GetCooldownMilitaryZone(id) then
        local timeCase = GetCooldownMilitaryZone(id)
        if timeCase < 1 then 
            -- open case
            local randomItems = GetRandomItem()
            local labelItems = Items[randomItems].label
            local count = 1
            if exports["gamemode"]:AddItem(src, "inventory", randomItems, count) then
                RemoveCooldownMilitaryZone(id)
                DoNotif(src, "You have opened the case and received ~g~" .. labelItems .. " x" .. count)
            else 
                DoNotif(src, "~r~ERROR CONTACT DEVELOPER (1)")
            end
        else
            DoNotif(src, "You can open the case in ~b~" .. GetCooldownMilitaryZone(id) .. " seconds~w~.")
            return 
        end
    else
        CreateCooldownMilitaryZone(id, 150)
        DoNotif(src, "You can open the case in ~b~" .. GetCooldownMilitaryZone(id) .. " seconds~w~.")
    end
end)