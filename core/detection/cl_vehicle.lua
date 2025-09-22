local BlacklistedVehicles = {
    --Commercials
    "phantom2", -- Phantom2
    -- Helicopters
    "annihilator", -- Anihilator
    "akula",
    "cargobob", -- CargoBob
    "cargobob2", -- CargoBob 2
    "cargobob3", -- Cargobob 3
    "cargobob4", -- Cargobob 4
    "frogger", -- Frogger
    "frogger2", -- Frogger 2
    "savage", -- Savage
    "skylift", -- Skylift
    "valkyrie", -- Valkyrie
    "valkyrie2", -- Valkyrie 2
    -- Industrial
    "bulldozer", -- Bulldozer
    "cutter", -- Cutter
    "dump", -- Dump
    "handler", -- Handler
    -- Military
    "apc", -- APC
    "barracks", -- Barracks
    "barracks2", -- Barracks 2
    "barracks3", -- Barracks 3
    "crusader", -- Crusader
    "halftrack", -- Halftrack
    "rhino", -- Rhino
    "trailersmall2", -- Trailer Small 2
    "khanjali",
    "chernobog",
    -- Motorcycles
    -- Off Road
    "dune3", -- Dune3
    "dune4", -- Dune4
    "dune5", -- Dune 5
    "insurgent", -- Insurgent
    "insurgent2", -- Insurgent 2
    "insurgent3", -- Insurgent 3
    "technical2", -- Technical2
    "technical", -- Technical
    "technical3", -- Technical3
    -- Planes
    "besra", -- Besra
    "blimp", --Blimp
    "blimp2", -- Blimp2
    "blimp3",
    "cargo", -- Cargo Plane
    "cuban800", -- Cuban800
    "dodo", -- Dodo
    "duster", -- Duster
    "hydra", -- Hydra
    "jet", -- Jet,
    "lazer", -- Lazer
    "miljet", -- Miljet
    "nimbus", --  Nimbus
    "shamal", -- Shamal
    "titan", -- Titan
    "molotok",
    "howard",
    "bombushka",
    "nokota",
    "pyro",
    "rogue",
    "starling",
    "strikeforce",
    "volatol",
    -- Trains
    "freight", -- Freight
    "adder",
}

BlacklistedWeapons = {
    "WEAPON_RAYPISTOL", -- Atomizer
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_REVOLVER",
    "WEAPON_REVOLVER_MK2",
    "WEAPON_DOUBLEACTION",
    "WEAPON_CERAMICPISTOL",
    -- SMGs
    "WEAPON_RAYCARBINE", -- Unholy Hellbringer
    -- Shotguns
    "WEAPON_SWEEPERSHOTGUN", -- Sweeper
    -- Heavy
    "WEAPON_GRENADELAUNCHER", --Grenade Launcher
    "WEAPON_GRENADELAUNCHER_SMOKE", -- Smoke Grenade Launcher
    "WEAPON_MINIGUN", -- MiniGun
    "WEAPON_FIREWORK", -- Firework Launcher
    "WEAPON_RAILGUN", -- Railgun
    "WEAPON_RAYMINIGUN", -- Widowmaker
    -- Throwables
    "WEAPON_STICKYBOMB", -- Sticky Bomb
    "WEAPON_PROXMINE", --  Proximity Mine
    "WEAPON_PIPEBOMB", -- Pipe Bomb
    "WEAPON_BZGAS",
    "WEAPON_SMOKEGRENADE",
    "WEAPON_GRENADE"
}

-- Citizen.CreateThread(function()
--     BlackVehs = BlacklistedVehicles
--     if BlacklistedVehicles then
-- 	    while true do
--             Citizen.Wait(1500)
--             local ped = GetPlayerPed(PlayerId())
--             local veh = GetVehiclePedIsUsing(ped)
--             local getLabelVehicle = GetLabelText(GetEntityModel(veh))
--             print(getLabelVehicle, "Label Vehicles")
--             for k, vehName in ipairs(BlackVehs) do
--                 if IsVehicleModel(veh, GetHashKey(vehName)) then
--                     local displaytext = vehName
--                     local PlayerID = GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1)))
--                     DeleteEntity(veh)
--                     Wait(5000)
--                     ShowAboveRadarMessage('~r~Vehicle successfully gived gg!')
--                     Wait(1000)
--                     Tse('ac:detected', "GIVE VEHICLE")
--                 end
--             end        
--         end
--     end
-- end)

Citizen.CreateThread(function()
    local BlackWeapons = BlacklistedWeapons

    if BlacklistedWeapons then
	    while true do
            Citizen.Wait(1500)
            -- TODO : Faire un check sur les armes que le joueur a dans son inventaire
            local ped = GetPlayerPed(PlayerId())
            for k, weaponName in ipairs(BlackWeapons) do
                local weaponHash = GetHashKey(weaponName)
                local HasWeapon = HasPedGotWeapon(ped, weaponHash, false)
                if HasWeapon then
                    RemoveAllPedWeapons(ped, true)
                    local id = PlayerId()
                    local PlayerID = GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1)))
                    Tse('ac:detected', "GIVE WEAPON")
                end
            end        
        end 
    end
end)

local function DetectionNoRecoil()
    if GetWeaponRecoilShakeAmplitude(GetSelectedPedWeapon(PlayerPedId())) <= 0.0 and not IsNuiFocus() and GetVehiclePedIsIn(PlayerPedId(), false) == 0 and IsPedShooting(PlayerPedId()) then
        Tse("logs", "Anti No Recoil")
    end
end

local function DetectionSilentAim()
    local model = GetEntityModel(PlayerPedId())
    local min, max 	= GetModelDimensions(model)
    if min.y < -0.29 or max.z > 0.98 then
        Tse("logs", "Silent Aim")
    end
end

function ReturnGiveWeapon()
    local inventory = PlayerItems["inventory"]
    local pInv = FormatItems(inventory)
    if pInv then 
        for i = 1, #pInv do 
            if GetHashKey(pInv[i].name) == GetSelectedPedWeapon(PlayerPedId()) then 
                return true
            end
        end
        return false
    end
    return false
end

function DetectWeapon()
    if GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey("weapon_unarmed") then

        if GM.Player.InGunrace then
            local weaponn = GetWeaponGunrace(GM.Player.InGunraceKills)
            if GetHashKey(weaponn) ~= GetSelectedPedWeapon(PlayerPedId()) then
                RemoveAllPedWeapons(PlayerPedId())
                SetCurrentPedWeapon(PlayerPedId(), GetHashKey(weaponn), true)
            end
        elseif not ReturnGiveWeapon() then
            RemoveAllPedWeapons(PlayerPedId())
        end
    end
end


Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Citizen.Wait(1) end
    while not GM.Init do Citizen.Wait(1) end
    while true do 
        Citizen.Wait(4000)
        DetectWeapon()
    end
end)

Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Citizen.Wait(1) end
    while not GM.Init do Citizen.Wait(1) end
    Citizen.Wait(5000)
    while true do 
        DetectionNoRecoil()
        DetectionSilentAim()
        Citizen.Wait(1)
    end
end)

-- Citizen.CreateThread(function()
--     while not NetworkIsPlayerActive(PlayerId()) do Citizen.Wait(1) end
--     while GetEntitySpeed(PlayerPedId()) == 0.0 do Citizen.Wait(1) end
--     while not GM.Init do Citizen.Wait(1) end
--     Citizen.Wait(5000)
--     while true do 
--         Citizen.Wait(1000) 
--         local player = PlayerPedId()
--         local initCoords = GetEntityCoords(player)
--         local vehicle = GetVehiclePedIsIn(player, false)
--         Citizen.Wait(1000)
--         local currentPos = GetEntityCoords(player)
--         local distance = GetDistanceBetweenCoords(initCoords, currentPos, true)
--         if distance >= 10.0 and not IsPedInAnyVehicle(player, false) and not IsPedDeadOrDying(player, true) and not GM.Player.InSafeZone and not GM.Player.InSelecGamemode and not Admin.InSpec and not IsInCustomVehicle then
--             Tse("logs", "Noclip detected")
--         end
--     end
-- end)