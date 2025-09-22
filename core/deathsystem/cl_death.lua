_AddEventHandler('onClientMapStart', function()
    -- exports.spawnmanager:spawnPlayer()
    Citizen.Wait(200)
    exports.spawnmanager:setAutoSpawn(false)
end)


killCount = 0
local blipsDeath = {}

exports("isDead", function()
    return GM.Player.Dead
end)

local function blipsDead()
    local alpha = 255 
    local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
    local deathBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipScale(deathBlip, 0.6)
    SetBlipSprite(deathBlip,  432)
    SetBlipColour(deathBlip,  1)
    SetBlipAlpha(deathBlip, alpha)
    SetBlipAsShortRange(deathBlip, true)
    BeginTextCommandSetBlipName("STRING") 
    AddTextComponentString("Dead")
    EndTextCommandSetBlipName(deathBlip)
    SetBlipAsShortRange(deathBlip, 1)
    -- Citizen.CreateThread(function()
    --     while alpha ~= 0 do
    --         Citizen.Wait(1 * 1000)
    --         alpha = alpha - 1
    --         SetBlipAlpha(deathBlip, alpha)

    --         if alpha == 0 then
    --             RemoveBlip(deathBlip)
    --             break
    --         end
    --     end
    --     RemoveBlip(deathBlip)
    -- end)
    SetTimeout(20000, function()
        RemoveBlip(deathBlip)
    end)
end

function ClearPeds()
    local pPed = PlayerPedId()
    NetworkResurrectLocalPlayer(GetEntityCoords(pPed), 90.0, true, true, false)
    SetTimeout(100, function()
        local pPed2 = GetPlayerPed(-1)
        if pPed ~= pPed2 then
            DeleteEntity(pPed)
        end
    end)
end

function Revive(playerPed, bool, forceSpawn)
    ClearPeds()
    local player = GM.Player:Get()
    local pCoords = GetEntityCoords(PlayerPedId())
    local Heading = GetEntityHeading(PlayerPedId())
    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
    RemoveAllPedWeapons(PlayerPedId(), true)
    local pPed = PlayerPedId()
    if GM.Player.InDarkzone then  
        DestroyExtract()
    end
    if not forceSpawn then
        if GM.Player.InFFA then
            local randomRespawn = RandomRespawnFFA()
            SetEntityCoords(pPed, randomRespawn.x, randomRespawn.y, randomRespawn.z)
            SetEntityHeading(pPed, randomRespawn.w)
        elseif GM.Player.InLeague then 
            RespawnPlayerLeague()
        elseif GM.Player.InHostGame then
            RespawnPlayerHost()
        elseif GM.Player.InGunrace then
            RandomSpawnGunrace()
        else
            local nearSafezone = NearSafeZone(pCoords, true)
            SetEntityCoords(pPed, nearSafezone.coords.x, nearSafezone.coords.y, nearSafezone.coords.z)
            NetworkResurrectLocalPlayer(nearSafezone.coords.x, nearSafezone.coords.y, nearSafezone.coords.z, Heading, true, true, false)
            ShowAboveRadarMessage("You can ~b~enable~s~/~b~disable ~s~loadout in your settings.")
        end
    else 
        SetEntityCoords(pPed, pCoords.x, pCoords.y, pCoords.z)
        NetworkResurrectLocalPlayer(pCoords.x, pCoords.y, pCoords.z, Heading, true, true, false)
    end
    SetEntityInvincible(pPed, false)
    ClearPedBloodDamage(playerPed)
	SetEntityHealth(playerPed, GetPedMaxHealth(playerPed))
	ClearPedTasksImmediately(playerPed)
    -- ClearTimecycleModifier()
    FreezeEntityPosition(PlayerPedId(), false)

    if GM.Player.InLeague or GM.Player.InHostGame then 
        SendNUIMessage({
            action = "showKillHud",
            value = killCount,
        })
    else 
        SendNUIMessage({
            action = "hideKillHud",
        })
    end

    if not GM.Player.InFFA and not GM.Player.InSelecGamemode and not GM.Player.InLeague and not GM.Player.InHostGame and not GM.Player.InGunrace then
        SetTimeout(1000, function()
            DoScreenFadeIn(1000)
        end)
    end
    if GM.Player.InLeague or GM.Player.InHostGame then 
        SetEntityAlpha(PlayerPedId(), 130)
        SetTimeout(2000, function()
            SetEntityAlpha(PlayerPedId(), 255)
            ResetEntityAlpha(PlayerPedId())
            SetCanAttackFriendly(GetPlayerPed(-1), true)
            NetworkSetFriendlyFireOption(true)
        end)
    end
    if GM.Player.MilitaryZone then
        Tse("militaryzone:leave")
    end
end

_RegisterNetEvent("death:Blips", function(coords)
    if GM.Player.InFFA or GM.Player.InGunrace or GM.Player.InFarm then 
        return 
    end
    local alpha = 255 
    local ped = PlayerPedId()
    local deathBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipScale(deathBlip, 0.6)
    SetBlipSprite(deathBlip,  84)
    SetBlipColour(deathBlip,  1)
    SetBlipAlpha(deathBlip, alpha)
    SetBlipAsShortRange(deathBlip, true)
    BeginTextCommandSetBlipName("STRING") 
    AddTextComponentString("Death")
    EndTextCommandSetBlipName(deathBlip)
    SetBlipAsShortRange(deathBlip, 1)
    SetTimeout(20000, function()
        RemoveBlip(deathBlip)
    end)
end)

function GlobalDeath(killerPed, type)
    local player =  GM.Player:Get()

    local spawnCounter = 3
    if GM.Player.InFFA then 
        spawnCounter = 1
    elseif GM.Player.InGunrace then
        spawnCounter = 1
    elseif GM.Player.InLeague then 
        spawnCounter = 3
    elseif GM.Player.InHostGame then
        spawnCounter = 3
    end
    isOpened = false
    Display({
        bool = false
    })
    blipsDead()
    if type == "suicide" then 
        ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)
        -- SetTimecycleModifier("rply_vignette")
    end
    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
    RemoveAllPedWeapons(PlayerPedId(), true)

    if killerPed then 
        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        AttachCamToEntity(cam, killerPed, 0.0, 5.0, 0.8, true)
        SetCamFov(cam, 50.0)
        PointCamAtEntity(cam, killerPed, 0.0, 0.0, 0.0, true)
        RenderScriptCams(true, true, 350, true, true)
        local killcamSkipped = false
        CreateThread(function()
            while cam and IsEntityDead(PlayerPedId()) and not killcamSkipped do
                if not DoesEntityExist(killerPed) then 
                    break
                end
                -- Check for F key press to skip killcam
                if IsControlJustPressed(0, 23) then -- F key
                    ShowAboveRadarMessage("~g~Killcam pass with F !")
                    killcamSkipped = true
                    break
                end
                Wait(1)
            end
            DestroyCam(cam, false)
            cam = nil
            RenderScriptCams(false, false, 0, true, true)
        end)
    end

    while spawnCounter > 0 and not killcamSkipped do 
        spawnCounter = spawnCounter - 1 
        Citizen.Wait(1000)
    end

    if not GM.Player.InLeague and not GM.Player.InHostGame then 
        killCount = 0
    end
    if not GM.Player.InFFA and not GM.Player.InSelecGamemode and not GM.Player.InLeague and not GM.Player.InHostGame and not GM.Player.InGunrace then
        DoScreenFadeOut(200)
    end
    ShowDeathScreen({bool = false})
    DisplayRadar(true)
    Wait(500)
    SetCanAttackFriendly(GetPlayerPed(-1), false)
    NetworkSetFriendlyFireOption(false)
    Revive(PlayerPedId(), false)
    SetPedArmour(PlayerPedId(), 99)
    
    player.Dead = false 
    DisableOpeninvKey = false
end

function ShowDeathScreen(data)
    if data.bool then 
        SendNUIMessage({
            type = "deathframe",
            bool = true,
            prestige = data.prestige,
            username = data.username,
            uuid = data.uuid,
            armor = data.armor,
            health = data.health,
            deathmessage = data.message,
        })
    else
        SendNUIMessage({
            type = "deathframe",
            bool = false,
        })
    end
end

function foundWeaponDeath(ped)
    local hash = GetSelectedPedWeapon(ped)
    for _,weapon in pairs(Items) do
        if GetHashKey(weapon.name) == hash then
            return weapon.label
        end
    end
    return nil
end

local function HashToLabel(ped)
    local listItems = ItemListInventory()
    local hash = GetSelectedPedWeapon(ped)
    for _,item in pairs(listItems) do
        local model = GetEntityModel(veh)
        if GetHashKey(_) == hash then
            return item.label
        end
    end
    return ""
end

_RegisterNetEvent("showDeathScreen")
_AddEventHandler("showDeathScreen", function(data)
    DisplayRadar(false)
    
    if data.killerId then
        local killerPed = GetPlayerPed(GetPlayerFromServerId(data.killerId))
        if DoesEntityExist(killerPed) then
            local health = GetEntityHealth(killerPed)
            if health > 0 then
                if health > 100 then
                    health = health - 100
                end
                data.health = health
            else
                data.health = 0
            end
            data.armor = GetPedArmour(killerPed)
            local handle = RegisterPedheadshot(killerPed)
            while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
                Citizen.Wait(0)
            end
            local txd = GetPedheadshotTxdString(handle)
            BeginTextCommandThefeedPost("STRING")
            AddTextComponentSubstringPlayerName(("You have been killed by ~r~%s ~g~[%s]"):format(data.username, data.uuid))
        
            -- Set the notification icon, title and subtitle.
            local title = "GUILD PVP"
            local subtitle = ""
            local iconType = 0
            local flash = false 
            EndTextCommandThefeedPostMessagetext(txd, txd, flash, iconType, title, subtitle)
            EndTextCommandThefeedPostTicker(true, false)
            UnregisterPedheadshot(handle)
            local weapon = HashToLabel(killerPed) or ""
            local distance = math.ceil(#(GetEntityCoords(killerPed) - GetEntityCoords(PlayerPedId()))).. "m"
            local msg = ("~b~ HP: ~w~%s~b~ Armor: ~w~%s | %s\n ~r~%s"):format(data.health, data.armor, distance, weapon)
            ShowAboveRadarMessage(msg)
        else
            data.health = 0
            data.armor = 0
        end
    else
        data.health = 0
        data.armor = 0
    end
    
    ShowDeathScreen({
        bool = true,
        prestige = data.prestige,
        username = data.username,
        uuid = data.uuid,
        armor = data.armor,
        health = data.health,
        message = data.message,
    })

end)

_RegisterNetEvent("death:KillsScreen", function()
    killCount = killCount + 1
    SendNUIMessage({
        action = "showKillHud",
        count = killCount,
    })
end)

RegisterCommand("deathmessage", function(source, args)
    if GM.Player.Role ~= "vip+" and GM.Player.Role ~= "mvp" and GM.Player.Role ~= "god" then 
        return ShowAboveRadarMessage("~r~You need to be a VIP+ or MVP or GOD to use this command")
    else
        local InputResult = KeyboardInput("Deathmessage", "", 100)
        if InputResult then 
            Tse("gamemode:setSettings", "deathmessage", InputResult)
        else
            ShowAboveRadarMessage("~r~You didn't enter a death message.")
        end
    end
end)


_RegisterNetEvent("killerEvent", function()
    SetPedArmour(PlayerPedId(), 99)
    SetEntityHealth(PlayerPedId(), 200)
end)



function GetPlayerByEntityID(id)
    for i=0,255 do
        if(NetworkIsPlayerActive(i) and GetPlayerPed(i) == id) then 
            return i
        end
    end
    return nil
end

weapons = {
	[-1569615261] = 'weapon_unarmed',
	[-1716189206] = 'weapon_knife',
	[1737195953] = 'weapon_nightstick',
	[1317494643] = 'weapon_hammer',
	[-1786099057] = 'weapon_bat',
	[-2067956739] = 'weapon_crowbar',
	[1141786504] = 'weapon_golfclub',
	[-102323637] = 'weapon_bottle',
	[-1834847097] = 'weapon_dagger',
	[-102973651] = 'weapon_hatchet',
	[940833800] = 'weapon_stone_hatchet',
	[-656458692] = 'weapon_knuckle',
	[-581044007] = 'weapon_machete',
	[-1951375401] = 'weapon_flashlight',
	[-538741184] = 'weapon_switchblade',
	[-1810795771] = 'weapon_poolcue',
	[419712736] = 'weapon_wrench',
	[-853065399] = 'weapon_battleaxe',
	[453432689] = 'weapon_pistol',
	[-1075685676] = 'weapon_pistol_mk2',
	[1593441988] = 'weapon_combatpistol',
	[-1716589765] = 'weapon_pistol50',
	[-1076751822] = 'weapon_snspistol',
	[-2009644972] = 'weapon_snspistol_mk2',
	[-771403250] = 'weapon_heavypistol',
	[137902532] = 'weapon_vintagepistol',
	[-598887786] = 'weapon_marksmanpistol',
	[-1045183535] = 'weapon_revolver',
	[-879347409] = 'weapon_revolver_mk2',
	[-1746263880] = 'weapon_doubleaction',
	[584646201] = 'weapon_appistol',
	[911657153] = 'weapon_stungun',
	[1198879012] = 'weapon_flaregun',
	[324215364] = 'weapon_microsmg',
	[-619010992] = 'weapon_machinepistol',
	[736523883] = 'weapon_smg',
	[2024373456] = 'weapon_smg_mk2',
	[-270015777] = 'weapon_assaultsmg',
	[171789620] = 'weapon_combatpdw',
	[-1660422300] = 'weapon_mg',
	[2144741730] = 'weapon_combatmg',
	[-608341376] = 'weapon_combatmg_mk2',
	[1627465347] = 'weapon_gusenberg',
	[-1121678507] = 'weapon_minismg',
	[-1074790547] = 'weapon_assaultrifle',
	[961495388] = 'weapon_assaultrifle_mk2',
	[-2084633992] = 'weapon_carbinerifle',
	[-86904375] = 'weapon_carbinerifle_mk2',
	[-1357824103] = 'weapon_advancedrifle',
	[-1063057011] = 'weapon_specialcarbine',
	[-1768145561] = 'weapon_specialcarbine_mk2',
	[2132975508] = 'weapon_bullpuprifle',
	[-2066285827] = 'weapon_bullpuprifle_mk2',
	[1649403952] = 'weapon_compactrifle',
	[100416529] = 'weapon_sniperrifle',
	[205991906] = 'weapon_heavysniper',
	[177293209] = 'weapon_heavysniper_mk2',
	[-952879014] = 'weapon_marksmanrifle',
	[1785463520] = 'weapon_marksmanrifle_mk2',
	[487013001] = 'weapon_pumpshotgun',
	[1432025498] = 'weapon_pumpshotgun_mk2',
	[2017895192] = 'weapon_sawnoffshotgun',
	[-1654528753] = 'weapon_bullpupshotgun',
	[-494615257] = 'weapon_assaultshotgun',
	[-1466123874] = 'weapon_musket',
	[984333226] = 'weapon_heavyshotgun',
	[-275439685] = 'weapon_dbshotgun',
	[317205821] = 'weapon_autoshotgun',
	[-1568386805] = 'weapon_grenadelauncher',
	[-1312131151] = 'weapon_rpg',
	[1119849093] = 'weapon_minigun',
	[2138347493] = 'weapon_firework',
	[1834241177] = 'weapon_railgun',
	[1672152130] = 'weapon_hominglauncher',
	[1305664598] = 'weapon_grenadelauncher_smoke',
	[125959754] = 'weapon_compactlauncher',
	[-1813897027] = 'weapon_grenade',
	[741814745] = 'weapon_stickybomb',
	[-1420407917] = 'weapon_proxmine',
	[-1600701090] = 'weapon_bzgas',
	[615608432] = 'weapon_molotov',
	[101631238] = 'weapon_fireextinguisher',
	[883325847] = 'weapon_petrolcan',
	[-544306709] = 'weapon_petrolcan',
	[1233104067] = 'weapon_flare',
	[600439132] = 'weapon_ball',
	[126349499] = 'weapon_snowball',
	[-37975472] = 'weapon_smokegrenade',
	[-1169823560] = 'weapon_pipebomb',
	[-72657034] = 'weapon_parachute',
	[-1238556825] = 'weapon_rayminigun',
	[-1355376991] = 'weapon_raypistol',
	[1198256469] = 'weapon_raycarbine',
    [1834241177] = 'weapon_railgun',
    [-774507221] = 'weapon_tacticalrifle',
}

function hashToWeapon(hash)
    print(hash, "hashToWeapon")
	if weapons[hash] ~= nil then
		return weapons[hash]
	else
		return 'weapon_unarmed'
	end
end


_RegisterNetEvent("GM:onPlayerDied")
_AddEventHandler("GM:onPlayerDied", function(victimEntity, attackEntity, type)
    local player =  GM.Player:Get()
    if victimEntity and not player.Dead and IsEntityDead(victimEntity) then 
        player.Dead = true 
        if not GM.Player.InSafeZone and not GM.Player.InFFA and not GM.Player.InSelecGamemode and not GM.Player.InLeague and not GM.Player.InHostGame and not GM.Player.InFFA and not GM.Player.InGunrace then 
            Tse("gamemode:createBags", GetEntityCoords(PlayerPedId()))
        end
        DisableOpeninvKey = true
        if type == "suicide" then 
            Tse("killfeed:event", player.Username, player.Username, "weapon_unarmed", GM.Player.InRedzone, (GM.Player.InFFA or GM.Player.InGunrace))
            GlobalDeath(_, "suicide")
        elseif type == "player" then 
            local player = PlayerId()
            local killer, killerweapon = NetworkGetEntityKillerOfPlayer(player)
            local killerentitytype = GetEntityType(killer)
            local killerid = GetPlayerByEntityID(killer)
            local killerPed = GetPlayerByEntityID(killer)
            local kPed = GetPlayerPed(killerPed)
            local kPed2 = GetPlayerPed(killer)
            local kPlayerPedId = PlayerPedId(kPed)
            local weaponKiller = hashToWeapon(GetPedCauseOfDeath(GetPlayerPed(PlayerId())))
            if killer ~= ped and killerid ~= nil and NetworkIsPlayerActive(killerid) then 
                killerid = GetPlayerServerId(killerid)
            else 
                killerid = -1
            end

            -- Event Death 
            Tse("death:event", killerid, NetworkGetNetworkIdFromEntity(killerid),  GM.Player.InRedzone)
            Tse("killfeed:event:test", killerid, weaponKiller, GM.Player.InRedzone, (GM.Player.InFFA or GM.Player.InGunrace))
            if not GM.Player.InFFA and not GM.Player.InSelecGamemode and not GM.Player.InLeague and not GM.Player.InHostGame and not GM.Player.InGunrace and not GM.Player.InFFA then 
                Tse("showDeathblip", killerid)
            end

            if GM.Player.InRedzone then 
                if GM.Player.RedZoneId == nil then 
                    return 
                end
                Tse("redzone:AddKillerKills", GM.Player.RedZoneId, killerid)
            end
            GlobalDeath(kPed)
        end
    end
end)