GM.Player = {}
GM.Test = false

GM.Player.Dead = false
GM.FinishLoading = false
GM.Player.InCombat = false
MyPlayer = nil

_AddEventHandler("playerSpawned", function()
    GM.Player.Spawned = true
    print("player spawned")
end)

CreateThread(function()
    DistantCopCarSirens(false)
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            -- SetEntityCoordsNoOffset(PlayerPedId(), 0.0, 0.0, 0.0, false, false,
            --                         false, true)
            ResetPausedRenderphases()

            DoScreenFadeOut(0)
            Wait(1000)
            ShowLoadingPrompt("Your character is loading...", 1)

            GM.Init()
            break
        end
    end
end)

function GM.Init()
    while not NetworkIsSessionStarted() do Wait(0) end

    Tse("player:JoiningServer")
end

-- Citizen.CreateThread(function() 
--   while true do 
--     Citizen.Wait(500)

--     if NetworkIsSessionStarted() then 
--       GM.Test = true
--       Citizen.CreateThread(function()
--         ShowLoadingPrompt(GetPhrase("loading_character"), 1)
--         DoScreenFadeOut(1000)

--       end)
--       -- while not GM.Player.Spawned or not GM.Init or GM.Test do 
--       --   Wait(100)
--       -- end
--       GM:InitPlayer()
--       break
--     end
--   end
-- end)

-- AddEventHandler("playerSpawned", function()
--   GM.Test = true
--   Citizen.CreateThread(function()
--     ShowLoadingPrompt(GetPhrase("loading_character"), 1)
--     DoScreenFadeOut(1000)

--   end)
--   -- while not GM.Player.Spawned or not GM.Init or GM.Test do 
--   --   Wait(100)
--   -- end
--   GM:InitPlayer()
-- end)

-- _RegisterNetEvent("connecting:Player", function()
--   GM:InitPlayer()
-- end)

function ItemExist(name)
    for k, v in pairs(Items) do if v.name == name then return true end end
end

-- RegisterCommand("test", function()
--     StartScreenEffect("MP_race_crash", 5000, false)
-- end)

function GM:InitPlayer()
    if GM.Init then return end
    if not GM.Init then Tse("player:JoiningServer") end

    Logger:trace("PLAYER", "Player initialized Step #1")
end

local BoosterAlert = false

_RegisterNetEvent("player:UpdateTable", function(player)
    GM.Player.Username = (player and player.username) or "Unknown"
    GM.Player.UUID = player.uuid
    GM.Player.Token = player.token
    GM.Player.Rank = player.rank
    GM.Player.Group = player.group
    GM.Player.Permissions = player.permissions
    GM.Player.Informations = player.informations
    GM.Player.Inventory = player.inventory
    GM.Player.Flag = player.flag
    GM.Player.Data = player.data
    GM.Player.Cosmetics = player.cosmetics
    GM.Player.Settings = player.settings
    GM.Player.CrewId = player.crewId
    GM.Player.XP = player.xp
    GM.Player.Identifiers = player.identifiers
    GM.Player.Blacklist = player.blacklist
    GM.Player.Skin = player.skin
    GM.Player.Coins = player.coins
    GM.Player.Kills_Global = player.kills_global
    GM.Player.Death_Global = player.death_global
    GM.Player.Prestique = player.prestige

    GM.Player.MaxWeight = (player and player.maxWeight) or 40.0
    GM.Player.MaxSafeWeight = (player and player.maxSafeWeight) or 25.0

    GM.Player.Role = player.role

    if player.isBooster then GM.Player.Booster = true end
end)

function GM.isSkinLoaded()
    return
        (GM.Player and GM.Player.Skin and json.encode(GM.Player.Skin) ~= "[]" and
            true or false)
end

exports('isSkinLoaded', GM.isSkinLoaded)

pedData_default = {
    model = "mp_m_freemode_01",
    faceFeatures = {
        nosePeakHigh = -0.1,
        chinBoneSize = 0,
        neckThickness = 0,
        eyesOpening = 0,
        nosePeakLowering = 0,
        chinBoneLenght = 0,
        chinBoneLowering = 0,
        jawBoneWidth = 0,
        cheeksBoneWidth = 0,
        chinHole = 0,
        noseBoneTwist = 0,
        cheeksWidth = 0,
        lipsThickness = 0,
        nosePeakSize = 0.2,
        eyeBrownHigh = 0,
        eyeBrownForward = 0,
        cheeksBoneHigh = 0,
        noseWidth = -0.3,
        noseBoneHigh = -0.4,
        jawBoneBackSize = 0
    },
    components = {
        { drawable = 0, component_id = 0, texture = 0 },
        { drawable = 0, component_id = 1, texture = 0 },
        { drawable = 0, component_id = 2, texture = 0 },
        { drawable = 0, component_id = 5, texture = 0 },
        { drawable = 0, component_id = 7, texture = 0 },
        { drawable = 0, component_id = 9, texture = 0 },
        { drawable = 0, component_id = 10, texture = 0 },
        { drawable = 0, component_id = 4, texture = 0 },
        { drawable = 7, component_id = 11, texture = 2 },
        { drawable = 4, component_id = 3, texture = 0 },
        { drawable = 1, component_id = 6, texture = 0 },
        { drawable = 0, component_id = 8, texture = 5 }
    },
    headOverlays = {
        complexion = { opacity = 0, color = 0, style = 0 },
        blush = { opacity = 0, color = 0, style = 0 },
        chestHair = { opacity = 0, color = 0, style = 0 },
        sunDamage = { opacity = 0, color = 0, style = 0 },
        bodyBlemishes = { opacity = 0, color = 0, style = 0 },
        lipstick = { opacity = 0, color = 0, style = 0 },
        ageing = { opacity = 0, color = 0, style = 0 },
        makeUp = { opacity = 0, color = 0, style = 0 },
        beard = { opacity = 0, color = 0, style = 0 },
        blemishes = { opacity = 0, color = 0, style = 0 },
        eyebrows = { opacity = 1, color = 0, style = 0 },
        moleAndFreckles = { opacity = 0, color = 0, style = 0 }
    },
    hair = {
        highlight = 0,
        color = 0,
        style = 2
    },
    headBlend = {
        shapeSecond = 0,
        skinSecond = 0,
        shapeFirst = 0,
        skinFirst = 8,
        skinMix = 0,
        shapeMix = 0
    },
    eyeColor = -1,
    props = {
        { drawable = -1, prop_id = 0, texture = -1 },
        { drawable = -1, prop_id = 1, texture = -1 },
        { drawable = -1, prop_id = 2, texture = -1 },
        { drawable = -1, prop_id = 6, texture = -1 },
        { drawable = -1, prop_id = 7, texture = -1 }
    }
}


RegisterCommand("default_ped", function()
    changeModel('mp_m_freemode_01')
    Wait(200)
    exports['fivem-appearance']:setPlayerAppearance(pedData_default)
end)

RegisterNetEvent("player:LoadPlayer")
AddEventHandler("player:LoadPlayer", function(player, newPlayer)
    Logger:trace("PLAYER", "Player initialized Step #1")
    ---@type GamePlayer
    MyPlayer = GamePlayer();
    local pPed = PlayerPedId()
    while not pPed do
        Wait(100)
        pPed = PlayerPedId()
    end
    if player == nil then return end

    GM.Init = true

    Logger:trace("PLAYER", " Player initialized Step #2")

    GM.Player.Username = player.username
    GM.Player.UUID = player.uuid
    GM.Player.Token = player.token
    GM.Player.Rank = player.rank
    GM.Player.Group = player.group
    GM.Player.Permissions = player.permissions
    GM.Player.Informations = player.informations
    GM.Player.Inventory = player.inventory
    GM.Player.Flag = player.flag
    GM.Player.Data = player.data
    GM.Player.Cosmetics = player.cosmetics
    GM.Player.Settings = player.settings
    GM.Player.CrewId = player.crewId
    GM.Player.XP = player.xp
    GM.Player.Identifiers = player.identifiers
    GM.Player.Blacklist = player.blacklist
    GM.Player.Skin = player.skin
    GM.Player.Coins = player.coins

    GM.Player.Kills_Global = player.kills_global
    GM.Player.Death_Global = player.death_global

    GM.Player.MaxWeight = (player and player.maxWeight) or 40.0
    GM.Player.MaxSafeWeight = (player and player.maxSafeWeight) or 25.0

    GM.Player.Prestique = player.prestige

    local Hipster = false
    local pPed = GetPlayerPed(-1)
    while not pPed or pPed == nil or pPed == 0 do
        pPed = GetPlayerPed(-1)
        Wait(100)
    end

    local maxTime = 10
    while not IsEntityVisible(pPed) and maxTime > 0 do
        pPed = GetPlayerPed(-1)
        print('Entity visible')
        SetEntityVisible(pPed, true)

        maxTime = maxTime - 1
        Wait(250)
    end

    print("Entity visible 2")

    while (IsPedModel(pPed, GetHashKey("a_m_y_hipster_01")) or
        IsPedModel(pPed, GetHashKey("a_m_y_hipster_02")) or 
        IsPedModel(pPed, GetHashKey("a_m_y_skater_02")) or 
        IsPedModel(pPed, GetHashKey("a_m_y_skater_01"))) and not Hipster do

        print('Entity hipster detected - changing ped')

        local modelHash = GetHashKey("a_m_y_business_01")
        
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(0)
        end
        
        SetPlayerModel(PlayerId(), modelHash)
        SetModelAsNoLongerNeeded(modelHash)
        
        pPed = PlayerPedId() -- Mise à jour du ped après changement
        Hipster = true
        print('Ped changed to:', randomModel)
        Wait(500)
    end

    print("Skin loaded")

    if (json.encode(GM.Player.Skin) ~= "[]") or (json.encode(GM.Player.Skin) ~= "[]" and Hipster) then
        print("Skin loaded 3")
        _TriggerEvent("skinchanger:loadSkin", GM.Player.Skin)
    end

    print("Skin loaded 2")

    print("Nui message")

    print('322')
    if (json.encode(player.skin) == "[]") or (json.encode(player.skin) == "[]" and Hipster) then
        print('324')
        changeModel('mp_m_freemode_01')
        Wait(200)
        exports['fivem-appearance']:setPlayerAppearance(pedData_default)
    end

    print("Spawn player")

    SpawnPlayer()
end)

function DisableAmbientSounds()

    DistantCopCarSirens(false)
    CanCreateRandomCops(false)
    for i = 0, 15 do
        EnableDispatchService(i, false)
    end
    SetScenarioGroupEnabled("LSA_Planes", false)

	AddRelationshipGroup("Zombies")
	SetRelationshipBetweenGroups(5, GetHashKey("Zombies"), GetHashKey("PlayerLS"))
    SetRelationshipBetweenGroups(5, GetHashKey("PlayerLS"), GetHashKey("Zombies"))

    SetDistantCarsEnabled(true)
    SetMaxWantedLevel(0)
    SetAiMeleeWeaponDamageModifier(0.7)
    SetAudioFlag("IsDirectorModeActive", true)
    local pId = PlayerId()
    SetIgnoreLowPriorityShockingEvents(pId, true)
    SetPlayerCanBeHassledByGangs(pId, false) 
    SetPoliceIgnorePlayer(pId, true)
    SetEveryoneIgnorePlayer(pId, true)
end

function SpawnPlayer()
    print("Spawn player 2")
    Logger:trace("MODULE PLAYER", "Loading all safezone.")
    Tse("dailyshop:getShopInfo")
    Wait(200)
    Tse("redzone:GetRedzoneInfo")
    Wait(200)
    Tse("player:SetMyXP")
    Tse("guildpvp:LoadMyCrew")
    TriggerServerEvent("squad:LoadExistingSquads")
    Tse("EventManager:GetEventData")
    Tse("league:GetLeagueData")
    Wait(200)
    Tse("event-manager:GetEventBox")
    Tse('npc_reward:GetNPCData')
    Tse('getDeluxoTricks')
    Tse('GetMilitaryZonePlayers')
    Tse('darkzone:GetData')
    Wait(200)
    Tse('afkfarm:GetData')
    Tse('gunrace:GetData')
    TriggerServerEvent("effect:GetListEffect")
    Wait(200)
    TriggerServerEvent("kaykl_drop:requestDropOnConnection")
    Wait(200)
    TriggerServerEvent("GetListPlayersServerGlobal")
    Tse('FFAGetData')
    loadSafes()
    Wait(6000)
    LoadGamemodeSelection()
    StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")

    print("SmugglerHangar")
	SmugglerHangar = exports['bob74_ipl']:GetSmugglerHangarObject()
    SmugglerHangar.Ipl.Interior.Load()

    print("Teleport to lobby")

	local pPed = PlayerPedId()
	local lobby = vec3(-1267.074, -3021.941, -48.49023) 
    TeleportToWp(pPed, lobby, nil, false)
    while IsPlayerTeleportActive() do
        print("Waiting for teleport")
        Wait(0)
    end

    print("Teleported to lobby")

    local timer = GetGameTimer()
    while #(GetEntityCoords(pPed) - lobby) > 2.5 and timer + 5000 > GetGameTimer() do
		print("Waiting for spawn", GetEntityCoords(pPed), lobby)
        Wait(500)

        TeleportToWp(pPed, lobby, nil, false)
        while IsPlayerTeleportActive() do
            print("Waiting for teleport 2")
            Wait(0)
        end
    end

    print("Loading player finish")

    GM.FinishLoading = true
    print("Test files")
    TriggerServerEvent("gfx-anticheat:server:changebucket")
    openNui()
    startStageOne(PlayerPedId())
    SetPedConfigFlag(PlayerPedId(), 48, true)
    Tse("pvpvideos:GetActualScaleform")
    RemoveLoadingPrompt()
    DoScreenFadeIn(500)

    SetPedMaxHealth(PlayerPedId(), 200)
    SetPlayerMaxArmour(PlayerId(), 100)
    print("Stop loading screen")
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    TriggerEvent('LoadingScreen:Stop')
    print("Stop loading screen 2")


    Tse('CheckPedAccess')
    Tse('CheckAccessEffect')
    DisableAmbientSounds()

    print("Disable ambient sounds")

    if MyPlayer:IsReady() then AlertBooster() end
end

function GM.Player:Get() return GM.Player end

_RegisterNetEvent("skin:SetSkin", function(skin)
    GM.Player.Skin = skin
    if json.encode(GM.Player.Skin) ~= "[]" then
        _TriggerEvent("skinchanger:loadSkin", GM.Player.Skin)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)
        if weapon ~= 0 then
            if IsPedShooting(ped) and not GM.Player.InSafeZone and
                not GM.Player.InCombat and not GM.Player.InFFA and not GM.Player.InGunrace then
                ShowAboveRadarMessage("~r~You are in combat mode.")
                SendNUIMessage({type = "updatecombatmode", combatmode = true})
                GM.Player.InCombat = true
                
                -- Attendre 2 secondes puis désactiver le combat mode
                Citizen.Wait(2000)
                
                GM.Player.InCombat = false
                SendNUIMessage({type = "updatecombatmode", combatmode = false})
                ShowAboveRadarMessage("~g~You are no longer in combat mode.")
            end
        else
            Citizen.Wait(500)
        end
        Citizen.Wait(1)
    end
end)

function GM.GetPlayerData() return GM end

exports("GetPlayerData", GM.GetPlayerData)

function GM.IsPlayerLoaded() return GM.Init end

local alertTime = 20000
function AlertBooster()
    Wait(alertTime)
    ShowNotificationUI({
        message = "~p~If you boost our discord server, you can get a lot of rewards.",
        type = "default",
        duration = 5000,
        sound = "notification.ogg",
        progressColor = "#b88fff"
    })
end

Citizen.CreateThread(function()
    _TriggerEvent('chat:addSuggestion', '/transferpoint',
                  'Transfer point to a player', {
        {name = 'uuid', help = 'uuid of the player'},
        {name = 'point', help = 'point to transfer'}
    })
end)
