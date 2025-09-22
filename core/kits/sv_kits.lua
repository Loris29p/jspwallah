local listKits = {
    {kit = "daily", label = "^8Daily", role = {"user", "invite", "support", "vip", "vip+", "mvp"}, listItems = {
        {name = "weapon_specialcarbine", count = 50, label = "Special Carbine"},
        {name = "buffalo4", count = 50, label = "Buffalo STX"},
        -- {name = "kevlar", count = 70, label = "Kevlar"},
        -- {name = "bandage", count = 140, label = "Bandage"},
    }, time = 86400},
    {kit = "booster", label = "^6Booster", role = {"support", "vip", "vip+", "mvp"}, listItems = {
        {name = "weapon_combatmg", count = 20, label = "Combat MG"},
        {name = "weapon_carbinerifle_mk2", count = 10, label = "Carbine Rifle Mk II"},
        {name = "buffalo4", count = 40, label = "Buffalo STX"},
        {name = "weapon_specialcarbine", count = 10, label = "Special Carbine"},
        {name = "weapon_compactlauncher", count = 1, label = "Compact launcher"},
    }, time = 86400},
    {kit = "combat", label = "^3Combat", role = {"user", "invite", "support", "vip", "vip+", "mvp"}, listItems = {
        {name = "weapon_combatmg", count = 20, label = "Combat MG"},
        {name = "weapon_combatmg_mk2", count = 10, label = "Combat MG MK II"},
        {name = "weapon_bullpuprifle_mk2", count = 15, label = "Fusil Bullpup MK II"},
        {name = "buffalo4", count = 45, label = "Buffalo STX"},
    }, time = 7200}, 
    {kit = "vip", label = "^3Vip", role = {"vip", "vip+"}, listItems = {
        {name = "weapon_marksmanrifle", count = 1, label = "Marksman Rifle"},
        {name = "weapon_specialcarbine", count = 10, label = "Special Carbine"},
        {name = "weapon_carbinerifle_mk2", count = 10, label = "Carbine Rifle Mk II"},
        {name = "weapon_bullpuprifle_mk2", count = 10, label = "Fusil Bullpup MK II"},
        {name = "weapon_combatmg", count = 10, label = "Combat MG"},
        {name = "buffalo4", count = 40, label = "Buffalo STX"},

    }, time = 14400},
    {kit = "vip+", label = "^2Vip+", role = {"vip+"}, listItems = {
        {name = "weapon_marksmanrifle", count = 1, label = "Marksman Rifle"},
        {name = "weapon_specialcarbine", count = 25, label = "Special Carbine"},
        {name = "weapon_combatmg_mk2", count = 15, label = "Combat MG MK II"},
        {name = "weapon_carbinerifle_mk2", count = 25, label = "Carbine Rifle Mk II"},
        {name = "weapon_bullpuprifle_mk2", count = 25, label = "Fusil Bullpup MK II"},
        {name = "weapon_combatmg", count = 25, label = "Combat MG"},
        {name = "buffalo4", count = 115, label = "Buffalo STX"},
    }, time = 14400},
    {kit = "mvp", label = "^5Mvp", role = {"mvp"}, listItems = {
        {name = "weapon_rpg", count = 1, label = "RPG"},
        {name = "weapon_specialcarbine", count = 65, label = "Special Carbine"},
        {name = "weapon_combatmg_mk2", count = 15, label = "Combat MG MK II"},
        {name = "weapon_carbinerifle_mk2", count = 50, label = "Carbine Rifle Mk II"},
        {name = "weapon_bullpuprifle_mk2", count = 50, label = "Fusil Bullpup MK II"},
        {name = "weapon_combatmg", count = 50, label = "Combat MG"},
        {name = "buffalo4", count = 230, label = "Buffalo STX"},
    }, time = 14400},
    {kit = "boss", label = "^1Boss", role = {"god"}, listItems = {
        {name = "weapon_rpg", count = 1, label = "RPG"},
        {name = "weapon_marksmanrifle", count = 1, label = "Marksman Rifle"},
        {name = "weapon_specialcarbine", count = 110, label = "Special Carbine"},
        {name = "weapon_combatmg_mk2", count = 45, label = "Combat MG MK II"},
        {name = "weapon_carbinerifle_mk2", count = 110, label = "Carbine Rifle Mk II"},
        {name = "weapon_bullpuprifle_mk2", count = 85, label = "Fusil Bullpup MK II"},
        {name = "weapon_combatmg", count = 40, label = "Combat MG"},
        {name = "buffalo4", count = 385, label = "Buffalo STX"},
    }, time = 14400},
}

RegisterCommand("kit", function(source, args)
    Kits(source, args[1])
end)

local SecondsToClock = function(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return hours..":"..mins..":"..secs
    end
end

-- New event to handle requests for kits data
_RegisterServerEvent('kits:requestData', function()
    local src = source
    local PLAYER = GetPlayerId(src)
    local timers = {}
    
    local function playerHasRole(player, allowedRoles)
        if not allowedRoles or type(allowedRoles) ~= 'table' then return false end
        local myRoles = {}
        if player.roles and type(player.roles) == 'table' then
            for _, r in ipairs(player.roles) do myRoles[r] = true end
        end
        if player.role then myRoles[player.role] = true end
        for _, role in ipairs(allowedRoles) do
            if myRoles[role] then return true end
        end
        return false
    end
    
    -- Get timers for all kits that the player has access to
    for _, kit in pairs(listKits) do
        if playerHasRole(PLAYER, kit.role) or kit.kit == 'daily' or kit.kit == 'combat' then
            local foundKit = GetResourceKvpString(kit.kit..PLAYER.uuid)
            if foundKit then
                local timeLeft = GetResourceKvpInt(kit.kit..PLAYER.uuid.."_time")
                if timeLeft > 0 then
                    timers[kit.kit] = timeLeft
                end
            end
        end
    end
    
    -- Send data back to client
    _TriggerClientEvent('kits:receiveData', src, {
        kits = listKits,
        timers = timers,
        playerRole = PLAYER.role,
        playerRoles = (PLAYER.roles and type(PLAYER.roles) == 'table') and PLAYER.roles or { PLAYER.role },
        playerUuid = PLAYER.uuid
    })
end)

-- New event to handle kit claims from the UI
_RegisterServerEvent('kits:claimKit', function(kitName)
    local src = source
    Kits(src, kitName)
end)

RegisterCommand("nickname", function(source, args)
    local PLAYER = GetPlayerId(source)
    if args[1] == nil then 
        return _TriggerClientEvent("ShowAboveRadarMessage", source, "You need to put a nickname")
    end
    local foundNickNameUse = GetResourceKvpString("nickname_"..PLAYER.uuid)
    if foundNickNameUse and PLAYER.role == "user" or PLAYER.role == "invite" or PLAYER.role == "support" then 
        return _TriggerClientEvent("ShowAboveRadarMessage", source, "~b~You already use a nickname, please buy vip")
    else 
        local pseudo = ""
        for i=1, #args do
			if i > 0 then
				pseudo = (pseudo .. " " .. tostring(args[i]))
			end
		end
        if string.len(pseudo) > 30 then 
            return _TriggerClientEvent("ShowAboveRadarMessage", source, "~r~Nickname too long") 
        end
        SetResourceKvp("nickname_"..PLAYER.uuid, "true")
        PLAYER.setNickname(pseudo)
        _TriggerClientEvent("ShowAboveRadarMessage", source, "You new nickname is ~g~"..pseudo)
    end
end)

function Kits(source, kitsName)
    local src = source
    local PLAYER = GetPlayerId(src)
    local kitName = kitsName
    local function playerHasRole(player, allowedRoles)
        if not allowedRoles or type(allowedRoles) ~= 'table' then return false end
        local myRoles = {}
        if player.roles and type(player.roles) == 'table' then
            for _, r in ipairs(player.roles) do myRoles[r] = true end
        end
        if player.role then myRoles[player.role] = true end
        for _, role in ipairs(allowedRoles) do
            if myRoles[role] then return true end
        end
        return false
    end
    if kitName == nil then 
        -- Open the Kits UI by sending the same payload as kits:requestData
        local timers = {}
        for _, kit in pairs(listKits) do
            if playerHasRole(PLAYER, kit.role) or kit.kit == 'daily' or kit.kit == 'combat' then
                local foundKit = GetResourceKvpString(kit.kit..PLAYER.uuid)
                if foundKit then
                    local timeLeft = GetResourceKvpInt(kit.kit..PLAYER.uuid.."_time")
                    if timeLeft > 0 then
                        timers[kit.kit] = timeLeft
                    end
                end
            end
        end
        _TriggerClientEvent('kits:receiveData', src, {
            kits = listKits,
            timers = timers,
            playerRole = PLAYER.role,
            playerRoles = (PLAYER.roles and type(PLAYER.roles) == 'table') and PLAYER.roles or { PLAYER.role },
            playerUuid = PLAYER.uuid
        })
        return
    end
    if kitName then 
        local foundKit = GetResourceKvpString(kitName..PLAYER.uuid)
        for a, b in pairs(listKits) do 
            if (playerHasRole(PLAYER, b.role) or b.kit == 'daily' or b.kit == 'combat') then 
                if b.kit == kitName then 
                    if not foundKit then 
                        _TriggerClientEvent('chat:addMessage', src, { args = { "^8Kits: ^*You have received your kit: ^8"..kitName }, color = 200, 0, 0 })
                        for k, v in pairs(b.listItems) do 
                            SetResourceKvp(kitName..PLAYER.uuid, "true")
                            local newTime = os.time() + b.time
                            SetResourceKvpInt(kitName..PLAYER.uuid.."_time", newTime)
                            exports["gamemode"]:AddItem(PLAYER.source, "protected", v.name, v.count, nil, true)
                            _TriggerClientEvent('chat:addMessage', src, { args = { "^8Kits: ^7You received: ^8"..v.label.."^7 ^2"..v.count.."^7x" }, color = 200, 0, 0 })
                            -- Update the client with the new timer
                            _TriggerClientEvent('kits:updateKitTimer', src, kitName, newTime)
                        end
                    else
                        local GetTime = GetResourceKvpInt(kitName..PLAYER.uuid.."_time")
                        local time = SecondsToClock(GetTime - os.time())
                        if GetTime < os.time() then 
                            _TriggerClientEvent('chat:addMessage', src, { args = { "^8Kits: ^7You have received your kit: ^8"..kitName }, color = 200, 0, 0 })
                            for k, v in pairs(b.listItems) do 
                                SetResourceKvp(kitName..PLAYER.uuid, "true")
                                local newTime = os.time() + b.time
                                SetResourceKvpInt(kitName..PLAYER.uuid.."_time", newTime)
                                exports["gamemode"]:AddItem(PLAYER.source, "protected", v.name, v.count, nil, true)
                                _TriggerClientEvent('chat:addMessage', src, { args = { "^8Kits: ^7You received: ^8"..v.label.."^7 ^2"..v.count.."^7x" }, color = 200, 0, 0 })
                                -- Update the client with the new timer
                                _TriggerClientEvent('kits:updateKitTimer', src, kitName, newTime)
                            end
                        else
                            _TriggerClientEvent('chat:addMessage', src, { args = { "^8Kits: ^7You already taken this kit. You need to wait: ^8"..time }, color = 200, 0, 0 })
                        end
                    end
                end
            end
        end
    end
end

function table.contains(tbl, value)
    for k, v in pairs(tbl) do
        if (v == value) then
            return true, k, v;
        end
    end
    return false;
end