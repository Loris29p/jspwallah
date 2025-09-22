

local function GetPlayersListLeague()
    local returnTable = {}
    for k, v in pairs(GM.League.teams) do
        for k2, v2 in pairs(v.players) do
            returnTable[#returnTable+1] = {name = v2.username, askX = true, ask = v.name, uuid = v2.uuid, team = v.name, teamId = v.id, src = v2.src}
        end
    end

    return returnTable
end

local function GetLobbyList()
    local returnTable = {}
    for k, v in pairs(GM.League.lobby) do
        returnTable[#returnTable+1] = {name = v.username, askX = true, ask = v.team, uuid = v.uuid, team = v.team, teamId = v.teamId, src = v.src, uuid = v.uuid}
    end
    return returnTable
end

local function onSlide(menuData, currentButton, currentSlt, PMenu)
end

local function onSelected(PMenu, MenuData, currentButton, currentSlt)
    if MenuData.currentMenu == "lobby" then
        PMenu.TempUUID = currentButton.uuid
        PMenu.TempTeam = currentButton.team
        PMenu.TempTeamId = currentButton.teamId
        PMenu.TempSrc = currentButton.src
        PMenu.TempUsername = currentButton.name
        MenuGestionLeague.Menu["action player"].b[1].name = "~r~"..PMenu.TempUsername.." ("..PMenu.TempSrc..") ["..PMenu.TempUUID.."]"
        PMenu:OpenMenu("action player")
    end

    if currentButton.name == "Start league" then
        Tse("league:StartLeague")
    end

    if MenuData.currentMenu == "action player" then
        if currentButton.name == "Kick League" then
            Tse("league:KickPlayerFromLeague", PMenu.TempSrc)
            PMenu:BackMenu({
                menu = "league_gestion",
            })
        elseif currentButton.name == "Ban League" then
            Tse("league:banLeague", PMenu.TempSrc)
            PMenu:BackMenu({
                menu = "league_gestion",
            })
        elseif currentButton.name == "Kick Team" then
            Tse("league:KickPlayerFromTeam", PMenu.TempSrc)
            PMenu:BackMenu({
                menu = "league_gestion",
            })
        end
    end
end

MenuGestionLeague = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, HeaderColor = { 255, 0, 0 }, Blocked = false, Title = "League Gestion"},
    Data = { currentMenu = "league_gestion"},
    Events = {
        onSlide = onSlide, 
        onSelected = onSelected,
    },
    Menu = {
        ["league_gestion"] = {NewTitle = "League Gestion", label = "League Gestion", b = {
            {name = "Lobby", askX = true, ask = ">", canSee = function() if not GM.League.started then return true else return false end end},
            {name = "List players", askX = true, ask = ">", canSee = function() if GM.League.started then return true else return false end end},
            {name = "Stop league", askX = true, ask = ">", canSee = function() if GM.League.started then return true else return false end end},
            {name = "Start league", askX = true, ask = ">", canSee = function() if GM.League.started then return false else return true end end},
        }},
        ["lobby"] = {NewTitle = "Lobby", label = "Lobby", b = GetLobbyList},
        ["list players"] = {NewTitle = "List players", label = "List players", b = GetPlayersListLeague},
        ["action player"] = {NewTitle = "Action player", label = "Action player", b = {
            {name = "Username", askX = true, ask = ""},
            {name = "Kick League", askX = true, ask = ""},
            {name = "Ban League", askX = true, ask = ""},
            {name = "Kick Team", askX = true, ask = ""},
        }},
    }
}