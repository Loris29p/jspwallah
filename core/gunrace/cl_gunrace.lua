GunraceData = {}

GM.Player.InGunrace = false
GM.Player.GunraceId = 0

GM.Player.InGunraceKills = 0

local InZoneRace = false
local BlipsPlayersGunrace = {}
local isDamageLoopRunning = false
local lastDamageTime = 0

function GetPlayersInGunrace()
    local playersCount = 0
    for k, v in pairs(GunraceData) do 
        for k2, v2 in pairs(v.players) do 
            playersCount = playersCount + 1
        end
    end
    return (playersCount and playersCount or nil)
end

_RegisterNetEvent("gunrace:sendingdata", function(action, tblData)
    if action == "create" then 
        GunraceData[tblData.gunraceId] = {
            id = tblData.gunraceId,
            name = tblData.name,
            map = tblData.map,
            players = {},
        }
        Logger:trace("GUNRACE", "Gunrace created with id: " .. tblData.gunraceId, "gunraceId", tblData.gunraceId)
    elseif action == "mass_update" then 
        for k, v in pairs(tblData) do
            GunraceData[k] = v
            Logger:trace("GUNRACE", "Gunrace updated with id: " .. k, "gunraceId", k)
        end
    elseif action == "finish" then
        if GM.Player.GunraceId ~= tblData.gunraceId then return end
        GM.Player.InGunrace = false
        GM.Player.GunraceId = 0
        GM.Player.InGunraceKills = 0
        DisableInventory(false)
        SendNUIMessage({
            type = "showFFA",
            show = false,
        })
        GunraceData[tblData.gunraceId].leaderboard = {}
        RemoveBlipsPlayersGunrace()
    elseif action == "join" then
        print("JOIN", tblData.gunraceId)
        JoinGunrace(tblData.gunraceId)
        Logger:trace("GUNRACE", "Gunrace joined with id: " .. tblData.gunraceId, "gunraceId", tblData.gunraceId)
    elseif action == "addkills" then
        GM.Player.InGunraceKills = GM.Player.InGunraceKills + 1
        print("ADD KILLS", GM.Player.InGunraceKills)
    elseif action == "leave" then 
        GM.Player.InGunrace = false
        GM.Player.GunraceId = 0
        GM.Player.InGunraceKills = 0
        DisableInventory(false)
        SendNUIMessage({
            type = "showFFA",
            show = false,
        })
        RemoveBlipsPlayersGunrace()
    elseif action == "update" then
        GunraceData[tblData.gunraceId].players = tblData.players
        Wait(3000)
        RefreshBlipsPlayersGunrace()
    elseif action == "leaderboard" then
        GunraceData[tblData.gunraceId].leaderboard = tblData.leaderboard
        SendNUIMessage({
            type = "showFFA",
            show = true,
            scores = tblData.leaderboard,
            myScore = {
                kills = (GM.Player.InGunraceKills and GM.Player.InGunraceKills or 0)
            }
        })
        Logger:trace("GUNRACE", "Gunrace leaderboard updated with id: " .. tblData.gunraceId, "gunraceId", tblData.gunraceId)
    elseif action == "remove" then
        GM.Player.InGunrace = false
        GM.Player.GunraceId = 0
        GM.Player.InGunraceKills = 0
        DisableInventory(false)
        SendNUIMessage({
            type = "showFFA",
            show = false,
        })
        FreezeEntityPosition(PlayerPedId(), true)
        TeleportToWp(PlayerPedId(), vec3(-541.263428, -211.064194, 37.649742), 211.573578, false)
        Wait(1500)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end)

function GetDataGunrace(gunraceId)
    return GunraceData[gunraceId]
end

function GetWeaponGunrace(kills)
    local bestWeapon = nil
    local bestKillsRequired = -1
    
    for k, v in pairs(Gunrace.gungameWeapons) do
        if kills >= v.killsRequired and v.killsRequired > bestKillsRequired then
            bestWeapon = v
            bestKillsRequired = v.killsRequired

        end
    end
    
    if bestWeapon then
        return bestWeapon.weapon, bestWeapon.ammo
    end
    
    return "weapon_pistol", 12
end

function WeaponGunrace()
    if not GM.Player.InGunrace then return end
    local lastKills = GM.Player.InGunraceKills
    local lastWeapon = nil
    
    Citizen.CreateThread(function()
        while GM.Player.InGunrace do
            local kills = GM.Player.InGunraceKills
            local weapon, ammo = GetWeaponGunrace(kills)
            GiveWeaponToPed(PlayerPedId(), GetHashKey(weapon), ammo, false, true)

            local playerPed = PlayerPedId()
            local currentWeapon = GetSelectedPedWeapon(playerPed)
            
            -- Si le joueur n'a pas la bonne arme, on la force
            if currentWeapon ~= GetHashKey(weapon) then
                SetCurrentPedWeapon(playerPed, GetHashKey(weapon), true)
            end
            
            -- Détecter si le joueur a changé d'arme (plus de kills)
            if kills > lastKills and lastWeapon ~= weapon then
                lastWeapon = weapon
                ScaleformNextWeapon(weapon)
            end
            
            lastKills = kills
            
            -- Désactiver le changement d'armes avec les touches
            DisableControlAction(0, 37, true) -- TAB (wheel)
            DisableControlAction(0, 157, true) -- 1
            DisableControlAction(0, 158, true) -- 2
            DisableControlAction(0, 160, true) -- 3
            DisableControlAction(0, 164, true) -- 4
            DisableControlAction(0, 165, true) -- 5
            DisableControlAction(0, 159, true) -- 6
            DisableControlAction(0, 161, true) -- 7
            DisableControlAction(0, 162, true) -- 8
            DisableControlAction(0, 163, true) -- 9
            DisableControlAction(0, 37, true) -- TAB
            
            -- Permettre le rechargement manuel
            -- DisableControlAction(0, 45, true) -- R (reload) - Commenté pour permettre le rechargement
            
            Citizen.Wait(0)
        end
    end)
end

function RemoveBlipsPlayersGunrace()
    for k, v in pairs(BlipsPlayersGunrace) do
        RemoveBlip(v)
    end
    BlipsPlayersGunrace = {}
end

function RefreshBlipsPlayersGunrace()
    local RaceData = GetDataGunrace(GM.Player.GunraceId)
    if not RaceData then return end

    RemoveBlipsPlayersGunrace()

    for k, v in pairs(RaceData.players) do
        if v.source ~= GetPlayerServerId(PlayerId()) then
            local memberServerId = v.source
            local memberClientId = GetPlayerFromServerId(memberServerId)
            print("MEMBER CLIENT ID", memberClientId, memberServerId, v.username)
            local memberPed = GetPlayerPed(memberClientId)
            local blip = AddBlipForEntity(memberPed)
            if DoesBlipExist(blip) then
                SetBlipSprite(blip, 1) -- Point blip
                SetBlipColour(blip, 1) -- Red color (enemy)
                SetBlipScale(blip, 0.8)
                SetBlipAsShortRange(blip, false) -- Visible sur la minimap même à distance
                SetBlipDisplay(blip, 2) -- Affichage sur minimap et carte
                SetBlipCategory(blip, 7) -- Catégorie "Other Players"
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Enemy")
                EndTextCommandSetBlipName(blip)
                BlipsPlayersGunrace[memberServerId] = blip
            end
        end
    end
end

local oldSpawn = nil

function RandomSpawnGunrace()
    local RaceData = GetDataGunrace(GM.Player.GunraceId)
    if not RaceData then return end
    ::continue:: 
    local randomSpawn = RaceData.map.respawn[math.random(1, #RaceData.map.respawn)]
    if oldSpawn == randomSpawn then
        goto continue
    end
    oldSpawn = randomSpawn
    SetEntityCoords(PlayerPedId(), randomSpawn.x, randomSpawn.y, randomSpawn.z)
    SetEntityHeading(PlayerPedId(), randomSpawn.w)
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
    SetEntityOnlyDamagedByPlayer(PlayerPedId(), true)
end


function ScaleformNextWeapon(weaponName)
    local currentKills = GM.Player.InGunraceKills
    local currentWeapon = nil
    local nextWeapon = nil
    local killsRemaining = 0
    
    -- Trouver l'arme actuelle
    for k, v in pairs(Gunrace.gungameWeapons) do
        if currentKills >= v.killsRequired then
            currentWeapon = v
        end
    end
    
    -- Trouver la prochaine arme dans la progression
    for k, v in pairs(Gunrace.gungameWeapons) do
        if v.killsRequired > currentKills then
            nextWeapon = v
            killsRemaining = v.killsRequired - currentKills
            break
        end
    end
    
    -- Si pas de prochaine arme, c'est qu'on a atteint le maximum
    if not nextWeapon then
        return
    end
    
    local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")

    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    
    -- Créer le message avec le nombre de kills restants et l'arme actuelle
    local title = killsRemaining .. " KILLS REMAINING"
    local subtitle = (Items[currentWeapon.weapon] and Items[currentWeapon.weapon].label) or "Unknown Weapon"
    
    BeginScaleformMovieMethod(scaleform, "SHOW_WEAPON_PURCHASED")
    PushScaleformMovieMethodParameterString(title) -- Titre avec kills restants
    PushScaleformMovieMethodParameterString(subtitle) -- Nom de l'arme actuelle
    PushScaleformMovieMethodParameterInt(GetHashKey(currentWeapon.weapon)) -- Hash de l'arme actuelle
    PushScaleformMovieMethodParameterBool(true) -- background
    EndScaleformMovieMethod()
    PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
    
    -- Affichage temporaire
    local timer = GetGameTimer() + 5000
    Citizen.CreateThread(function()
        while GetGameTimer() < timer do
            Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        end
    end)
end

function JoinGunrace(gunraceId)
    if GM.Player.InGunrace then return end 
    GM.Player.InGunrace = true
    GM.Player.GunraceId = gunraceId
    DisableInventory(true)

    local RaceData = GetDataGunrace(gunraceId)
    if not RaceData then 
        GM.Player.InGunrace = false
        GM.Player.GunraceId = 0
        GM.Player.InGunraceKills = 0
        DisableInventory(false)
        return 
    end

    RandomSpawnGunrace()
    GM.Player.InGunraceKills = 0
    WeaponGunrace()
    
    ScaleformNextWeapon()
    
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
    SetEntityOnlyDamagedByPlayer(PlayerPedId(), true)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityInvincible(PlayerPedId(), false)

    local color = {r = 0, g = 204, b = 204, a = 150}


    Citizen.CreateThread(function()
        while GM.Player.InGunrace do
            Wait(1)
            DrawMarker(28, RaceData.map.coords.x, RaceData.map.coords.y, RaceData.map.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, RaceData.map.radius, RaceData.map.radius, RaceData.map.radius, color.r, color.g, color.b, color.a, false, false, 2, false, nil, nil, false)
        end
    end)

    Citizen.CreateThread(function()
        while GM.Player.InGunrace do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(RaceData.map.coords.x, RaceData.map.coords.y, RaceData.map.coords.z))
            
            if distance <= RaceData.map.radius then
                if not InZoneRace then
                    InZoneRace = true
                    isDamageLoopRunning = false
                    color = {r = 0, g = 204, b = 204, a = 150}
                end
            else 
                if InZoneRace then
                    InZoneRace = false
                    color = {r = 204, g = 0, b = 0, a = 150}
                end
                
                local currentTime = GetGameTimer()
                if not isDamageLoopRunning and (currentTime - lastDamageTime) > 1000 then
                    isDamageLoopRunning = true
                    lastDamageTime = currentTime
                    DamageLeaveGunrace()
                end
            end
            Citizen.Wait(100)
        end
    end)
    Wait(2000)
    RefreshBlipsPlayersGunrace()
end

function DamageLeaveGunrace()
    Citizen.CreateThread(function()
        local damageCount = 0
        while not InZoneRace and GM.Player.InGunrace and damageCount < 5 do
            Wait(1000)
            if not InZoneRace and GM.Player.InGunrace then
                ApplyDamageToPed(PlayerPedId(), 10.0, false, true, true)
                ShowAboveRadarMessage("~r~You have been damaged by leaving the gunrace zone!")
                damageCount = damageCount + 1
            end
        end
        isDamageLoopRunning = false
    end)
end

Citizen.CreateThread(function()
    local ListNPC_GunRace = {
        {
            safezone = "Main SafeZone",
            coords = vec4(-540.082886, -222.434250, 37.649727, 297.430634),
        }
    }

    for k, v in pairs(ListNPC_GunRace) do 
        RegisterSafeZonePedAction({
            safezone = v.safezone, 
            pedType = 4, 
            model = "cs_lestercrest", 
            pos = v.coords,
            weapon = "weapon_bat",
            action = function()
                if not IsPedInAnyVehicle(PlayerPedId(), false) then
                    Tse("gunrace:joinGunrace", 1)
                end
            end,
            drawText = function()
                local playersCount = GetPlayersInGunrace()
                if playersCount and playersCount > 0 then 
                    return "[ ~r~GUNRACE ~s~] - ~g~" .. playersCount .. " players"
                else 
                    return "[ ~r~GUNRACE ~s~] - ~w~No players"
                end
            end,
            distanceLimit = 2.0,
            distanceShowText = 20.0,
        })
    end
end)