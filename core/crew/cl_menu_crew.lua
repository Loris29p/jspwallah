RegisterNUICallback('createCrew', function(data, cb)
    if not data then return end

    if not data.crewName or not data.crewTag or not data.crewDescription then
        return cb({
            success = false,
            message = "Invalid data"
        })
    end

    Tse("PREFIX_PLACEHOLDER:c:CreateCrew", {
        crewName = data.crewName,
        crewTag = data.crewTag,
        crewDesc = data.crewDescription,
        NewbieRanklabel = "Newbie",
    })

    SendNUIMessage({
        type = "sendCrewData",
        haveCrew = true,
        isLeader = true,
        crewName = data.crewName,
        crewTag = data.crewTag,
        crewDescription = data.crewDescription,
        crewTotalKills = 0,
        crewTotalKillsRedzone = 0,
        crewTotalAirdrops = 0,
        crewTotalCupWins = 0,
        crewMembers = {}
    })

    cb({
        success = true,
        message = "Crew created successfully"
    })
end)

RegisterNUICallback('editCrewInfo', function(data, cb)
    if not data then return end

    if not data.crewTag or not data.crewDescription then
        return cb({
            success = false,
            message = "Invalid data"
        })
    end

    Tse("PREFIX_PLACEHOLDER:c:ChangeCrewTag", {
        crewTag = data.crewTag,
    })
    Tse("PREFIX_PLACEHOLDER:c:ChangeCrewDesc", {
        description = data.crewDescription,
    })

    cb({
        success = true,
        message = "Crew info updated successfully"
    })
end)

RegisterNUICallback('leaveCrew', function(data, cb)
    local isLeave =  CallbackServer("callback:crew:LeaveCrew")
    if isLeave then
        cb({
            success = true,
            message = "Crew left successfully"
        })
    end
end)

RegisterNUICallback('crewKickMember', function(data, cb)
    if not data then return end

    Tse("PREFIX_PLACEHOLDER:c:RemoveMembers", {
        uuid = data.memberId
    })
    print("crewKickMember", data.memberId)
    SendCrewData()
end)

RegisterNUICallback('crewPromoteMember', function(data, cb)
    if not data then return end

    Tse("PREFIX_PLACEHOLDER:c:UpgradeCrewMembers", {
        targetUUID = data.memberId,
        rank = data.rank
    })
    SendCrewData()
end)

RegisterNUICallback('crewDemoteMember', function(data, cb)
    if not data then return end

    Tse("PREFIX_PLACEHOLDER:c:DemoteCrewMembers", {
        targetUUID = data.memberId,
        rank = "newbie"
    })
    SendCrewData()
end)

RegisterNUICallback('inviteToCrew', function(data, cb)
    if not data then return end
    -- Tse("PREFIX_PLACEHOLDER:c:InvitePlayer", {
    --     target = data.target
    -- })
    -- SendCrewData()
    print("inviteToCrew", data)
    local result = KeyboardInput("Enter the player id", "", 20)
    if tonumber(result) then
        print("inviteToCrew", tonumber(result))
        Tse("PREFIX_PLACEHOLDER:c:InvitePlayer", {
            target = tonumber(result)
        })
    end
end)

function SendCrewData()
    SendNUIMessage({
        type = "sendCrewData",
        haveCrew = CrewData ~= nil,
        isLeader = CrewData.myRank == "leader",
        crewName = CrewData.crewName,
        crewTag = CrewData.crewTag,
        crewDescription = CrewData.description,
        crewTotalKills = CrewData.kills,
        crewTotalKillsRedzone = CrewData.killsRedzone,
        crewTotalAirdrops = CrewData.aidropTaken,
        crewTotalCupWins = CrewData.cupWin,
        crewMembers = CrewData.members,
        rankList = CrewData.rankList,
        flag = CrewData.flag
    })
end

RegisterNUICallback('getCrewData', function(data, cb)
    if not CrewData then return cb("nocrew") end

    SendNUIMessage({
        type = "sendCrewData",
        haveCrew = CrewData ~= nil,
        isLeader = CrewData.myRank == "leader",
        crewName = CrewData.crewName,
        crewTag = CrewData.crewTag,
        crewDescription = CrewData.description,
        crewTotalKills = CrewData.kills,
        crewTotalKillsRedzone = CrewData.killsRedzone,
        crewTotalAirdrops = CrewData.aidropTaken,
        crewTotalCupWins = CrewData.cupWin,
        crewMembers = CrewData.members,
        rankList = CrewData.rankList,
        flag = CrewData.flag
    })
end)

RegisterNetEvent("PREFIX_PLACEHOLDER:c:ReceiveLeaveCrew", function()
    -- local isLeave =  CallbackServer("callback:crew:LeaveCrew")
    -- if isLeave then
    --     SendNUIMessage({
    --         type = "sendCrewData",
    --         haveCrew = false,
    --         isLeader = false,
    --         crewName = "CREW",
    --         crewTag = "",
    --         crewDescription = "",
    --         crewTotalKills = 0,
    --         crewTotalKillsRedzone = 0,
    --         crewTotalAirdrops = 0,
    --         crewTotalCupWins = 0,
    --         crewMembers = {}
    --     })
    -- end
    SendNUIMessage({
        type = "sendCrewData",
        haveCrew = false,
        isLeader = false,
        crewName = "CREW",
        crewTag = "",
        crewDescription = "",
        crewTotalKills = 0,
        crewTotalKillsRedzone = 0,
        crewTotalAirdrops = 0,
        crewTotalCupWins = 0,
        crewMembers = {}
    })
end)

_RegisterNetEvent("PREFIX_PLACEHOLDER:c:ReloadUICrew", function(data)
    if not data then data = CrewData end
    SendNUIMessage({
        type = "sendCrewData",
        haveCrew = data ~= nil,
        isLeader = CrewData.myRank == "leader",
        crewName = data.crewName,
        crewTag = data.crewTag,
        crewDescription = data.description,
        crewTotalKills = data.kills,
        crewTotalKillsRedzone = data.killsRedzone,
        crewTotalAirdrops = data.aidropTaken,
        crewTotalCupWins = data.cupWin,
        crewMembers = data.members,
        rankList = data.rankList,
        flag = data.flag
    })
end)

function CreateCrewMenu()
    CreateMenuCrew = {

        Base = { Title = "Create your crew", Header = {"commonmenu", "interaction_bgd"}, HeaderColor = { 255, 0, 0 }, Color = {color_black}}, -- intX pour menu a droite
        Data = { currentMenu = "Create crew", "" },

        Events = {
            onSelected = function(self, m, button, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)

                if self.Data.currentMenu == "Create crew" then
                    if button.name == "Crew name" then 
                        local crewName = KeyboardInput("Enter your crew name", "", 20)
                        if KeyboardInput then 
                            self.TempDataCrewName = crewName
                            CreateMenuCrew.Menu["Create crew"].b[1].ask = crewName
                        end
                    elseif button.name == "Crew tag" then 
                        local crewTag = KeyboardInput("Enter your crew tag", "", 4)
                        if KeyboardInput then 
                            self.TempDataCrewTag = crewTag
                            CreateMenuCrew.Menu["Create crew"].b[2].ask = crewTag
                        end
                    elseif button.name == "Crew description" then 
                        local crewDesc = KeyboardInput("Enter your crew description", "", 100)
                        if KeyboardInput then 
                            self.TempDataCrewDesc = crewDesc
                            CreateMenuCrew.Menu["Create crew"].b[3].ask = crewDesc
                        end
                    elseif button.name == "Crew newbie rank" then 
                        local crewNewbieRank = KeyboardInput("Enter your newbie rank", "", 15)
                        if KeyboardInput then 
                            self.TempDataCrewNewbieRank = crewNewbieRank
                            CreateMenuCrew.Menu["Create crew"].b[4].ask = crewNewbieRank
                        end
                    end

                    if button.name == "Create" then 
                        if self.TempDataCrewName and self.TempDataCrewTag and self.TempDataCrewDesc and self.TempDataCrewNewbieRank then 
                            Tse(button.event, {
                                crewName = self.TempDataCrewName,
                                crewTag = self.TempDataCrewTag,
                                crewDesc = self.TempDataCrewDesc,
                                NewbieRanklabel = self.TempDataCrewNewbieRank,
                            })
                            CloseMenu(true)
                        end

                    end

                end
            end
        },

        Menu = {
            ["Create crew"] = {
                b = {
                    {name = "Crew name", ask = "Enter your crew name", askX = true},
                    {name = "Crew tag", ask = "Enter your crew tag", askX = true},
                    {name = "Crew description", ask = "Enter your crew description", askX = true},
                    {name = "Crew newbie rank", ask = "Enter your newbie rank", askX = true},
                    {name = "Create", event = "PREFIX_PLACEHOLDER:c:CreateCrew", ask = ">", askX = true, colorFree = {0, 200, 0, 150}},
                }
            }
        },
    }

    return CreateMenu(CreateMenuCrew)
end

-- RegisterCommand("createcrew", function()
--     if CrewData then return ShowAboveRadarMessage("~HUD_COLOUR_RED~ You already part in crew") end 
--     CreateCrewMenu()
-- end)


function OpenCrewMenu()

    OpenCrewMenuTable = {

        Base = { Title = "Crew", Header = {"commonmenu", "interaction_bgd"}, HeaderColor = { 0, 200, 0 }, Color = {color_black}},
        Data = { currentMenu = "Gestion crew", "" },

        Events = {

            onSelected = function(self, m, button, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)

                if self.Data.currentMenu == "list members" then 
                    if button.uuid then 
                        if hasPermissions(2) then
                            if button.name == GM.Player.Username then 
                                ShowAboveRadarMessage("~HUD_COLOUR_RED~ You can't manage yourself")
                            else
                                if GetRankPermissions(GetMyRank()) >= GetRankPermissions(button.rank) then
                                    self.TempDataUUIDPLAYER = button.uuid
                                    self.TempDataUSERNAMEPLAYER = button.name
                                    OpenMenu("Manage player")
                                else
                                    ShowAboveRadarMessage("~HUD_COLOUR_RED~ You can't manage this player")
                                end
                            end
                        end
                    end
                end

                if self.Data.currentMenu == "Manage player" then 
                    if button.name == "Kick" then 
                        Tse("PREFIX_PLACEHOLDER:c:RemoveMembers", {
                            uuid = self.TempDataUUIDPLAYER
                        })
                        CloseMenu(true)
                        CreateMenu(OpenCrewMenuTable)
                    end

                    if button.name == "Change rank" then
                        local nameSlide = button.slidemax[button.slidenum]
                        if nameSlide == "leader" then 
                            ShowAboveRadarMessage("~HUD_COLOUR_RED~ You can't change leader rank")
                        else
                            Tse("PREFIX_PLACEHOLDER:c:ChangeRankMembers", {
                                uuid = self.TempDataUUIDPLAYER,
                                rank = nameSlide
                            })
                            CloseMenu(true)
                            CreateMenu(OpenCrewMenuTable)
                        end
                    end
                end

                if self.Data.currentMenu == "actions" then 
                    if button.name == "Invite player" then 
                        local player = GetNearbyPlayer(2)
                        if player then 
                            Tse("PREFIX_PLACEHOLDER:c:InvitePlayer", {
                                target = GetPlayerServerId(player)
                            })
                        else
                            ShowAboveRadarMessage("~HUD_COLOUR_RED~ No player nearby")
                        end
                    end

                    if button.name == "Change flag" then 
                        local flag = KeyboardInput("Enter your flag", "", 2)
                        if flag and CountryFlag[flag] then 
                            Tse("PREFIX_PLACEHOLDER:c:ChangeFlag", {
                                flag = flag
                            })
                            CloseMenu(true)
                            CreateMenu(OpenCrewMenuTable)
                        else 
                            ShowAboveRadarMessage("~HUD_COLOUR_RED~ Invalid flag")
                        end
                    end

                    if button.name == "Rename crew" then 
                        local name = KeyboardInput("Enter your name", "", 20)
                        if name then 
                            Tse("PREFIX_PLACEHOLDER:c:ChangeCrewName", {
                                crewName = name
                            })
                            CloseMenu(true)
                            CreateMenu(OpenCrewMenuTable)
                        end
                    end

                    if button.name == "Change tag" then 
                        local tag = KeyboardInput("Enter your tag", "", 10)
                        if tag then 
                            Tse("PREFIX_PLACEHOLDER:c:ChangeCrewTag", {
                                crewTag = tag
                            })
                            CloseMenu(true)
                            CreateMenu(OpenCrewMenuTable)
                        end
                    end

                    if button.name == "Create rank" then 
                        local name = KeyboardInput("Enter your rank name", "", 15)
                        if name then 
                            local permissions = KeyboardInput("Enter your permissions", "", 2)
                            if permissions then 
                                Tse("PREFIX_PLACEHOLDER:c:CreateRank", {
                                    rankname = name,
                                    permissions = permissions
                                })
                                CloseMenu(true)
                                CreateMenu(OpenCrewMenuTable)
                            end
                        end
                    end
                end
            end,

        },

        Menu = {

            ["Gestion crew"] = {
                b = {
                    {name = "Information", ask = ">", askX = true},
                    {name = "Actions", ask = ">", askX = true, canSee = function()
                        if hasPermissions(2) then 
                            return true
                        end
                        return false
                    end},
                    {name = "List members", ask = ">", askX = true},
                    {name = "List rank", ask = ">", askX = true},
                    {name = "Gestion permissions", ask = ">", askX = true, canSee = function()
                        if hasPermissions(10) then 
                            return true
                        end
                        return false
                    end},

                },
            },

            ["information"] = {
                b = function()
                    local returnTable = {}
                    local dataActuel = CallbackServer("callback:crew:getData")
                    table.insert(returnTable, {name = "Name", ask = dataActuel.crewName, askX = true})
                    table.insert(returnTable, {name = "Tag", ask = dataActuel.crewTag, askX = true})
                    table.insert(returnTable, {name = "Description", ask = dataActuel.description, askX = true})
                    table.insert(returnTable, {name = "Country", ask = dataActuel.flag, askX = true})
                    table.insert(returnTable, {name = "Kills", ask = dataActuel.kills, askX = true})
                    table.insert(returnTable, {name = "Kills redzone", ask = dataActuel.killsRedzone, askX = true})
                    table.insert(returnTable, {name = "Airdrop taken", ask = dataActuel.aidropTaken, askX = true})
                    table.insert(returnTable, {name = "Cup win", ask = dataActuel.cupWin, askX = true})
                    table.insert(returnTable, {name = "Total Members", ask = #dataActuel.members, askX = true})
                    return returnTable
                end,
            },

            ["actions"] = {
                b = function()
                    local returnTable = {}
                    table.insert(returnTable, {name = "Invite player", ask = ">", askX = true, canSee = function()
                        if hasPermissions(2) then 
                            return true
                        end
                        return false
                    end})

                    table.insert(returnTable, {name = "Create rank", ask = ">", askX = true, canSee = function()
                        if hasPermissions(10) then 
                            return true
                        end
                        return false
                    end})

                    table.insert(returnTable, {name = "Rename crew", ask = ">", askX = true, canSee = function()
                        if hasPermissions(4) then 
                            return true
                        end
                        return false
                    end})

                    table.insert(returnTable, {name = "Change flag", ask = ">", askX = true, canSee = function()
                        if hasPermissions(5) then 
                            return true
                        end
                        return false
                    end})

                    table.insert(returnTable, {name = "Change tag", ask = ">", askX = true, canSee = function()
                        if hasPermissions(9) then 
                            return true
                        end
                        return false
                    end})

                    return returnTable
                end,
            },

            ["list members"] = {
                b = function()
                    local returnTable = {}
                    local dataActuel = CallbackServer("callback:crew:getData")
                    for k, v in pairs(dataActuel.members) do 
                        table.insert(returnTable, {name = v.username, ask = v.rank, askX = true, uuid = v.uuid, rank = v.rank})
                    end
                    return returnTable
                end,
            },

            ["list rank"] = {
                b = function()
                    local returnTable = {}
                    local dataActuel = CallbackServer("callback:crew:getData")
                    for k, v in pairs(dataActuel.rankList) do 
                        table.insert(returnTable, {name = v.name, ask = v.permissions, askX = true})
                    end
                    return returnTable
                end,
            },

            ["gestion permissions"] = {
                b = function()
                    local returnTable = {}
                    for k, v in pairs(CrewConfig.Permissions) do 
                        table.insert(returnTable, {name = v, ask = k, askX = true})
                    end
                    return returnTable
                end,
            },

            ["Manage player"] = {
                b = function()
                    local returnTable = {}
                    local dataActuel = CallbackServer("callback:crew:getData")
                    local tableRank = {}
                    for k, v in pairs(dataActuel.rankList) do 
                        table.insert(tableRank, v.name)
                    end
                    table.insert(returnTable, {name = "Change rank", slidemax = tableRank})
                    table.insert(returnTable, {name = "Kick", ask = ">", askX = true})
                    return returnTable
                end,
            },

        }
    }

    return CreateMenu(OpenCrewMenuTable)
end

_RegisterNetEvent("PREFIX_PLACEHOLDER:c:ReceiveInviteCrew", function(tblData)
    ShowAboveRadarMessage("~HUD_COLOUR_GREEN~ You have been invited to join the crew ~HUD_COLOUR_RED~" .. tblData.crewName)
    ShowAboveRadarMessage("Press ~HUD_COLOUR_RED~Y ~s~ to accept or ~HUD_COLOUR_RED~N ~s~to refuse")
    
    -- Create a timer for the invitation
    local remainingTime = 15
    local inviteActive = true
    
    -- Display countdown timer
    Citizen.CreateThread(function()
        while remainingTime > 0 and inviteActive do
            -- Update every second
            Citizen.Wait(1000)
            remainingTime = remainingTime - 1
            
            -- Optional: Display remaining time
            ShowAboveRadarMessage("~s~Invitation expires in: ~HUD_COLOUR_RED~" .. remainingTime .. "~s~ seconds")
        end
        
        -- Auto-reject if timer expires and invitation is still active
        if inviteActive then
            inviteActive = false
            ShowAboveRadarMessage("~HUD_COLOUR_RED~ Invitation expired")
        end
    end)
    
    -- Handle user input
    Citizen.CreateThread(function()
        while inviteActive do
            Citizen.Wait(0)
            
            -- Accept with Y
            if IsControlJustPressed(0, 246) then 
                inviteActive = false
                Tse("PREFIX_PLACEHOLDER:c:AcceptInviteCrew", {
                    crewId = tblData.crewId,
                })
            end
            
            -- Reject with N
            if IsControlJustPressed(0, 249) then 
                inviteActive = false
                ShowAboveRadarMessage("~HUD_COLOUR_RED~ You refused the invitation")
            end
        end
    end)
end)

-- RegisterCommand("crew", function()
--     if not CrewData then return ShowAboveRadarMessage("~HUD_COLOUR_RED~ You are not in crew") end
--     OpenCrewMenu()
-- end)