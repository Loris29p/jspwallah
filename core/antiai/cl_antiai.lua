function TriggerCallback(name, ...)
    local id = GetRandomIntInRange(0, 999999)
    local eventName = "gfx-antiMagicandAntiAccuracy:triggerCallback:" .. id
    local eventHandler
    local promise = promise:new()
    RegisterNetEvent(eventName)
    local eventHandler = AddEventHandler(eventName, function(...)
        promise:resolve(...)
    end)   
    SetTimeout(15000, function()
        promise:resolve("timeout")
        RemoveEventHandler(eventHandler)
    end)
    local args = {...}
    TriggerServerEvent(name, id, args)   
    local result = Citizen.Await(promise)
    RemoveEventHandler(eventHandler)
    return result
end

local testActive = false
local adminCommand = false
local testPed
local playerOldCoords
local cam
local testVehicle
local prop
local recoilped

function openNui()
    SendNUIMessage({
        type = "magicTestStart",
    })
    SetNuiFocus(true, true)
end

function closeNui()
    SendNUIMessage({
        type = "magicTestEnd",
    })
    SetNuiFocus(false, false)
end



RegisterNetEvent(ConfigAI.PlayerLoadedEvent)
AddEventHandler(ConfigAI.PlayerLoadedEvent, function ()
    Wait(3000)
    if not ConfigAI.PlayerCheck then
        return
    end
    local isBypass = TriggerCallback("gfx-antiMagicandAntiAccuracy:isBypass")

    if isBypass then
        return
    end
    -- TriggerServerEvent("gfx-anticheat:server:changebucket")
    -- openNui()
    -- startStageOne(PlayerPedId())
end)

-- Silahı sıfırlama ve mermi doldurma fonksiyonu
function resetWeapon(playerPed, weapon) -- for magic test ('WEAPON_COMPACTRIFLE') for ped accuracy test ('WEAPON_SMG')
    local weaponHash = GetHashKey(weapon)--('WEAPON_COMPACTRIFLE')
    --RemoveAllPedWeapons(playerPed, true)
    local _, currentweapon
    while currentweapon ~= GetHashKey(weapon) do
        GiveWeaponToPed(PlayerPedId(), GetHashKey(weapon), 50, false, true)
        _, currentweapon = GetCurrentPedWeapon(PlayerPedId())
        Wait(100)
    end

    SetPedAmmo(playerPed, weaponHash, 50)
    SetAmmoInClip(playerPed, weaponHash, 10)
    RefillAmmoInstantly(playerPed)
end

-- Ped, araç ve prop oluşturma fonksiyonu
function createEntity(modelHash, x, y, z, heading, isPed, insideVehicle)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(1)
    end
    local entity
    if isPed then
        if insideVehicle then
            entity = CreatePedInsideVehicle(insideVehicle, 4, modelHash, -1, true, true)
        else
            entity = CreatePed(0, modelHash, x, y, z, heading, false, true)
        end
        TaskSetBlockingOfNonTemporaryEvents(entity, true)
        SetPedFleeAttributes(entity, 0, 0)
        SetPedCombatAttributes(entity, 46, true)
        FreezeEntityPosition(entity, true) -- Ped'i sabitle
    else
        entity = CreateVehicle(modelHash, x, y, z, heading, false, true)
    end
    return entity
end

function createProp(modelHash, x, y, z, heading)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(1)
    end
    local prop = CreateObject(modelHash, x, y, z, false, false, true)
    SetEntityHeading(prop, heading)
    FreezeEntityPosition(prop, true) -- Prop'u sabitle
    return prop
end

-- wall magic test
function startStageOne(targetPlayerPed)
    local pedcoord = vector3(-1266.9507, -3013.0781, -49.4902)
    local pedheading = 6.5421
    local propCoord = vector3(-1266.9507, -3010.0781, -49.4902)
    local propHeading = 90.0
    playerOldCoords = GetEntityCoords(targetPlayerPed)
    if #(vector3(playerOldCoords.x, playerOldCoords.y, playerOldCoords.z) - vector3(-1267.3702, -3003.5459, -49.4900)) < 50.0 then
        playerOldCoords = ConfigAI.DefaultSpawnLocation
    end
    SetEntityCoords(targetPlayerPed, -1267.3702, -3003.5459, -49.4900)
    SetEntityHeading(targetPlayerPed, 182.1322)
    FreezeEntityPosition(targetPlayerPed, true)

    Citizen.Wait(100) -- Işınlandıktan sonra bekleme süresi
    resetWeapon(targetPlayerPed, "weapon_magic") -- Silahı sıfırla ve mermi doldur

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    SetCamCoord(cam, -1267.3702, -3003.5459, -47.4900)
    PointCamAtCoord(cam, -1266.9507, -3013.0781, -49.4902)

    testPed = createEntity(GetHashKey("a_f_m_beach_01"), pedcoord.x, pedcoord.y, pedcoord.z, pedheading, true)
    prop = createProp(GetHashKey("prop_ld_container"), propCoord.x, propCoord.y, propCoord.z, propHeading)

    Citizen.Wait(500)
    TaskAimGunAtEntity(targetPlayerPed, testPed, 3000, true)
    Citizen.Wait(1000)
    TaskShootAtEntity(targetPlayerPed, testPed, 2000, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
    Citizen.Wait(2000)

    if DoesEntityExist(testPed) and IsPedDeadOrDying(testPed, true) then
        TriggerServerEvent("gfx-anticheat:server:discordLog", "magic", true)
        if not adminCommand then
            if ConfigAI.banActive then
                TriggerServerEvent("gfx-anticheat:server:banPlayer", ConfigAI.LogMessages["magicBanMsg"])
            elseif ConfigAI.kickActive then
                TriggerServerEvent("gfx-anticheat:server:kickPlayer", ConfigAI.LogMessages["magicKickMsg"])
            end
        end
       

        DeletePed(testPed)
        Citizen.Wait(500)
    else
        TriggerServerEvent("gfx-anticheat:server:discordLog", "magic", false)
    end

    if DoesEntityExist(testPed) then
        DeletePed(testPed)
    end
    if DoesEntityExist(prop) then
        DeleteObject(prop)
    end

    startStageTwo(targetPlayerPed)
end

-- İkinci aşama test fonksiyonu
function startStageTwo(targetPlayerPed)
    local pedcoord = vector3(-1266.9507, -3013.0781, -49.9902)
    local pedheading = 6.5421

    Citizen.Wait(100)
    resetWeapon(targetPlayerPed, "weapon_magic")

    testPed = createEntity(GetHashKey("a_f_m_beach_01"), pedcoord.x, pedcoord.y, pedcoord.z, pedheading, true)
    testVehicle = createEntity(GetHashKey("dukes2"), -1266.9507, -3010.0781, -49.4902, 90.0, false)
    Citizen.Wait(500)

    --SetCamCoord(cam, -1267.3702, -3003.5459, -47.4900)
    --PointCamAtCoord(cam, -1266.9507, -3013.0781, -50.0)

    TaskTurnPedToFaceEntity(targetPlayerPed, testPed, -1)
    Citizen.Wait(1000)
    TaskAimGunAtEntity(targetPlayerPed, testPed, 3000, true)
    Citizen.Wait(1000)
    TaskShootAtEntity(targetPlayerPed, testPed, 2000, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
    Citizen.Wait(2000)

    if DoesEntityExist(testPed) and IsPedDeadOrDying(testPed, true) then
        TriggerServerEvent("gfx-anticheat:server:discordLog", "magic", true)
        if not adminCommand then
            if ConfigAI.banActive then
                TriggerServerEvent("gfx-anticheat:server:banPlayer", ConfigAI.LogMessages["magicBanMsg"])
            elseif ConfigAI.kickActive then
                TriggerServerEvent("gfx-anticheat:server:kickPlayer", ConfigAI.LogMessages["magicKickMsg"])
            end
        end
        
    else
        TriggerServerEvent("gfx-anticheat:server:discordLog", "magic", false)
    end
    
    DeletePed(testPed)
    DeleteVehicle(testVehicle)
    --endTest(targetPlayerPed)
    startStageThree(targetPlayerPed)
end

-- RegisterCommand("recoil", function (source)
--     startStageThree(PlayerPedId())
-- end)

function startStageThree(targetPlayerPed)
    testActive = true
    local pedcoord = vector3(-1266.9507, -3013.0781, -50.4902)
    local pedheading = 6.5421

    --playerOldCoords = GetEntityCoords(targetPlayerPed)
    SetEntityCoords(targetPlayerPed, -1267.3702, -3003.5459, -49.4900)
    SetEntityHeading(targetPlayerPed, 182.1322)
    FreezeEntityPosition(targetPlayerPed, true)

    SetNuiFocus(true, true)

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    SetCamCoord(cam, -1267.3702, -3003.5459, -47.4900)
    PointCamAtCoord(cam, -1266.9507, -3013.0781, -49.4902)

    Citizen.Wait(100)
    -- RemoveAllPedWeapons(targetPlayerPed, true)
    -- GiveWeaponToPed(targetPlayerPed, GetHashKey('WEAPON_SMG'), 150, false, true)
    -- RefillAmmoInstantly(playerPed)
    resetWeapon(targetPlayerPed, "weapon_norecoil")

    recoilped = createEntity(GetHashKey("a_f_m_beach_01"), pedcoord.x, pedcoord.y, pedcoord.z - 0.0, pedheading, true)
    SetPedArmour(recoilped, 100)
    --SetPedAccuracy(PlayerPedId(), 1)
    Citizen.Wait(500)

    -- SetCamCoord(GetRenderingCam(), pedcoord.x, pedcoord.y, pedcoord.z - 0.0)
    -- PointCamAtCoord(GetRenderingCam(),pedcoord.x, pedcoord.y, pedcoord.z - 0.0)

    TaskTurnPedToFaceEntity(targetPlayerPed, recoilped, -1)
    Citizen.CreateThread(function ()
        while DoesEntityExist(recoilped) do
            SetPedSuffersCriticalHits(recoilped, false)
            Citizen.Wait(0)
        end
    end)

    Citizen.Wait(1000)
    TaskAimGunAtEntity(targetPlayerPed, recoilped, 3000, true)
    Citizen.Wait(1000)
    TaskShootAtEntity(targetPlayerPed, recoilped, 5000, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
    Citizen.Wait(6000)

    --print(GetEntityHealth(recoilped), GetEntityMaxHealth(recoilped), GetPedArmour(recoilped))
    if DoesEntityExist(recoilped) and (GetEntityHealth(recoilped) < 100 or IsPedDeadOrDying(recoilped, true)) then
        --print("Recoil Detected")
        TriggerServerEvent("gfx-anticheat:server:discordLog", "accuracy", true)
        if not adminCommand then
            if ConfigAI.banActive then
                TriggerServerEvent("gfx-anticheat:server:banPlayer", ConfigAI.LogMessages["accuracyBanMsg"])
            elseif ConfigAI.kickActive then
                TriggerServerEvent("gfx-anticheat:server:kickPlayer", ConfigAI.LogMessages["accuracyKickMsg"])
            end
        end
    else
        TriggerServerEvent("gfx-anticheat:server:discordLog", "accuracy", false)
    end

    DeletePed(recoilped)
    recoilped = nil

    endTest(targetPlayerPed)
end

-- Testi bitirme fonksiyonu
function endTest(targetPlayerPed)
    if DoesEntityExist(testPed) then
        DeletePed(testPed)
    end
    if DoesEntityExist(testVehicle) then
        DeleteVehicle(testVehicle)
    end
    if DoesEntityExist(prop) then
        DeleteObject(prop)
    end
    if DoesEntityExist(recoilped) then
        DeletePed(recoilped)
    end
    RemoveAllPedWeapons(targetPlayerPed, true)
    --SetCurrentPedWeapon(targetPlayerPed, GetHashKey('WEAPON_UNARMED'), true)
    SetNuiFocus(false, false)
    SetEntityCoords(targetPlayerPed, playerOldCoords)
    FreezeEntityPosition(targetPlayerPed, false)
    Citizen.Wait(1000)
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, false)
    testActive = false
    closeNui()
    TriggerServerEvent("gfx-anticheat:server:DefaultBucket")
    if adminCommand then adminCommand = false end
    if GM.Player.InSafeZone then
        print("in safezone")
        Tse("safezone:action", "join")
    end
end

function disableControls()
    while testActive do
        Citizen.Wait(0)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 47, true)
        DisableControlAction(0, 58, true)
        DisablePlayerFiring(PlayerPedId(), true)
    end
end

RegisterNetEvent("gfx-antiMagicandAntiAccuracy:TestStart")
AddEventHandler("gfx-antiMagicandAntiAccuracy:TestStart", function(isadmin)
    if not testActive then
        if isadmin then
            adminCommand = true
        end
        openNui()
        startStageOne(PlayerPedId())
    end
end)