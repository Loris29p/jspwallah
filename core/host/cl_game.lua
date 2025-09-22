ListActiveHost = {}
imHost = false

GM.Player.InHostLobby = false 
GM.Player.InHostPanel = false 
GM.Player.InHostGame = false
GM.Player.InHostGameSpectate = false

function GetTeamByPlayer(uuid)
    for k, v in pairs(ListActiveHost) do
        for k2, v2 in pairs(v.game.listPlayers) do
            if v2.uuid == uuid then
                return v2.teamId
            end
        end
    end
    return false
end

function GetTeamInfo(teamId)
    for k, v in pairs(ListActiveHost) do
        for k2, v2 in pairs(v.ListEquipe) do
            if v2.id == teamId then
                return v2
            end
        end
    end
    return false
end

function GetHostIDByPlayer(uuid)
    for k, v in pairs(ListActiveHost) do
        for k2, v2 in pairs(v.game.listPlayers) do
            if v2.uuid == uuid then
                return k
            end
        end
    end
    return false
end

function CheckHost(uuid)
    for k, v in pairs(ListActiveHost) do
        if v.game.ownerUUID == uuid then
            return k
        end
    end
    return false
end

function GetHostInfo(hostId)
    if not ListActiveHost[hostId] then return false end
    return ListActiveHost[hostId]
end

_RegisterNetEvent("host_handler:event", function(type, tblData)
    if type == "createHost" then
        ListActiveHost[tblData.id] = tblData.data
        if ListActiveHost[tblData.id].game.ownerUUID == GM.Player.UUID then
            imHost = true
            ShowAboveRadarMessage("Look your chat for the host id")
        end
    elseif type == "updateHost" then
        ListActiveHost[tblData.id] = tblData.data
        RefreshLeaderboardHost(tblData.leaderboard)
        print("updateHost")
    elseif type == "updateLeaderboard" then
        RefreshLeaderboardHost(tblData.leaderboard)
    elseif type == "deleteHost" then 
        if imHost then
            imHost = false 
        end
        ListActiveHost[tblData.id] = nil
    elseif type == "removed" then
        local pPed = PlayerPedId()
        local lobby = vec3(250.5532, -1399.933, 30.52891)
        local heading = 78.6264
        TeleportToWp(pPed, lobby, heading, false, function()
            -- TODO : Modify the notification maybe?
            ShowAboveRadarMessage("~g~You have been teleported to the Safe-Zone")
            SetDisableInventoryMoveState(false)
            SendNUIMessage({
                type = "cc",
                movestatus = false
            })
        end)
        GM.HostID = nil
        GM.Player.InHostLobby = false
        GM.Player.InHostPanel = false
        GM.Player.InHostGame = false
        SendNUIMessage({
            type = "showFFA",
            show = false,
        })
    elseif type == "joinHost" then
        -- TODO : AA
        local pPed = PlayerPedId() 
        local lobby = vec3(-1266.524, -3029.621, -48.49195) 
        GM.Player.InHostLobby = true

        TeleportToWp(pPed, lobby, 1.467792, false, function()
            ShowAboveRadarMessage("~g~You have been teleported to the lobby")
            InitalizeHost()
        end)
    elseif type == "refreshUI" then
        RefreshHostUI(tblData.id)
    end
end)

function InitalizeHost()
    SetEntityInvincible(PlayerPedId(), true)
    SetDisableInventoryMoveState(true)
    SendNUIMessage({
        type = "cc",
        movestatus = true
    })
    Citizen.CreateThread(function() 
        while GM.Player.InHostLobby do 
            Wait(1) 
            DrawTopNotification("Press ~INPUT_CELLPHONE_CAMERA_FOCUS_LOCK~ to open host panel.")
            DrawCenterText("Your team is : ~b~"..(GM.HostMyTeam and GM.HostMyTeam.name or "None"), 1000)
            if IsControlJustPressed(0, 182) then
                if not GM.Player.InHostPanel and not GM.Player.InHostGame then
                    OpenHostPanel(GetHostIDByPlayer(GM.Player.UUID))
                else
                    CloseHostPanel()
                end
            end
        end
    end)
end

function RefreshHostUI(hostId)

    local isUIVisible = false 

    if GM.Player.InHostPanel then
        isUIVisible = true
    end
    
    if not isUIVisible then return end
    
    local playerData = {
        name = GM.Player.Username,
        uuid = GM.Player.UUID
    }
    
    local hostData = {}
    if ListActiveHost[hostId] and ListActiveHost[hostId].ListEquipe then
        hostData = ListActiveHost[hostId].ListEquipe
    end

    local myTeamId = nil
    if GM.HostMyTeam then
        myTeamId = GM.HostMyTeam.id
    end
    
    SendNUIMessage({
        type = "refreshLeague",
        panelType = "host",
        player = playerData,
        teams = hostData,
        currentTeamId = myTeamId
    })
end

function OpenHostPanel(hostId)
    if not ListActiveHost[hostId] then 
        print("Cannot open host panel: No host data")
        return 
    end
    
    GM.Player.InHostPanel = true
    local playerData = {
        name = GM.Player.Username,
        uuid = GM.Player.UUID
    }

    local myTeamId = nil  
    if GM.HostMyTeam then
        myTeamId = GM.HostMyTeam.id
    end

    SendNUIMessage({
        type = "openPanelLeague",
        panelType = "host",
        player = playerData,
        teams = ListActiveHost[hostId].ListEquipe,
        currentTeamId = myTeamId
    })
    SetNuiFocus(true, true)
end

function CloseHostPanel()
    GM.Player.InHostPanel = false
    SendNUIMessage({
        type = "closePanelLeague"
    })
    SetNuiFocus(false, false)
end

RegisterNUICallback("host:joinTeam", function(data, cb)
    local teamId = data.teamId
    print("joinTeam", teamId)
    Tse("host_server:event:joinTeam", teamId)
end)

RegisterNUICallback("host:leaveTeam", function(data, cb)
    local teamId = data.teamId
    print("leaveTeam", teamId)
    Tse("host_server:event:leaveTeam", teamId)
end)

RegisterNUICallback("closePanelHost", function(data)
    if GM.Player.InHostPanel then
        CloseHostPanel()
    end
end)