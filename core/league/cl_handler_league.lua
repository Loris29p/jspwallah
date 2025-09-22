GM.MyTeamData = nil
GM.BarLeague = nil
local isGamertagsThreadActive = false
local myTeamGamertags = {}

-- Safe JSON encode function that returns a string even if encoding fails
local function SafeJsonEncode(data)
    local status, result = pcall(function() return json.encode(data) end)
    if status then
        return result
    else
        return "[Failed to encode data]"
    end
end

_RegisterNetEvent("league:myTeamData", function(type, data)
    if type == "initData" then
        -- Clean up any existing gamertags before initializing new ones
        CleanupGamertags()

        GM.MyTeamData = data
        changeModel(GM.MyTeamData.ped)
        RefreshLeagueUI()

        -- Setup gamertags once after a small delay
        Citizen.SetTimeout(500, function()
            if GM.MyTeamData then
                SetupGamertags()
                SetHealthAndArmour()
            end
        end)
    elseif type == "leaveTeam" then 
        print("Player left team")
        GM.MyTeamData = nil
        _TriggerEvent("skinchanger:loadSkin", GM.Player.Skin)
        SetTimerBarAsNoLongerNeeded(GM.BarLeague)
        RefreshLeagueUI()
        CleanupGamertags() -- Clean up gamertags when leaving team
    elseif type == "update" then
        GM.MyTeamData = data
        RefreshLeagueUI()
        -- Don't recreate gamertags on update, just refresh the UI
    elseif type == "initGamertags" then
        -- Only setup gamertags if we don't have any active ones
        if not isGamertagsThreadActive then
            SetupGamertags()
        end
    end
end)

function CleanupGamertags()
    for src, gamertagId in pairs(myTeamGamertags) do
        RemoveMpGamerTag(gamertagId)
    end
    myTeamGamertags = {}
    isGamertagsThreadActive = false
end

function ForceRefreshGamertags()
    print("Force refreshing all gamertags")

    local playersToRefresh = {}
    if GM.MyTeamData and GM.MyTeamData.players then
        for k, player in pairs(GM.MyTeamData.players) do
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

function SetupGamertags()
    if GM.Player.InLeague and GM.MyTeamData then
        -- Always cleanup existing gamertags before setting up new ones
        CleanupGamertags()

        -- Add a small delay to ensure cleanup is complete
        Wait(100)

        if not isGamertagsThreadActive then
            isGamertagsThreadActive = true

            CreateThread(function()
                Wait(1000)
                
                local lastForceRefresh = GetGameTimer()
                local forceRefreshInterval = 30000 -- 30 seconds
                
                while GM.Player.InLeague and GM.MyTeamData do

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
                    for k, player in pairs(GM.MyTeamData.players) do

                        -- Skip if this is the local player
                        if player.src == myPlayerServerId then
                            -- Skip local player
                        else
                            local playerFromServerId = GetPlayerFromServerId(player.src)
                            
                            -- Some debug to check if we're getting valid player index
                            if playerFromServerId == -1 then

                            end
                            
                            local playerPed = GetPlayerPed(playerFromServerId)
                            
                            -- If player exists and is not the local player
                            if DoesEntityExist(playerPed) and player.src ~= myPlayerServerId then
                                
                                -- Get player position for debug
                                local playerPos = GetEntityCoords(playerPed)
                                local localPos = GetEntityCoords(PlayerPedId())
                                local distance = #(playerPos - localPos)
                                
                                -- Only create/update gamertags for players within a reasonable distance (adjust as needed)
                                local maxDisplayDistance = 500.0 -- 500 meters max distance
                                
                                if distance <= maxDisplayDistance then
                                    if not myTeamGamertags[player.src] then
                                        
                                        -- Format display text
                                        local displayText = string.format("%s (%s) Kills: %s", player.username, player.src, player.kills)
                                        
                                        -- Try different approaches for creating the gamerTag
                                        -- First try with player index
                                        -- Use player ped directly for CreateMpGamerTag
                                        local gamerTagId = CreateMpGamerTag(
                                            playerPed, -- Use ped directly, not server ID
                                            displayText,
                                            false, -- isn't networked
                                            false, -- don't show in extended view
                                            "", -- custom player name
                                            0 -- clan tag
                                        )
                                        
                                        if gamerTagId ~= 0 and gamerTagId ~= -1 then
                                            myTeamGamertags[player.src] = gamerTagId
                                            SetMpGamerTagVisibility(gamerTagId, 0, true) -- MP_TAG_VISIBLE
                                            SetMpGamerTagVisibility(gamerTagId, 2, true) -- MP_TAG_HEALTH
                                            SetMpGamerTagVisibility(gamerTagId, 4, true) -- MP_TAG_ARMOUR
                                            
                                            SetMpGamerTagAlpha(gamerTagId, 0, 255) -- Name tag
                                            SetMpGamerTagAlpha(gamerTagId, 2, 255) -- Health
                                            SetMpGamerTagAlpha(gamerTagId, 4, 255) -- Armour
                                            
                                            SetMpGamerTagColour(gamerTagId, 0, 118) -- Name tag (white)
                                            
                                        else
                                            print("ERROR: Failed to create gamerTag for player " .. player.username .. " with both methods")
                                            myTeamGamertags[player.src] = nil
                                        end
                                    else
                                        local gamerTagId = myTeamGamertags[player.src]
                                        if gamerTagId == -1 or gamerTagId == 0 or not IsMpGamerTagActive(gamerTagId) then

                                            if gamerTagId ~= -1 and gamerTagId ~= 0 then
                                                RemoveMpGamerTag(gamerTagId)
                                            end
                                            
                                            local displayText = string.format("%s (%s) Kills: %s", player.username, player.src, player.kills)
                                            local newGamerTagId = CreateMpGamerTag(
                                                playerPed, -- Use ped, not server ID
                                                displayText,
                                                false, -- isn't networked
                                                false, -- don't show in extended view
                                                "", -- custom player name
                                                0 -- clan tag
                                            )
                                            
                                            if newGamerTagId ~= 0 then
                                                print("GamerTag recreated successfully with ID: " .. newGamerTagId)
                                                myTeamGamertags[player.src] = newGamerTagId
                                                
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
                                                myTeamGamertags[player.src] = nil
                                            end
                                        else
                                            local displayText = string.format("%s (%s) Kills: %s", player.username, player.src, player.kills)
                                            SetMpGamerTagName(gamerTagId, displayText)
                                            
                                            SetMpGamerTagVisibility(gamerTagId, 0, true)
                                            SetMpGamerTagVisibility(gamerTagId, 2, true) 
                                            SetMpGamerTagVisibility(gamerTagId, 4, true)
                                        end
                                    end
                                else
                                    print("Player " .. player.username .. " is too far away (" .. distance .. "m) - not displaying gamertag")
                                    
                                    if myTeamGamertags[player.src] then
                                        RemoveMpGamerTag(myTeamGamertags[player.src])
                                        myTeamGamertags[player.src] = nil
                                    end
                                end
                            elseif not DoesEntityExist(playerPed) then
                                
                                if myTeamGamertags[player.src] then
                                    RemoveMpGamerTag(myTeamGamertags[player.src])
                                    myTeamGamertags[player.src] = nil
                                end
                            end
                        end
                    end
                    
                    -- Check for players who left and remove their gamertags
                    for src, gamertagId in pairs(myTeamGamertags) do
                        local stillExists = false
                        for k, player in pairs(GM.MyTeamData.players) do
                            if player.src == src then
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
        if not GM.Player.InLeague then

        end
        if not GM.MyTeamData then

        end
    end
end 

function insidePolygon(point)
    local oddNodes = false
    local zones = GM.League.map.Zones
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

function drawPoly(isEntityZone)
    local iPed = PlayerPedId()
    local zones = GM.League.map.Zones
    local n = #zones
    
    for i = 1, n do
        local j = i % n + 1  -- Next point (loops back to first point)
        _drawWall(zones[i], zones[j], GM.League.map.color)
    end
end

function _drawWall(p1, p2, color)
    local bottomLeft = vector3(p1.x, p1.y, p1.z - 20.0)
    local topLeft = vector3(p1.x, p1.y, p1.z + GM.League.map.High) 
    local bottomRight = vector3(p2.x, p2.y, p2.z - 20.0)
    local topRight = vector3(p2.x, p2.y, p2.z + GM.League.map.High)

    DrawPoly(bottomLeft, topLeft, bottomRight, color.r, color.g, color.b, color.a)
    DrawPoly(topLeft, topRight, bottomRight, color.r, color.g, color.b, color.a)
    DrawPoly(bottomRight, topRight, topLeft, color.r, color.g, color.b, color.a)
    DrawPoly(bottomRight, topLeft, bottomLeft, color.r, color.g, color.b, color.a)
end

function SetHealthAndArmour()
    SetEntityMaxHealth(PlayerPedId(), 200)
    SetEntityHealth(PlayerPedId(), 200)
    SetPlayerMaxArmour(PlayerPedId(), 100)
    SetPedArmour(PlayerPedId(), 100)
end



function RespawnPlayerLeague()
    local coordsSafe = GM.League.map.coordsRespawn
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityCoords(PlayerPedId(), coordsSafe.x, coordsSafe.y, coordsSafe.z)
    SetEntityHeading(PlayerPedId(), coordsSafe.w)
    SetCanAttackFriendly(GetPlayerPed(-1), true)
    NetworkSetFriendlyFireOption(true)
end

function RefreshLeaderboard(leaderboard)
    if GM.Player.InLeague or GM.Player.InSpectateModeLeague then 
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

function SetupLeague()
    GM.Player.InLeague = true
    GM.Player.LeagueLobby = false
    SetEntityInvincible(PlayerPedId(), false)
    RespawnPlayerLeague()
    local currentTime = GetGameTimer()
    local endTime = currentTime + (GM.League.time * 1000) -- Conversion en millisecondes
    GM.BarLeague = AddTimerBar("Time remaining", {
        endTime = endTime,
    })
    SetEntityInvincible(PlayerPedId(), false)
    -- Register a command to force refresh gamertags for debug purposes
    RegisterCommand("refreshtags", function()
        if GM.Player.InLeague and GM.MyTeamData then
            exports["kUI"]:NewNotification("Force refreshing gamertags...", 3000)
            ForceRefreshGamertags()
        else
            exports["kUI"]:NewNotification("You must be in a league team to refresh tags", 3000)
        end
    end, false)

    CreateThread(function() 
        while GM.Player.InLeague do
            Wait(0)
            local point = GetEntityCoords(PlayerPedId(), true)
            local inZone = insidePolygon(point)
            drawPoly(inZone)
            if inZone then
                -- SetCanAttackFriendly(GetPlayerPed(-1), true)
                -- NetworkSetFriendlyFireOption(true)
                -- SetEntityInvincible(PlayerPedId(), false)
                DrawCenterText("Kill the most hostile players in the fight zone.", 1000)
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