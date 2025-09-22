MilitazyZoneInfo = nil
MilitaryZoneCases = {}
MilitaryPed = nil
GM.Player.MilitaryZone = false
_RegisterNetEvent("militaryzone:broadcastAll", function(tblData)
    if type(tblData) ~= "table" then return end
    MilitazyZoneInfo = tblData
end)


_RegisterNetEvent("militaryzone:join", function()
    GM.Player.MilitaryZone = true
    Wait(1000)
    CreateCases({})
    Wait(500)
    
    -- Multiple spawn points for military zone
    local spawnPoints = {
        {pos = vec3(-2456.89, 3063.664, 196.3324), heading = 274.2532},
        {pos = vec3(-2128.4087, 2968.7966, 196.3324), heading = 180.0},
        {pos = vec3(-2053.1882, 3208.5959, 196.3324), heading = 148.4967},
        {pos = vec3(-2239.1807, 3225.4236, 196.3324), heading = 292.56}
    }
    
    -- Randomly select a spawn point
    local randomSpawn = spawnPoints[math.random(#spawnPoints)]
    local lobby = randomSpawn.pos
    local heading = randomSpawn.heading
    
    TeleportToWp(PlayerPedId(), lobby, heading, false, function()
        para()
    end)
end)

local text = "~r~MILITARY ZONE - ~w~0 PLAYERS"

Citizen.CreateThread(function()

    local NPC_MilitaryZone_Paleto = {
        safezone = "Paleto",
        pedType = 4,
        model = "csb_ramp_marine",
        pos = vector4(-944.2444, 6197.943, 3.68201, 40.78871),
        action = function()
            Tse("militaryzone:join")
        end,
        drawText = function()
            if MilitazyZoneInfo and #MilitazyZoneInfo > 0 then 
                return "~r~MILITARY ZONE - ~g~"..#MilitazyZoneInfo.." PLAYERS"
            else
                return "~r~MILITARY ZONE - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }


    local NPC_MilitaryZone_Mountain = {
        safezone = "Mountain",
        pedType = 4,
        model = "csb_ramp_marine",
        pos = vector4(-436.4289, 1133.319, 325.9045, 163.6283),
        action = function()
            Tse("militaryzone:join")
        end,
        drawText = function()
            if MilitazyZoneInfo and #MilitazyZoneInfo > 0 then 
                return "~r~MILITARY ZONE - ~g~"..#MilitazyZoneInfo.." PLAYERS"
            else
                return "~r~MILITARY ZONE - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_MilitaryZone_Main = {
        safezone = "Main SafeZone",
        pedType = 4,
        model = "csb_ramp_marine",
        pos = vector4(-536.9349, -218.2864, 37.6498, 33.03482),
        action = function()
            Tse("militaryzone:join")
        end,
        drawText = function()
            if MilitazyZoneInfo and #MilitazyZoneInfo > 0 then 
                return "~r~MILITARY ZONE - ~g~"..#MilitazyZoneInfo.." PLAYERS"
            else
                return "~r~MILITARY ZONE - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_MilitaryZone_Hospital = {
        safezone = "Hospital",
        pedType = 4,
        model = "csb_ramp_marine",
        pos = vector4(243.5518, -1397.063, 30.51999, 55.85244),
        action = function()
            Tse("militaryzone:join")
        end,
        drawText = function()
            if MilitazyZoneInfo and #MilitazyZoneInfo > 0 then 
                return "~r~MILITARY ZONE - ~g~"..#MilitazyZoneInfo.." PLAYERS"
            else
                return "~r~MILITARY ZONE - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_MilitaryZone_Mirror = {
        safezone = "Mirror Park",
        pedType = 4,
        model = "csb_ramp_marine",
        pos = vector4(1366.479, -570.7899, 74.33691, 263.4291),
        action = function()
            Tse("militaryzone:join")
        end,
        drawText = function()
            if MilitazyZoneInfo and #MilitazyZoneInfo > 0 then 
                return "~r~MILITARY ZONE - ~g~"..#MilitazyZoneInfo.." PLAYERS"
            else
                return "~r~MILITARY ZONE - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_MilitaryZone_Depot = {
        safezone = "depot",
        pedType = 4,
        model = "csb_ramp_marine",
        pos = vector4(768.05, -1416.76, 26.48, 358.95),
        action = function()
            Tse("militaryzone:join")
        end,
        drawText = function()
            if MilitazyZoneInfo and #MilitazyZoneInfo > 0 then 
                return "~r~MILITARY ZONE - ~g~"..#MilitazyZoneInfo.." PLAYERS"
            else
                return "~r~MILITARY ZONE - ~w~No players"
            end
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_MilitaryZone_Paleto)
    RegisterSafeZonePedAction(NPC_MilitaryZone_Mountain)
    RegisterSafeZonePedAction(NPC_MilitaryZone_Main)
    RegisterSafeZonePedAction(NPC_MilitaryZone_Hospital) 
    RegisterSafeZonePedAction(NPC_MilitaryZone_Mirror)
    RegisterSafeZonePedAction(NPC_MilitaryZone_Depot)
    
    -- Création du blip principal de la zone militaire (zone circulaire)
    local militaryZoneBlip = AddBlipForRadius(-2138.4978, 3121.7825, 32.8100, 500.0)
    SetBlipRotation(militaryZoneBlip, 0)
    SetBlipColour(militaryZoneBlip, 14) -- Rouge
    SetBlipAlpha(militaryZoneBlip, 128) -- Semi-transparent
    SetBlipDisplay(militaryZoneBlip, 4)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Military Zone")
    EndTextCommandSetBlipName(militaryZoneBlip)
    
end)

_RegisterNetEvent("militaryzone:leave", function()
    GM.Player.MilitaryZone = false
    for k, v in pairs(MilitaryZoneCases) do 
        if DoesEntityExist(v.model) then 
            DeleteEntity(v.model)
        end

        if DoesBlipExist(v.blips) then 
            RemoveBlip(v.blips)
        end
    end
    MilitaryZoneCases = {}
end)

function CreateCases(tblData)
    if type(tblData) ~= "table" then return end 
    for k, v in pairs(MilitaryZoneConfig.cases) do 
        local model = GetHashKey("prop_box_wood04a")
        RequestModel(model)
        while not HasModelLoaded(model) do 
            Citizen.Wait(0)
        end
        local object =  CreateObject(model, vec3(v.x,v.y, v.z - 1.0), true, true, true)
        SetEntityInvincible(object)
        FreezeEntityPosition(object, true)
        PlaceObjectOnGroundProperly(object)
        SetEntityHeading(object, v.w)
        SetEntityAsMissionEntity(object, true, true)
        local blip = AddBlipForEntity(object)
        SetBlipSprite(blip, 478)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Military Box")
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip, 1)
        table.insert(MilitaryZoneCases, {
            model = object,
            id = k,
            pos = vec3(v.x,v.y, v.z - 1.0),
            blips = blip,
            near = false
        })
    end
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
end

Citizen.CreateThread(function()
    while true do 
        local timer = 1000
        local isNear = false
        local playerPos = GetEntityCoords(PlayerPedId())

        if GM.Player.MilitaryZone then 
            for k, v in pairs(MilitaryZoneCases) do 
                local objectCoords = GetEntityCoords(v.model)
                local distance = #(playerPos - objectCoords)
                if distance <= 4.0 then 
                    isNear = true
                    timer = 0
                    if distance <= 3.5 then 
                        DrawTopNotification("Press ~INPUT_CONTEXT~ to open the case")
                        if IsControlJustPressed(0, 38) then 
                            print('OPEN CASE', v.id)
                            Tse("militaryzone:openCase", v.id)
                        end
                    end
                end
            end
        end

        if not isNear then 
            timer = 1000
        end

        Wait(timer)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    for k, v in pairs(MilitaryZoneCases) do 
        if DoesEntityExist(v.object) then 
            DeleteEntity(v.object)
        end
    end
end)
