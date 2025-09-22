
local BlipsRadius = nil 
local Blips = nil 
local tempCoords = nil

RegisterCommand("farm", function()
    if GM.Player.InSelecGamemode then return end
    if GM.Player.InFFA then return end
    if GM.Player.InRedzone then return end
    if GM.Player.InFarm then 
        GM.Player.InFarm = false
        FarmHandler(false)
        DeleteAllZombies()
        SetZombieCanSpawn(false)
    else 
        if GM.Player.InSafeZone then 
            if not GM.Player.InFarm then 
                GM.Player.InFarm = true
                FarmHandler(true)
            end 
        end
    end
end)


local NPC_Farm_Main = {
    safezone = "Hospital",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(240.8636, -1396.938, 30.52595, 51.19801),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_Highway = {
    safezone = "Highway",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(733.1791, -1187.617, 44.95468, 275.6082),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_Marabunta = {
    safezone = "Marabunta",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(1150.187, -1495.213, 34.69259, 199.0914),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_Beach = {
    safezone = "Beach Safezone",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(-1077.214722, -1268.248779, 5.864951, 302.751587),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_AA = {
    safezone = "Cross Field",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(1205.224, 1871.197, 78.18395, 243.0435),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_Blaine = {
    safezone = "Sandy Shores Safezone",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(2765.622, 3459.245, 55.70893, 80.41955),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_Paleto = {
    safezone = "Hideout",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(1469.194, 6355.288, 23.81465, 308.8685),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_Paleto2 = {
    safezone = "Paleto",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(-954.4135, 6192.201, 3.741186, 37.21659),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_Mountain = {
    safezone = "Mountain",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(-432.1657, 1131.817, 325.9045, 167.6721),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_Mirror = {
    safezone = "Mirror Park",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(1371.594, -569.7591, 74.23081, 155.9993),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else 
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Farm_Main = {
    safezone = "Main SafeZone",
    pedType = 4,
    model = "cs_priest",
    pos = vector4(-544.8487, -230.0595, 37.61161, 31.35588),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            GM.Player.InFarm = true
            FarmHandler(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the farm zone")
        end
    end,
    drawText = "[ ~r~SAFE ZONE FARM ~s~]",
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

Citizen.CreateThread(function()
    RegisterSafeZonePedAction(NPC_Farm_Main)
    -- RegisterSafeZonePedAction(NPC_Farm_Highway)
    RegisterSafeZonePedAction(NPC_Farm_Marabunta)
    RegisterSafeZonePedAction(NPC_Farm_Beach)
    RegisterSafeZonePedAction(NPC_Farm_AA)
    RegisterSafeZonePedAction(NPC_Farm_Blaine)
    RegisterSafeZonePedAction(NPC_Farm_Paleto)
    RegisterSafeZonePedAction(NPC_Farm_Paleto2)
    RegisterSafeZonePedAction(NPC_Farm_Mountain)
    RegisterSafeZonePedAction(NPC_Farm_Mirror)
end)

local function drawTxt(text, font, centre, x, y, scale, r, g, b, a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end


-- vector4(182.4448, -949.4304, 30.09195, 329.9964)

local tempcoords2 = nil
local AttackableZombies = false

function FarmHandler(bool)
    if bool then
        tempcoords2 = GetEntityCoords(PlayerPedId())
        RequestCollisionAtCoord(Farm.Coords.x, Farm.Coords.y, Farm.Coords.z)
        TeleportPlayerCoords(Farm.Coords, PlayerPedId())
        Instance:CreateInstance(math.random(1, 1000000))
        Tse("enterFarmZone")
        tempCoords = GetEntityCoords(PlayerPedId())

        Blips = AddBlipForCoord(Farm.Coords.x, Farm.Coords.y, Farm.Coords.z)
        SetBlipSprite(Blips, 1)
        SetBlipColour(Blips, 2)
        SetBlipScale(Blips, 0.7)
        SetBlipAsShortRange(Blips, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Farm")
        EndTextCommandSetBlipName(Blips)
        -- SetBypassTeleport(true)
        Wait(2000)
        -- SetZombieCanSpawn(true)
        Citizen.CreateThread(function()
            while GM.Player.InFarm do 
                DrawMarker(28, Farm.Coords.x, Farm.Coords.y, Farm.Coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 20.0, 20.0, 10.0, 51, 200, 153, 70, false, false, 2, false, nil, nil, false)

                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(vec3(playerCoords.x, playerCoords.y, playerCoords.z) - vec3(Farm.Coords.x, Farm.Coords.y, Farm.Coords.z))
                if distance > 20.0 then
                    if not AttackableZombies then
                        AttackableZombies = true
                        print("AttackableZombies")
                        SetZombieCanSpawn(true)
                    end
                else
                    if AttackableZombies then
                        AttackableZombies = false
                        print("Not AttackableZombies")
                        DeleteAllZombies()
                        SetZombieCanSpawn(false)
                    end
                end
                Wait(1)
            end
        end)
        Citizen.CreateThread(function()
            while GM.Player.InFarm do 
                DrawCenterText("Use ~r~/farm ~s~for leave the mode.")
                Citizen.Wait(0)
            end
        end)
    else
        SetZombieCanSpawn(false)
        Instance:LeaveInstance()
        if BlipsRadius then 
            RemoveBlip(BlipsRadius)
        end
        if Blips then
            RemoveBlip(Blips)
        end
        TeleportPlayerCoords(tempcoords2, PlayerPedId())
        Tse("leaveFarmZone")
    end
end