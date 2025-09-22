local letime = {}
local coordsveh = {}

ListPlayersServerGlobal = {}

RegisterNetEvent('updateListPlayersServerGlobal', function(list)
    ListPlayersServerGlobal = list
end)

-- Alias for TriggerCallback to maintain backward compatibility
function CallbackServer(name, ...)
    return TriggerCallback(name, ...)
end

CreateThread(function()
    SetMaxWantedLevel(0)
    ClearPlayerWantedLevel(PlayerId())
    StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
end)


function LoadAnimSet(animSet)
    if not HasAnimSetLoaded(animSet) then
        RequestAnimSet(animSet)
        while not HasAnimSetLoaded(animSet) do
            Citizen.Wait(100)
        end
    end
end	

Citizen.CreateThread(function()
    local walkstyle = "move_m@jog@"
    while true do
        LoadAnimSet(walkstyle)
        local ped = PlayerPedId()
        if GetPlayerStamina(PlayerId()) <= 50 then
            ResetPedMovementClipset(ped)
        else
            SetPedMovementClipset(ped, walkstyle)
        end
        Citizen.Wait(1000)
    end
end)


Citizen.CreateThread(function()
    exports.spawnmanager:setAutoSpawn(false)
    while true do 

        local playerPed = PlayerPedId()

        DisablePlayerVehicleRewards(PlayerId()) -- Pas de drop d'arme véhicule

        DisableControlAction(0, 199, true) -- Pas la Map sur P
        
        if GM.Player.InGunrace then
            SetPedSuffersCriticalHits(PlayerPedId(), true) -- Pas de NoHeadShot
        else
            SetPedSuffersCriticalHits(PlayerPedId(), false) -- Pas de NoHeadShot
        end

		RestorePlayerStamina(PlayerId(), 1.0) -- Stamina infiny

        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0) -- Pas de regen vie
        
        N_0xf4f2c0d4ee209e20() -- Disable cinématique AFK
        HudWeaponWheelIgnoreSelection()

        -- SetPedHelmet(PlayerPedId(), false) -- Pas de casque auto sur les moto

        for a = 1, 15 do
            EnableDispatchService(a, false) -- Pas de dispatch
        end

        DisablePoliceReports() -- Disable Police Call

        N_0x4757f00bc6323cfe(-1553120962, 0.0)


        SetEntityProofs(PlayerPedId(), false, true, false, true, false, false, nil, false)

        SetPedCanRagdoll(playerPed, false)
        SetPedRagdollOnCollision(playerPed, false)
        SetPedCanRagdollFromPlayerImpact(playerPed, false)
        SetPedCanRagdoll(playerPed, false)

        NetworkOverrideClockTime(12, 12, 12)
        SetWeatherTypeNowPersist("CLEAR")

        local allveh = GetGamePool('CVehicle')
        for i = 1, #allveh do
            local vehicle = allveh[i]
            coordsveh[tostring(vehicle)] = GetEntityCoords(vehicle)
            local model = GetEntityModel(vehicle)
            
            -- Liste des véhicules spéciaux à réparer automatiquement
            if model == GetHashKey("deluxo") or model == GetHashKey("oppressor") or 
               model == GetHashKey("dukes2") or model == GetHashKey("scarab") or 
               model == GetHashKey("nightshark") then
                
                -- Vérifie si le véhicule est détruit (plusieurs conditions)
                local isDestroyed = GetVehicleBodyHealth(vehicle) <= 50 or 
                                   GetVehicleEngineHealth(vehicle) <= 0
                
                if isDestroyed then
                    -- Si le véhicule n'est pas déjà marqué pour réparation
                    if letime[vehicle] ~= true then
                        letime[vehicle] = true
                        
                        -- Enregistrer l'ID du véhicule pour la réparation
                        local vehicleToRepair = vehicle
                        
                        -- Créer un thread pour réparer le véhicule après un délai
                        Citizen.CreateThread(function()
                            -- Attendre 30 secondes avant la réparation
                            Citizen.Wait(30000)
                            
                            -- Vérifier que le véhicule existe toujours avant de le réparer
                            if DoesEntityExist(vehicleToRepair) then
                                -- Réparer complètement le véhicule
                                SetVehicleFixed(vehicleToRepair)
                                SetVehicleDeformationFixed(vehicleToRepair)
                                SetVehicleUndriveable(vehicleToRepair, false)
                                SetVehicleEngineOn(vehicleToRepair, true, true)
                                SetVehicleBodyHealth(vehicleToRepair, 1000.0)
                                SetVehicleEngineHealth(vehicleToRepair, 1000.0)
                                SetEntityHealth(vehicleToRepair, 1000)
                                
                                -- Réinitialiser le statut pour permettre une future réparation
                                letime[vehicleToRepair] = false
                            end
                        end)
                    end
                end
            end
        end

        Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        DisableControlAction(0, 140, true)
    end
end)

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(2)
      local ped = PlayerPedId()
        if IsPedArmed(ped, 6) then
            DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
        end 
    end 
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        BlockWeaponWheelThisFrame()
        HudWeaponWheelIgnoreSelection()
        HideHudComponentThisFrame(19)

        HudForceWeaponWheel(false)

        DisableControlAction(0, 37, true)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local worked, groundZ, normal = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z)
        SetPedConfigFlag(PlayerPedId(), 359, false)
        SetPedConfigFlag(PlayerPedId(), 422, false)
        if IsPedGettingUp(PlayerPedId()) then
            local velo = GetEntityVelocity(PlayerPedId())
            ClearPedTasksImmediately(playerPed)
            SetEntityVelocity(PlayerPedId(), velo)
            Citizen.Wait(1000)
            end
        if IsPedFalling(playerPed) and #(coords-vector3(coords.x, coords.y, groundZ)) <= 6.0 then
            ClearPedTasks(playerPed)
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()

    DisableVehicleDistantlights(true)
    SetPedPopulationBudget(0)
    SetVehiclePopulationBudget(0)
    SetRandomEventFlag(false)
    local scenarios = {
        'WORLD_VEHICLE_ATTRACTOR',
        'WORLD_VEHICLE_AMBULANCE',
        'WORLD_VEHICLE_BICYCLE_BMX',
        'WORLD_VEHICLE_BICYCLE_BMX_BALLAS',
        'WORLD_VEHICLE_BICYCLE_BMX_FAMILY',
        'WORLD_VEHICLE_BICYCLE_BMX_HARMONY',
        'WORLD_VEHICLE_BICYCLE_BMX_VAGOS',
        'WORLD_VEHICLE_BICYCLE_MOUNTAIN',
        'WORLD_VEHICLE_BICYCLE_ROAD',
        'WORLD_VEHICLE_BIKE_OFF_ROAD_RACE',
        'WORLD_VEHICLE_BIKER',
        'WORLD_VEHICLE_BOAT_IDLE',
        'WORLD_VEHICLE_BOAT_IDLE_ALAMO',
        'WORLD_VEHICLE_BOAT_IDLE_MARQUIS',
        'WORLD_VEHICLE_BOAT_IDLE_MARQUIS',
        'WORLD_VEHICLE_BROKEN_DOWN',
        'WORLD_VEHICLE_BUSINESSMEN',
        'WORLD_VEHICLE_HELI_LIFEGUARD',
        'WORLD_VEHICLE_CLUCKIN_BELL_TRAILER',
        'WORLD_VEHICLE_CONSTRUCTION_SOLO',
        'WORLD_VEHICLE_CONSTRUCTION_PASSENGERS',
        'WORLD_VEHICLE_DRIVE_PASSENGERS',
        'WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED',
        'WORLD_VEHICLE_DRIVE_SOLO',
        'WORLD_VEHICLE_FIRE_TRUCK',
        'WORLD_VEHICLE_EMPTY',
        'WORLD_VEHICLE_MARIACHI',
        'WORLD_VEHICLE_MECHANIC',
        'WORLD_VEHICLE_MILITARY_PLANES_BIG',
        'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
        'WORLD_VEHICLE_PARK_PARALLEL',
        'WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN',
        'WORLD_VEHICLE_PASSENGER_EXIT',
        'WORLD_VEHICLE_POLICE_BIKE',
        'WORLD_VEHICLE_POLICE_CAR',
        'WORLD_VEHICLE_POLICE',
        'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
        'WORLD_VEHICLE_QUARRY',
        'WORLD_VEHICLE_SALTON',
        'WORLD_VEHICLE_SALTON_DIRT_BIKE',
        'WORLD_VEHICLE_SECURITY_CAR',
        'WORLD_VEHICLE_STREETRACE',
        'WORLD_VEHICLE_TOURBUS',
        'WORLD_VEHICLE_TOURIST',
        'WORLD_VEHICLE_TANDL',
        'WORLD_VEHICLE_TRACTOR',
        'WORLD_VEHICLE_TRACTOR_BEACH',
        'WORLD_VEHICLE_TRUCK_LOGS',
        'WORLD_VEHICLE_TRUCKS_TRAILERS',
        'WORLD_VEHICLE_DISTANT_EMPTY_GROUND'
    }
    for i, v in pairs(scenarios) do
        SetScenarioTypeEnabled(v, false)
    end
end)


-- Citizen.CreateThread(function()
--     while true do 
--         local timer = 500
--         local playerPed = PlayerPedId()
--         local coords = GetEntityCoords(playerPed)

--         local markerCoords = vector3(26.41342, -637.7908, 16.08864)
        

--         if GetDistanceBetweenCoords(coords, markerCoords, true) < 9.0 then
--             timer = 1
--             DrawMarker(2, markerCoords.x, markerCoords.y, markerCoords.z + 1.0, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 1.2, 200, 0, 0, 200, 0, 0, 0, 0)
--             if GetDistanceBetweenCoords(coords, markerCoords, true) < 1.5 then
--                 DrawTopNotification("Press ~INPUT_PICKUP~ to up.")
--                 if IsControlJustPressed(0, 38) then
--                     -- SetBypassTeleport(true)
--                     SetEntityCoords(playerPed, 38.12601, -626.2302, 31.63213)
--                     Wait(500)
--                     -- SetBypassTeleport(false)
--                 end
--             end
--         end
--         Citizen.Wait(timer)
--     end
-- end)


local BLIP_INFO_DATA = {}

--[[
    Default state for blip info
]]

function ensureBlipInfo(blip)
    if blip == nil then blip = 0 end
    SetBlipAsMissionCreatorBlip(blip, true)
    if not BLIP_INFO_DATA[blip] then BLIP_INFO_DATA[blip] = {} end
    if not BLIP_INFO_DATA[blip].title then BLIP_INFO_DATA[blip].title = "" end
    if not BLIP_INFO_DATA[blip].rockstarVerified then BLIP_INFO_DATA[blip].rockstarVerified = false end
    if not BLIP_INFO_DATA[blip].info then BLIP_INFO_DATA[blip].info = {} end
    if not BLIP_INFO_DATA[blip].money then BLIP_INFO_DATA[blip].money = "" end
    if not BLIP_INFO_DATA[blip].rp then BLIP_INFO_DATA[blip].rp = "" end
    if not BLIP_INFO_DATA[blip].dict then BLIP_INFO_DATA[blip].dict = "" end
    if not BLIP_INFO_DATA[blip].tex then BLIP_INFO_DATA[blip].tex = "" end
    return BLIP_INFO_DATA[blip]
end

--[[
    Export functions, use these via an export pls
]]

function ResetBlipInfo(blip)
    BLIP_INFO_DATA[blip] = nil
end

function SetBlipInfoTitle(blip, title, rockstarVerified)
    local data = ensureBlipInfo(blip)
    data.title = title or ""
    data.rockstarVerified = rockstarVerified or false
end

function SetBlipInfoImage(blip, dict, tex)
    local data = ensureBlipInfo(blip)
    data.dict = dict or ""
    data.tex = tex or ""
end

function SetBlipInfoEconomy(blip, rp, money)
    local data = ensureBlipInfo(blip)
    data.money = tostring(money) or ""
    data.rp = tostring(rp) or ""
end

function SetBlipInfo(blip, info)
    local data = ensureBlipInfo(blip)
    data.info = info
end

function AddBlipInfoText(blip, leftText, rightText)
    local data = ensureBlipInfo(blip)
    if rightText then
        table.insert(data.info, {1, leftText or "", rightText or ""})
    else
        table.insert(data.info, {5, leftText or "", ""})
    end
end

function AddBlipInfoName(blip, leftText, rightText)
    local data = ensureBlipInfo(blip)
    table.insert(data.info, {3, leftText or "", rightText or ""})
end

function AddBlipInfoHeader(blip, leftText, rightText)
    local data = ensureBlipInfo(blip)
    table.insert(data.info, {4, leftText or "", rightText or ""})
end

function AddBlipInfoIcon(blip, leftText, rightText, iconId, iconColor, checked)
    local data = ensureBlipInfo(blip)
    table.insert(data.info, {2, leftText or "", rightText or "", iconId or 0, iconColor or 0, checked or false})
end

--[[
    All that fancy decompiled stuff I've kinda figured out
]]

local Display = 1
function UpdateDisplay()
    if PushScaleformMovieFunctionN("DISPLAY_DATA_SLOT") then
        PushScaleformMovieFunctionParameterInt(Display)
        PopScaleformMovieFunctionVoid()
    end
end

function SetColumnState(column, state)
    if PushScaleformMovieFunctionN("SHOW_COLUMN") then
        PushScaleformMovieFunctionParameterInt(column)
        PushScaleformMovieFunctionParameterBool(state)
        PopScaleformMovieFunctionVoid()
    end
end

function ShowDisplay(show)
    SetColumnState(Display, show)
end

function func_36(fParam0)
    BeginTextCommandScaleformString(fParam0)
    EndTextCommandScaleformString()
end

function SetIcon(index, title, text, icon, iconColor, completed)
    if PushScaleformMovieFunctionN("SET_DATA_SLOT") then
        PushScaleformMovieFunctionParameterInt(Display)
        PushScaleformMovieFunctionParameterInt(index)
        PushScaleformMovieFunctionParameterInt(65)
        PushScaleformMovieFunctionParameterInt(3)
        PushScaleformMovieFunctionParameterInt(2)
        PushScaleformMovieFunctionParameterInt(0)
        PushScaleformMovieFunctionParameterInt(1)
        func_36(title)
        func_36(text)
        PushScaleformMovieFunctionParameterInt(icon)
        PushScaleformMovieFunctionParameterInt(iconColor)
        PushScaleformMovieFunctionParameterBool(completed)
        PopScaleformMovieFunctionVoid()
    end
end

function SetText(index, title, text, textType)
    if PushScaleformMovieFunctionN("SET_DATA_SLOT") then
        PushScaleformMovieFunctionParameterInt(Display)
        PushScaleformMovieFunctionParameterInt(index)
        PushScaleformMovieFunctionParameterInt(65)
        PushScaleformMovieFunctionParameterInt(3)
        PushScaleformMovieFunctionParameterInt(textType or 0)
        PushScaleformMovieFunctionParameterInt(0)
        PushScaleformMovieFunctionParameterInt(0)
        func_36(title)
        func_36(text)
        PopScaleformMovieFunctionVoid()
    end
end

local _labels = 0
local _entries = 0
function ClearDisplay()
    if PushScaleformMovieFunctionN("SET_DATA_SLOT_EMPTY") then
        PushScaleformMovieFunctionParameterInt(Display)
    end
    PopScaleformMovieFunctionVoid()
    _labels = 0
    _entries = 0
end

function _label(text)
    local lbl = "LBL" .. _labels
    AddTextEntry(lbl, text)
    _labels = _labels + 1
    return lbl
end

function SetTitle(title, rockstarVerified, rp, money, dict, tex)
    if PushScaleformMovieFunctionN("SET_COLUMN_TITLE") then
        PushScaleformMovieFunctionParameterInt(Display)
        func_36("")
        func_36(_label(title))
        PushScaleformMovieFunctionParameterInt(rockstarVerified)
        PushScaleformMovieFunctionParameterString(dict)
        PushScaleformMovieFunctionParameterString(tex)
        PushScaleformMovieFunctionParameterInt(0)
        PushScaleformMovieFunctionParameterInt(0)
        if rp == "" then
            PushScaleformMovieFunctionParameterBool(0)
        else
            func_36(_label(rp))
        end
        if money == "" then
            PushScaleformMovieFunctionParameterBool(0)
        else
            func_36(_label(money))
        end
    end
    PopScaleformMovieFunctionVoid()
end

function AddText(title, desc, style)
    SetText(_entries, _label(title), _label(desc), style or 1)
    _entries = _entries + 1
end

function AddIcon(title, desc, icon, color, checked)
    SetIcon(_entries, _label(title), _label(desc), icon, color, checked)
    _entries = _entries + 1
end

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local model = GetEntityModel(vehicle) 


        if IsPedOnAnyBike(playerPed) and model == GetHashKey("oppressor") then
            SetPedCanRagdoll(playerPed, true)
            SetPedRagdollOnCollision(playerPed, true)
            SetPedCanRagdollFromPlayerImpact(playerPed, true)

            SetPedCanBeKnockedOffVehicle(playerPed, 1)
        elseif IsPedOnAnyBike(playerPed) and model == GetHashKey("deathbike") then
            SetPedCanRagdoll(playerPed, false)
            SetPedRagdollOnCollision(playerPed, false)
            SetPedCanRagdollFromPlayerImpact(playerPed, false)

            SetPedCanBeKnockedOffVehicle(playerPed, 0)
        else
            SetEntityInvincible(GetVehiclePedIsIn(playerPed, false), false)
        end
    end
end)

function showBigMessage(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry('esxAdvancedNotification', msg)
	BeginTextCommandThefeedPost('esxAdvancedNotification')
	if hudColorIndex then ThefeedSetNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
	PlaySoundFrontend(-1, "TENNIS_POINT_WON","HUD_AWARDS", 0)
end

_RegisterNetEvent('showBigMessage')
_AddEventHandler('showBigMessage', function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	showBigMessage(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
end)

function GetFPS()
    local startCount = GetFrameCount()
    Wait(1000)
    local endCount = GetFrameCount()
    local frameNum = endCount - startCount
    return frameNum
end

Citizen.CreateThread(function()

    while GM.Player == nil do Wait(0) end

    while true do
        local PlayerName = (GM and GM.Player and GM.Player.Username or "Unknown")
        local id = GetPlayerServerId(PlayerId())
        local uuid = (GM and GM.Player and GM.Player.UUID or "Unknown")
        
        SetDiscordAppId(1294685844438777906)

        SetRichPresence(PlayerName.. " - "..GetFPS().." FPS")
        SetDiscordRichPresenceAsset('LargeIcon')
        

        SetDiscordRichPresenceAssetText('GUILD: PVP ('..uuid..') - '..PlayerName)
        SetDiscordRichPresenceAction(1, "Discord 🔊​", "https://discord.gg/guildpvp")
        SetDiscordRichPresenceAction(0, "Play with "..PlayerName.." 🎉", "fivem://connect/play.guildpvp.fr")
        Citizen.Wait(4000)
    end
end)

function CheckIfVehicleIsDarkzone(vehicle)
   for k, v in pairs(DarkzoneData.Extraction) do 
    if v == vehicle then
        return true
    end
   end
   return false
end

_RegisterNetEvent("wld:delallveh", function()
    for vehicle in EnumerateVehicles() do
        if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then 
            if not CheckIfVehicleIsDarkzone(vehicle) then 
                SetVehicleHasBeenOwnedByPlayer(vehicle, false) 
                SetEntityAsMissionEntity(vehicle, false, false) 
                DeleteVehicle(vehicle)
                if (DoesEntityExist(vehicle)) then 
                    DeleteVehicle(vehicle) 
                end
            end
        end
    end
end)

_RegisterNetEvent("wld:delallvehauto", function()
    for vehicle in EnumerateVehicles() do
        if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then 
            if not CheckIfVehicleIsDarkzone(vehicle) then 
                SetVehicleHasBeenOwnedByPlayer(vehicle, false) 
                SetEntityAsMissionEntity(vehicle, false, false) 
                DeleteVehicle(vehicle)
                if (DoesEntityExist(vehicle)) then 
                    DeleteVehicle(vehicle) 
                end
            end
        end
    end
end)

InSoloTricksZone = false 
soloTricksZone = nil
blipsTricks = nil 

_RegisterNetEvent("changeDeluxoTricks", function(deluxoTricks)
    print("changeDeluxoTricks", deluxoTricks.name, deluxoTricks.pos, deluxoTricks.radius)
    soloTricksZone = deluxoTricks
    if blipsTricks then 
        RemoveBlip(blipsTricks)
    end
    blipsTricks = AddBlipForRadius(soloTricksZone.pos.x, soloTricksZone.pos.y, soloTricksZone.pos.z, soloTricksZone.radius)
    SetBlipColour(blipsTricks, 32)
    SetBlipAlpha(blipsTricks, 120)
    SetBlipAsShortRange(blipsTricks, false)
end)

Citizen.CreateThread(function()
    while soloTricksZone == nil do Wait(1500) end

    Citizen.CreateThread(function()
        while true do 
            local time = 1000 
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(vector2(playerCoords.x, playerCoords.y) - vector2(soloTricksZone.pos.x, soloTricksZone.pos.y))

            if distance <= soloTricksZone.radius then 
                if not InSoloTricksZone then 
                    InSoloTricksZone = true
                end
            else
                if InSoloTricksZone then 
                    InSoloTricksZone = false
                end
            end
            Wait(time)
        end
    end)
end)

local coldown = false
local letimeenseconde = 5
RegisterCommand("solotricks", function(source, args)
    if not InSoloTricksZone or not GM.Player.InFFA then return end 
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return end

    if GetEntityModel(veh) ~= GetHashKey("deluxo") then return end
    if GetCooldownProgress('solotricks') > 0 then ShowAboveRadarMessage("~r~Please wait "..GetCooldownProgress('solotricks').." seconds before using this command again.") return end

    if soloTricksZone.highdetect then 
        local found, floorZ = GetGroundZFor_3dCoord_2(GetEntityCoords(veh).x, GetEntityCoords(veh).y, GetEntityCoords(veh).z, 0, 0)
        if found and (GetEntityCoords(ped).z - floorZ) <= 300.0 then
            ShowAboveRadarMessage("~r~You can't tricks at this height.")
            return
        end
    end

    AddCooldown('solotricks', letimeenseconde)
    local vel = GetEntityVelocity(veh)
    SetEntityCoords(ped, GetEntityCoords(veh) .x, GetEntityCoords(veh).y, GetEntityCoords(veh).z)
    SetEntityVelocity(veh, vel)
    SetEntityVelocity(ped, vel)
end)
-- RegisterKeyMapping("solotricks", "Solo Tricks Deluxo", "keyboard", "B")

local function DisableVehicleWeapons(playerVeh)
    local model = GetEntityModel(playerVeh)
    
    if model == GetHashKey("oppressor") then
        DisableVehicleWeapon(true, GetHashKey("VEHICLE_WEAPON_OPPRESSOR_MG"), playerVeh, PlayerPedId())
        DisableVehicleWeapon(true, GetHashKey("VEHICLE_WEAPON_OPPRESSOR_MISSILE"), playerVeh, PlayerPedId())
    elseif model == GetHashKey("oppressor2") then
        DisableVehicleWeapon(true, GetHashKey("VEHICLE_WEAPON_OPPRESSOR2_MG"), playerVeh, PlayerPedId())
        DisableVehicleWeapon(true, GetHashKey("VEHICLE_WEAPON_OPPRESSOR2_MISSILE"), playerVeh, PlayerPedId())
    elseif model == GetHashKey("revolter") then 
        DisableVehicleWeapon(true, GetHashKey("VEHICLE_WEAPON_REVOLTER_MG"), playerVeh, PlayerPedId())
    elseif model == GetHashKey("deluxo") then
        DisableVehicleWeapon(true, GetHashKey("VEHICLE_WEAPON_DELUXO_MG"), playerVeh, PlayerPedId())
        DisableVehicleWeapon(true, GetHashKey("VEHICLE_WEAPON_DELUXO_MISSILE"), playerVeh, PlayerPedId())
    end
end

AddEventHandler('gameEventTriggered', function(name, args)
    if name == "CEventNetworkPlayerEnteredVehicle" then
        local player = args[1]
        local vehicle = args[2]
        
        if player == PlayerId() and vehicle ~= 0 then
            DisableVehicleWeapons(vehicle)
        end
    end
end)

local lastVehicle = 0
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        local playerVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        
        if playerVeh and playerVeh ~= 0 and playerVeh ~= lastVehicle then
            lastVehicle = playerVeh
            DisableVehicleWeapons(playerVeh)
        elseif not playerVeh then
            lastVehicle = 0
        end
    end
end)



-- RegisterCommand("car", function(source, args)
--     local model = args[1]
--     local playerPed = PlayerPedId()
--     local coords = GetEntityCoords(playerPed)
--     local heading = GetEntityHeading(playerPed)
--     local vehicle = GetHashKey(model)
--     RequestModel(vehicle)
--     while not HasModelLoaded(vehicle) do
--         Citizen.Wait(0)
--     end
--     local veh = CreateVehicle(vehicle, coords.x, coords.y, coords.z, heading, true, false)
--     SetVehicleOnGroundProperly(veh)
--     SetEntityAsMissionEntity(veh, true, true)

--     SetVehicleHasBeenOwnedByPlayer(veh, true)
--     TaskWarpPedIntoVehicle(playerPed, veh, -1)

-- end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsTryingToEnter(playerPed)
            if vehicle ~= 0 then
                local seat = GetSeatPedIsTryingToEnter(playerPed)
                local occupant = GetPedInVehicleSeat(vehicle, seat)

                if occupant ~= 0 then
                    ClearPedTasks(playerPed)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()

end)

-- Système de transparence des véhicules lors de la visée
local currentTransparentVehicles = {}
local isAiming = false
local lastCheckedVehicle = nil

-- Fonction pour vérifier si un véhicule est vide (aucun joueur dedans)
local function isVehicleEmpty(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    
    for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        local ped = GetPedInVehicleSeat(vehicle, i)
        if ped and ped ~= 0 and IsPedAPlayer(ped) then
            return false
        end
    end
    return true
end

-- Fonction pour vérifier s'il y a des joueurs autour du véhicule
local function hasPlayersNearVehicle(vehicle, radius)
    if not DoesEntityExist(vehicle) then return false end
    
    local vehicleCoords = GetEntityCoords(vehicle)
    local players = GetActivePlayers()
    
    -- POUR TEST : Inclure le joueur qui vise s'il est à pied
    local myPlayerId = PlayerId()
    local myPed = PlayerPedId()
    if not IsPedInAnyVehicle(myPed, false) then
        local myCoords = GetEntityCoords(myPed)
        local distance = #(vehicleCoords - myCoords)
        if distance <= radius then
            return true -- Le joueur qui vise compte pour le test
        end
    end
    
    for _, playerId in ipairs(players) do
        if playerId ~= myPlayerId then -- Autres joueurs
            local targetPed = GetPlayerPed(playerId)
            if DoesEntityExist(targetPed) and not IsPedInAnyVehicle(targetPed, false) then
                local playerCoords = GetEntityCoords(targetPed)
                local distance = #(vehicleCoords - playerCoords)
                
                if distance <= radius then
                    return true
                end
            end
        end
    end
    return false
end

-- Fonction pour rendre un véhicule transparent
local function makeVehicleTransparent(vehicle)
    if not currentTransparentVehicles[vehicle] then
        currentTransparentVehicles[vehicle] = {
            originalAlpha = GetEntityAlpha(vehicle),
            originalCollision = true
        }
        
        -- Rendre transparent (150 = semi-transparent)
        SetEntityAlpha(vehicle, 150, false)
        
        -- Désactiver les collisions
        SetEntityCollision(vehicle, false, false)
        
        -- Désactiver les collisions spécifiquement pour le joueur qui vise
        local playerPed = PlayerPedId()
        SetEntityNoCollisionEntity(vehicle, playerPed, true)
        
        -- Désactiver les collisions avec les projectiles (bullet proof)
        SetEntityProofs(vehicle, false, false, false, false, false, false, false, false)
        
        -- Rendre l'entité "fantôme" pour les balles
        SetEntityCanBeDamaged(vehicle, false)
        
        -- Optionnel : effet visuel supplémentaire
        SetEntityRenderScorched(vehicle, true)
    end
end

-- Fonction pour restaurer un véhicule à son état normal
local function restoreVehicle(vehicle)
    if currentTransparentVehicles[vehicle] then
        local data = currentTransparentVehicles[vehicle]
        
        -- Restaurer l'alpha original
        ResetEntityAlpha(vehicle)
        
        -- Réactiver les collisions
        SetEntityCollision(vehicle, true, true)
        
        -- Réactiver les collisions avec le joueur
        local playerPed = PlayerPedId()
        SetEntityNoCollisionEntity(vehicle, playerPed, false)
        
        -- Restaurer les propriétés de résistance (désactiver bullet proof)
        SetEntityProofs(vehicle, false, false, false, false, false, false, false, false)
        
        -- Réactiver les dégâts
        SetEntityCanBeDamaged(vehicle, true)
        
        -- Restaurer l'effet visuel
        SetEntityRenderScorched(vehicle, false)
        
        -- Supprimer de la liste
        currentTransparentVehicles[vehicle] = nil
    end
end

-- Fonction pour restaurer tous les véhicules
local function restoreAllVehicles()
    for vehicle, _ in pairs(currentTransparentVehicles) do
        restoreVehicle(vehicle)
    end
end

-- Thread principal du système de transparence
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local currentlyAiming = IsPlayerFreeAiming(PlayerId())
        
        if currentlyAiming then
            isAiming = true
            local hit, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
            
            if hit and DoesEntityExist(entity) and IsEntityAVehicle(entity) then
                -- Nouveau véhicule visé ou même véhicule
                if entity ~= lastCheckedVehicle then
                    -- Restaurer l'ancien véhicule s'il y en avait un
                    if lastCheckedVehicle and DoesEntityExist(lastCheckedVehicle) then
                        restoreVehicle(lastCheckedVehicle)
                    end
                    
                    lastCheckedVehicle = entity
                    
                    -- Vérifier les conditions pour le nouveau véhicule
                    if isVehicleEmpty(entity) and hasPlayersNearVehicle(entity, 10.0) then
                        makeVehicleTransparent(entity)
                    end
                end
            else
                -- Pas de véhicule visé, restaurer le dernier
                if lastCheckedVehicle and DoesEntityExist(lastCheckedVehicle) then
                    restoreVehicle(lastCheckedVehicle)
                    lastCheckedVehicle = nil
                end
            end
            
            Wait(100) -- Check fréquent quand on vise
        else
            -- Plus en train de viser
            if isAiming then
                isAiming = false
                restoreAllVehicles()
                lastCheckedVehicle = nil
            end
            
            Wait(500) -- Check moins fréquent quand on ne vise pas
        end
    end
end)

-- Nettoyage quand le joueur quitte ou change de dimension
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        restoreAllVehicles()
    end
end)

-- Nettoyage périodique des véhicules qui n'existent plus
Citizen.CreateThread(function()
    while true do
        Wait(5000) -- Check toutes les 5 secondes
        
        for vehicle, _ in pairs(currentTransparentVehicles) do
            if not DoesEntityExist(vehicle) then
                currentTransparentVehicles[vehicle] = nil
            end
        end
    end
end)




RegisterCommand("getcoords", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local msg = string.format("~y~Coords: ~s~vector4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, heading)
    ShowAboveRadarMessage(msg)
    print(string.format("vector4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, heading))
    -- Copie automatique dans le presse-papiers
    if SetClipboard then
        SetClipboard(string.format("vector4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, heading))
        ShowAboveRadarMessage("~g~Coordonnées copiées dans le presse-papiers !")
    else
        -- Si SetClipboard n'est pas disponible, affiche juste le message
        ShowAboveRadarMessage("~r~Impossible de copier automatiquement, SetClipboard non disponible.")
    end
end, false)
