Discord.Register("death_log", "Death Log", "logs-kill")

function SendKillEffect(killerid, killedid)
    local PLAYER = GetPlayerId(killerid)
    local access = false 
    if PLAYER.role == "user" then 
        if CheckAccessEffect(killerid) then 
            access = true 
        end
    else
        access = true 
    end
    if not access then 
        return 
    end
    MySQL.Async.fetchAll("SELECT killeffect FROM settings WHERE license = @license", {["@license"] = PLAYER.license}, function(result)
        if result[1] ~= nil then 
            local killEffect = json.decode(result[1].killeffect)
            if not killEffect or not killEffect.dictname or not killEffect.particlename then return end 
            local KILLED_COORDS = GetEntityCoords(GetPlayerPed(killedid))
            _TriggerClientEvent("GM:KillEffect", killerid, killEffect.dictname, killEffect.particlename, KILLED_COORDS)
            _TriggerClientEvent("GM:KillEffect", killedid, killEffect.dictname, killEffect.particlename, KILLED_COORDS)
        end
    end)
end

local LoadoutItems = {
    "weapon_specialcarbine",
    "weapon_carbinerifle",
    "weapon_assaultrifle",
    "weapon_assaultrifle_mk2",
    "weapon_specialcarbine_mk2",
    "weapon_bullpuprifle_mk2",
    "weapon_vintagepistol",
    "weapon_combatpdw",
    "weapon_carbinerifle_mk2",
    "weapon_specialcarbine_mk2"
}

local LoadoutVeh = {
    "kuruma",
    "issi",
    "dominator4",
    "ztype",
    "gauntlet4",
    "cliffhanger",
    "omnis",
    "revolter",
    "jugular",
    "buffalo4"
}

-- Configuration for loadout kits
local LoadoutKitsConfig = {
    ["buffalo4_specialcarbine"] = {
        ["buffalo4"] = {
            display_name = "Buffalo STX"
        },
        ["weapon_specialcarbine"] = {
            display_name = "Special Carbine"
        }
    },
    ["buffalo4_bullpuprifle_mk2"] = {
        ["buffalo4"] = {
            display_name = "Buffalo STX"
        },
        ["weapon_bullpuprifle_mk2"] = {
            display_name = "Bullpup Rifle MK II"
        }
    },
    ["buffalo4_carbinerifle_mk2"] = {
        ["buffalo4"] = {
            display_name = "Buffalo STX"
        },
        ["weapon_carbinerifle_mk2"] = {
            display_name = "Carbine Rifle Mk II"
        }
    },
    ["buffalo4_specialcarbine_mk2"] = {
        ["buffalo4"] = {
            display_name = "Buffalo STX"
        },
        ["weapon_specialcarbine_mk2"] = {
            display_name = "Special Carbine MK II"
        }
    },
    -- Add more loadout kits here as needed
}

function SendLoadout(src)

    local randomItems = LoadoutItems[math.random(1, #LoadoutItems)]
    local randomVeh = LoadoutVeh[math.random(1, #LoadoutVeh)]

    exports.gamemode:AddItem(src, "inventory", randomItems, 1, nil, true)
    exports.gamemode:AddItem(src, "inventory", randomVeh, 1, nil, true)

    _TriggerClientEvent("ShowAboveRadarMessage", src, "~g~You received a free loadout")
end

function SendLoadoutKits(src)
    local PLAYER <const> = GetPlayerId(src) 

    local loadoutActive = GetSettings(PLAYER.uuid, "loadout")
    if not loadoutActive then return end 

    local loadoutKits = GetSettings(PLAYER.uuid, "loadout_kits")
    local kitConfig = LoadoutKitsConfig[loadoutKits]
    
    if not kitConfig then
        return
    end
    
    -- Process each item in the kit configuration
    for itemName, itemInfo in pairs(kitConfig) do
        local displayName = itemInfo.display_name or itemName
        local inInventory = exports["gamemode"]:HasItem(src, "inventory", itemName, 1)
        local inProtected = exports["gamemode"]:HasItem(src, "protected", itemName, 1)
        if inProtected then
            if exports["gamemode"]:AddItem(src, "inventory", itemName, 1, nil, true) then 
                exports["gamemode"]:RemoveItem(src, "protected", itemName, 1)
                DoNotif(src, "~g~Added ~r~"..Items[itemName].label.."~g~ to your inventory.")
            end
        else
            if tonumber(PLAYER.token) >= tonumber(Items[itemName].price) then 
                PLAYER.RemoveTokens(tonumber(Items[itemName].price))
                exports["gamemode"]:AddItem(src, "inventory", itemName, 1, nil, true)
                DoNotif(src, "~g~Added ~r~"..Items[itemName].label.."~g~ to your inventory.")
            end
        end
    end
end

RegisterCommand('loadout', function(source, args, rawCommand)
    SendLoadoutKits(source)
end)

function LoadoutLeague(src) 
    exports["gamemode"]:ClearInventory(src, "inventory")
    Wait(200)
    exports["gamemode"]:AddItem(src, "inventory", "weapon_specialcarbine", 1, nil, true)
    exports["gamemode"]:AddItem(src, "inventory", "weapon_carbinerifle_mk2", 1, nil, true)
    exports["gamemode"]:AddItem(src, "inventory", "weapon_specialcarbine_mk2", 1, nil, true)
    exports["gamemode"]:AddItem(src, "inventory", "kuruma", 1, nil, true)
    exports["gamemode"]:AddItem(src, "inventory", "revolter", 1, nil, true)
end

_RegisterServerEvent("death:event", function(killerId, killerdNetWorkid, isRedzone)

    local killed = source
    local killer = killerId

    local PLAYER_KILLED = GetPlayerId(killed)
    local PLAYER_KILLER = GetPlayerId(killer)

    PLAYER_KILLER.AddKills()
    PLAYER_KILLED.AddDeath()

    local inGamemode = false
    local FFA_DATA = GetFFAPlayer(killer)
    if FFA_DATA then 
        print("FFA DATA", FFA_DATA)
        FFA_DATA:AddKills(killer)
        inGamemode = true
        print("FFA DATA", FFA_DATA:GetKillsLeader(), FFA_DATA.map.kills_limit)
        if FFA_DATA:GetKillsLeader() >= FFA_DATA.map.kills_limit then
            FFA_DATA:Finish()
        end
    end


    if PlayerIsCapturing(killed) then 
        local npcId = PlayerIsCapturing(killed)
        RemoveNPCReward(npcId)
    end

    if FoundPlayerInGunrace(killerId) then 
        local gunraceId = FoundPlayerInGunrace(killerId)
        if gunraceId then 
            inGamemode = true
            gunraceId:AddKills({
                source = killerId,
            })
            if gunraceId:GetKillsLeader() >= 38 then
                gunraceId:Finish()
            end
        end
    end

    if GetPlayerInLeague(killerId) then 
        local teamKiller = GetPlayerTeam(killerId)
        if teamKiller then 
            AddKillToPlayerLeague(killerId)
        end
    end

    if GetHostPlayer(killerId) then 
        local teamKiller = GetPlayerTeamHost(killerId)
        if teamKiller then 
            AddKillToPlayerHost(killerId)
        end
    end

    if isRedzone then 
        PLAYER_KILLER.AddTokens(300)
        PLAYER_KILLER.AddXP(1500)
        _TriggerClientEvent("ShowAboveRadarMessage", PLAYER_KILLER.source, "~g~+300 Tokens")
        if GetPlayerCrew(killer) then 
            local CREW_DAT = GetCrewData(GetPlayerCrew(killer).crewId)
            if CREW_DAT then 
                CREW_DAT:AddKills({
                    type = "redzone",
                })
                -- CREW_DAT:AddAidropTaken()
            end
        end
    else
        PLAYER_KILLER.AddXP(1000)
        PLAYER_KILLER.AddTokens(150)
        _TriggerClientEvent("ShowAboveRadarMessage", PLAYER_KILLER.source, "~g~+150 Tokens")
    end


    if (PLAYER_KILLER.role == "vip+" or PLAYER_KILLER.role == "mvp" or PLAYER_KILLER.role == "boss") or CheckAccessEffect(killer) then 
        SendKillEffect(killer, killed)
    end

    _TriggerClientEvent("killerEvent", PLAYER_KILLER.source)

    local returnUser = ""
    if GetPlayerCrew(killer) then 
        local CREW_DAT = GetCrewData(GetPlayerCrew(killer).crewId)
        returnUser = GetTextWithGameColors(CREW_DAT.crewTag).." "..ReturnUsernameWithTagAndColor(killer)
    else
        returnUser = ReturnUsernameWithTagAndColor(killer)
    end

    _TriggerClientEvent("showDeathScreen", PLAYER_KILLED.source, {
        bool = true,
        prestige = PLAYER_KILLER.prestige,
        username = returnUser,
        uuid = PLAYER_KILLER.uuid,
        message = (PLAYER_KILLER.role == "vip+" or PLAYER_KILLER.role == "mvp" or PLAYER_KILLER.role == "boss") and GetSettings(PLAYER_KILLER.uuid, "deathmessage") or "",
        killerId = killer,
    })
    
    -- print(deathmessage, "DEATH MESSAGE")

    -- _TriggerClientEvent("showDeathScreen", PLAYER_KILLED.source, {
    --     bool = true,
    --     prestige = PLAYER_KILLER.prestige,
    --     username = PLAYER_KILLER.username,
    --     uuid = PLAYER_KILLER.uuid,
    --     message = deathmessage,
    --     killerId = killer,
    --     health = (GetEntityHealth(GetPlayerPed(PLAYER_KILLER.source)) / 2),
    --     armor = GetPedArmour(GetPlayerPed(PLAYER_KILLER.source)),
    -- })

    if GetPlayerCrew(killer) then 
        local CREW_DAT = GetCrewData(GetPlayerCrew(killer).crewId)
        if CREW_DAT then 
            CREW_DAT:AddKills({
                type = "global",
            })
        end
    end


    if GetPlayerId(killer).role ~= "user" then 
        if GetSettings(PLAYER_KILLER.uuid, "music_kill") ~= "none" then 
            _TriggerClientEvent("settings:playKillMusic", PLAYER_KILLED.source, GetSettings(PLAYER_KILLER.uuid, "music_kill"))
        end
    end

    
    local message = DiscordMessage(); 
    local returnMessage = ""
    local returnMessage2 = ""
    if DiscordId(killer) then 
        local PLAYER_DATA <const> = GetPlayerId(killer)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..") | Discord ID: <@"..DiscordId(killer)..">"
    else
        local PLAYER_DATA <const> = GetPlayerId(killer)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..")"
    end


    if DiscordId(killed) then 
        local PLAYER_DATA <const> = GetPlayerId(killed)
        returnMessage2 = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..") | Discord ID: <@"..DiscordId(killed)..">"
    else
        local PLAYER_DATA <const> = GetPlayerId(killed)
        returnMessage2 = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..")"
    end

    message:AddField()
        :SetName("Killer")
        :SetValue(returnMessage);
    message:AddField()
        :SetName("Killed")
        :SetValue(returnMessage2);

    Discord.Send("death_log", message);

    _TriggerClientEvent("death:KillsScreen", PLAYER_KILLER.source)
    _TriggerClientEvent("ShowAboveRadarMessage", PLAYER_KILLER.source, ("You killed ~r~%s (%s)"):format(PLAYER_KILLED.username, PLAYER_KILLED.source))
    _TriggerClientEvent("death:Blips", -1, GetEntityCoords(GetPlayerPed(PLAYER_KILLED.source)))

    if GetPlayerInLeague(killed) then 
        LoadoutLeague(killed)
    elseif GetHostPlayer(killed) then 
        SendLoadoutHost(killed)
    else
        if not inGamemode then 
            SendLoadoutKits(killed)
        end
    end
    
    -- SendLoadout(killed)
end)

_RegisterServerEvent("tggggg:bb", function(attackerid, isDead)
    _TriggerClientEvent("kO:client:writehit", attackerid, isDead)
end)