AdminPlayers = {}
_RegisterNetEvent("admin:openMenu", function(dataP)
    AdminPlayers = dataP
    MenuAdministration(AdminPlayers)
end)


Admin = {}
Admin.checkbox = false
Admin.checkbox2 = false

local function EventTableList()
    local returnTable = {}
    if json.encode(ListRobberyActive) ~= "[]" then
        returnTable[#returnTable + 1] = { name = "Robbery Event", ask = ">", askX = true, Description =
        "Manage the robbery event", id = "robbery" }
    end
    if RedzoneConfig.CurrentRedZoneInfo ~= "{}" then
        returnTable[#returnTable + 1] = {
            name = "Redzone Event",
            ask = ">",
            askX = true,
            Description = "Manage the redzone event",
            id = "redzone",
            canSee = function()
                if GM.Player.Group == "owner" or GM.Player.Group == "EM" then
                    return true
                else
                    return false
                end
            end
        }
    end
    returnTable[#returnTable + 1] = {
        name = "Gift Box",
        ask = ">",
        askX = true,
        Description = "Manage the gift box event",
        id = "giftbox",
        canSee = function()
            if GM.Player.Group == "owner" or GM.Player.Group == "EM" then
                return true
            else
                return false
            end
        end
    }

    return returnTable
end

local function LoadEventsTable(type)
    local returnTable = {}
    if type == "robbery" then
        for k, v in pairs(ListRobberyActive) do
            returnTable[#returnTable + 1] = { name = "Robbery Event " .. v.id, ask = ">", askX = true, Description =
            "Manage the robbery event " .. v.id, id = v.id, btnId = "robbery" }
        end
    end
    if type == "redzone" then
        for k, v in pairs(RedzoneConfig.CurrentRedZoneInfo) do
            returnTable[#returnTable + 1] = { name = "Redzone Event " .. v.redzoneId, ask = ">", askX = true, Description =
            "Manage the redzone event " .. v.redzoneId, id = v.redzoneId, data = v, btnId = "redzone" }
        end
        returnTable[#returnTable + 1] = { name = "Change Redzone", ask = ">", askX = true, btnId = "change redzone" }
    end
    return returnTable
end

local function LoadInformationsEvent(type, id)
    local returnTable = {}
    if type == "robbery" then
        returnTable[#returnTable + 1] = { name = "Teleport to position", ask = ">", askX = true, position =
        ListRobberyActive[id].pos }
        returnTable[#returnTable + 1] = { name = "Delete the event", ask = ">", askX = true, id = id, event =
        "PREFIX_PLACEHOLDER:rh:DeleteEvent" }
        returnTable[#returnTable + 1] = { name = "Debug the event", ask = ">", askX = true, id = id, event =
        "PREFIX_PLACEHOLDER:rh:DebugEvent" }
    elseif type == "redzone" then
        local redzoneInfo = GetRedzoneInformations(id)
        returnTable[#returnTable + 1] = { name = "Teleport to position", ask = ">", askX = true, position = redzoneInfo
        .redzonePos }
    end
    return returnTable
end


local function GestionServerTable()
    local returnTable = {}
    returnTable[#returnTable + 1] = { name = "Search player in database", ask = ">", askX = true }
    if GM.Player.Group == "owner" or GM.Player.Group == "refund" or GM.Player.Group == "sysadmin" then
        returnTable[#returnTable + 1] = { name = "List items", ask = ">", askX = true }
    end
    return returnTable
end

local function ListItemsTable()
    local returnTable = {}
    for k, v in pairs(Items) do
        returnTable[#returnTable + 1] = { name = v.label, ask = ">", askX = true, item = k, type = v.type, price = v
        .price }
    end
    return returnTable
end
inSpectatePlayer = false

_RegisterNetEvent("FreezePlayer", function()
    local isFrozen = IsEntityPositionFrozen(PlayerPedId())
    if isFrozen then
        FreezeEntityPosition(PlayerPedId(), false)
        ShowAboveRadarMessage("~HUD_COLOUR_GREEN~You have been unfrozen")
    else
        FreezeEntityPosition(PlayerPedId(), true)
        ShowAboveRadarMessage("~HUD_COLOUR_RED~You have been frozen")
    end
end)

function MenuAdministration(data)
    local menuPos = .24
    local heightPos = .175

    local mySettings = GetResourceKvpInt("admin_menu_right")
    if mySettings == 1 then
        menuPos = .99
        heightPos = .175
    else
        menuPos = .24
        heightPos = .175
    end
    MenuMainAdministration = {
        Base = { Title = "Administration", intY = heightPos, intX = menuPos, Header = { "commonmenu", "interaction_bgd" }, HeaderColor = { 255, 0, 0 }, Color = { color_black } }, -- intX pour menu a droite
        Data = { currentMenu = "Menu options" },

        Events = {
            onOpened = function()
            end,

            onBack = function()
            end,

            onExited = function()
            end,

            onButtonSelected = function(currentMenu, r, p, C, self)
            end,

            onSlider = function(self, r, P, Q)
            end,

            onSlide = function(p, n, q, s)
                local currentMenu = p.currentMenu, GetPlayerPed(-1)
                local t = n.slidenum;
                local F = n.opacity;
                local G = n.name;
                local H = n.parentSlider;
                local y = p.currentMenu, GetPlayerPed(-1)
            end,

            onSelected = function(self, m, button, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
                if self.Data.currentMenu == "Menu options" then
                    if button.name == "Announce" then
                        local message = KeyboardInput("Enter the message", "", 150)
                        if message then
                            Tse("admin:announce", message)
                        end
                    end
                    if button.name == "List Reports" then
                        local reportsList = CallbackServer("admin:GetReports")
                        if reportsList then
                            MenuMainAdministration.Menu["list reports"].b = {}
                            for k, v in pairs(reportsList) do
                                local statusReport = CallbackServer("admin:GetStatusReport", v.uuid)
                                table.insert(MenuMainAdministration.Menu["list reports"].b,
                                    {
                                        name = statusReport .. " [" .. v.uuid .. "] " .. v.author,
                                        ask = v.author,
                                        Description = v.message,
                                        askX = true,
                                        uuid = v.uuid,
                                        report = v,
                                        statusReport = statusReport,
                                        canSee = function()
                                            if statusReport.takenBy == GM.Player.UUID then
                                                return true
                                            elseif statusReport.takenBy == nil then
                                                return true
                                            else
                                                return false
                                            end
                                            return false
                                        end
                                    })
                            end
                            self:OpenMenu("list reports")
                        end
                    end
                end


                if self.Data.currentMenu == "list reports" then
                    if button.report then
                        self.TempReportData = button.report
                        local statusReport = CallbackServer("admin:GetStatusReport", self.TempReportData.uuid)
                        MenuMainAdministration.Menu["report information"].b = {}
                        MenuMainAdministration.Menu["report information"].b[#MenuMainAdministration.Menu["report information"].b + 1] = { name =
                        statusReport .. " ~r~[" .. self.TempReportData.uuid .. "] " .. self.TempReportData.author, askX = true }
                        MenuMainAdministration.Menu["report information"].b[#MenuMainAdministration.Menu["report information"].b + 1] = { name =
                        "Reason: " .. self.TempReportData.message, askX = true }
                        MenuMainAdministration.Menu["report information"].b[#MenuMainAdministration.Menu["report information"].b + 1] = { name =
                        "Teleport to player", ask = "", askX = true }
                        MenuMainAdministration.Menu["report information"].b[#MenuMainAdministration.Menu["report information"].b + 1] = { name =
                        "Take the report", ask = "", askX = true }
                        MenuMainAdministration.Menu["report information"].b[#MenuMainAdministration.Menu["report information"].b + 1] = { name =
                        "Close the report", ask = "", askX = true, colorFree = { 150, 0, 0, 150 } }
                        self:OpenMenu("report information")
                    end
                end

                if self.Data.currentMenu == "report information" then
                    if button.name == "Teleport to player" then
                        Tse("admin:TeleportToPlayerReport", self.TempReportData.author)
                    elseif button.name == "Take the report" then
                        Tse("admin:TakeReport", self.TempReportData.uuid)
                    elseif button.name == "Close the report" then
                        Tse("admin:CloseReport", self.TempReportData.uuid)
                        self:BackMenu({
                            menu = "Menu options",
                        })
                    end
                end

                if self.Data.currentMenu == "gestions server" then
                    if button.name == "Search player in database" then
                        local search = KeyboardInput("Enter the UUID", "", 100)
                        if tonumber(search) then
                            local searchData = CallbackServer("admin:searchPlayer", search)
                            if searchData then
                                self.TempUUID = searchData.uuid
                                self.TempTagsList = searchData.tags
                                self.TempInfo = searchData
                                MenuMainAdministration.Menu["player informations"].b = {}
                                MenuMainAdministration.Menu["player informations"].b[#MenuMainAdministration.Menu["player informations"].b + 1] = { name =
                                "~r~[" .. searchData.uuid .. "] " .. searchData.username, askX = true }
                                MenuMainAdministration.Menu["player informations"].b[#MenuMainAdministration.Menu["player informations"].b + 1] = { name =
                                "Ban List", askX = true, uuid = searchData.uuid, ask = ">" }
                                MenuMainAdministration.Menu["player informations"].b[#MenuMainAdministration.Menu["player informations"].b + 1] = { name =
                                "Warns List", askX = true, uuid = searchData.uuid, ask = ">" }
                                MenuMainAdministration.Menu["player informations"].b[#MenuMainAdministration.Menu["player informations"].b + 1] = { name =
                                "Information", askX = true, slidemax = { "UUID", "Tokens", "Tags" }, slidenum = 1 }
                                self:OpenMenu("player informations")
                            else
                                return ShowAboveRadarMessage("~HUD_COLOUR_RED~Player not found")
                            end
                        else
                            return ShowAboveRadarMessage("~HUD_COLOUR_RED~You must enter a UUID (number)")
                        end
                    end
                end

                if self.Data.currentMenu == "list items" then
                    local uuidInput = KeyboardInput("Enter the UUID", "", 10)
                    local amountInput = KeyboardInput("Enter the amount", "", 10)
                    if uuidInput and amountInput then
                        Tse("gamemode:RefundItemsUUID", uuidInput, {
                            name = button.item,
                            count = tonumber(amountInput),
                        })
                    else
                        return ShowAboveRadarMessage("~HUD_COLOUR_RED~You must enter a UUID and an amount")
                    end
                end

                if self.Data.currentMenu == "player informations" then
                    if button.name == "Information" then
                        local slidemax = button.slidemax
                        if button.slidemax[button.slidenum] == "UUID" then
                            ShowAboveRadarMessage("~b~" .. self.TempInfo.username .. "~s~\nUUID: ~g~" .. self.TempUUID)
                        elseif button.slidemax[button.slidenum] == "Tokens" then
                            ShowAboveRadarMessage("~b~" ..
                            self.TempInfo.username .. "~s~\nTokens: ~g~" .. self.TempInfo.token)
                        elseif button.slidemax[button.slidenum] == "Tags" then
                            local tags = self.TempTagsList
                            if tags then
                                local tagsList = ""
                                for k, v in pairs(tags) do
                                    tagsList = tagsList .. v.name .. ", "
                                end
                                ShowAboveRadarMessage("~b~" .. self.TempInfo.username .. "~s~\nTags: ~g~" .. tagsList)
                            end
                        end
                    end

                    -- if button.name == "Warns List" then
                    --     local warnsList = CallbackServer("admin:GetWarnsUUID", tonumber(self.TempUUID))
                    --     if warnsList then
                    --         MenuMainAdministration.Menu["warns list"].b = {}
                    --         for k, v in pairs(warnsList) do
                    --             table.insert(MenuMainAdministration.Menu["warns list"].b, {name = v.reason, ask = v.author, Description = v.date, askX = true})
                    --         end
                    --         self:OpenMenu("warns list")
                    --     end
                    -- end
                    -- if button.name == "Ban List" then
                    --     local banList = CallbackServer("admin:GetBansHistoryUUID", tonumber(self.TempUUID))
                    --     if banList then
                    --         MenuMainAdministration.Menu["ban list"].b = {}
                    --         for k, v in pairs(banList) do
                    --             table.insert(MenuMainAdministration.Menu["ban list"].b, {name = v.reason, ask = "~r~"..v.author, Description = v.date.." | Ban ID: "..v.banId.."\nExpiration: "..v.expiration, askX = true})
                    --         end
                    --         self:OpenMenu("ban list")
                    --     end
                    -- end
                end
                if self.Data.currentMenu == "redzone management" then
                    if button.name == "Teleport to position" then
                        SetEntityCoords(PlayerPedId(), button.position.x, button.position.y, button.position.z)
                    end
                end

                if self.Data.currentMenu == "redzone event" then
                    if button.btnId == "change redzone" then
                        Tse("admin:changeRedzone")
                        self:Back()
                    end
                    if button.btnId == "redzone" then
                        MenuMainAdministration.Menu["redzone management"].b = LoadInformationsEvent("redzone", button.id)
                        self:OpenMenu("redzone management")
                    end
                end

                if self.Data.currentMenu == "robbery management" then
                    if button.name == "Teleport to position" then
                        SetEntityCoords(PlayerPedId(), button.position.x, button.position.y, button.position.z)
                    end
                    if button.name == "Delete the event" then
                        Tse(button.event, button.id)
                        self:BackMenu({
                            menu = "Menu options",
                        })
                    end
                    if button.name == "Debug the event" then
                        Tse(button.event, button.id)
                    end
                end

                if self.Data.currentMenu == "robbery event" then
                    if button.btnId == "robbery" then
                        MenuMainAdministration.Menu["robbery management"].b = LoadInformationsEvent("robbery", button.id)
                        self:OpenMenu("robbery management")
                    end
                end

                if self.Data.currentMenu == "gestions event" then
                    if button.id == "robbery" then
                        MenuMainAdministration.Menu["robbery event"].b = LoadEventsTable("robbery")
                        self:OpenMenu("robbery event")
                    end
                    if button.id == "redzone" then
                        MenuMainAdministration.Menu["redzone event"].b = LoadEventsTable("redzone")
                        self:OpenMenu("redzone event")
                    end

                    if button.id == "giftbox" then
                        if #ListBox > 0 then return ShowAboveRadarMessage(
                            "~HUD_COLOUR_RED~The gift box event is already running") end
                        local keyboard = KeyboardInput("Enter the number of boxes", "", 2)
                        if tonumber(keyboard) and tonumber(keyboard) > 0 and tonumber(keyboard) <= 10 then
                            Tse("eventmanger:CreateEventBox", tonumber(keyboard))
                        else
                            return ShowAboveRadarMessage("~HUD_COLOUR_RED~You must enter a number between 1 and 10")
                        end
                    end
                end
                if self.Data.currentMenu == "player list" then
                    if MenuMainAdministration and MenuMainAdministration.Menu and MenuMainAdministration.Menu["Player"] then
                        -- MenuMainAdministration.Menu["Player"].b = {}
                        MenuMainAdministration.Menu["Player"].b[1].name = "~r~(" ..
                        button.source .. ") - " .. button.username
                        MenuMainAdministration.Menu["Player"].b[2].name = "Gamemode: ~g~" .. button.gamemode
                        MenuMainAdministration.Menu["Player"].b[3].name = "New player: ~g~" ..
                        (button.isNew and "~HUD_COLOUR_GREEN~New" or "No")
                        self.Data.username = button.username
                        self.Data.uuid = button.uuid
                        self.Data.source = button.source
                        self.Data.stats = button.stats
                        self.Data.group = button.group
                        self.Data.token = button.token
                        self.Data.role = button.rank
                        self.Data.container = button.container
                        self.Data.identifiers = button.identifiers
                        self:OpenMenu("Player")
                    else
                    end
                end

                if self.Data.currentMenu == "Player" then
                    if button.name == "Send a private message" then
                        local message = KeyboardInput("Enter the message", "", 100)
                        if message then
                            Tse("admin:sendMessage", self.Data.source, message)
                            ShowAboveRadarMessage("~HUD_COLOUR_NET_PLAYER7~Message sent to ~HUD_COLOUR_NET_PLAYER8~" ..
                            self.Data.username)
                        else
                            return ShowAboveRadarMessage("~HUD_COLOUR_RED~You must enter a message")
                        end
                    elseif button.name == "Go to the player" then
                        Tse("admin:GoToPlayer", self.Data.source)

                        if Admin and Admin.Cam then
                            SetCamCoord(Admin.Cam, GetEntityCoords(GetPlayerPed(GetPlayerServerId(self.Data.source))))
                        end
                    elseif button.name == "Bring the player to you" then
                        Tse("admin:BringPlayer", self.Data.source)
                    elseif button.name == "Information" then
                        local slidemax = button.slidemax
                        if button.slidemax[button.slidenum] == "UUID" then
                            ShowAboveRadarMessage("~b~" .. self.Data.username .. "~s~\nUUID: ~g~" .. self.Data.uuid)
                        elseif button.slidemax[button.slidenum] == "Tokens" then
                            ShowAboveRadarMessage("~b~" .. self.Data.username .. "~s~\nTokens: ~g~" .. self.Data.token)
                        elseif button.slidemax[button.slidenum] == "Ping" then
                            Tse("admin:getPing", self.Data.source)
                        elseif button.slidemax[button.slidenum] == "Stats" then
                            Tse("admin:getStats", self.Data.source)
                        end
                    elseif button.name == "Warn" then
                        local reason = KeyboardInput("Enter the reason", "", 100)
                        if reason then
                            Tse("admin:WarnPlayer", self.Data.source, reason)
                        else
                            return ShowAboveRadarMessage("~HUD_COLOUR_RED~You must enter a reason")
                        end
                        -- elseif button.name == "Warns list" then
                        --     local warnsList = CallbackServer("admin:GetWarns", self.Data.source)
                        --     if warnsList then
                        --         MenuMainAdministration.Menu["warns list"].b = {}
                        --         for k, v in pairs(warnsList) do
                        --             table.insert(MenuMainAdministration.Menu["warns list"].b, {name = v.reason, ask = v.author, Description = v.date, askX = true})
                        --         end
                        --         self:OpenMenu("warns list")
                        --     end
                        -- elseif button.name == "Ban list" then
                        --     local banList = CallbackServer("admin:GetBansHistory", self.Data.source)
                        --     if banList then
                        --         MenuMainAdministration.Menu["ban list"].b = {}
                        --         for k, v in pairs(banList) do
                        --             table.insert(MenuMainAdministration.Menu["ban list"].b, {name = v.reason, ask = "~r~"..v.author, Description = v.date.." | Ban ID: "..v.banId.."\nExpiration: "..v.expiration, askX = true})
                        --         end
                        --         self:OpenMenu("ban list")
                        --     end
                    elseif button.name == "Kick" then
                        local reason = KeyboardInput("Enter the reason", "", 100)
                        if reason then
                            Tse("admin:kickPlayer", self.Data.source, reason)
                        else
                            return ShowAboveRadarMessage("~HUD_COLOUR_RED~You must enter a reason")
                        end
                    elseif button.name == "Ban" then
                        local reason = KeyboardInput("Enter the reason", "", 100)
                        local duration = KeyboardInput("Enter the duration (3m, 12m, 2y ect)", "", 100)
                        if reason then
                            if duration then
                                Tse("admin:banPlayer", self.Data.source, reason, duration)
                            else
                                return ShowAboveRadarMessage("~HUD_COLOUR_RED~You must enter a duration")
                            end
                        else
                            return ShowAboveRadarMessage("~HUD_COLOUR_RED~You must enter a reason")
                        end
                    elseif button.name == "Open inventory" then
                        Tse("inventory:OpenInventoryByStaff", self.Data.source)
                    elseif button.name == "Open container" then
                        Tse("inventory:OpenContainerByStaff", self.Data.source)
                    elseif button.name == "Spectate the player" then
                        inSpectatePlayer = not inSpectatePlayer
                        -- Convertir l'ID du serveur en index local du joueur
                        local playerIdx = GetPlayerFromServerId(self.Data.source)
                        local targetPed = GetPlayerPed(playerIdx)
                        if targetPed > 0 then
                            if not inSpectatePlayer then
                                SetEntityVisible(PlayerPedId(), false, false)
                                SetEntityCoords(PlayerPedId(), GetEntityCoords(targetPed))
                                NetworkSetInSpectatorMode(true, targetPed)
                                ShowAboveRadarMessage("~HUD_COLOUR_NET_PLAYER7~Spectating ~HUD_COLOUR_NET_PLAYER8~" ..
                                self.Data.username)
                            else
                                NetworkSetInSpectatorMode(false, targetPed)
                                SetEntityVisible(PlayerPedId(), true, false)
                                ShowAboveRadarMessage(
                                "~HUD_COLOUR_NET_PLAYER7~No longer spectating ~HUD_COLOUR_NET_PLAYER8~" ..
                                self.Data.username)
                            end
                        else
                            ShowAboveRadarMessage("~HUD_COLOUR_RED~Player not found or too far away")
                        end
                    elseif button.name == "Change username" then
                        local name = KeyboardInput("Enter the new name", "", 100)
                        if name then
                            Tse("admin:changeName", self.Data.source, name)
                        end
                    elseif button.name == "Verification" then
                        Tse("admin:PutVerifPlayer", self.Data.source)
                    elseif button.name == "Verification Stop" then
                        Tse("verification:Finish", self.Data.source)
                    elseif button.name == "Record player" then
                        Tse("admin:recordPlayer", self.Data.source)
                    elseif button.name == "Screenshot" then
                        Tse("admin:screenshot", self.Data.source)
                    elseif button.name == "Freeze" then
                        Tse("admin:FreezePlayer", self.Data.source)
                    end
                end

                if self.Data.currentMenu == "my player" then
                    if button.name == "Teleport to waypoint" then
                        local waypoint = GetFirstBlipInfoId(8)
                        if DoesBlipExist(waypoint) then
                            local waypointCoords = GetBlipInfoIdCoord(waypoint)
                            SetEntityCoords(PlayerPedId(), waypointCoords.x, waypointCoords.y, waypointCoords.z)
                            ShowAboveRadarMessage("~HUD_COLOUR_NET_PLAYER7~Teleported to the waypoint")
                        else
                            ShowAboveRadarMessage("~HUD_COLOUR_RED~You must set a waypoint")
                        end
                    elseif button.name == "Invisible" then
                        Admin.checkbox = not Admin.checkbox
                        button.checkbox = Admin.checkbox
                        SetEntityVisible(PlayerPedId(), not Admin.checkbox, false)
                        ShowAboveRadarMessage("~HUD_COLOUR_NET_PLAYER7~You are now " ..
                        (Admin.checkbox and "~HUD_COLOUR_NET_PLAYER8~invisible" or "~HUD_COLOUR_NET_PLAYER8~visible"))
                    elseif button.name == "Invincible" then
                        Admin.checkbox2 = not Admin.checkbox2
                        button.checkbox = Admin.checkbox2
                        SetEntityInvincible(PlayerPedId(), Admin.checkbox2)
                        ShowAboveRadarMessage("~HUD_COLOUR_NET_PLAYER7~You are now " ..
                        (Admin.checkbox2 and "~HUD_COLOUR_NET_PLAYER8~invincible" or "~HUD_COLOUR_NET_PLAYER8~vulnerable"))
                    end
                end

                if self.Data.currentMenu == "other options" then
                    if button.name == "Right menu" then
                        button.checkbox = not button.checkbox
                        if button.checkbox then
                            SetResourceKvpInt("admin_menu_right", 1)
                            CloseMenu(true)
                            Tse("admin:openMenu")
                        else
                            SetResourceKvpInt("admin_menu_right", 0)
                            CloseMenu(true)
                            Tse("admin:openMenu")
                        end
                    end
                end

                if self.Data.currentMenu == "world" then
                    if button.name == "Show gamertags" then
                        button.checkbox = not button.checkbox
                        showName = button.checkbox
                        if showName then
                            showNames()
                        end
                        -- showNames()
                    end
                    if button.name == "Delete all vehicles" then
                        DeleteAllVehicles()
                        if button.slidemax[button.slidenum] == "Closest" then
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
                            if DoesEntityExist(vehicle) then
                                DeleteEntity(vehicle)
                            end
                        else
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z,
                                tonumber(button.slidemax[button.slidenum]), 0, 71)
                            if DoesEntityExist(vehicle) then
                                DeleteEntity(vehicle)
                            end
                        end
                    end
                    if button.name == "Delete all objects" then
                        if button.slidemax[button.slidenum] == "Closest" then
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, 0, false)
                            if DoesEntityExist(object) then
                                DeleteEntity(object)
                            end
                        else
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local object = GetClosestObjectOfType(coords.x, coords.y, coords.z,
                                tonumber(button.slidemax[button.slidenum]), 0, false)
                            if DoesEntityExist(object) then
                                DeleteEntity(object)
                            end
                        end
                    end

                    if button.name == "Delete all peds" then
                        if button.slidemax[button.slidenum] == "Closest" then
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local ped = GetClosestPed(coords.x, coords.y, coords.z, 3.0, 0, 71)
                            if DoesEntityExist(ped) then
                                DeleteEntity(ped)
                            end
                        else
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local ped = GetClosestPed(coords.x, coords.y, coords.z,
                                tonumber(button.slidemax[button.slidenum]), 0, 71)
                            if DoesEntityExist(ped) then
                                DeleteEntity(ped)
                            end
                        end
                    end
                end
            end,

        },

        Menu = {

            ["Menu options"] = {
                refresh = true,
                b = {
                    { name = "Player list",     ask = ">", askX = true },
                    { name = "My player",       ask = ">", askX = true },
                    { name = "List Reports",    ask = ">", askX = true },
                    { name = "Gestions Event",  ask = ">", askX = true },
                    { name = "Gestions Server", ask = ">", askX = true },
                    { name = "Vehicles",        ask = ">", askX = true },
                    { name = "World",           ask = ">", askX = true },
                    { name = "Other options",   ask = ">", askX = true },
                    {
                        name = "Announce",
                        ask = ">",
                        askX = true,
                        canSee = function()
                            if GM.Player.Group == "moderator" then return false end
                            return true
                        end
                    },
                },
            },

            ["list reports"] = {
                useFilter = true,
                b = {}
            },

            ["report information"] = {
                b = {}
            },

            ["list items"] = {
                useFilter = true,
                b = ListItemsTable()
            },

            ["gestions server"] = {
                b = GestionServerTable()

            },

            ["gestions event"] = {
                b = EventTableList
            },

            ["robbery event"] = {

            },

            ["robbery management"] = {

            },

            ["redzone event"] = {

            },

            ["redzone management"] = {

            },

            ["player informations"] = {

            },

            ["world"] = {
                b = {
                    { name = "Show gamertags",      checkbox = showName and true or false },
                    { name = "Delete all vehicles", slidemax = { "Closest", "5.0", "10.0", "20.0", "30.0", "40.0", "50.0" } },
                    { name = "Delete all objects",  slidemax = { "Closest", "5.0", "10.0", "20.0", "30.0", "40.0", "50.0" } },
                    { name = "Delete all peds",     slidemax = { "Closest", "5.0", "10.0", "20.0", "30.0", "40.0", "50.0" } },
                }
            },

            ["other options"] = {
                refresh = true,
                b = {
                    { name = "Right menu", Description = "Move the menu to the right", askX = true, checkbox = GetResourceKvpInt("admin_menu_right") == 1 and true or false },
                }
            },

            ["my player"] = {
                refresh = true,
                b = {
                    { name = "Teleport to waypoint", askX = true },
                    { name = "Invisible",            checkbox = Admin.checkbox },
                    { name = 'Invincible',           checkbox = Admin.checkbox },
                }
            },

            ["player list"] = {
                refresh = true,
                useFilter = true,
                b = function()
                    local returnTable = {}
                    for k, v in pairs(AdminPlayers) do
                        if v.flag == nil then
                            v.flag = ""
                        end

                        if v.username == nil then
                            v.username = "Unknown"
                        end

                        if v.source == nil then
                            v.source = "Unknown"
                        end

                        if v.uuid == nil then
                            v.uuid = "Unknown"
                        end

                        if v.group == nil then
                            v.group = "Unknown"
                        end

                        if v.role == nil then
                            v.role = "Unknown"
                        end

                        if v.stats == nil then
                            v.stats = "Unknown"
                        end

                        if v.inventory == nil then
                            v.inventory = "Unknown"
                        end
                        if v.token == nil then
                            v.token = 0
                        end

                        if v.gamemode == nil then
                            v.gamemode = "Unknown"
                        end

                        if v.prestige == nil then
                            v.prestige = 0
                        end

                        buttonName = "(" .. v.source .. ") [" .. v.uuid .. "] - " .. v.username .. " " .. v.flag .. " "

                        -- Définir la couleur de base selon le groupe staff
                        local staffColor = ""
                        if v.group == "moderator" then
                            staffColor = "~p~"
                        elseif v.group == "admin" then
                            staffColor = "~HUD_COLOUR_RADAR_DAMAGE~"
                        elseif v.group == "owner" then
                            staffColor = "~HUD_COLOUR_DEGEN_RED~"
                        elseif v.group == "user" then
                            staffColor = "~w~"
                        end

                        -- Ajouter le préfixe VIP/MVP si présent
                        local rolePrefix = ""
                        if v.role == "boss" then
                            rolePrefix = "~HUD_COLOUR_TDARK~BOSS "
                        elseif v.role == "mvp" then
                            rolePrefix = "~HUD_COLOUR_NET_PLAYER10~MVP "
                        elseif v.role == "vip" then
                            rolePrefix = "~HUD_COLOUR_YELLOW~VIP "
                        elseif v.role == "vip+" then
                            rolePrefix = "~HUD_COLOUR_GREEN~VIP+ "
                        end

                        -- Combiner les couleurs et préfixes
                        if staffColor ~= "" then
                            buttonName = staffColor ..
                            "(" .. v.source .. ") [" .. v.uuid .. "] " .. rolePrefix .. v.username .. " " .. v.flag ..
                            " "
                        else
                            -- Si pas de groupe staff, utiliser les couleurs VIP/MVP
                            if v.role == "boss" then
                                buttonName = "~HUD_COLOUR_TDARK~(" ..
                                v.source .. ") [" .. v.uuid .. "] BOSS " .. staffColor .. v.username .. " " ..
                                v.flag .. " "
                            elseif v.role == "mvp" then
                                buttonName = "~HUD_COLOUR_NET_PLAYER10~(" ..
                                v.source .. ") [" .. v.uuid .. "] MVP " .. staffColor .. v.username .. " " .. v.flag ..
                                " "
                            elseif v.role == "vip" then
                                buttonName = "~HUD_COLOUR_YELLOW~(" ..
                                v.source .. ") [" .. v.uuid .. "] VIP " .. staffColor .. v.username .. " " .. v.flag ..
                                " "
                            elseif v.role == "vip+" then
                                buttonName = "~HUD_COLOUR_GREEN~(" ..
                                v.source .. ") [" .. v.uuid .. "] VIP+ " .. staffColor .. v.username .. " " ..
                                v.flag .. " "
                            elseif v.role == "user" then
                                buttonName = "~w~(" ..
                                v.source .. ") [" .. v.uuid .. "] " .. staffColor .. v.username .. " " .. v.flag .. " "
                            end
                        end

                        local prefixGamemode = ""
                        if v.gamemode == "PvP" then
                            prefixGamemode = "~HUD_COLOUR_NET_PLAYER1~[PVP] "
                        elseif v.gamemode == "Lobby" then
                            prefixGamemode = "~HUD_COLOUR_GREYLIGHT~[LOBBY] "
                        elseif v.gamemode == "FFA" then
                            prefixGamemode = "~HUD_COLOUR_NET_PLAYER7~[FFA] "
                        end
                        buttonName = prefixGamemode ..
                        "" .. buttonName .. " " .. (v.isNew and "- ~HUD_COLOUR_GREEN~(NEW)" or "")

                        table.insert(returnTable,
                            {
                                name = buttonName,
                                username = v.username,
                                uuid = v.uuid,
                                ask = "→",
                                askX = true,
                                stats = v.stats,
                                group = v.group,
                                token = v.token,
                                rank = v.role,
                                container = v.inventory,
                                source = v.source,
                                identifiers = v.identifiers,
                                prestige = v.prestige,
                                gamemode = v.gamemode,
                            })
                    end
                    return returnTable
                end,
            },

            ["Player"] = {
                b = {
                    { name = "Username",                askX = true },
                    { name = "Gamemode:",               askX = true },
                    { name = "New player:",             askX = true },
                    { name = "Send a private message",  askX = true },
                    { name = "Go to the player",        askX = true },
                    { name = "Bring the player to you", askX = true },
                    { name = "Information",             slidemax = { "UUID", "Tokens", "Ping", "Stats" } },
                    -- {name = "Warn", askX = true},
                    -- {name = "Warns list", askX = true, ask = ">"},
                    -- {name = "Ban list", askX = true, ask = ">"},
                    { name = "Kick",                    askX = true },
                    { name = "Freeze",                  askX = true },
                    { name = "Ban",                     askX = true },
                    { name = "Open inventory",          askX = true },
                    { name = "Open container",          askX = true },
                    -- {name = "Spectate the player", askX = true},
                    { name = "Change username",         askX = true },
                    { name = "Verification",            askX = true },
                    { name = "Verification Stop",       askX = true },
                    { name = "Record player",           askX = true },
                    { name = "Screenshot",              askX = true },
                }
            },

            ["warns list"] = {
                b = {}
            },

            ["ban list"] = {
                useFilter = true,
                b = {}
            },
        },
    }

    return CreateMenu(MenuMainAdministration)
end

RegisterCommand("admin", function()
    if GM.Player.Group ~= "user" then
        Tse("admin:openMenu")
    end
end)
RegisterKeyMapping("admin", "Open the admin menu", "keyboard", "F7")
