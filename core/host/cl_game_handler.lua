GM.HostMyTeam = nil
GM.HostID = nil
GM.BarHost = nil

local isGamertagsThreadActive = false
local myTeamGamertags = {}

_RegisterNetEvent("host_handler:event", function(type, tblData)
    if type == "team" then
        GM.HostMyTeam = tblData.myTeam
        print("TEAM FOUND, update it", tblData.myTeam.name, tblData.myTeam.id)
        SetupGamertags()    
        SetHealthAndArmour()
        GM.HostID = tblData.id
        killCount = 0
    elseif type == "leaveTeam" then
        GM.HostMyTeam = nil
        SetTimerBarAsNoLongerNeeded(GM.BarHost)
        RefreshHostUI(GM.HostID)
        CleanupGamertags()
        killCount = 0
    end
end)

local function CleanupGamertags()
    for src, gamertagId in pairs(myTeamGamertags) do
        RemoveMpGamerTag(gamertagId)
    end
    myTeamGamertags = {}
    isGamertagsThreadActive = false
end

local function ForceRefreshGamertags()
    print("Force refreshing all gamertags")

    local playersToRefresh = {}
    if GM.HostMyTeam and GM.HostMyTeam.players then
        for k, player in pairs(GM.HostMyTeam.players) do
            -- Skip the local player
            if player.src ~= GetPlayerServerId(PlayerId()) then
                table.insert(playersToRefresh, player)
            end
        end
    end
    
    CleanupGamertags()
    
    if #playersToRefresh > 0 then
        SetupGamertags()
    end
end

local function SetupGamertags()
    if GM.Player.InHostGame and GM.HostMyTeam then
        CleanupGamertags()
        
        if not isGamertagsThreadActive then
            isGamertagsThreadActive = true
            
            CreateThread(function()
                Wait(1000)
                
                local lastForceRefresh = GetGameTimer()
                local forceRefreshInterval = 30000 -- 30 seconds
                
                while GM.Player.InHostGame and GM.HostMyTeam do

                    local currentTime = GetGameTimer()
                    if currentTime - lastForceRefresh > forceRefreshInterval then
                        for src, gamertagId in pairs(myTeamGamertags) do
                            if not IsMpGamerTagActive(gamertagId) then
                                RemoveMpGamerTag(gamertagId)
                                myTeamGamertags[src] = nil
                            end
                        end
                        lastForceRefresh = currentTime
                    end
                    
                    local myPlayerServerId = GetPlayerServerId(PlayerId())

                    
                    -- Create or update gamertags for each player
                    for k, player in pairs(GM.HostMyTeam.players) do
                        
                        -- Skip if this is the local player
                        if player.source == myPlayerServerId then

                        else
                            local playerFromServerId = GetPlayerFromServerId(player.source)
                            
                            -- Some debug to check if we're getting valid player index
                            if playerFromServerId == -1 then

                            end
                            
                            local playerPed = GetPlayerPed(playerFromServerId)
                            
                            -- If player exists and is not the local player
                            if DoesEntityExist(playerPed) and player.source ~= myPlayerServerId then
                                
                                -- Get player position for debug
                                local playerPos = GetEntityCoords(playerPed)
                                local localPos = GetEntityCoords(PlayerPedId())
                                local distance = #(playerPos - localPos)
                                
                                -- Only create/update gamertags for players within a reasonable distance (adjust as needed)
                                local maxDisplayDistance = 500.0 -- 500 meters max distance
                                
                                if distance <= maxDisplayDistance then
                                    if not myTeamGamertags[player.source] then
                                        
                                        -- Format display text
                                        local displayText = string.format("%s (%s) Kills: %s", player.username, player.source, player.kills)
                                        
                                        -- Try different approaches for creating the gamerTag
                                        -- First try with player index
                                        local gamerTagId = CreateMpGamerTag(
                                            playerFromServerId,
                                            displayText,
                                            false, -- isn't networked
                                            false, -- don't show in extended view
                                            "", -- custom player name, we'll use the format directly in the main text
                                            0 -- clan tag
                                        )
                                        
                                        -- If that failed, try with player ped
                                        if gamerTagId == 0 or gamerTagId == -1 then
                                            gamerTagId = CreateMpGamerTag(
                                                playerPed, -- Try directly with ped
                                                displayText,
                                                false,
                                                false,
                                                "",
                                                0
                                            )
                                        end
                                        
                                        if gamerTagId ~= 0 and gamerTagId ~= -1 then
                                            myTeamGamertags[player.source] = gamerTagId
                                            SetMpGamerTagVisibility(gamerTagId, 0, true) -- MP_TAG_VISIBLE
                                            SetMpGamerTagVisibility(gamerTagId, 2, true) -- MP_TAG_HEALTH
                                            SetMpGamerTagVisibility(gamerTagId, 4, true) -- MP_TAG_ARMOUR
                                            
                                            SetMpGamerTagAlpha(gamerTagId, 0, 255) -- Name tag
                                            SetMpGamerTagAlpha(gamerTagId, 2, 255) -- Health
                                            SetMpGamerTagAlpha(gamerTagId, 4, 255) -- Armour
                                            
                                            SetMpGamerTagColour(gamerTagId, 0, 118) -- Name tag (white)
                                            
                                        else
                                            print("ERROR: Failed to create gamerTag for player " .. player.username .. " with both methods")
                                            myTeamGamertags[player.source] = nil
                                        end
                                    else
                                        local gamerTagId = myTeamGamertags[player.source]
                                        if gamerTagId == -1 or gamerTagId == 0 or not IsMpGamerTagActive(gamerTagId) then

                                            if gamerTagId ~= -1 and gamerTagId ~= 0 then
                                                RemoveMpGamerTag(gamerTagId)
                                            end
                                            
                                            local displayText = string.format("%s (%s) Kills: %s", player.username, player.source, player.kills)
                                            local newGamerTagId = CreateMpGamerTag(
                                                playerFromServerId,
                                                displayText,
                                                false, -- isn't networked
                                                false, -- don't show in extended view
                                                "", -- custom player name, we'll use the format directly in the main text
                                                0 -- clan tag
                                            )
                                            
                                            if newGamerTagId ~= 0 then
                                                print("GamerTag recreated successfully with ID: " .. newGamerTagId)
                                                myTeamGamertags[player.source] = newGamerTagId
                                                
                                                SetMpGamerTagVisibility(newGamerTagId, 0, true) -- MP_TAG_VISIBLE
                                                SetMpGamerTagVisibility(newGamerTagId, 2, true) -- MP_TAG_HEALTH
                                                SetMpGamerTagVisibility(newGamerTagId, 4, true) -- MP_TAG_ARMOUR
                                                
                                                SetMpGamerTagAlpha(newGamerTagId, 0, 255) -- Name tag
                                                SetMpGamerTagAlpha(newGamerTagId, 2, 255) -- Health
                                                SetMpGamerTagAlpha(newGamerTagId, 4, 255) -- Armour
                                                
                                                SetMpGamerTagColour(newGamerTagId, 0, 0) -- Name tag (white)
                                                
                                                SetMpGamerTagBigText(newGamerTagId, player.username)
                                            else
                                                print("ERROR: Failed to recreate gamerTag for player " .. player.username)
                                                myTeamGamertags[player.source] = nil
                                            end
                                        else
                                            local displayText = string.format("%s (%s) Kills: %s", player.username, player.source, player.kills)
                                            SetMpGamerTagName(gamerTagId, displayText)
                                            
                                            SetMpGamerTagVisibility(gamerTagId, 0, true)
                                            SetMpGamerTagVisibility(gamerTagId, 2, true) 
                                            SetMpGamerTagVisibility(gamerTagId, 4, true)
                                        end
                                    end
                                else
                                    print("Player " .. player.username .. " is too far away (" .. distance .. "m) - not displaying gamertag")
                                    
                                    if myTeamGamertags[player.source] then
                                        RemoveMpGamerTag(myTeamGamertags[player.source])
                                        myTeamGamertags[player.source] = nil
                                    end
                                end
                            elseif not DoesEntityExist(playerPed) then
                                
                                if myTeamGamertags[player.source] then
                                    RemoveMpGamerTag(myTeamGamertags[player.source])
                                    myTeamGamertags[player.source] = nil
                                end
                            end
                        end
                    end
                    
                    -- Check for players who left and remove their gamertags
                    for src, gamertagId in pairs(myTeamGamertags) do
                        local stillExists = false
                        for k, player in pairs(GM.HostMyTeam.players) do
                            if player.source == src then
                                stillExists = true
                                break
                            end
                        end
                        
                        if not stillExists then
                            RemoveMpGamerTag(gamertagId)
                            myTeamGamertags[src] = nil
                        end
                    end
                    
                    Wait(500) -- Update every half second
                end
                
                CleanupGamertags()
                isGamertagsThreadActive = false
            end)
        end
    else
        if not GM.Player.InHostGame then

        end
        if not GM.HostMyTeam then

        end
    end
end

function insidePolygonHost(point)
    local oddNodes = false
    local zones = GetHostInfo(GM.HostID).game.map.Zones
    local n = #zones
    
    for i = 1, n do
        local j = i % n + 1  -- Next point (loops back to first point)
        
        -- Ray-casting algorithm
        if ((zones[i].y < point.y and zones[j].y >= point.y) or 
            (zones[j].y < point.y and zones[i].y >= point.y)) then
            if (zones[i].x + (point.y - zones[i].y) / (zones[j].y - zones[i].y) * (zones[j].x - zones[i].x) < point.x) then
                oddNodes = not oddNodes
            end
        end
    end
    
    return oddNodes
end

function drawPolyHost(isEntityZone)
    local iPed = PlayerPedId()
    local zones = GetHostInfo(GM.HostID).game.map.Zones
    local n = #zones
    
    for i = 1, n do
        local j = i % n + 1  -- Next point (loops back to first point)
        _drawWallHost(zones[i], zones[j], GetHostInfo(GM.HostID).game.map.color)
    end
end

function _drawWallHost(p1, p2, color)
    local bottomLeft = vector3(p1.x, p1.y, p1.z - 20.0)
    local topLeft = vector3(p1.x, p1.y, p1.z + GetHostInfo(GM.HostID).game.map.High) 
    local bottomRight = vector3(p2.x, p2.y, p2.z - 20.0)
    local topRight = vector3(p2.x, p2.y, p2.z + GetHostInfo(GM.HostID).game.map.High)

    DrawPoly(bottomLeft, topLeft, bottomRight, color.r, color.g, color.b, color.a)
    DrawPoly(topLeft, topRight, bottomRight, color.r, color.g, color.b, color.a)
    DrawPoly(bottomRight, topRight, topLeft, color.r, color.g, color.b, color.a)
    DrawPoly(bottomRight, topLeft, bottomLeft, color.r, color.g, color.b, color.a)
end

function RespawnPlayerHost()
    local teamId = GetTeamByPlayer(GM.Player.UUID)

    local spawnTeam1 = GetHostInfo(GM.HostID).game.map.coordsRespawnEquipe1 
    local spawnTeam2 = GetHostInfo(GM.HostID).game.map.coordsRespawnEquipe2  
    local coordsSafe = nil
    if teamId == 1 then
        coordsSafe = spawnTeam1
    else
        coordsSafe = spawnTeam2
    end

    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityCoords(PlayerPedId(), coordsSafe.x, coordsSafe.y, coordsSafe.z)
    SetEntityHeading(PlayerPedId(), coordsSafe.w)
    SetCanAttackFriendly(GetPlayerPed(-1), true)
    NetworkSetFriendlyFireOption(true)
end

function RefreshLeaderboardHost(leaderboard)
    if GM.Player.InHostGame or GM.Player.InHostGameSpectate then 
        SendNUIMessage({
            type = "showFFA",
            show = true,
            scores = leaderboard, -- TODO : FIX
            myScore = {
                kills = (killCount and killCount or 0)
            }
        })
    end
end

_RegisterNetEvent("host_handler:event:startGame", function()
    GM.Player.InHostLobby = false 
    if GM.Player.InHostPanel then  
        CloseHostPanel()
    end
    SetDisableInventoryMoveState(true)
    SendNUIMessage({
        type = "cc",
        movestatus = true
    })
    SetEntityInvincible(PlayerPedId(), false)
    SetupHost()
end)

function SetupHost()
    GM.Player.InHostGame = true 
    GM.Player.InHostLobby = false 
    GM.Player.InHostPanel = false 

    SetEntityInvincible(PlayerPedId(), false)
    RespawnPlayerHost()

    local currentTime = GetGameTimer()
    local endTime = currentTime + (GetHostInfo(GM.HostID).time * 1000) -- Conversion en millisecondes
    GM.BarHost = AddTimerBar("Time remaining", {
        endTime = endTime,
    })
    SetEntityInvincible(PlayerPedId(), false)

    SetEntityInvincible(PlayerPedId(), false)

    CreateThread(function() 
        while GM.Player.InHostGame do
            Wait(0)
            local point = GetEntityCoords(PlayerPedId(), true)
            local inZone = insidePolygonHost(point)
            drawPolyHost(inZone)
            if inZone then
                -- SetCanAttackFriendly(GetPlayerPed(-1), true)
                -- NetworkSetFriendlyFireOption(true)
                -- SetEntityInvincible(PlayerPedId(), false)
            else
                -- SetCanAttackFriendly(GetPlayerPed(-1), false)
                -- NetworkSetFriendlyFireOption(false)
                -- SetEntityInvincible(PlayerPedId(), true)
                -- drawPoly(inZone)
                DrawCenterText("Drive to the fight zone and kill the most players.", 1000)

    
                SetTimeout(1000, function() 
                    SetCanAttackFriendly(GetPlayerPed(-1), true)
                    NetworkSetFriendlyFireOption(true)
                    SetEntityInvincible(PlayerPedId(), false)
                end)
            end
        end
    end)
end