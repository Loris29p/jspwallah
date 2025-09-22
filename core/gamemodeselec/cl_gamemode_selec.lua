Gamemode = {}
GM.Player.InSelecGamemode = false

_RegisterNetEvent("gamemode:client:UpdateConnected", function(gamemodeAll)
    Gamemode = gamemodeAll
    SendNUIMessage({
        type = "updateGameModeSelec",
        gamemode = "pvp",
        players = #Gamemode["PvP"],
    })

    SendNUIMessage({
        type = "updateGameModeSelec",
        gamemode = "FFA",
        players = #Gamemode["FFA"],
    })
end)

local url = "https://cfx-nui-gamemode/ui/welcome.html"

local scale = 0.13
local sfName = 'generic_texture_renderer_2'

local width = 1280
local height = 720

local sfHandle = nil
local txdHasBeenSet = false
local duiObj = nil

local testCoords = vector3(-1268.367, -3013.23, -48.49023)


function loadScaleform(scaleform)
    local scaleformHandle = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleformHandle) do 
        scaleformHandle = RequestScaleformMovie(scaleform)
        Citizen.Wait(0) 
    end
    return scaleformHandle
end


local blipGamemode = nil
function LoadGamemodeSelection()
    -- SetBypassTeleport(false)
    SetEntityAlpha(PlayerPedId(), 150)
    SetEntityInvincible(PlayerPedId(), true)
    GM.Player.InSelecGamemode = true
    local selection = vector4(-1267.084, -3013.089, -48.49021, 1.372242)
    sfHandle = loadScaleform(sfName)
    runtimeTxd = 'meows'

    local txd = CreateRuntimeTxd('meows')
    duiObj = CreateDui(url, width, height)
    local dui = GetDuiHandle(duiObj)
    local tx = CreateRuntimeTextureFromDuiHandle(txd, 'woof', dui)

    Citizen.CreateThread(function()
        while GM.Player.InSelecGamemode do
    
            if (sfHandle ~= nil and not txdHasBeenSet) then
                print('SET_TEXTURE')
                PushScaleformMovieFunction(sfHandle, 'SET_TEXTURE')
            
                PushScaleformMovieMethodParameterString('meows')
                PushScaleformMovieMethodParameterString('woof')
            
                PushScaleformMovieFunctionParameterInt(0)
                PushScaleformMovieFunctionParameterInt(0)
                PushScaleformMovieFunctionParameterInt(width)
                PushScaleformMovieFunctionParameterInt(height)
            
                PopScaleformMovieFunctionVoid()
            
                txdHasBeenSet = true
            end
    
            if (sfHandle ~= nil and HasScaleformMovieLoaded(sfHandle)) then
                DrawScaleformMovie_3dNonAdditive(sfHandle, testCoords.x, testCoords.y, testCoords.z+2, 0, 0, 0, 2, 2, 2, scale * 1, scale * (9/16), 1, 2)
            end
            Citizen.Wait(0)
        end
    end)

    Citizen.CreateThread(function()
        while GM.Player.InSelecGamemode do 
            Wait(1)
            local pCoords = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(pCoords.x, pCoords.y, pCoords.z, selection.x, selection.y, selection.z)
            if dist < 50.0 then 
                DrawMarker(1, selection.x, selection.y, selection.z - 1.0, 0, 0, 0, 0, 0, 0, 7.2, 7.2, 1.2, 253, 66, 85, 150, 0, 0, 0, true)
            end
            if dist < 4.0 then 
                DrawTopNotification("~INPUT_CONTEXT~ to select gamemode.")
                if IsControlJustPressed(0, 51) then 
                    Tse("gamemode:ConnectToGame", "PvP")
                    isGamemodeSelector = false
                    ArrangeControlsGameselector(false)
                    GM.Player.InSelecGamemode = false
                    ResetEntityAlpha(PlayerPedId())
                    SetEntityInvincible(PlayerPedId(), false)
                    _TriggerEvent("gamemode:OpenTeleporter", true)
                end
            end
        end
    end)

    if GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "boss" then 
        SetPedMoveRateOverride(PlayerId(), 10.0)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.70)
    end
end


function LeaveGamemode()
    -- SetBypassTeleport(true)
    LoadGamemodeSelection()
    Tse("gamemode:LeaveGamemode")
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    RequestCollisionAtCoord(-1267.074, -3021.941, -48.49023)
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        Citizen.Wait(0)
    end
    TeleportPlayerCoords(vector3(-1267.074, -3021.941, -48.49023), PlayerPedId(), true)
    SetEntityHeading(PlayerPedId(), 359.7063)
    local ped = PlayerPedId()
    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
    RemoveWeaponFromPed(ped, GetSelectedPedWeapon(ped))
    RemoveAllPedWeapons(PlayerPedId(), true)
    DoScreenFadeIn(1000)
    m_tblConfigFarm.canSpawn = false
    SetZombieCanSpawn(false)
    -- SetBypassTeleport(false)
end

RegisterCommand("lobby", function()
    if GM.Player.InFarm then return end
    if GM.Player.InSelecGamemode then return end
    if GM.Player.InLeague then return end
    if GM.Player.InFFA then return end
    if GM.Player.InGunrace then return end
    if GM.Player.Afk then return end
    if GM.Player.LeagueLobby then return ShowAboveRadarMessage("~r~You are in the league lobby. (/leaveleague)") end
    if GM.Player.InSafeZone then 
        m_tblConfigFarm.canSpawn = false
        SetZombieCanSpawn(false)
        LeaveGamemode()
    end
end)

RegisterCommand('zombie', function()
    if m_tblConfigFarm.canSpawn then 
        SetZombieCanSpawn(false)
        ShowAboveRadarMessage("~r~Zombies disabled")
    else
        SetZombieCanSpawn(true)
        ShowAboveRadarMessage("~g~Zombies enabled")
    end
end)

-- Citizen.CreateThread(function()
--     while true do

--         if (sfHandle ~= nil and not txdHasBeenSet) then
--             print('SET_TEXTURE')
--             PushScaleformMovieFunction(sfHandle, 'SET_TEXTURE')
        
--             PushScaleformMovieMethodParameterString('meows')
--             PushScaleformMovieMethodParameterString('woof')
        
--             PushScaleformMovieFunctionParameterInt(0)
--             PushScaleformMovieFunctionParameterInt(0)
--             PushScaleformMovieFunctionParameterInt(width)
--             PushScaleformMovieFunctionParameterInt(height)
        
--             PopScaleformMovieFunctionVoid()
        
--             txdHasBeenSet = true
--         end

--         if (sfHandle ~= nil and HasScaleformMovieLoaded(sfHandle)) then
--             DrawScaleformMovie_3dNonAdditive(sfHandle, testCoords.x, testCoords.y, testCoords.z+2, 0, 0, 0, 2, 2, 2, scale * 1, scale * (9/16), 1, 2)
--         end
--         Citizen.Wait(0)
--     end
-- end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        DestroyDui(duiObj)
        SetScaleformMovieAsNoLongerNeeded(sfName)
    end
end)
