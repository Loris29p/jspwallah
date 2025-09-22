ListHostActive = {}

-- Table pour garder une trace des sources et leurs hostIds
local PlayerHostIds = {}

function SecondToTime(intSecond)
    local intHour = math.floor(intSecond / 3600)
    local intMinute = math.floor((intSecond % 3600) / 60)
    local intSecond = intSecond % 60
    return string.format("%02d:%02d:%02d", intHour, intMinute, intSecond)
end

function OwnerHost(source)
    local PLAYER = GetPlayerId(source)
    if not PLAYER then 
        -- Si le joueur n'existe plus, on vérifie dans notre table de sauvegarde
        return PlayerHostIds[source]
    end
    
    for k, v in pairs(ListHostActive) do
        if v.game.ownerUUID == PLAYER.uuid then
            -- On sauvegarde l'association source -> hostId
            PlayerHostIds[source] = k
            return k
        end
    end
    return false
end

function CreateHost(source, tblData)
    local intSource = source 

    if OwnerHost(intSource) then return false, DoNotif(intSource, "~r~You are already in a game") end

    if not intSource then return false end
    if not tblData then return false end

    local PLAYER <const> = GetPlayerId(intSource)
    if not PLAYER then return false end

    local idHost = tonumber(PLAYER.uuid)

    if not tblData.code or not tblData.map then return false end
    ListHostActive[idHost] = {
        game = GameClass:new({
            id = idHost,
            code = tblData.code,
            map = Deepcopy(ListConfigHostMap[tblData.map]),
            ownerUUID = PLAYER.uuid,
            ownerUsername = PLAYER.username,
            bet = (tblData.bet and tblData.bet or 100000),
        }),
        ListEquipe = {
            [1] = TeamClass:New({
                name = (tblData.team and tblData.team[1].name or "Green"),
                color = "^#73ff9f",
                color2 = {r = 115, g = 255, b = 159},
                players = {},
                sizeEquipe = 20,
                teamId = 1,
            }),
            [2] = TeamClass:New({
                name = (tblData.team and tblData.team[2].name or "Purple"),
                color = "^#723ddb",
                color2 = {r = 114, g = 61, b = 219},
                players = {},
                sizeEquipe = 20,
                teamId = 2,
            }),
        },
        time = (tblData.time and tblData.time or 600), -- Seconds
        ListSpectate = {},
    }

    -- print("Host created with id "..idHost.." and time "..SecondToTime(ListHostActive[idHost].time), json.encode(ListHostActive[idHost], {indent = true}))

    _TriggerClientEvent("host_handler:event", -1, "createHost", {
        id = idHost,
        data = ListHostActive[idHost],
    })

    _TriggerClientEvent('chat:addMessage', source, { 
        args = { "~g~Host created with id "..idHost.." and time "..SecondToTime(ListHostActive[idHost].time) },
    })

    return true
end

function CheckPlayerInHost(source)
    local PLAYER <const> = GetPlayerId(source)
    if not PLAYER then return false end
    for k, v in pairs(ListHostActive) do
        for k2, v2 in pairs(v.game.listPlayers) do
            if v2.uuid == PLAYER.uuid then
                return true
            end
        end
    end
    return false
end

function CheckPlayerOwnerHost(source)
    local PLAYER <const> = GetPlayerId(source)
    if not PLAYER then return false end
    for k, v in pairs(ListHostActive) do
        if v.game.ownerUUID == PLAYER.uuid then
            return true
        end
    end
    return false
end

function GetHostIDByPlayer(source)
    local PLAYER <const> = GetPlayerId(source)
    if not PLAYER then return false end
    for k, v in pairs(ListHostActive) do
        for k2, v2 in pairs(v.game.listPlayers) do
            if v2.uuid == PLAYER.uuid then
                return k
            end
        end
    end
    return false
end

function GetHostPlayer(source)
    local idHost = GetHostIDByPlayer(source)
    if not idHost then return false end
    for k, v in pairs(ListHostActive[idHost].game.listPlayers) do
        if v.uuid == GetPlayerId(source).uuid then
            return v
        end
    end
    return false
end

function GetHostInfo(idHost)
    if not idHost then return false end
    if not ListHostActive[idHost] then return false end
    return ListHostActive[idHost]
end

function GetHostData(idHost)
    if not idHost then return false end
    if not ListHostActive[idHost] then return false end
    return ListHostActive[idHost].game
end

function GetTeamData(idHost, teamId)
    if not idHost then return false end
    if not ListHostActive[idHost] then return false end
    if not ListHostActive[idHost].ListEquipe[teamId] then return false end
    return ListHostActive[idHost].ListEquipe[teamId]
end


-- Use for update for everyone (Join, Leave, Kick)
function UpdateHost(idHost)

    if not idHost then return false end
    if not ListHostActive[idHost] then return false end

    _TriggerClientEvent("host_handler:event", -1, "updateHost", {
        id = idHost,
        data = ListHostActive[idHost],
    })
    return true
end

-- Use for update player in team
function BroadcastHostUpdate(idHost, leaderboard)
    if not idHost then return false end
    if not ListHostActive[idHost] then return false end

    for k, v in pairs(ListHostActive[idHost].ListEquipe) do
        for k2, v2 in pairs(v.players) do
            if leaderboard then
                local leaderboard = {}
                for k, v in pairs(ListHostActive[idHost].ListEquipe) do 
                    table.insert(leaderboard, {
                        username = GetTextWithGameColors(v.color..""..v.name, false),
                        kills = v:GetKills() or 0,
                    })
                end 
    
                table.sort(leaderboard, function(a, b)
                    return a.kills > b.kills
                end)
                _TriggerClientEvent("host_handler:event", v2.source, "updateLeaderboard", {
                    id = idHost,
                    leaderboard = leaderboard,
                })
            end
            _TriggerClientEvent("host_handler:event", v2.source, "team", {
                id = idHost,
                myTeam = v,
            })
            _TriggerClientEvent('host_handler:event', v2.source, "refreshUI", {
                id = idHost,
            }) 
        end
    end
end

function DeleteHost(source, idHost, force)

    if not idHost then return false end
    if not ListHostActive[idHost] then return false end
    ListHostActive[idHost].game.started = false

    if force or (ListHostActive[idHost].game.ownerUUID == GetPlayerId(source).uuid) then
        local playersList = ListHostActive[idHost].game:GetPlayerList()
        for k, v in pairs(playersList) do
            ListHostActive[idHost].game:RemovePlayer({
                v.uuid,
            })
            if v.teamId ~= 0 then 
                ListHostActive[idHost].ListEquipe[v.teamId]:RemovePlayer({
                    uuid = v.uuid,
                })
                _TriggerClientEvent("host_handler:event", v.source, "leaveTeam")
            end
            _TriggerClientEvent("host_handler:event", v.source, "removed", {
                id = idHost,
            })
            SetPlayerRoutingBucket(v.source, 0)
            exports["gamemode"]:ClearInventory(v.source, "inventory")
        end
        _TriggerClientEvent("host_handler:event", -1, "deleteHost", {
            id = idHost,
        })
        ListHostActive[idHost] = nil
        return true
    end

    return false
end

function RemovePlayerFromHost(source)
    local idHost = GetHostIDByPlayer(source)
    print("RemovePlayerFromHost - Start", source)
    print("idHost found:", idHost)

    if not idHost then return false, DoNotif(source, "~r~You are not in a game (1)") end
    if not CheckPlayerInHost(source) then return false, DoNotif(source, "~r~You are not in a game (2)") end

    print("Player checks passed")

    -- On récupère d'abord l'équipe du joueur
    local team = GetPlayerTeamHost(source)
    if team then
        print("Found player team:", team.name)
        -- On retire d'abord le joueur de l'équipe
        if team:RemovePlayer({uuid = GetPlayerId(source).uuid}) then
            print("Player removed from team")
            _TriggerClientEvent("host_handler:event", source, "leaveTeam")
        end
    end

    -- Ensuite on retire le joueur du jeu
    if ListHostActive[idHost].game:RemovePlayer({uuid = GetPlayerId(source).uuid}) then
        print("Player removed from game")
        UpdateHost(idHost)
        print("Host updated")
        _TriggerClientEvent("host_handler:event", source, "removed", {
            id = idHost,
        })
        print("Removed event sent")
        exports["gamemode"]:ClearInventory(source, "inventory")
        print("Inventory cleared")
        DoNotif(source, "~r~You have been removed from the game")
        SetPlayerRoutingBucket(source, 0)
        return true
    else 
        print("Failed to remove player from game")
        DoNotif(source, "~r~You are not in a game")
        return false
    end
end

function LeaveSpectateHost(source, hostId)
    if not ListHostActive[hostId].ListSpectate[source] then return false end
    SetPlayerRoutingBucket(source, 0)
    ListHostActive[hostId].ListSpectate[source] = nil
    return true
end

_RegisterServerEvent("host_server:event:goSpectate", function(hostId)
    local src = source
    GoSpectateHost(src, hostId)
end)

function GoSpectateHost(source, hostId)
    if not ListHostActive[hostId].game.started then return false end
    if not ListHostActive[hostId].ListSpectate[source] then return false end
    SetPlayerRoutingBucket(source, (hostId*2))
    -- TODO : Add Spectate
end

_RegisterServerEvent("host_server:event:leaveSpectate", function(hostId)
    local src = source
    LeaveSpectateHost(src, hostId)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    print("PLAYER CONNECTING EVENT TRIGGERED", name)
end)

AddEventHandler("playerDropped", function(reason)
    local src = source
    print("PLAYER DROPPED EVENT TRIGGERED", src, "Reason:", reason)
    
    -- Vérifier si le joueur est dans un host (soit comme hôte, soit comme joueur)
    local isInHost = false
    local hostId = PlayerHostIds[src]
    
    if hostId and ListHostActive[hostId] then
        isInHost = true
    elseif GetHostPlayer(src) then
        isInHost = true
        hostId = GetHostIDByPlayer(src)
    end

    -- Si le joueur est dans un host, on nettoie son inventaire
    if isInHost then
        print("Player was in host, clearing inventory", src)
        exports["gamemode"]:ClearInventory(src, "inventory")
    end
    
    -- Traitement pour l'hôte
    if hostId and ListHostActive[hostId] then
        print("Found host data for disconnected player", hostId)
        DeleteHost(src, hostId, true)
        PlayerHostIds[src] = nil
        return
    end

    -- Traitement pour les spectateurs
    for k, v in pairs(ListHostActive) do
        if v.ListSpectate[src] then
            LeaveSpectateHost(src, k)
        end
    end
    
    -- Traitement pour les joueurs normaux dans un host
    if GetHostPlayer(src) then
        RemovePlayerFromHost(src)
    end
end)

function JoinHost(source, idHost, code)

    if not idHost then return false end
    if not ListHostActive[idHost] then return false, DoNotif(source, "~r~Invalid id host (2)") end

    local PLAYER <const> = GetPlayerId(source)
    if not PLAYER then return false end

    if ListHostActive[idHost].game.code ~= code then return false, DoNotif(source, "~r~Invalid code (2)") end
    if ListHostActive[idHost].game.started then return false, DoNotif(source, "~r~The game has already started") end
    if ListHostActive[idHost].game.bet > tonumber(PLAYER.token) then return false, DoNotif(source, "~r~You don't have enough money to join the game (~s~"..ListHostActive[idHost].game.bet.." Tokens~r~)") end


    local joinHost, message = ListHostActive[idHost].game:AddPlayer({uuid = PLAYER.uuid, username = PLAYER.username, source = PLAYER.source})
    if joinHost then 
        UpdateHost(idHost)
        DoNotif(source, message)
        _TriggerClientEvent("host_handler:event", source, "joinHost", {
            id = idHost,
        })
        SetPlayerRoutingBucket(PLAYER.source, (idHost*2))
        local inventory = exports["gamemode"]:GetInventory(source, "inventory")
        for i = 1, #inventory do 
            local name, count = inventory[i].name, inventory[i].count
            local bool, remove = exports["gamemode"]:RemoveItem(source, "inventory", name, count)
            if bool then 
                exports["gamemode"]:AddItem(source, "protected", name, count, remove or nil, true)
            end
        end
        return true
    else 
        DoNotif(source, message)
        return false
    end

    return false
end

function GetPlayerTeamHost(source)
    local idHost = GetHostIDByPlayer(source)
    if not idHost then return nil end
    if not ListHostActive[idHost] then return nil end
    
    for k, v in pairs(ListHostActive[idHost].ListEquipe) do
        for k2, v2 in pairs(v.players) do
            if v2.source == source then
                return v
            end
        end
    end
    return false
end

function LeaveTeamHost(source)
    local idHost = GetHostIDByPlayer(source)
    print("LeaveTeamHost - Start", source)
    print("idHost found:", idHost)

    if not idHost then 
        print("No host found")
        return false 
    end
    if not ListHostActive[idHost] then 
        print("Host not active")
        return false 
    end

    local team = GetPlayerTeamHost(source)
    print("Team found:", team and team.name or "nil")
    if not team then 
        print("No team found")
        return false 
    end

    local hostPlayer = GetHostPlayer(source)
    print("Host player found:", hostPlayer and hostPlayer.uuid or "nil")
    if not hostPlayer then 
        print("No host player found")
        return false 
    end

    if team:RemovePlayer({uuid = GetPlayerId(source).uuid}) then
        print("Player removed from team")
        hostPlayer.team = "None"
        hostPlayer.teamId = 0
        UpdateHost(idHost)
        print("Host updated")
        DoNotif(source, "~r~You have left the team "..team:GetName())
        BroadcastHostUpdate(idHost)
        print("Host broadcast updated")
        _TriggerClientEvent("host_handler:event", source, "leaveTeam")
        print("LeaveTeam event sent")
        return true
    end
    print("Failed to remove player from team")
    return false
end

function JoinTeamHost(source, teamId)

    local idHost = GetHostIDByPlayer(source)
    if not idHost then return false end

    if not ListHostActive[idHost] then return false end
    if not ListHostActive[idHost].ListEquipe[teamId] then return false end

    if #ListHostActive[idHost].ListEquipe[teamId].players >= ListHostActive[idHost].ListEquipe[teamId].sizeEquipe then return false end

    local PLAYER <const> = GetPlayerId(source)
    if not PLAYER then return false end

    local hostPlayer = GetHostPlayer(source)
    if not hostPlayer then return false end
    
    local team = ListHostActive[idHost].ListEquipe[teamId]
    if not team then return false end

    local currentTeam = GetPlayerTeamHost(source)
    if currentTeam then
        LeaveTeamHost(source)
    end

    local success = team:AddPlayer({uuid = PLAYER.uuid, username = PLAYER.username, source = PLAYER.source})
    if not success then return false end

    hostPlayer.team = team:GetName()
    hostPlayer.teamId = teamId

    UpdateHost(idHost)
    DoNotif(source, "~g~You have joined the team "..team:GetName())

    BroadcastHostUpdate(idHost)

    return true
end

_RegisterServerEvent("host_server:event:joinTeam", function(data)
    local src = source
    local teamId = nil

    if type(data) == "table" and data.teamId then
        teamId = data.teamId
    else
        teamId = data
    end

    JoinTeamHost(src, teamId)
end)


local TableMeta = {
    ["kuruma_specialcarbine"] = {
        "weapon_specialcarbine",
        "kuruma"
    },
    ["kuruma_carbineriflemk2"] = {
        "weapon_carbinerifle_mk2",
        "kuruma"
    },
    ["kuruma_m60"] = {
        "weapon_combatmg",
        "kuruma"
    },
    ["brioso_specialcarbine"] = {
        "weapon_specialcarbine",
        "brioso"
    },
    ["brioso_carbineriflemk2"] = {
        "weapon_carbinerifle_mk2",
        "brioso"
    },
    ["brioso_m60"] = {
        "weapon_combatmg",
        "brioso"
    }
}

function SendLoadoutHost(source)
    local idHost = GetHostIDByPlayer(source)
    if not idHost then return false end
    if not ListHostActive[idHost] then return false end
    local meta = TableMeta[ListHostActive[idHost].game.meta]
    exports["gamemode"]:ClearInventory(source, "inventory")
    Wait(200)
    for k2, v2 in pairs(meta) do
        exports["gamemode"]:AddItem(source, "inventory", v2, 1, nil, true)
    end
    return true
end

function StartGameHost(source) 
    if not OwnerHost(source) then return false end
    local idHost = GetHostIDByPlayer(source)
    if not idHost then return false end

    if not ListHostActive[idHost] then return false end
    ListHostActive[idHost].game.started = true

    if #ListHostActive[idHost].ListEquipe[1].players < 1 or #ListHostActive[idHost].ListEquipe[2].players < 1 then 
        return false, DoNotif(source, "~r~Not enough players to start the game")
    end

    for k, v in pairs(ListHostActive[idHost].game.listPlayers) do
        if v.team == "None" then
            RemovePlayerFromHost(v.source)
            BroadcastHostUpdate(idHost)
            UpdateHost(idHost)
        end
    end
    Wait(1000)
    for k, v in pairs(ListHostActive[idHost].ListEquipe) do
        for _, player in pairs(v.players) do
            _TriggerClientEvent("host_handler:event:startGame", player.source)
            BroadcastHostUpdate(idHost, true)
            UpdateHost(idHost)
            SendLoadoutHost(player.source)
        end
    end

    Citizen.CreateThread(function()
        while ListHostActive[idHost].game.started do
            Wait(1000)
            if ListHostActive[idHost].time then 
                ListHostActive[idHost].time = ListHostActive[idHost].time - 1
                if ListHostActive[idHost].time <= 0 then
                    ListHostActive[idHost].game.started = false
                    FinishGameHost(idHost)
                end
            end
        end
    end)

    
    return true
end

function FinishGameHost(idHost)
    if not idHost then return false end
    if not ListHostActive[idHost] then return false end
    ListHostActive[idHost].game.started = false

    print("FINISH GAME", idHost)

    for k, v in pairs(ListHostActive[idHost].ListEquipe) do
        for _, player in pairs(v.players) do
            print("FINISH GAME 2", player.source)
            exports["gamemode"]:ClearInventory(player.source, "inventory")
            RemovePlayerFromHost(player.source)
        end
    end

    -- Notify all clients that the host is being deleted
    _TriggerClientEvent("host_handler:event", -1, "deleteHost", {
        id = idHost,
    })
    
    -- Clear the host from the list
    ListHostActive[idHost] = nil
    return true
end

function AddKillToPlayerHost(source)
    local idHost = GetHostIDByPlayer(source)
    if not idHost then return false end
    if not ListHostActive[idHost] then return false end
   
    local team = GetPlayerTeamHost(source)
    if not team then return false end

    team:AddKillsToPlayer(GetPlayerId(source).uuid)
    BroadcastHostUpdate(idHost, true)
    return true
end

_RegisterServerEvent("host_server:event:startGame", function()
    local src = source
    print("START GAME", src)
    StartGameHost(src)
end)

_RegisterServerEvent("host_server:event:leaveTeam", function(data)
    local src = source
    LeaveTeamHost(src)
end)

_RegisterServerEvent("host_server:event:createGame", function(tblData)
    if CheckPlayerInHost(source) then return DoNotif(source, "~r~You are already in a game") end
    print("CREATE GAME", json.encode(tblData, {indent = true}))
    CreateHost(source, {
        code = tblData.code,
        map = tblData.map,
        time = tblData.time,
        bet = tblData.bet,
        meta = tblData.meta,
    })
end)
disabledMenuCommand = true

RegisterCommand("createhost", function(source, args, rawCommand)
    if disabledMenuCommand then return end
    local tblData = {
        code = "test",
        map = "Desert (Open Field)",
        time = 60,
        bet = 11,
        meta = "kuruma_specialcarbine",
    }
    if OwnerHost(source) then return false end
    -- TODO : VERIF CREW LEADER OR MVP
    if CheckPlayerInHost(source) then return DoNotif(source, "~r~You are already in a game") end
    CreateHost(source, tblData)
end)

RegisterCommand("joinhost", function(source, args)
    if disabledMenuCommand then return end
    local idHost = tonumber(args[1])
    local code = args[2]
    if CheckPlayerInHost(source) then return DoNotif(source, "~r~You are already in a game") end
    if not idHost then return DoNotif(source, "~r~Invalid id host") end
    if not code then return DoNotif(source, "~r~Invalid code") end
    JoinHost(source, idHost, code)
end)

_RegisterServerEvent("host_server:event:joinHost", function(data)
    local src = source
    local idHost = data.hostId
    local code = data.code
    if CheckPlayerInHost(source) then return DoNotif(source, "~r~You are already in a game") end
    if not idHost then return DoNotif(source, "~r~Invalid id host") end
    if not code then return DoNotif(source, "~r~Invalid code") end
    JoinHost(src, idHost, code)
end)

RegisterCommand("leavehost", function(source, args)
    if disabledMenuCommand then return end
    RemovePlayerFromHost(source)
end)

RegisterCommand("deletehost", function(source, args)
    if disabledMenuCommand then return end
    local idHost = GetHostIDByPlayer(source)
    if not idHost then return DoNotif(source, "~r~You are not in a game") end
    if ListHostActive[idHost].game.ownerUUID ~= GetPlayerId(source).uuid then return DoNotif(source, "~r~You are not the owner of the game") end
    DeleteHost(source, idHost)
    DoNotif(source, "~g~Host deleted successfully")
end)