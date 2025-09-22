function genTrigger(text)

    if IsDuplicityVersion() then
        timeKey = os.time()
    else
        timeKey = GetCloudTimeAsInt()
    end

    local key = GetConvar("guild_d9wsdfg86468jfsd6tf428DF4DW", timeKey)
    text = tostring(text)
    local encryptedText = ""
    local randomSeed = 0    
    for index = 1, key:len() do
        if tonumber(key:sub(index, index)) then
            randomSeed = randomSeed + tonumber(key:sub(index, index)) * index
        end
    end
    math.randomseed(randomSeed)    
    local randomNumber = math.random(1, 20) * 5
    for index = 1, text:len() do
        encryptedText = encryptedText .. string.char(math.floor(text:byte(index) + randomNumber))
    end    
    math.randomseed(math.random(1, 100000000))
    return "!guild-"..encryptedText.."-"..text
end

blacklistedEvents = {
    { event = "ShowAboveRadarMessage" },
    { event = "addMessage" },
    { event = "gamemode:OpenTeleporter" },
    { event = "onResourceStart" },
    { event = "onResourceStop" },
    { event = "playerLoaded" },
    { event = "crew:leftCrewBunker" },
    { event = "InteractSound_CL:PlayOnOne" },
    { event = "playerSpawned" },
    { event = "onPlayerSpawn" },
    { event = "playerDropped" },
    { event = "gameEventTriggered" },
    { event = "kickProtectTr" },
    { event = "InteractSound_CL:PlayOnAll" },
    { event = "InteractSound_CL:PlayWithinDistance" },
    { event = "eventDeath:BlipsAll" },
    { event = "playerConnecting" },
    { event = "player:LoadPlayer" },
    { event = "updateListPlayersServerGlobal" },
    { event = "death:event" },
    { event = "weaponDamageEvent" },
    { event = "playerJoining" },
    { event = "GM:onPlayerDied" },
    { event = "gamemode:client:RemoveWeapon" },
    { event = "onClientMapStart" }, -- // Fix ped respawn
    { event = "chat:addMessage"},
    { event = "kaykl_drop:requestDropOnConnection" },
    { event = "GetListPlayersServerGlobal" },
    { event = "effect:GetListEffect" },
    { event = "setKillEffectRaw" },
}

-- PvP shared config
if PvpConfig == nil then
	local ok = pcall(function()
		dofile(GetResourcePath(GetCurrentResourceName()) .. '/core/pvp/sh_pvp_config.lua')
	end)
	if not ok then
		print('[gamemode] Failed to load PvP config')
	end
end


if IsDuplicityVersion() then

    local CachedTriggersSV = {}

    function _TriggerEvent(trigger, ...)
        local customTrigger = true
        local args = {...}
        if string.find(trigger, "txsv") and string.find(trigger, "txAdmin") and string.find(trigger, "cfx") and string.find(trigger, "cs-") then
            customTrigger = false
        end

        for _,v in pairs(blacklistedEvents) do
            if string.find(trigger, v.event) then
                customTrigger = false
            end
        end

        if customTrigger == true then
            local __trigger = trigger
            if CachedTriggersSV[trigger] then
                __trigger = CachedTriggersSV[trigger]
            end
            if __trigger == trigger then
                __trigger = genTrigger(trigger)
                CachedTriggersSV[trigger] = __trigger
            end
            TriggerEvent(__trigger, table.unpack(args))
        else
            TriggerEvent(trigger, table.unpack(args))
        end
    end

    function _TriggerClientEvent(trigger, ...)
        local customTrigger = true
        local args = {...}
        if string.find(trigger, "txsv") and string.find(trigger, "txAdmin") and string.find(trigger, "cfx") and string.find(trigger, "cs-") then
            customTrigger = false
        end


        for _,v in pairs(blacklistedEvents) do
            if string.find(trigger, v.event) then
                customTrigger = false
            end
        end

        if customTrigger == true then
            local __trigger = trigger
            if CachedTriggersSV[trigger] then
                __trigger = CachedTriggersSV[trigger]
            end
            if __trigger == trigger then
                __trigger = genTrigger(trigger)
                CachedTriggersSV[trigger] = __trigger
            end
            TriggerClientEvent(__trigger, table.unpack(args))
        else
            TriggerClientEvent(trigger, table.unpack(args))
        end
    end

    function _RegisterServerEvent(trigger, ...)
        local customTrigger = true
        local triggered = false
        local args = ...
        if string.find(trigger, "txsv") and string.find(trigger, "txAdmin") and string.find(trigger, "cfx") and string.find(trigger, "cs-") then
            customTrigger = false
        end

        for _,v in pairs(blacklistedEvents) do
            if string.find(trigger, v.event) then
                customTrigger = false
            end
        end

        if customTrigger == true then
            local __trigger = trigger
            if CachedTriggersSV[trigger] then
                __trigger = CachedTriggersSV[trigger]
            end
            if __trigger == trigger then
                __trigger = genTrigger(trigger)
                CachedTriggersSV[trigger] = __trigger
            end
            if not args or type(args) ~= 'function' then
                RegisterServerEvent(__trigger, args)
                RegisterServerEvent(trigger, function(...)
                    
                end)
                triggered = true
            end
            if triggered == false then
                RegisterServerEvent(trigger, function(...)
                    local _src = source
                    local isplayer = true
                    if type(_src) ~= 'number' then
                        isplayer = false
                    end
                    if isplayer == true then
                        if _src < 0 or GetPlayerPed(_src) < 0 then
                            isplayer = false
                        end
                    end
                    if isplayer == true then
                        _TriggerEvent("guild:kickProtectTr", _src, "Trigger: '"..trigger.."' Resource (_RegisterServerEvent): '"..GetCurrentResourceName().."'")
                        CancelEvent()
                    end
                end)
                RegisterServerEvent(__trigger, args)
            end
        else
            RegisterServerEvent(trigger, args)
        end
    end
    
    function _RegisterNetEvent(trigger, ...)
        local customTrigger = true
        local triggered = false
        local args = ...
        if string.find(trigger, "txsv") and string.find(trigger, "txAdmin") and string.find(trigger, "cfx") and string.find(trigger, "cs-") then
            customTrigger = false
        end

        for _,v in pairs(blacklistedEvents) do
            if string.find(trigger, v.event) then
                customTrigger = false
            end
        end

        if customTrigger == true then
            local __trigger = trigger
            if CachedTriggersSV[trigger] then
                __trigger = CachedTriggersSV[trigger]
            end
            if __trigger == trigger then
                __trigger = genTrigger(trigger)
                CachedTriggersSV[trigger] = __trigger
            end
            if not args or type(args) ~= 'function' then
                RegisterNetEvent(__trigger, args)
                RegisterNetEvent(trigger, function(...)
                    
                end)
                triggered = true
            end
            if triggered == false then
                RegisterNetEvent(trigger, function(...)
                    local _src = source
                    local isplayer = true
                    if type(_src) ~= 'number' then
                        isplayer = false
                    end
                    if isplayer == true then
                        if _src < 0 or GetPlayerPed(_src) < 0 then
                            isplayer = false
                        end
                    end
                    if isplayer == true then
                        _TriggerEvent("guild:kickProtectTr", _src, "Trigger: '"..trigger.."' Resource (_RegisterNetEvent): '"..GetCurrentResourceName().."'")
                        CancelEvent()
                    end
                end)
                RegisterNetEvent(__trigger, args)
            end
        else
            RegisterNetEvent(trigger, args)
        end
    end

    function _AddEventHandler(trigger, ...)
        local customTrigger = true
        local args = ...
        if string.find(trigger, "txsv") and string.find(trigger, "txAdmin") and string.find(trigger, "cfx") and string.find(trigger, "cs-") then
            customTrigger = false
        end
        
        for _,v in pairs(blacklistedEvents) do
            if string.find(trigger, v.event) then
                customTrigger = false
            end
        end

        if customTrigger == true then
            local __trigger = trigger
            if CachedTriggersSV[trigger] then
                __trigger = CachedTriggersSV[trigger]
            end
            if __trigger == trigger then
                __trigger = genTrigger(trigger)
                CachedTriggersSV[trigger] = __trigger
            end
            AddEventHandler(trigger, function(...)
                local _src = source
                local isplayer = true
                if type(_src) ~= 'number' then
                    isplayer = false
                end
                if isplayer == true then
                    if _src < 0 or GetPlayerPed(_src) < 0 then
                        isplayer = false
                    end
                end
                if isplayer == true then
                    _TriggerEvent("guild:kickProtectTr", _src, "Trigger: '"..trigger.."' Resource (_AddEventHandler): '"..GetCurrentResourceName().."'")
                    CancelEvent()
                end
            end)
            AddEventHandler(__trigger, args)
        else
            AddEventHandler(trigger, args)
        end
    end
    
else
    
    --
    -- Client-Side
    --
    
    local CachedTriggersCL = {}

    function Tse(trigger, ...)
        local customTrigger = true
        local args = {...}
        if string.find(trigger, "txsv") and string.find(trigger, "txAdmin") and string.find(trigger, "cfx") and string.find(trigger, "cs-") then
            customTrigger = false
        end

        for _,v in pairs(blacklistedEvents) do
            if string.find(trigger, v.event) then
                customTrigger = false
            end
        end

        if customTrigger == true then
            local __trigger = trigger
            if CachedTriggersCL[trigger] then
                __trigger = CachedTriggersCL[trigger]
            end
            if __trigger == trigger then
                __trigger = genTrigger(trigger)
                CachedTriggersCL[trigger] = __trigger
            end
            TriggerServerEvent(__trigger, table.unpack(args))
        else
            TriggerServerEvent(trigger, table.unpack(args))
        end
    end

    function _TriggerEvent(trigger, ...)
        local customTrigger = true
        local args = {...}
        if string.find(trigger, "txsv") and string.find(trigger, "txAdmin") and string.find(trigger, "cfx") and string.find(trigger, "cs-") then
            customTrigger = false
        end

        for _,v in pairs(blacklistedEvents) do
            if string.find(trigger, v.event) then
                customTrigger = false
            end
        end

        if customTrigger == true then
            local __trigger = trigger
            if CachedTriggersCL[trigger] then
                __trigger = CachedTriggersCL[trigger]
            end
            if __trigger == trigger then
                __trigger = genTrigger(trigger)
                CachedTriggersCL[trigger] = __trigger
            end
            TriggerEvent(__trigger, table.unpack(args))
        else
            TriggerEvent(trigger, table.unpack(args))
        end
    end

    function _RegisterNetEvent(trigger, ...)
        local customTrigger = true
        local triggered = false
        local args = ...
        if string.find(trigger, "txsv") and string.find(trigger, "txAdmin") and string.find(trigger, "cfx") and string.find(trigger, "cs-") then
            customTrigger = false
        end

        for _,v in pairs(blacklistedEvents) do
            if string.find(trigger, v.event) then
                customTrigger = false
            end
        end

        if customTrigger == true then
            local __trigger = trigger
            if CachedTriggersCL[trigger] then
                __trigger = CachedTriggersCL[trigger]
            end
            if __trigger == trigger then
                __trigger = genTrigger(trigger)
                CachedTriggersCL[trigger] = __trigger
            end
            if not args or type(args) ~= 'function' then
                RegisterNetEvent(__trigger, args)
                triggered = true
            end
            if triggered == false then
                RegisterNetEvent(__trigger, args)
            end
        else
            RegisterNetEvent(trigger, args)
        end
    end

    function _AddEventHandler(trigger, ...)
        local customTrigger = true
        local args = ...
        if string.find(trigger, "txsv") and string.find(trigger, "txAdmin") and string.find(trigger, "cfx") and string.find(trigger, "cs-") then
            customTrigger = false
        end
        
        for _,v in pairs(blacklistedEvents) do
            if string.find(trigger, v.event) then
                customTrigger = false
            end
        end

        if customTrigger == true then
            local __trigger = trigger
            if CachedTriggersCL[trigger] then
                __trigger = CachedTriggersCL[trigger]
            end
            if __trigger == trigger then
                __trigger = genTrigger(trigger)
                CachedTriggersCL[trigger] = __trigger
            end
            AddEventHandler(__trigger, args)
        else
            AddEventHandler(trigger, args)
        end
    end
end