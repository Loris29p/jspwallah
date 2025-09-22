function InitCreationLeaguePrivate()

    local returnTable = {}

    returnTable[#returnTable+1] = {name = "Maps", slidemax = {"Mirror Park", "Vagos", "Beach"}, askX = true}
    returnTable[#returnTable+1] = {name = "Time", slidemax = {"1 minute", "10 minutes", "15 minutes", "20 minutes"}}
    returnTable[#returnTable+1] = {name = "Team", slidemax = 30, askX = true}
    returnTable[#returnTable+1] = {name = "Members per team", slidemax = 3, askX = true}
    returnTable[#returnTable+1] = {name = "Create League", askX = true, colorFree = {0, 255, 0, 200}}
    return returnTable
end


function LeagueMenuPublicCreate()

end

function InitLeagueMenu()

    local returnTable = {}

    returnTable[#returnTable+1] = {name = "League Public", ask = ">", askX = true}
    returnTable[#returnTable+1] = {name = "league_creation_private", label = "League Private (Only Staff)", ask = ">", askX = true, canSee = function()
        if GM.Player.Group == "user" then return false end
        return true
    end}
    return returnTable
end

local function onSelected(PMenu, MenuData, currentButton, currentSlt)
    if MenuData.currentMenu == "league_creation" then
        if currentButton.name == "League Public" then
            CreateMenu(QuickMenu)
        elseif currentButton.name == "League Private (Only Staff)" then
            CreateMenu(QuickMenu)
        end
    end
    if currentButton.name == "Maps" then
        print(currentButton.slidemax[currentButton.slidenum])
        PMenu.TempMap = League.maps[currentButton.slidemax[currentButton.slidenum]]
        ShowAboveRadarMessage("~g~Map set to "..currentButton.slidemax[currentButton.slidenum])
    elseif currentButton.name == "Time" then
        print(currentButton.slidemax[currentButton.slidenum])
        if currentButton.slidemax[currentButton.slidenum] == "10 minutes" then
            PMenu.TempTime = 600
            ShowAboveRadarMessage("~g~Time set to 10 minutes")
        elseif currentButton.slidemax[currentButton.slidenum] == "15 minutes" then
            PMenu.TempTime = 900
            ShowAboveRadarMessage("~g~Time set to 15 minutes")
        elseif currentButton.slidemax[currentButton.slidenum] == "20 minutes" then
            PMenu.TempTime = 1200
            ShowAboveRadarMessage("~g~Time set to 20 minutes")
        elseif currentButton.slidemax[currentButton.slidenum] == "1 minute" then
            PMenu.TempTime = 60
            ShowAboveRadarMessage("~g~Time set to 1 minute")
        end
    elseif currentButton.name == "Team" then
        print(currentButton.slidenum-1)
        if currentButton.slidenum-1 == 0 then 
            ShowAboveRadarMessage("~r~You need to select at least 1 team")
        elseif currentButton.slidenum-1 > 0 then
            PMenu.TempTeam = currentButton.slidenum-1
            ShowAboveRadarMessage("~g~Team set to "..currentButton.slidenum-1)
        end
    elseif currentButton.name == "Members per team" then
        print(currentButton.slidenum-1)
        if currentButton.slidenum-1 == 0 then 
            ShowAboveRadarMessage("~r~You need to select at least 1 member per team")
        elseif currentButton.slidenum-1 > 0 then
            PMenu.TempMembersPerTeam = currentButton.slidenum-1
            ShowAboveRadarMessage("~g~Members per team set to "..currentButton.slidenum-1)
        end
    elseif currentButton.name == "Create League" then
        if not PMenu.TempMap or not PMenu.TempTime or not PMenu.TempTeam or not PMenu.TempMembersPerTeam then
            ShowAboveRadarMessage("~r~You need to select all options")
        else
            CloseMenu(true)
            Tse("league:CreateLeague", {map = PMenu.TempMap, time = PMenu.TempTime, team = PMenu.TempTeam, members = PMenu.TempMembersPerTeam})
        end
    end
end

local function onSlide(menuData, currentButton, currentSlt, PMenu)
end

local QuickMenu = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, HeaderColor = { 255, 0, 0 }, Blocked = false, Title = "League Creation"},
    Data = { currentMenu = "league_creation"},
    Events = {
        onSlide = onSlide, 
        onSelected = onSelected,
    },
    Menu = {
        ["league_creation"] = {NewTitle = "League Creation", label = "League Maker", b = InitLeagueMenu},
        ["league_creation_public"] = {NewTitle = "League Creation", label = "League Maker", b = InitLeagueMenu},
        ["league_creation_private"] = {NewTitle = "League Creation", label = "League Maker", b = InitCreationLeaguePrivate},
    }
}

RegisterCommand("league_menu", function()
    if GM.Player.Group == "user" then return ShowAboveRadarMessage("~r~You don't have access to this feature.") end
    if GM.League then
        if GM.League.active then
            if GM.League.host.uuid == GM.Player.UUID then
                CreateMenu(MenuGestionLeague)
            else
                return ShowAboveRadarMessage("~r~You are not the host of this league")
            end
        end
    else
        CreateMenu(QuickMenu)
    end
end) 