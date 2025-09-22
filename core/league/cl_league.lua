GM.Player.LeagueLobby = false 
GM.Player.InLeague = false 
GM.Player.LeaguePanelOpen = false

GM.League = nil

LeaguePeds = nil

local spawnLeague = vector4(-1266.524, -3029.621, -48.49021, 1.467792)


_RegisterNetEvent("league:data", function(type, data, leaderboard)
    if type == "init" then
        GM.League = data
        RefreshLeagueUI()
        print('Create Peds League')
        LeaguePeds = CreatePedAction({
            pedType = 4,
            pos = vector4(227.3881, -1381.925, 30.44476, 150.7903),
            model = "mp_m_securoguard_01",
            weapon = "weapon_combatmg",
            action = function()
                if not GM.Player.InDarkzone and not GM.Player.InFarm and not GM.Player.Afk then 
                    if GM.League.started then
                        -- Si la league a déjà commencé, rejoindre en mode spectateur
                        if not GM.Player.InSpectateModeLeague then
                            ExecuteCommand("joinleague")
                        else
                            ShowAboveRadarMessage("~r~You are already spectating the league")
                        end
                    else
                        -- Si la league n'a pas commencé, rejoindre normalement
                        if not GM.Player.InLeague and not GM.Player.LeagueLobby then 
                            ExecuteCommand("joinleague")
                        else 
                            ShowAboveRadarMessage("~r~You are already in the league")
                        end
                    end
                else 
                    ShowAboveRadarMessage("~r~You cannot join the league in this state")
                end
            end,
            drawText = "[ ~r~LEAGUE - WAITING FOR PLAYERS ~s~]", 
            distanceLimit = 1.5,
            distanceShowText = 20.0,
        })
        print('Create Peds League 2', LeaguePeds)
    elseif type == "update" then
        GM.League = data
        if GM.League.started then 
            if LeaguePeds then 
                ChangeDrawText(LeaguePeds, "[ ~r~LEAGUE - ~s~STARTED ]")
            end
        end
        RefreshLeagueUI()
        if leaderboard then
            RefreshLeaderboard(leaderboard)
        end
    elseif type == "leave" then
        LeaveLeague()
        SendNUIMessage({
            type = "showFFA",
            show = false,
        })
    elseif type == "announce" then
        if not GM.League then return end
        if not GM.League.active then return end
        if GM.League.started then return end
        exports["kUI"]:NewNotification("League available! Hosted by "..GM.League.host.username, 6000)
    elseif type == "end" then
        if LeaguePeds then 
            DestroyPedAction(LeaguePeds)
        end
        GM.League = nil
        GM.Player.LeagueLobby = false
        GM.Player.InLeague = false
        GM.Player.LeaguePanelOpen = false
        GM.Player.InSpectateModeLeague = false
    end
end)

_RegisterNetEvent("league:init", function()
    InitializeLeague()
end)

-- Event to force refresh the UI when someone joins/leaves a team
_RegisterNetEvent("league:refreshUI", function()
    RefreshLeagueUI()
end)

_RegisterNetEvent("league:StartLeague", function()
    print("START LEAGUE")
    GM.Player.LeagueLobby = false
    if GM.Player.LeaguePanelOpen then  
        CloseLeaguePanel()
    end
    SetDisableInventoryMoveState(true)
    SendNUIMessage({
        type = "cc",
        movestatus = true
    })
    SetEntityInvincible(PlayerPedId(), false)
    SetupLeague()
end)

-- Function to refresh the league UI with current data
function RefreshLeagueUI()
    -- Check if the UI is visible by checking if the container is displayed
    local isUIVisible = false
    
    -- We can't directly check NUI focus state, but we can track our own state                             
    if GM.Player.LeaguePanelOpen then
        isUIVisible = true
    end
    
    if not isUIVisible then return end
    
    -- Prepare player data
    local playerData = {
        name = GM.Player.Username,
        uuid = GM.Player.UUID
    }
    
    -- Log data for debugging
    print("Refreshing UI with player data:", GM.Player.Username, GM.Player.UUID)
    
    -- Create a copy of the league data
    local leagueData = {}
    if GM.League and GM.League.teams then
        leagueData = GM.League.teams
        print("Teams data available for refresh:", #leagueData)
    else
        print("Warning: No league data available for refresh")
    end
    
    -- Ajout: Affiche explicitement dans quelle équipe se trouve le joueur
    local myTeamId = nil
    if GM.MyTeamData then
        myTeamId = GM.MyTeamData.id
        print("Player is in team:", GM.MyTeamData.name, "ID:", myTeamId)
    end
    
    -- Send refresh message to NUI with information about player's current team
    SendNUIMessage({
        type = "refreshLeague",
        player = playerData,
        teams = leagueData,
        currentTeamId = myTeamId
    })
end

-- New function to open the league panel UI
function OpenLeaguePanel()
    if not GM.League then 
        print("Cannot open league panel: No league data")
        return 
    end
    
    if not GM.League.active then 
        print("Cannot open league panel: League not active")
        return 
    end
    
    -- Set our tracking variable
    GM.Player.LeaguePanelOpen = true
    
    -- Prepare player and teams data for UI
    local playerData = {
        name = GM.Player.Username,
        uuid = GM.Player.UUID
    }
    
    -- Log data for debugging
    print("Opening league panel with player data:", GM.Player.Username, GM.Player.UUID)
    
    -- Ajout: Récupère l'ID de l'équipe actuelle du joueur
    local myTeamId = nil
    if GM.MyTeamData then
        myTeamId = GM.MyTeamData.id
        print("Player is in team:", GM.MyTeamData.name, "ID:", myTeamId)
    end
    
    -- Send data to NUI
    SendNUIMessage({
        type = "openPanelLeague",
        panelType = "league",
        player = playerData,
        teams = GM.League.teams,
        currentTeamId = myTeamId
    })
    
    -- Set NUI focus to allow interaction
    SetNuiFocus(true, true)
end

-- Close the league panel UI
function CloseLeaguePanel()
    -- Set our tracking variable
    GM.Player.LeaguePanelOpen = false
    
    SendNUIMessage({
        type = "closePanelLeague"
    })
    
    -- Remove NUI focus
    SetNuiFocus(false, false)
end


local tempsCoords = nil

-- NUI callback for when a player joins a team
RegisterNUICallback("league:joinTeam", function(data, cb)
    local teamId = data.teamId
    print(teamId, "TEAM ID")
    -- Call server-side function to join the team
    TriggerServerEvent("league:joinTeam", teamId)
    
    -- Send success response back to UI
    cb({
        status = "success"
    })
end)

-- NUI callback for when a player leaves a team
RegisterNUICallback("league:leaveTeam", function(data, cb)
    local teamId = data.teamId
    -- Call server-side function to leave the team
    TriggerServerEvent("league:leaveTeam", teamId)
    
    -- Send success response back to UI
    cb({
        status = "success"
    })
end)

RegisterNUICallback("closePanelLeague", function(data)
    if GM.Player.LeaguePanelOpen then
        print("Closing league panel")
        CloseLeaguePanel()
        cb({
            status = "success"
        })
    end
end)

function LeaveLeague()
    if GM.Player.LeagueLobby then
        CloseLeaguePanel()
        GM.Player.LeagueLobby = false
    end 

    if GM.Player.InLeague then
        CloseLeaguePanel()
    end
    local player = GM.Player:Get()
    if player.Dead then 
        Revive(PlayerPedId(), true, true)
    end
    Wait(500)
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(PlayerPedId(), tempsCoords.x, tempsCoords.y, tempsCoords.z)
    Wait(500)
    DoScreenFadeIn(500)
    SetDisableInventoryMoveState(false)
    SendNUIMessage({
        type = "cc",
        movestatus = false
    })
    GM.Player.InLeague = false
    SetEntityInvincible(PlayerPedId(), false)
end

function InitializeLeague(tblData)
    if not GM.League then return end
    if not GM.League.active then return end
    if GM.Player.InLeague then  return end
    if GM.Player.LeagueLobby then return end
    GM.Player.LeagueLobby = true
    DoScreenFadeOut(500)
    Wait(500)
    RequestCollisionAtCoord(spawnLeague.x, spawnLeague.y, spawnLeague.z)
    Wait(200)
    TeleportPlayerCoords(spawnLeague, PlayerPedId())
    Wait(500)
    DoScreenFadeIn(500)
    SetEntityInvincible(PlayerPedId(), true)
    SetDisableInventoryMoveState(true)
    SendNUIMessage({
        type = "cc",
        movestatus = true
    })
    Citizen.CreateThread(function() 
        while GM.Player.LeagueLobby do 
            Wait(1) 
            DrawTopNotification("Press ~INPUT_CELLPHONE_CAMERA_FOCUS_LOCK~ to open league panel.")
            -- SetCanAttackFriendly(GetPlayerPed(-1), false, false)
            -- NetworkSetFriendlyFireOption(false)
            -- SetEntityInvincible(PlayerPedId(), true)
            DrawCenterText("Your team is : ~b~"..(GM.MyTeamData and GM.MyTeamData.name or "None"), 1000)
            if IsControlJustPressed(0, 182) then
                if not GM.Player.LeaguePanelOpen and not GM.Player.InLeague then
                    OpenLeaguePanel()
                else
                    CloseLeaguePanel()
                end
            end
        end
    end)
end

-- Add event to teleport player when exiting spectate mode
_RegisterNetEvent("league:TeleportToCoords", function(coords)
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    Wait(500)
    DoScreenFadeIn(500)
end)

RegisterCommand("joinleague", function()    
    if GM.Player.Data.league_ban then 
        return ShowAboveRadarMessage("~r~You are banned from league ("..GM.Player.Data.league_ban.author..")")
    end
    if not GM.League then return ShowAboveRadarMessage("~r~No league is currently active") end 
    if not GM.League.active then return ShowAboveRadarMessage("~r~No league is currently active") end 
    if GM.Player.InSpectateModeLeague then return ShowAboveRadarMessage("~r~You are already in spectate mode") end
    if GM.League.started then 
        print("League already started", GM.League.started)
        local isStartedWithoutMyTeam = CallbackServer("league:IsStartedWithoutMyTeam")
        if isStartedWithoutMyTeam then 
            -- Enter spectate mode for an ongoing league
            ShowAboveRadarMessage("~g~Joining the league as a spectator (2)...")
            tempsCoords = GetEntityCoords(PlayerPedId())
            DoScreenFadeOut(500)
            Wait(500)
            Tse("league:GoToSpectate")
            Wait(500)
            DoScreenFadeIn(500)
            return 
        end
    end
    if GM.Player.InLeague then return ShowAboveRadarMessage("~r~You are already in the league") end  
    if GM.Player.LeagueLobby then return ShowAboveRadarMessage("~r~You are already in the league lobby") end  
    if GM.Player.InSelecGamemode then return ShowAboveRadarMessage("~r~You are in selection gamemode") end 
    if not GM.Player.InSafeZone then return ShowAboveRadarMessage("~r~You must be in a safe zone to join the league") end 
    ShowAboveRadarMessage("~g~Joining the league...")
    tempsCoords = GetEntityCoords(PlayerPedId())
    Tse("league:joinLeague")
end)