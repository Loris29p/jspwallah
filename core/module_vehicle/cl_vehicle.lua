DecorRegister("vehicleId", 3)
_RegisterNetEvent("vehicle:VehicleUsed", function(model, vehId, custom)
    local myCooldown = GetCooldownProgress("spawn_veh")
    local spawn2veh = GetCooldownProgress("spawn_veh2") 


    if spawn2veh > 0 then
        ShowAboveRadarMessage("~HUD_COLOUR_RED~You must wait "..spawn2veh.." seconds before spawning another vehicle.")
        return
    end

    if myCooldown > 0 then
        ShowAboveRadarMessage("~HUD_COLOUR_RED~You must wait "..myCooldown.." seconds before spawning another vehicle.")
        return
    end


    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 and model ~= "bmx" then
        ShowAboveRadarMessage("~HUD_COLOUR_RED~You must exit your vehicle before spawning another.")
        return
    end


    local coords = GetEntityCoords(PlayerPedId())
    local found, floorZ = GetGroundZFor_3dCoord_2(coords.x, coords.y, coords.z, 0, 0)

    if found and (coords.z - floorZ) >= 5.0 and model == "bmx" then
        ShowAboveRadarMessage("~r~You can't spawn bmx while you are in the air.")
        return
    end


    if IsEntityInAir(PlayerPedId()) and model == "bmx" then
        ShowAboveRadarMessage("~HUD_COLOUR_RED~You can't spawn bmx while you are in the air.")
        return
    end
    
    if veh ~= 0 then 
        local currentModelVehicle = GetEntityModel(veh)
        if currentModelVehicle == GetHashKey(model) and model == "bmx" then
            ShowAboveRadarMessage("~HUD_COLOUR_RED~You can't spawn bmx while you are on bmx.")
            return
        end
    end


    local playerDat = GM.Player:Get()
    if playerDat.dead then 
        ShowAboveRadarMessage("~HUD_COLOUR_RED~You can't spawn a vehicle while you are dead.")
        return
    end
    -- local success = CallbackServer("vehicle:spawn", model, vehId)
    -- if not success then 
    --     ShowAboveRadarMessage("~HUD_COLOUR_RED~You can't spawn this vehicle.")
    --     return
    -- end
    Tse("vehicle:setVehId", vehId, model)
    Wait(20)
    -- Tse("removeVeh", model, vehId)

    AddCooldown("spawn_veh2", 3)
    
    local ped = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(ped))
    local h = GetEntityHeading(ped)
    LoadModel(model)
    local vel = GetEntityVelocity(PlayerPedId()) * 2.5
    ClearPedTasksImmediately(PlayerPedId())
    local vehicle = CreateVehicle(GetHashKey(model), x, y, z, h, true, true)
    SetVehicleNumberPlateText(vehicle, "GUILD PVP")
    if IsPedFalling(PlayerPedId()) then
        local coords = GetEntityCoords(PlayerPedId())
        local worked, groundZ, normal = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z - groundZ)
        ClearPedTasksImmediately(PlayerPedId())
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    end
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetPedIntoVehicle(ped, vehicle, -1)
    if custom then 
        SetVehicleData(vehicle, custom)
    end
    SetVehicleForwardSpeed(vehicle, 20)
    SetEntityVelocity(vehicle, vel)
    SetVehicleOnGroundProperly(vehicle)
    print("Vehicle spawned", vehicle, vehId)
    DecorSetInt(vehicle, "vehicleId", vehId)
    ShowAboveRadarMessage("Spawning ~b~"..model.."\n~s~ID: ~b~"..vehId)
end)


RegisterKeyMapping("examinevehicle", 'Store Vehicle', 'keyboard', "K")
RegisterCommand("examinevehicle", function()
    if GM.Player.InFFA then return end
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return end
    if not IsPedInAnyVehicle(ped, false) then return end
    local vehicleId = DecorGetInt(vehicle, "vehicleId")
    local speed = GetEntitySpeed(vehicle) * 3.6
    local coords = GetEntityCoords(vehicle)

    local found, floorZ = GetGroundZFor_3dCoord_2(GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z, 0, 0)

    if speed >= 50.0 then
        ShowAboveRadarMessage("~r~You can't store a vehicle that is moving this fast!")
        return
    end

    if not IsPedInAnyVehicle(ped, false) then return end
    if vehicleId and GetEntityHealth(PlayerPedId()) ~= 0 then
        AddCooldown("spawn_veh", 5)
        DeleteEntity(vehicle)
        Tse("vehicle:StockVeh", vehicleId, vehicle)
        EffectOnPlayer("scr_sr_adversary", "scr_sr_lg_weapon_highlight")
        
        -- Activer l'effet spawncar pour 5 secondes
        SendNUIMessage({
            type = "spawncar"
        })
        
        TriggerEvent("vehicle:ResetSpawningState")
        
        -- On vérifie l'arme seulement si le joueur n'est pas en train de tomber
        -- if not IsPedFalling(ped) then
        --     Citizen.SetTimeout(100, function()
        --         RemoveWeaponIfDontHave()
        --     end)
        -- end
    end
end)


_RegisterNetEvent("updatedInv", function()
    UpdateInventory("protected")
end)


Citizen.CreateThread(function()
    while true do
        N_0x4757f00bc6323cfe(-1553120962, 0.0) 
        Wait(0)
    end
end)


local vehListWhitelist = {
    "deluxo",
    "oppressor",
    "scarab",
    "nightshark",
    "dukes2",
}

Citizen.CreateThread(function()
    while true do 
        local vehiclePool = GetGamePool('CVehicle')           
        for i = 1, #vehiclePool do
            local vehicle = vehiclePool[i]
            if GetPedInVehicleSeat(vehicle, -1) == 0  and not CheckIfVehicleIsDarkzone(vehicle) then

                local vehicleModel = GetEntityModel(vehicle)
                local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
                local vehicleNameLower = string.lower(vehicleName)
                
                local isWhitelisted = false
                for _, whitelistedVehicle in ipairs(vehListWhitelist) do
                    if string.find(vehicleNameLower, string.lower(whitelistedVehicle)) then
                        isWhitelisted = true
                        break
                    end
                end
                
                if not isWhitelisted then
                    DeleteEntity(vehicle)
                else
                end
            end
        end
        Wait(1000*60*2) -- 2 minutes
    end
end)

-- Optimization Vehicles Load 
Citizen.CreateThread(function()
    while true do 
        local vehiclePool = GetGamePool('CVehicle')
        for i = 1, #vehiclePool do
            local vehicle = vehiclePool[i]
            if GM.Player.InDarkzone then 
                SetEntityLodDist(vehicle, 200)
            elseif GM.Player.InFarm then 
                SetEntityLodDist(vehicle, 200)
            elseif GM.Player.InFFA then 
                SetEntityLodDist(vehicle, 200)
            elseif GM.Player.InSafeZone then 
                SetEntityLodDist(vehicle, 300)
            elseif not GM.Player.InSafeZone then 
                SetEntityLodDist(vehicle, 175)
            end
        end
        Wait(1000*60*2) -- 2 minutes
    end
end)

-- Optimization Players 
-- Citizen.CreateThread(function()
--     while true do 
--         local playerPool = GetGamePool('CPlayer')
--         for i = 1, #playerPool do
--             local player = playerPool[i]
--             if IsPedAPlayer(player) then
--                 local playerId = GetPlayerServerId(player)
--                 if playerId ~= GetPlayerServerId(PlayerId()) then
--                     SetEntityLodDist(player, 150)
--                 end
--             end
--         end
--         Wait(1000*60*2) -- 2 minutes
--     end
-- end)


function DeleteAllVehicles()
    local vehiclePool = GetGamePool('CVehicle')           
    for i = 1, #vehiclePool do
        local vehicle = vehiclePool[i]
        if GetPedInVehicleSeat(vehicle, -1) == 0  and not CheckIfVehicleIsDarkzone(vehicle) then

            local vehicleModel = GetEntityModel(vehicle)
            local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
            local vehicleNameLower = string.lower(vehicleName)
            
            local isWhitelisted = false
            for _, whitelistedVehicle in ipairs(vehListWhitelist) do
                if string.find(vehicleNameLower, string.lower(whitelistedVehicle)) then
                    isWhitelisted = true
                    break
                end
            end
            
            if not isWhitelisted then
                DeleteEntity(vehicle)
            else
            end
        end
    end
end