_RegisterServerEvent("player:SetMyXP", function()
    local ply = GetPlayerId(source)
    _TriggerClientEvent('XNL_NET:XNL_SetInitialXPLevels', source, tonumber(ply.xp), true, true)
end)  

local PrestigeListe = {
    [0] = 8000,
    [1] = 25000,
    [2] = 30000,
    [3] = 35000,
    [4] = 40000,
    [5] = 45000,
    [6] = 50000,
    [7] = 55000,
    [8] = 65000,
    [9] = 75000,
    [10] = 85000,
    [11] = 100000,
    [12] = 200000,
    [13] = 350000,
    [14] = 600000,
    [15] = 900000,
}

function setPrestige(src, newPrestige, bypass)
    local player = GetPlayerId(src)
    local xpNeeded = 1584350
    if not bypass then
        if player.xp > xpNeeded then 
            player.prestige = newPrestige
            player.xp = 0
            player.AddXP(0)
            _TriggerClientEvent('XNL_NET:XNL_SetInitialXPLevels', src, tonumber(player.xp), true, true)
            player.sendTrigger("ShowAboveRadarMessage", "Prestige " .. player.prestige .. " reached! You unlock new advantages!")
        else
            player.sendTrigger("ShowAboveRadarMessage", "You need " .. xpNeeded - player.xp .. " more XP to reach prestige " .. newPrestige)
        end
    else
        player.prestige = newPrestige
        player.xp = 0
        player.AddXP(0)
        _TriggerClientEvent('XNL_NET:XNL_SetInitialXPLevels', src, tonumber(player.xp), true, true)
        player.sendTrigger("ShowAboveRadarMessage", "Prestige " .. player.prestige .. " reached! You unlock new advantages!")
    end
end


_RegisterServerEvent("PREFIX_PLACEHOLDER:prestigeSrv", function(action)
    local player = GetPlayerId(source)
    if action == "setPrestige" then 
        local actualPrestige = player.prestige
        if actualPrestige <= 15 then 
            setPrestige(source, actualPrestige + 1)
        else
            player.sendTrigger("ShowAboveRadarMessage", "You are already prestige 15!")
        end
    end
end)

RegisterCommand("edit_prestige", function(source, args)
    if not args then return end
    local player = GetPlayerId(source)
    if not player then return end
    if player.group == "user" then return end

    local playerToEdit = GetPlayerId(tonumber(args[1]))
    if not playerToEdit then return end

    local actualPrestige = playerToEdit.prestige
    if actualPrestige <= 15 then 
        setPrestige(playerToEdit.source, tonumber(args[2]), true)
    else
        player.sendTrigger("ShowAboveRadarMessage", "~r~This player are already prestige max")
    end
end)

RegisterCommand("prestige", function(source, args)
    local player = GetPlayerId(source)
    local helpCommand = args[1]
    if helpCommand == nil then 
       return  player.sendTrigger("ShowAboveRadarMessage", "~b~Usage: ~s~/prestige set\n/prestige my\n/prestige reset")
    end
    if helpCommand == "set" then 
        local actualPrestige = player.prestige
        if actualPrestige <= 15 then 
            setPrestige(source, actualPrestige + 1)
        else
            player.sendTrigger("ShowAboveRadarMessage", "You are already prestige 15!")
        end
    elseif helpCommand == "my" then 
        player.sendTrigger("ShowAboveRadarMessage", "You are ~b~prestige ~s~" .. player.prestige)
    elseif helpCommand == "reset" then 
        player.prestige = 0
        player.xp = 0
        player.AddXP(0)
        _TriggerClientEvent('XNL_NET:XNL_SetInitialXPLevels', source, tonumber(player.xp), true, true)
        player.sendTrigger("ShowAboveRadarMessage", "~g~Prestige reset!")
    end
end)

RegisterCommand("addxp", function(source, args)
    local player = GetPlayerId(source)
    local xp = tonumber(args[1])
    if player.group ~= "user" and player.group ~= "moderator" then
        if xp == nil then 
            return player.sendTrigger("ShowAboveRadarMessage", "~b~Usage: ~s~/addxp [xp]")
        end
        player.AddXP(xp)
    end
end)


Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1000*60*10)
        for k, v in pairs(Players) do 
            v.AddXP(1500)
        end
    end
end)