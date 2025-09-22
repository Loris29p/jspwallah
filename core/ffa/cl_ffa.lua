FFA_DATA = {}

GM.Player.InFFA = false 
GM.Player.FFAZone = false  
GM.Player.FFAID = 0

local BlipsPlayersFFA = {}


function GetPlayersFFA(id) 
    if not FFA_DATA[id] then return 0 end
    local playersCount = 0 
    for k, v in pairs(FFA_DATA[id].players) do
        playersCount = playersCount + 1
    end
    return playersCount
end

Citizen.CreateThread(function()
    local tblData_Rifle = {
        {
            safezone = "Main SafeZone",
            coords = vec4(-531.653931, -217.492584, 37.649822, 120.370918),
        },
    }

    local tblData_Sniper = {
        {
            safezone = "Main SafeZone",
            coords = vec4(-532.862976, -215.138504, 37.649792, 127.651314),
        },
    }

    for k, v in pairs(tblData_Rifle) do
        RegisterSafeZonePedAction({
            safezone = v.safezone,
            pedType = 4,
            model = "cs_mrs_thornhill",
            pos = v.coords,
            weapon = "weapon_specialcarbine",
            action = function()
                if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                    if not GM.Player.InFFA then
                        Tse("ffa:join", 1)
                    end
                end
            end,
            drawText = function()
                local FFA_DATA = GetFFAData(1)
                if not FFA_DATA then return "~r~No FFA found" end

                local playersCount = GetPlayersFFA(1)

                if playersCount > 0 then
                    return "[ ~r~" .. FFA_DATA.name .. "~s~ ] - ~g~" .. playersCount .. " players"
                else 
                    return "[ ~r~" .. FFA_DATA.name .. "~s~ ] - ~w~No players"
                end
            end,
            distanceLimit = 2.0,
            distanceShowText = 20.0,
        })
    end

    for k, v in pairs(tblData_Sniper) do
        RegisterSafeZonePedAction({
            safezone = v.safezone,
            pedType = 4,
            model = "cs_orleans",
            pos = v.coords,
            weapon = "weapon_heavysniper_mk2",
            action = function()
                if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                    if not GM.Player.InFFA then
                        Tse("ffa:join", 2)
                    end
                end
            end,
            drawText = function()
                local FFA_DATA = GetFFAData(2)
                if not FFA_DATA then return "~r~No FFA found" end

                local playersCount = GetPlayersFFA(2)

                if playersCount > 0 then
                    return "[ ~r~" .. FFA_DATA.name .. "~s~ ] - ~g~" .. playersCount .. " players"
                else 
                    return "[ ~r~" .. FFA_DATA.name .. "~s~ ] - ~w~No players"
                end
            end,
            distanceLimit = 2.0,
            distanceShowText = 20.0,
        })
    end
end)


function GetFFAData(id) 
    return FFA_DATA[id]
end

_RegisterNetEvent("ffa:sendingdata", function(type, data)
    if type == "create" then
        FFA_DATA[data.id] = {
            name = data.name,
            map = data.map,
            players = {},
            leaderboard = {},
        }
        Logger:trace("FFA", "An FFA has been created with the id " .. data.id)
    elseif type == "update" then
        if not FFA_DATA[data.id] then return end
        FFA_DATA[data.id].players = data.players
        Logger:trace("FFA", "An FFA has been updated with the id " .. data.id)
        Wait(3000)
        RefreshBlipsPlayersFFA()
    elseif type == "mass_update" then
        FFA_DATA = data
    elseif type == "join" then 
        GM.Player.FFAID = data.id
        GM.Player.InFFA = true
        Logger:trace("FFA", "You join the FFA with the id " .. data.id)
        JoinFFA()
    elseif type == "leave" then 
        GM.Player.FFAID = 0
        GM.Player.InFFA = false
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle then
            DeleteEntity(vehicle)
        end
        SendNUIMessage({
            type = "showFFA",
            show = false,
        })
        SetDisableInventoryMoveState(false)
        SendNUIMessage({
            type = "cc",
            movestatus = false
        })
        FreezeEntityPosition(PlayerPedId(), true)
        TeleportToWp(PlayerPedId(), vec3(-541.263428, -211.064194, 37.649742), 211.573578, false)
        Wait(1500)
        FreezeEntityPosition(PlayerPedId(), false)
        Logger:trace("FFA", "You leave the FFA with the id " .. data.id)
        RemoveBlipsPlayersFFA()
    elseif type == "finish" then
        Logger:trace("FFA", "You finish the FFA with the id " .. data.id)
        FFA_DATA[data.id].leaderboard = {}
        
        -- Close inventory when FFA finishes
        if isOpened then
            isOpened = false
            Display({
                bool = false
            })
            Logger:trace("FFA", "Inventory closed due to FFA finish event")
        end
    elseif type == "leaderboard" then 
        FFA_DATA[data.id].leaderboard = data.leaderboard
        SendNUIMessage({
            type = "showFFA",
            show = true,
            scores = data.leaderboard,
        })
        Logger:trace("FFA", "The leaderboard of the FFA with the id " .. data.id .. " has been updated")
    end
end)

-- Close inventory when FFA finishes
_RegisterNetEvent("gamemode:closeInventory", function()
    if isOpened then
        isOpened = false
        Display({
            bool = false
        })
        Logger:trace("FFA", "Inventory closed due to FFA finish")
    end
end)

local oldRespawn = nil

function RandomRespawnFFA() 
    local FFA_DATA = GetFFAData(GM.Player.FFAID)
    if not FFA_DATA then return end 
    ::continue::
    local randomRespawn = FFA_DATA.map.respawn[math.random(1, #FFA_DATA.map.respawn)]
    if oldRespawn == randomRespawn then
        goto continue
    else
        oldRespawn = randomRespawn
    end
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
    SetEntityOnlyDamagedByPlayer(PlayerPedId(), true)
    return randomRespawn
end

function RemoveBlipsPlayersFFA()
    for k, v in pairs(BlipsPlayersFFA) do
        RemoveBlip(v)
    end
    BlipsPlayersFFA = {}
end

function RefreshBlipsPlayersFFA()
    local FFA_DATA = GetFFAData(GM.Player.FFAID)
    if not FFA_DATA then return end
    RemoveBlipsPlayersFFA()

    for k, v in pairs(FFA_DATA.players) do
        local memberServerId = v.source
        local memberClientId = GetPlayerFromServerId(memberServerId)
        local memberPed = GetPlayerPed(memberClientId)
        local blip = AddBlipForEntity(memberPed)
        if DoesBlipExist(blip) then
            SetBlipSprite(blip, 1)
            SetBlipColour(blip, 1)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, false)
            SetBlipDisplay(blip, 2)
            SetBlipCategory(blip, 7)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Enemy")
            EndTextCommandSetBlipName(blip)
            BlipsPlayersFFA[memberServerId] = blip
        end
    end
end

function JoinFFA()
    local FFA_DATA = GetFFAData(GM.Player.FFAID)
    if not FFA_DATA then  
        GM.Player.InFFA = false 
        GM.Player.FFAID = 0 
        return
    end 

    local randomRespawn = RandomRespawnFFA()

    SetDisableInventoryMoveState(true)
    SendNUIMessage({
        type = "cc",
        movestatus = true
    })

    TeleportToWp(PlayerPedId(), vec3(randomRespawn.x, randomRespawn.y, randomRespawn.z), randomRespawn.w, false, function()
        print("Teleported to the FFA")
        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(PlayerPedId(), true, true)
        SetEntityOnlyDamagedByPlayer(PlayerPedId(), true)
        SetEntityInvincible(PlayerPedId(), false)
    end)
    
    -- Ajouter un gestionnaire pour détecter les sorties de zone et les crashes
    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName == GetCurrentResourceName() and GM.Player.InFFA then
            -- Le script s'arrête, notifier le serveur
            Tse("ffa:resourceStop", GM.Player.FFAID)
        end
    end)
    
    -- Gestionnaire pour les changements de gamemode
    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName == GetCurrentResourceName() and GM.Player.InFFA then
            -- Le script redémarre, vérifier si on est toujours en FFA
            Wait(1000)
            if not GM.Player.InFFA then
                Tse("ffa:checkStatus")
            end
        end
    end)


    Citizen.CreateThread(function()
        while GM.Player.InFFA do
            Wait(1)
            DrawMarker(28, FFA_DATA.map.posCenter.x, FFA_DATA.map.posCenter.y, FFA_DATA.map.posCenter.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, FFA_DATA.map.blipsConfig.radius, FFA_DATA.map.blipsConfig.radius, FFA_DATA.map.blipsConfig.radius, 255, 118, 164, 180, false, false, 2, false, nil, nil, false)
        end
    end)

    Citizen.CreateThread(function()
        while GM.Player.InFFA do
            Wait(1)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(vec2(playerCoords.x, playerCoords.y) - vec2(FFA_DATA.map.posCenter.x, FFA_DATA.map.posCenter.y))
            if distance < FFA_DATA.map.blipsConfig.radius then
                if not GM.Player.FFAZone then 
                    GM.Player.FFAZone = true
                    
                end
            else
                if GM.Player.FFAZone then 
                    GM.Player.FFAZone = false
                    local coords = RandomRespawnFFA()
                    TeleportToWp(PlayerPedId(), vec3(coords.x, coords.y, coords.z), coords.w, false)
                end
            end
        end
    end)

    Wait(2000)
    RefreshBlipsPlayersFFA()
end