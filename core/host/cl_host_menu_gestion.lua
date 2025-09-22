local function HostGestionMenuPrincipal()
    local returnTable = {}
    returnTable[#returnTable+1] = {name = "host_gestion_list_players", label = "List Players", askX = true, ask = ">"}
    returnTable[#returnTable+1] = {name = "Start", askX = true, ask = ">", colorFree = {0, 255, 0, 200}, canSee = function()
        print(GestionHostMenu.Data.hostId)
        local hostInfo = GetHostInfo(GestionHostMenu.Data.hostId) 
        if not hostInfo then return false end
        if hostInfo.game and hostInfo.game.started then 
            return false
        end
        return true
    end}
    returnTable[#returnTable+1] = {name = "Stop", askX = true, ask = ">", colorFree = {255, 0, 0, 200}, canSee = function()
        local hostInfo = GetHostInfo(GestionHostMenu.Data.hostId) 
        if not hostInfo then return false end
        if hostInfo.game and hostInfo.game.started then 
            return true
        end
        return false
    end}
    return returnTable
end

local function GetPlayersList(hostId)
    local returnTable = {}
    local hostInfo = GetHostInfo(hostId)
    if hostInfo and hostInfo.game and hostInfo.game.listPlayers then
        for k, v in pairs(hostInfo.game.listPlayers) do
            returnTable[#returnTable+1] = {name = "Player : ~g~"..v.username, askX = true, ask = v.team or "None"}
        end
    end
    return returnTable
end

local function onSelected(PMenu, MenuData, currentButton, currentSlt)
    if MenuData.currentMenu == "host_gestion_principal_menu" then
        if currentButton.name == "host_gestion_list_players" then
            GestionHostMenu.Menu["host_gestion_list_players"].b = GetPlayersList(GestionHostMenu.Data.hostId)
        elseif currentButton.name == "Start" then
            Tse("host_server:event:startGame")
        elseif currentButton.name == "Stop" then
            Tse("host_server:event:stopGame")
        end
    end
end

function OpenGestionHostMenu(hostId)
    if not hostId then return end
    print(hostId, "hostId")
    GestionHostMenu.Data.hostId = hostId
    print(json.encode(GestionHostMenu.Data, {indent = true}))
    CreateMenu(GestionHostMenu)
end

GestionHostMenu = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, HeaderColor = { 255, 0, 0 }, Blocked = false, Title = "Host Menu"},
    Data = { currentMenu = "host_gestion_principal_menu", hostId = nil},
    Events = {
        onSelected = onSelected,
    },
    Menu = {
        ["host_gestion_principal_menu"] = {NewTitle = "Host Menu", label = "Host Menu", b = HostGestionMenuPrincipal},
        ["host_gestion_list_players"] = {NewTitle = "Host List", label = "Host List", b = {}, useFilter = true},
    }
}

