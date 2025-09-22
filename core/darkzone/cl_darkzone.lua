
heli = nil
pilot = nil
BlipDarkzoneRadius = nil 
BlipDarkZone = nil
DarkzonePlayers = nil 

_RegisterNetEvent("darkzone:update", function(tblData)
    DarkzonePlayers = tblData
end)

GM.Player.InDarkzone = false

DarkzoneData = {
    Extraction = {},
    ExtractionPeds = {}
}

function para()
    local ped = PlayerPedId()
    GiveWeaponToPed(ped, GetHashKey("GADGET_PARACHUTE"), 1, false, true)
	SetPedParachuteTintIndex(ped, math.random(0,7))
	
	SetPlayerHasReserveParachute(PlayerId())
	SetPedReserveParachuteTintIndex(math.random(0,7))
	
	SetPlayerCanLeaveParachuteSmokeTrail(PlayerId(), true)
	
	local color = {}
	color.r = math.random(0,255)
	color.g = math.random(0,255)
	color.b = math.random(0,255)
	
	SetPlayerParachuteSmokeTrailColor(PlayerId(),color.r,color.g,color.b)
end

function StartPtfx(entity)
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Citizen.Wait(1)
        end
    end
    SetPtfxAssetNextCall("core")
    local smoke = StartParticleFxLoopedOnEntity("exp_grd_flare", entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75, false, false, false, false)
    SetEntityVelocity(crate, 0.0, 0.0, -0.2)
    SetParticleFxLoopedAlpha(smoke, 0.8)
    SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
    FreezeEntityPosition(box, true)
    Citizen.CreateThread(function()
        Citizen.Wait(60000*4)
        StopParticleFxLooped(smoke, 0)
    end)
end

function DarkzoneInit()
    GM.Player.InDarkzone = true
    BoostZombies(true)
    Tse("darkzone:instance", "join")
    para()
    SetZombieCanSpawn(true)
    local darkzoneCenter = vector4(5154.041, -5046.09, 4.381957, 341.0933)
    BlipDarkzoneRadius = AddBlipForRadius(darkzoneCenter.x, darkzoneCenter.y, darkzoneCenter.z, 2000.0)
    SetBlipColour(BlipDarkzoneRadius, 50)
    SetBlipAlpha(BlipDarkzoneRadius, 128)
    SpawnExtract(DarkzoneConfig.extractPoints)
    SetDisableInventoryMoveState(false)
    SendNUIMessage({
        type = "cc",
        movestatus = true
    })

    Citizen.CreateThread(function()
        while GM.Player.InDarkzone  do 
            Citizen.Wait(15000)
            ShowAboveRadarMessage("~o~If you disconnect in DarkZone \n~s~You will lose all your items.")
        end
    end)
end

local function GetLineCountAndMaxLenght(text)
    local count = 0
    local maxLenght = 0
    for line in text:gmatch("([^\n]*)\n?") do
        count = count + 1
        local lenght = string.len(line)
        if lenght > maxLenght then maxLenght = lenght end
    end
    return count, maxLenght
end

local function DrawText3D(data)
    SetTextScale(0.50, 0.50)
    SetTextFont(2)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextDropShadow()
    local totalLenght = string.len(data.text)
    local textMaxLenght = data.textMaxLenght or 99 -- max 99
    local text = totalLenght > textMaxLenght and data.text:sub(1, totalLenght - (totalLenght - textMaxLenght)) or data.text
    AddTextComponentString(text)
    SetDrawOrigin(data.coords.x, data.coords.y, data.coords.z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end


function SpawnExtract(tblConfig)
    for k, v in pairs(tblConfig) do 
        RequestModel("buzzard2")
        while not HasModelLoaded("buzzard2") do 
            Citizen.Wait(100)
        end 
        DarkzoneData.Extraction[k] = CreateVehicle(GetHashKey("buzzard2"), v.heliSpawn.x, v.heliSpawn.y, v.heliSpawn.z - 1.0, 0.0, false, true)
        SetEntityAsMissionEntity(DarkzoneData.Extraction[k], true, true)
        SetModelAsNoLongerNeeded("buzzard2")
        SetEntityInvincible(DarkzoneData.Extraction[k], true)
        SetEntityDynamic(DarkzoneData.Extraction[k], true)
        SetVehicleDoorsLocked(DarkzoneData.Extraction[k], 2)
        SetEntityProofs(DarkzoneData.Extraction[k], true, true, true, true, true, true, true, true)
        ActivatePhysics(DarkzoneData.Extraction[k])
        SetVehicleEngineOn(DarkzoneData.Extraction[k], true, true, true)
        SetHeliBladesFullSpeed(DarkzoneData.Extraction[k])
        SetEntityLodDist(DarkzoneData.Extraction[k], 2000)
        SetVehicleIsConsideredByPlayer(DarkzoneData.Extraction[k], false)
        FreezeEntityPosition(DarkzoneData.Extraction[k], true)
        SetVehicleJetEngineOn(DarkzoneData.Extraction[k], true)
        local blip = AddBlipForEntity(DarkzoneData.Extraction[k])
        SetBlipSprite(blip, v.blip)
        SetBlipColour(blip, v.color)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        StartPtfx(DarkzoneData.Extraction[k])
        RequestModel("a_m_m_tranvest_02")
        while not HasModelLoaded("a_m_m_tranvest_02") do 
            Citizen.Wait(100)
        end 
        DarkzoneData.ExtractionPeds[k] = CreatePed(4, "a_m_m_tranvest_02", v.heliSpawn.x, v.heliSpawn.y,  v.heliSpawn.z, 0.0, false, true)
        if not DoesEntityExist(DarkzoneData.ExtractionPeds[k]) then  
            print("Failed to create buzzard extraction")
        end
        SetEntityAsMissionEntity(DarkzoneData.ExtractionPeds[k], true, true)
        SetModelAsNoLongerNeeded("a_m_m_tranvest_02")
        SetEntityAsMissionEntity(DarkzoneData.ExtractionPeds[k], true, true)
        SetBlockingOfNonTemporaryEvents(DarkzoneData.ExtractionPeds[k], true)
        TaskSetBlockingOfNonTemporaryEvents(DarkzoneData.ExtractionPeds[k], true)
        SetEntityLodDist(DarkzoneData.ExtractionPeds[k], 2000)
        SetPedRandomComponentVariation(DarkzoneData.ExtractionPeds[k], false)
        SetPedKeepTask(DarkzoneData.ExtractionPeds[k], true)
        SetDriverAbility(DarkzoneData.ExtractionPeds[k], 0.5)
        SetPedConfigFlag(DarkzoneData.ExtractionPeds[k], 116, true)
        SetPedConfigFlag(DarkzoneData.ExtractionPeds[k], 118, true)
        SetPedIntoVehicle(DarkzoneData.ExtractionPeds[k], DarkzoneData.Extraction[k], -1)
        SetEntityInvincible(DarkzoneData.ExtractionPeds[k], true)

        SetBlockingOfNonTemporaryEvents(DarkzoneData.ExtractionPeds[k], true) -- ignore explosions and other shocking events
        SetPedRandomComponentVariation(DarkzoneData.ExtractionPeds[k], false)

        Citizen.CreateThread(function()
            while true do 
                local time = 2000 
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local heliCoords = GetEntityCoords(DarkzoneData.Extraction[k])
                local distance = #(playerCoords - heliCoords)
                if distance <= 10.0 then
                    time = 0
                    DrawText3D({
                        text = "Press ~b~E~w~ to extract",
                        coords = vector3(heliCoords.x, heliCoords.y, heliCoords.z + 1.0),
                    })
                    if distance <= 3.0 then 
                        if IsControlJustReleased(0, 38) then 
                            print("Extracting")
                            TaskWarpPedIntoVehicle(PlayerPedId(), DarkzoneData.Extraction[k], 2)
                            Wait(2000)
                            FreezeEntityPosition(DarkzoneData.Extraction[k], false)
                            TaskVehicleDriveToCoord(DarkzoneData.ExtractionPeds[k], DarkzoneData.Extraction[k], vector3(5525.646, -4794.581, 199.402) + vector3(0.0, 0.0, 500.0), 30.0, 8.0, 'buzzard2', 262144, 20.0) -- to the dropsite, could be 
                            Wait(10000)
                            TeleportPlayerCoords(vector3(235.7291, -1394.518, 30.51498), PlayerPedId(), true)
                            ShowAboveRadarMessage("~r~You have been extracted")
                            PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
                            DeleteEntity(DarkzoneData.Extraction[k])
                            DeleteEntity(DarkzoneData.ExtractionPeds[k])
                            DarkzoneData.Extraction[k] = nil
                            DarkzoneData.ExtractionPeds[k] = nil
                            DestroyExtract()
                        end
                    end
                end
                Wait(time)
            end
        end)
    end
end


function DestroyExtract()
    print("Destroy Extract")
    if DoesBlipExist(BlipDarkzoneRadius) then 
        RemoveBlip(BlipDarkzoneRadius)
    end
    for k, v in pairs(DarkzoneData.Extraction) do 
        DeleteEntity(v)
    end
    for k, v in pairs(DarkzoneData.ExtractionPeds) do 
        DeleteEntity(v)
    end
    SetZombieCanSpawn(false)
    SetDisableInventoryMoveState(false)
    SendNUIMessage({
        type = "cc",
        movestatus = false
    })
    Tse("darkzone:instance", "leave")
    BoostZombies(false)
    GM.Player.InDarkzone = false
end

function CreateHeliSpawn()
    local heliSpawn = DarkzoneConfig.helicopterSpawn[1]
    RequestModel("buzzard2")
    while not HasModelLoaded("buzzard2") do 
        Citizen.Wait(100)
    end 
    TeleportPlayerCoords(vector3(heliSpawn.startCoords.x, heliSpawn.startCoords.y, heliSpawn.startCoords.z), PlayerPedId(), true)
    heli = CreateVehicle(GetHashKey("buzzard2"), heliSpawn.startCoords.x, heliSpawn.startCoords.y, heliSpawn.startCoords.z, 0.0, true, true)
    SetEntityAsMissionEntity(heli, true, true)
    SetModelAsNoLongerNeeded("buzzard2")
    SetEntityInvincible(heli, true)
    SetEntityDynamic(heli, true)
    SetVehicleDoorsLocked(heli, 2)
    SetEntityProofs(heli, true, true, true, true, true, true, true, true)
    ActivatePhysics(heli)
    SetVehicleForwardSpeed(heli, 120.0)
    SetVehicleEngineOn(heli, true, true, true)
    SetHeliBladesFullSpeed(heli)
    SetEntityLodDist(heli, 2000)
    SetVehicleIsConsideredByPlayer(heli, false)
	SetVehicleCanBeVisiblyDamaged(heli, false)
	SetVehicleEngineCanDegrade(heli, false)
	SetEntitySomething(heli, false)
	SetVehicleJetEngineOn(heli, true)
	SetTaskVehicleGotoPlaneMinHeightAboveTerrain(heli, 1.0)
    
    TaskWarpPedIntoVehicle(PlayerPedId(), heli, 2)
    -- Create fake Ped Driver 
    RequestModel("a_m_m_tranvest_02")
    while not HasModelLoaded("a_m_m_tranvest_02") do 
        Citizen.Wait(100)
    end 
    pilot = CreatePed(4, "a_m_m_tranvest_02", heliSpawn.startCoords.x, heliSpawn.startCoords.y,  heliSpawn.startCoords.z, 0.0, false, true)
    SetEntityAsMissionEntity(pilot, true, true)
    SetModelAsNoLongerNeeded("a_m_m_tranvest_02")
    SetEntityAsMissionEntity(pilot, true, true)
	SetBlockingOfNonTemporaryEvents(pilot, true)
	TaskSetBlockingOfNonTemporaryEvents(pilot, true)
    SetEntityLodDist(pilot, 2000)
    SetPedRandomComponentVariation(pilot, false)
    SetPedKeepTask(pilot, true)
	SetDriverAbility(pilot, 0.5)
	SetPedConfigFlag(pilot, 116, true)
	SetPedConfigFlag(pilot, 118, true)
	SetPedIntoVehicle(pilot, heli, -1)

    SetBlockingOfNonTemporaryEvents(pilot, true) -- ignore explosions and other shocking events
    SetPedRandomComponentVariation(pilot, false)
    TaskVehicleDriveToCoord(pilot, heli, vector3(heliSpawn.endCoords.x, heliSpawn.endCoords.y,heliSpawn.endCoords.z) + vector3(0.0, 0.0, 500.0), 30.0, 8.0, 'buzzard2', 262144, 20.0) -- to the dropsite, could be 
    InHeli = true
    -- Hélicoptère ne se supprime plus automatiquement quand le joueur sort
    -- Citizen.CreateThread(function()
    --     while InHeli do 
    --         Citizen.Wait(500)
    --         if not IsPedInVehicle(PlayerPedId(), heli, false) then 
    --             DeleteEntity(heli)
    --             DeleteEntity(pilot)
    --             InHeli = false
    --         end
    --     end
    -- end)
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then 
        DeleteEntity(heli)
        DeleteEntity(pilot)
        DestroyExtract()
    end
end)

Citizen.CreateThread(function()
    while not WrapperPedInit do 
        Citizen.Wait(100)
    end
    -- Darkzone Hospital
    local NPC_Darkzone = {
        safezone = "Hospital",
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        pos = vector4(238.3296, -1400.461, 30.57711, 49.76275),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    -- CreatePedAction(NPC_Darkzone)
    RegisterSafeZonePedAction(NPC_Darkzone)

    -- Darkzone Marabunta SafeZone
    local NPC_Darkzone = {
        safezone = "Marabunta",
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        pos = vector4(1142.747, -1495.306, 34.6926, 184.8052),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    -- CreatePedAction(NPC_Darkzone)
    RegisterSafeZonePedAction(NPC_Darkzone)

     -- Darkzone  Beach  SafeZone
     local NPC_Darkzone = {
        safezone = "Beach Safezone",
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        pos = vector4(-1083.323, -1661.934, 4.450292, 220.694),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    -- CreatePedAction(NPC_Darkzone)
    RegisterSafeZonePedAction(NPC_Darkzone)

     -- Darkzone AA SafeZone
     local NPC_Darkzone = {
        pedType = 4,
        safezone = "Cross Field",
        model = "u_m_y_juggernaut_01",
        pos = vector4(1210.721, 1878.597, 78.32185, 219.1976),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    -- CreatePedAction(NPC_Darkzone)
    RegisterSafeZonePedAction(NPC_Darkzone)

    -- Darkzone Blaine County

    local NPC_Darkzone = {
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        safezone = "Sandy Shores Safezone",
        pos = vector4(2763.893, 3454.833, 55.78238, 69.68078),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    -- CreatePedAction(NPC_Darkzone)
    RegisterSafeZonePedAction(NPC_Darkzone)

    -- Darkzone Paleto

    local NPC_Darkzone = {
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        safezone = "Hideout", 
        pos = vector4(1466.802, 6362.855, 23.80778, 245.6518),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    -- CreatePedAction(NPC_Darkzone)
    RegisterSafeZonePedAction(NPC_Darkzone)

    -- Darkzone Paleto
    local NPC_Darkzone = {
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        safezone = "Paleto",
        pos = vector4(-961.1006, 6188.512, 3.500323, 38.58202),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    -- CreatePedAction(NPC_Darkzone)
    RegisterSafeZonePedAction(NPC_Darkzone)


    local NPC_Darkzone = {
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        safezone = "Mountain",
        pos = vector4(-417.1306, 1127.795, 325.9048, 171.7346),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Darkzone)

    local NPC_Darkzone = {
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        safezone = "Main SafeZone",
        pos = vector4(-540.8453, -227.7436, 37.61166, 32.47306),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Darkzone)

    local NPC_Darkzone = {
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        safezone = "Mirror Park",
        pos = vector4(1365.763, -573.3719, 74.38037, 247.1587),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Darkzone)

    local NPC_Darkzone = {
        pedType = 4,
        model = "u_m_y_juggernaut_01",
        safezone = "depot",
        pos =  vector4(757.59, -1416.98, 26.51, 1.27),
        weapon = "weapon_minigun",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not GM.Player.InDarkzone and not GM.Player.InFarm then
                    DarkzoneInit()
                    CreateHeliSpawn()
                else
                    ShowAboveRadarMessage("~r~You are already in the darkzone")
                end
            else
                ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the darkzone")
            end
        end,
        drawText = function()
            if DarkzonePlayers and #DarkzonePlayers > 0 then 
                return "[ ~r~DARKZONE ~s~] - ~g~"..#DarkzonePlayers.." players"
            else
                return "[ ~r~DARKZONE ~s~] - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Darkzone)

    
end)