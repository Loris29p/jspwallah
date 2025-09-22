
local function InitHostMenu()
    local returnTable = {}

    returnTable[#returnTable+1] = {name = "host_game_menu", label = "Host Game", askX = true, canSee = function()
        if GM.Player.Role == "mvp" or GM.Player.Role == "boss" or GM.Player.Group == "owner" or GetMyRank() == "leader" then 
            return true
        end
        return false
    end}
    returnTable[#returnTable+1] = {name = "host_list_menu", label = "List Game(s)", askX = true}

    return returnTable
end

local function InitHostGameMenu()
    local returnTable = {}

    returnTable[#returnTable+1] = {name = "Map", askX = true, slidemax = {"Desert (Open Field)"} }
    returnTable[#returnTable+1] = {name = "Time", askX = true, slidemax = {"10 minutes", "15 minutes", "20 minutes"}}
    returnTable[#returnTable+1] = {name = "Bet", askX = true, slidemax = {100000, 150000, 250000, 500000, 1000000}}
    returnTable[#returnTable+1] = {name = "Meta", askX = true, slidemax = {"kuruma_specialcarbine", "kuruma_carbineriflemk2", "kuruma_m60", "brioso_specialcarbine", "brioso_carbineriflemk2", "brioso_m60"}}
    returnTable[#returnTable+1] = {name = "Code", askX = true, ask = "NOT DEFINED"}
    returnTable[#returnTable+1] = {name = "Create Game", askX = true, colorFree = {0, 255, 0, 200}, ask = ">"}

    return returnTable
end

function SecondToTime(intSecond)
    local intMinute = math.floor((intSecond % 3600) / 60)
    local intSecond = intSecond % 60
    return string.format("%02d:%02d", intMinute, intSecond)
end

local function InitHostListMenu()
    local returnTable = {}
    
    for k, v in pairs(ListActiveHost) do 
        print(json.encode(v, {indent = true}))
        returnTable[#returnTable+1] = {name = "Host : ~g~"..v.game.ownerUsername, askX = true, ask = #v.game.listPlayers.."/40", Description = "Map: ~r~"..v.game.map.name.."~s~ \nTime: ~r~"..SecondToTime(v.time).."~s~ \nBet: ~r~"..v.game.bet.."~s~ \nMeta: ~r~"..v.game.meta.."~s~", hostId = k}
    end
    return returnTable
end

local function onSelected(PMenu, MenuData, currentButton, currentSlt)
    if MenuData.currentMenu == "host_list_menu" then
        if currentButton.hostId then
            local hostInfo = GetHostInfo(currentButton.hostId)
            if hostInfo.game.started then
                return print("GO SPECTATE")
            end
            -- if hostInfo.game.ownerUUID == GM.Player.UUID then
            --     return print("GO GESTION HOST")
            -- end
            local keyboard = KeyboardInput("Enter the code", "Code", 10)
            if keyboard then
                Tse("host_server:event:joinHost", {
                    hostId = currentButton.hostId,
                    code = keyboard,
                })
                CloseMenu()
            end
        end
    end
    if currentButton.name == "Map" then
        print(currentButton.slidemax[currentButton.slidenum])
        PMenu.TempMap = currentButton.slidemax[currentButton.slidenum]
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
        end 
    elseif currentButton.name == "Bet" then
        PMenu.TempBet = currentButton.slidemax[currentButton.slidenum]
        ShowAboveRadarMessage("~g~Bet set to "..currentButton.slidemax[currentButton.slidenum])
    elseif currentButton.name == "Meta" then
        PMenu.TempMeta = currentButton.slidemax[currentButton.slidenum]
        ShowAboveRadarMessage("~g~Meta set to "..currentButton.slidemax[currentButton.slidenum])
    elseif currentButton.name == "Code" then
        local keyboard = KeyboardInput("Enter the code", "Code", 10)
        if keyboard then
            PMenu.TempCode = keyboard
            ShowAboveRadarMessage("~g~Code set to "..keyboard)
        end
    elseif currentButton.name == "Create Game" then
        if PMenu.TempMap and PMenu.TempTime and PMenu.TempBet and PMenu.TempMeta and PMenu.TempCode then
            Tse("host_server:event:createGame", {
                map = PMenu.TempMap,
                time = PMenu.TempTime,
                bet = PMenu.TempBet,
                meta = PMenu.TempMeta,
                code = PMenu.TempCode,
            })
            CloseMenu()
        end
    end
end

local QuickMenu = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, HeaderColor = { 255, 0, 0 }, Blocked = false, Title = "Host Menu"},
    Data = { currentMenu = "host_principal_menu"},
    Events = {
        onSelected = onSelected,
    },
    Menu = {
        ["host_principal_menu"] = {NewTitle = "Host Menu", label = "Host Menu", b = InitHostMenu},
        ["host_game_menu"] = {NewTitle = "Host Game", label = "Host Game", b = InitHostGameMenu},
        ["host_list_menu"] = {NewTitle = "Host List", label = "Host List", b = InitHostListMenu, useFilter = true},
    }
}

-- RegisterCommand("hostmenu", function()
--     if GetHostIDByPlayer(GM.Player.UUID) then
--         if imHost then
--             print("OPEN GESTION HOST ", GetHostIDByPlayer(GM.Player.UUID))
--             return OpenGestionHostMenu(GetHostIDByPlayer(GM.Player.UUID))
--         else
--             return ShowAboveRadarMessage("~r~You are already in a game & you are not the host")
--         end
--         return
--     else 
--         if CheckHost(GM.Player.UUID) then
--             print("OPEN GESTION HOST 2", CheckHost(GM.Player.UUID))
--             return OpenGestionHostMenu(CheckHost(GM.Player.UUID))
--         end
--     end
--     CreateMenu(QuickMenu)
-- end)