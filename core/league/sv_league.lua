ListEquipe = {}
LeagueGlobal = {
    teams = {},
    lobby = {},
    league = {},
    map = {},
    host = {
        username = "John Doe",
        src = 1,
        uuid = "1234567890",
    },
    type = "solo", -- duo, trio, solo
    time = 600, -- MS 10 MINUTES
    teamNumber = 2,
    teamMembers = 1,
    active = false,
    started = false,
}
ListSpectate = {}
LeagueTimeActual = nil

function UpdateLeague()
    -- for k, v in pairs(LeagueGlobal.teams) do 
    --     for _, player in pairs(v.players) do 
    --         _TriggerClientEvent('league:data', player.src, "update", LeagueGlobal)
    --     end
    -- end
    _TriggerClientEvent('league:data', -1, "update", LeagueGlobal)
end

_RegisterServerEvent('league:banLeague', function(target)
    local src = source
    if GetPlayerId(src).group == "user" then return DoNotif(src, "~r~You are not allowed to ban players") end 
    local PLAYER_TARGET = GetPlayerId(target)
    local dataPlayer = PLAYER_TARGET.GetData()
    if not dataPlayer["league_ban"] then 
        PLAYER_TARGET.AddNewData("league_ban", {
            reason = "blacklisted from league",
            author = GetPlayerId(src).username.." - ["..GetPlayerId(src).uuid.."]",
            time = os.date("%Y-%m-%d %H:%M:%S"),
        })
        DoNotif(src, "~g~You have banned "..GetPlayerId(target).username.." from league")
        DoNotif(target, "~r~You have been banned from league. Contact the staff if you think this is a mistake.")
        KickPlayerFromLeague(target)
        SetPlayerRoutingBucket(target, 0)
        exports["gamemode"]:ClearInventory(target, "inventory")
        _TriggerClientEvent('league:data', target, "leave")
        _TriggerClientEvent("league:myTeamData", target, "leaveTeam")
        BroadcastLeagueUpdate()
    end
end)

function RemoveUnbanLeague(src)
    local PLAYER <const> = GetPlayerId(src)
    if PLAYER.GetData()["league_ban"] then 
        PLAYER.RemoveData("league_ban")
        DoNotif(src, "~g~You have been unbanned from league")
        return true
    end
    DoNotif(src, "~r~You are not banned from league")
    return false
end


function CreateLeague(tblData)
    if LeagueGlobal.active then return false end
    if type(tblData) ~= "table" then return false end
    PerTeamPlayer = tblData.teamMembers
    LeagueGlobal = tblData
    LeagueGlobal.active = true
    LeagueGlobal.maxPlayers = (PerTeamPlayer * tblData.teamNumber)
    LeagueTimeActual = LeagueGlobal.time

    for k, v in pairs(League.ListEquipe) do 
        local equipe = LeagueTeam:CreateTeam({
            name = v.name,
            coords = v.coords,
            ped = v.ped,
            color = v.color,
            color2 = v.color2,
            id = k,
            sizeEquipe = PerTeamPlayer,
        })
        
        LeagueGlobal.teams[k] = equipe
        if #LeagueGlobal.teams == LeagueGlobal.teamNumber then
            break
        end
    end

    UpdateLeague()

    _TriggerClientEvent('league:data', -1, "init", LeagueGlobal)
    _TriggerClientEvent('league:data', -1, "announce")
    return true
end

_RegisterServerEvent("league:GetLeagueData", function()
    if not LeagueGlobal.active then return end
    _TriggerClientEvent("league:data", source, "init", LeagueGlobal)
    _TriggerClientEvent('league:data', source, "announce")
end)

_RegisterServerEvent("league:CreateLeague", function(tblData)
    if GetPlayerId(source).group == "user" then return end
    if type(tblData) ~= "table" then return end
    CreateLeague({
        map = tblData.map,
        time = tblData.time,
        teamNumber = tblData.team,
        teamMembers = tblData.members,
        type = "solo",
        host = {
            username = GetPlayerId(source).username,
            src = source,
            uuid = GetPlayerId(source).uuid,
        },
        active = false,
        teams = {},
        lobby = {},
        league = {},
        started = false,
    })
end)

function LeaveLeague(src)
    if not LeagueGlobal.active then return false end
    if GetPlayerInLeague(src) then
        KickPlayerFromLeague(src)
        exports["gamemode"]:ClearInventory(src, "inventory")
        SetPlayerRoutingBucket(src, 0)
        Wait(1000)
        _TriggerClientEvent('league:data', src, "leave")
        _TriggerClientEvent("league:myTeamData", src, "leaveTeam")
    end
    return true
end
 
RegisterCommand("leaveleague", function(source, args)
    if not LeagueGlobal.active then return end
    if GetPlayerInLeague(source) then
        LeaveLeague(source)
    end
end)

function GetPlayerInLobby(src)
    if not LeagueGlobal.active then return false end
    for k, v in pairs(LeagueGlobal.lobby) do 
        if v.src == src then
            return v
        end
    end
    return false
end

function AddPlayerToLobby(src)
    if not LeagueGlobal.active then return false end
    table.insert(LeagueGlobal.lobby, {
        username = GetPlayerId(src).username,
        src = src,
        uuid = GetPlayerId(src).uuid,
        team = "None",
        teamId = 0,
    })
    local inventory = exports["gamemode"]:GetInventory(src, "inventory")
    for i = 1, #inventory do 
        local name, count = inventory[i].name, inventory[i].count
        local bool, remove = exports["gamemode"]:RemoveItem(src, "inventory", name, count)
        if bool then 
            exports["gamemode"]:AddItem(src, "protected", name, count, remove or nil, true)
        end
    end
    SetPlayerRoutingBucket(src, 90505)
    _TriggerClientEvent('league:data', src, "update", LeagueGlobal)
    Wait(200)
    _TriggerClientEvent('league:init', src)
    UpdateLeague()
    return true
end

function RemovePlayerFromLobby(src)
    if not LeagueGlobal.active then return false end
    for k, v in pairs(LeagueGlobal.lobby) do 
        if v.src == src then
            table.remove(LeagueGlobal.lobby, k)
            return true
        end
    end
    return false
end

function KickPlayerFromLeague(src, force)
    if not LeagueGlobal.active then return false end
    for k, v in pairs(LeagueGlobal.lobby) do 
        if v.src == src then
            -- TODO : Update for all players & players in the lobby
            DoNotif(src, "~r~You have been kicked from the league")
            SetPlayerRoutingBucket(src, 0)
            table.remove(LeagueGlobal.lobby, k)
            exports["gamemode"]:ClearInventory(src, "inventory")
            if not force then
                BroadcastLeagueUpdate()
            end
        end
    end

    for k, v in pairs(LeagueGlobal.teams) do  
        for k2, v2 in pairs(v.players) do 
            if v2.src == src then
                table.remove(v.players, k2)
                SetPlayerRoutingBucket(src, 0)
                _TriggerClientEvent('league:data', src, "leave")
                exports["gamemode"]:ClearInventory(src, "inventory")
                if not force then
                    BroadcastLeagueUpdate()
                end
            end
        end
    end
    return true
end 


_RegisterServerEvent("league:KickPlayerFromTeam", function(src)
    if GetPlayerId(source).group == "user" then return end
    local team = GetPlayerTeam(src)
    if not team then return DoNotif(source, "~r~The player is not in a team") end
    if team:RemovePlayer(src) then
        DoNotif(source, "~r~You kicked "..GetPlayerId(src).username.." from the team "..team:GetName())
        DoNotif(src, "~r~You have been kicked from the team "..team:GetName())
        _TriggerClientEvent("league:myTeamData", src, "leaveTeam")
        BroadcastLeagueUpdate()
    end
end)

_RegisterServerEvent("league:KickPlayerFromLeague", function(src)
    if GetPlayerId(source).group == "user" then return end
    if KickPlayerFromLeague(src) then 
        SetPlayerRoutingBucket(src, 0)
        Wait(1000)
        _TriggerClientEvent('league:data', src, "leave")
        _TriggerClientEvent("league:myTeamData", src, "leaveTeam")
        BroadcastLeagueUpdate()
    end
end)

function JoinLobbyLeague(src)
    if not LeagueGlobal.active then return false end

    local player = GetPlayerInLobby(src)
    if player then return DoNotif(src, "~r~You are already in the lobby") end

    if #LeagueGlobal.lobby >= LeagueGlobal.maxPlayers then return DoNotif(src, "~r~The lobby is full") end
    AddPlayerToLobby(src)
    UpdateLeague()
    return true
end

function JoinTeamLeague(src, teamId)
    if not LeagueGlobal.active then return false end

    local player = GetPlayerInLobby(src)
    if not player then return DoNotif(src, "~r~You are not in the lobby") end

    teamId = tonumber(teamId)
    if not teamId then return DoNotif(src, "~r~Invalid team ID") end
    
    if not LeagueGlobal.teams[teamId] then
        return DoNotif(src, "~r~Team not found")
    end
    
    if #LeagueGlobal.teams[teamId].players >= LeagueGlobal.teams[teamId].sizeEquipe then 
        return DoNotif(src, "~r~The team is full") 
    end
    
    local team = LeagueGlobal.teams[teamId]
    if not team then return DoNotif(src, "~r~Team not found") end

    local currentTeam = GetPlayerTeam(src)
    if currentTeam then
        LeaveTeamLeague(src, false)
    end
    
    local success = team:AddPlayer(player)
    if not success then
        return DoNotif(src, "~r~Failed to join team")
    end

    player.team = team:GetName()
    player.teamId = teamId

    UpdateLeague()
    DoNotif(src, "~g~You have joined the team "..team:GetName())

    BroadcastLeagueUpdate()

    Wait(1000)
    _TriggerClientEvent("league:myTeamData", src, "initData", team)
    
    return true
end

function LeaveTeamLeague(src, shouldUpdate)
    if not LeagueGlobal.active then return false end

    local team = GetPlayerTeam(src)
    if not team then return DoNotif(src, "~r~You are not in a team") end
    
    
    if team:RemovePlayer(src) then
        DoNotif(src, "~r~You have left the team "..team:GetName())

        if shouldUpdate ~= false then
            BroadcastLeagueUpdate()
        end

        _TriggerClientEvent("league:myTeamData", src, "leaveTeam")
        UpdateLeague()
        return true
    end
    return false
end

function BroadcastLeagueUpdate(isLeaderboard)
    local playerCounts = {}

    for k, v in pairs(LeagueGlobal.teams) do
        playerCounts[k] = #v.players
    end

    -- For active players in teams
    for k, v in pairs(LeagueGlobal.teams) do 
        for _, player in pairs(v.players) do 
            if isLeaderboard then
                local leaderboard = {}
                for k, v in pairs(LeagueGlobal.teams) do 
                    table.insert(leaderboard, {
                        username = GetTextWithGameColors(v.color..""..v.name, false),
                        kills = v:GetKills(),
                    })
                end 
    
                table.sort(leaderboard, function(a, b)
                    return a.kills > b.kills
                end)
                _TriggerClientEvent('league:data', player.src, "update", LeagueGlobal, leaderboard)
            else
                _TriggerClientEvent('league:data', player.src, "update", LeagueGlobal)
            end
            _TriggerClientEvent('league:refreshUI', player.src)
            _TriggerClientEvent('league:myTeamData', player.src, "update", v)
        end
    end

    if #ListSpectate > 0 then
        for k, v in pairs(ListSpectate) do 
            if isLeaderboard then 
                local leaderboard = {}
                for k, v in pairs(LeagueGlobal.teams) do 
                    table.insert(leaderboard, {
                        username = GetTextWithGameColors(v.color..""..v.name, false),
                        kills = v:GetKills(),
                    })  
                end 

                table.sort(leaderboard, function(a, b)
                    return a.kills > b.kills
                end)

                _TriggerClientEvent('league:data', k, "update", LeagueGlobal, leaderboard)
            else 
                _TriggerClientEvent('league:data', k, "update", LeagueGlobal)
            end
        end
    end
end

_RegisterServerEvent("league:joinLeague", function(data)
    JoinLobbyLeague(source)
end)
    

-- Event handlers for joining/leaving teams from UI
RegisterServerEvent("league:joinTeam")
AddEventHandler("league:joinTeam", function(data)
    local src = source
    local teamId = nil

    if type(data) == "table" and data.teamId then
        teamId = data.teamId
    else
        teamId = data
    end
    
    JoinTeamLeague(src, teamId)
end)

RegisterServerEvent("league:leaveTeam")
AddEventHandler("league:leaveTeam", function(data)
    local src = source
    local teamId = nil
    
    -- Handle both direct teamId and data object formats
    if type(data) == "table" and data.teamId then
        teamId = data.teamId
    else
        teamId = data
    end
    
    -- print("league:leaveTeam event received: TeamID = " .. tostring(teamId))
    LeaveTeamLeague(src)
end)

function GetLeague()
    if not LeagueGlobal.active then return false end
    return LeagueGlobal
end

function GetPlayerInLeague(src)
    for k, v in pairs(LeagueGlobal.teams) do 
        for _, player in pairs(v.players) do 
            if player.src == src then
                return player -- Return the player object (username, src, uuid, kills)
            end
        end
    end
    return false
end

function GetPlayerTeam(src)
    for k, v in pairs(LeagueGlobal.teams) do 
        for _, player in pairs(v.players) do 
            if player.src == src then
                return v -- Return the team object (name, color, coords, ped, players, kills, sizeEquipe, id)
            end
        end
    end
    return false
end

function GetHowManyPlayersInLeague()
    if not LeagueGlobal.active then return 0 end
    local count = 0
    for k, v in pairs(LeagueGlobal.teams) do 
        count = count + #v.players
    end
    return count
end

function LeagueIsStartedWithoutMyTeam(src)
    if not LeagueGlobal.active then return false end
    if not LeagueGlobal.started then return false end
    for k, v in pairs(LeagueGlobal.teams) do 
        for _, player in pairs(v.players) do 
            if player.src == src then return false end
        end
    end
    return true
end

_RegisterServerEvent('league:LeaveSpectate', function()
    local src = source
    if not ListSpectate[src] then return end
    SetPlayerRoutingBucket(src, 0)
    ListSpectate[src] = nil
end)

_RegisterServerEvent('league:GoToSpectate', function()
    local src = source
    if not LeagueGlobal.active then return end
    if not LeagueGlobal.started then return end
    if ListSpectate[src] then return DoNotif(src, "~r~You are already in spectate mode") end
    ListSpectate[src] = true
    SetPlayerRoutingBucket(src, 90505)
    _TriggerClientEvent('league:GoSpectate', src)
    
end)

RegisterCallback("league:IsStartedWithoutMyTeam",  function(source)
    return LeagueIsStartedWithoutMyTeam(source)
end)

_RegisterNetEvent("league:StartLeague", function()
    if not LeagueGlobal.active then return end
    if LeagueGlobal.started then return end

    local howManyPlayers = GetHowManyPlayersInLeague()
    -- if howManyPlayers <= 1 then return DoNotif(LeagueGlobal.host.src, "~r~Not enough players to start the league (min 2 players in team)") end
    LeagueGlobal.started = true

    for k, v in pairs(LeagueGlobal.lobby) do 
        if v.team == "None" then    
            if KickPlayerFromLeague(v.src) then 
                SetPlayerRoutingBucket(v.src, 0)
                Wait(1000)
                _TriggerClientEvent('league:data', v.src, "leave")
                _TriggerClientEvent("league:myTeamData", v.src, "leaveTeam")
                BroadcastLeagueUpdate()
            end
        end
    end
    Wait(1000)
    for k, v in pairs(LeagueGlobal.teams) do 
        for _, player in pairs(v.players) do 
            _TriggerClientEvent('league:data', player.src, "update", LeagueGlobal)
            _TriggerClientEvent('league:StartLeague', player.src)
            _TriggerClientEvent('league:myTeamData', player.src, "initGamertags")
            exports["gamemode"]:AddItem(player.src, "inventory", "weapon_specialcarbine", 1, nil, true)
            exports["gamemode"]:AddItem(player.src, "inventory", "weapon_carbinerifle_mk2", 1, nil, true)
            exports["gamemode"]:AddItem(player.src, "inventory", "weapon_specialcarbine_mk2", 1, nil, true)
            exports["gamemode"]:AddItem(player.src, "inventory", "kuruma", 1, nil, true)
            exports["gamemode"]:AddItem(player.src, "inventory", "revolter", 1, nil, true)
            exports["gamemode"]:AddItem(player.src, "inventory", "kevlar", 1, nil, true)
            exports["gamemode"]:AddItem(player.src, "inventory", "bandage", 1, nil, true)
            BroadcastLeagueUpdate(true)
        end
    end
    _TriggerClientEvent('league:data', -1, "update", LeagueGlobal)

    Citizen.CreateThread(function()
        while LeagueGlobal.started do 
            Wait(1000)
            LeagueTimeActual = LeagueTimeActual - 1  
            GlobalState.LeagueTimeActual = LeagueTimeActual 
            if LeagueTimeActual <= 0 then 
                FinishLeague()
            end
        end
    end)
end)


local webhookDiscord = 'https://discord.com/api/webhooks/1368365413859196998/3VwFscTqWo3YihER1PZgj8CAS3EFVvEEuzwCpIrQKz5vtCNqUId0cDOt_so7VID9o2JJ'
function SendLeagueResultsTeamToDiscord(team, place)
    -- Formatage des informations sur les membres
    local membersInfo = ""
    for _, member in pairs(team.members) do
        membersInfo = membersInfo .. "• " .. member.username .. " - **" .. member.kills .. " kills** (<@"..DiscordId(member.src)..">)\n"
    end
    
    -- Si aucun membre n'est trouvé
    if membersInfo == "" then
        membersInfo = "No members found"
    end
    
    local embed = {
        {
            ["color"] = 3447003, -- Couleur bleu en code décimal
            ["title"] = "**#" .. place .. " - " .. team.name .. "**",
            ["description"] = "**Total: " .. team.kills .. " kills**",
            ["fields"] = {
                {
                    ["name"] = "Team Members",
                    ["value"] = membersInfo,
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "Guild League Results"
            },
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%S')
        }
    }

    local message = {
        username = "League Bot",
        embeds = embed
    }

    -- Envoyer la requête HTTP
    PerformHttpRequest(webhookDiscord, function(err, text, headers) 
        if err == 204 then
            print("Message envoyé avec succès au webhook Discord")
        else
            print("Erreur lors de l'envoi au webhook Discord: " .. tostring(err))
        end
    end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end

-- Nouvelle fonction pour envoyer un récapitulatif de toutes les équipes à Discord
function SendLeagueResultsCompletTeamToDiscord(leaderboardTeam)
    local teamsInfo = ""
    for place, team in ipairs(leaderboardTeam) do
        teamsInfo = teamsInfo .. "#" .. place .. ". **" .. team.name .. "** - " .. team.kills .. " kills\n"
    end
    
    if teamsInfo == "" then
        teamsInfo = "No teams data available"
    end
    
    local embed = {
        {
            ["color"] = 16711680, -- Rouge (peut être changé selon préférence)
            ["title"] = "**Complete League Results**",
            ["description"] = teamsInfo,
            ["footer"] = {
                ["text"] = "Guild League Complete Results"
            },
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%S')
        }
    }

    local message = {
        username = "League Bot",
        embeds = embed
    }

    -- Envoyer la requête HTTP
    PerformHttpRequest(webhookDiscord, function(err, text, headers) 
        if err == 204 then
            print("Récapitulatif des équipes envoyé avec succès")
        else
            print("Erreur lors de l'envoi du récapitulatif des équipes: " .. tostring(err))
        end
    end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end

-- Nouvelle fonction pour envoyer le top 15 des joueurs à Discord
function SendLeagueResultsPlayersToDiscord(leaderboardTeam)
    -- Créer une liste plate de tous les joueurs de toutes les équipes
    local allPlayers = {}
    
    for _, team in ipairs(leaderboardTeam) do
        for _, player in pairs(team.members) do
            table.insert(allPlayers, {
                username = player.username,
                kills = player.kills,
                teamName = team.name
            })
        end
    end
    
    -- Trier tous les joueurs par nombre de kills
    table.sort(allPlayers, function(a, b)
        return a.kills > b.kills
    end)
    
    -- Limiter à 15 joueurs maximum
    local maxPlayers = 15
    if #allPlayers > maxPlayers then
        local tempTable = {}
        for i = 1, maxPlayers do
            table.insert(tempTable, allPlayers[i])
        end
        allPlayers = tempTable
    end
    
    -- Formater les informations des joueurs
    local playersInfo = ""
    for place, player in ipairs(allPlayers) do
        local discordMention = ""
        if player.src and DiscordId(player.src) then
            discordMention = " <@" .. DiscordId(player.src) .. ">"
        end
        
        playersInfo = playersInfo .. "#" .. place .. ". **" .. player.username .. "** (" .. player.teamName .. ") : **" .. player.kills .. " kills**" .. discordMention .. "\n"
    end
    
    if playersInfo == "" then
        playersInfo = "No players data available"
    end
    
    local embed = {
        {
            ["color"] = 65280, -- Vert (peut être changé selon préférence)
            ["title"] = "**Top " .. #allPlayers .. " Players**",
            ["description"] = playersInfo,
            ["footer"] = {
                ["text"] = "Guild League Top Players"
            },
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%S')
        }
    }

    local message = {
        username = "League Bot",
        embeds = embed
    }

    -- Envoyer la requête HTTP
    PerformHttpRequest(webhookDiscord, function(err, text, headers) 
        if err == 204 then
            print("Top des joueurs envoyé avec succès")
        else
            print("Erreur lors de l'envoi du top des joueurs: " .. tostring(err))
        end
    end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end

function FinishLeague()
    if not LeagueGlobal.active then return end
    
    -- IMPORTANT: Collect player data FIRST, before kicking anyone
    local leaderboardTeam = {}
    for k, v in pairs(LeagueGlobal.teams) do 
        table.insert(leaderboardTeam, {
            name = v.name,
            kills = v:GetKills(),
            members = {},
        })
        
        -- Collect all player data for this team
        for _, player in pairs(v.players) do 
            table.insert(leaderboardTeam[#leaderboardTeam].members, {
                username = player.username,
                kills = player.kills,
                src = player.src,
            })
        end
    end

    -- Sort teams by kill count
    table.sort(leaderboardTeam, function(a, b)
        return a.kills > b.kills
    end)
    
    -- NOW kick players AFTER collecting all data
    for k, v in pairs(LeagueGlobal.teams) do 
        for _, player in pairs(v.players) do 
           KickPlayerFromLeague(player.src, true)
           exports["gamemode"]:ClearInventory(player.src, "inventory")
           _TriggerClientEvent('league:data', player.src, "leave")
           _TriggerClientEvent("league:myTeamData", player.src, "leaveTeam")
           SetPlayerRoutingBucket(player.src, 0)
        end
    end
    
    -- 3. Envoyer les détails de chaque équipe individuellement
    for place, team in ipairs(leaderboardTeam) do
        SendLeagueResultsTeamToDiscord(team, place)
        Wait(500)
        if place > 3 then break end
    end

    -- 1. Envoyer le récapitulatif complet des équipes
    SendLeagueResultsCompletTeamToDiscord(leaderboardTeam)
    Wait(500)
    
    -- 2. Envoyer le top des joueurs
    SendLeagueResultsPlayersToDiscord(leaderboardTeam)
    Wait(500)

    LeagueGlobal = {
        teams = {},
        lobby = {},
        league = {},
        map = {},
        host = {
            username = "John Doe",
            src = 1,
            uuid = "1234567890",
        },
        type = "solo", -- duo, trio, solo
        time = 600, -- MS 10 MINUTES
        teamNumber = 2,
        teamMembers = 1,
        active = false,
        started = false,
    }
    _TriggerClientEvent("league:data", -1, "end")
end


AddEventHandler("playerDropped", function()
    local src = source
    if ListSpectate[src] then 
        ListSpectate[src] = nil
    end
    if GetPlayerInLeague(src) then 
        KickPlayerFromLeague(src)
        BroadcastLeagueUpdate()
        exports["gamemode"]:ClearInventory(src, "inventory")
    end
end)

function AddKillToPlayerLeague(src) 
    if not LeagueGlobal.active then return end
    local CheckifPlayerInLeague = GetPlayerInLeague(src)
    if CheckifPlayerInLeague then
        local team = GetPlayerTeam(src)
        if team then 
            team:AddKills()
            team:AddKillsToPlayer(src)
            BroadcastLeagueUpdate(true)
        end
    end
end

-- Helper function to get player coordinates
function GetPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if ped and DoesEntityExist(ped) then
        local coords = GetEntityCoords(ped)
        return {
            x = coords[1],
            y = coords[2],
            z = coords[3]
        }
    end
    return nil
end

