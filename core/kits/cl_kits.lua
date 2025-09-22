CreateThread(function()
    Wait(1000)
    _TriggerEvent('chat:addSuggestion', '/kit', 'Choose your kit', {
        { name = 'kit', help = 'starterkit, dailykit, gold, zombie, diamond' }
    })
end)

local isMenuOpen = false
local kitData = {}
local kitTimers = {}
local playerRoles = nil

function OpenKitMenu()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then 
        if isMenuOpen then return end
        isMenuOpen = true

        Tse('kits:requestData')
    else 
        ShowAboveRadarMessage("~r~You cannot open the kit menu in a vehicle")
    end
end

RegisterNUICallback('closeKitMenu', function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('claimKit', function(data, cb)
    Tse('kits:claimKit', data.kitName)
    cb('ok')
end)

_RegisterNetEvent('kits:receiveData',function(data)
    kitData = data.kits
    kitTimers = data.timers
    playerRole = data.playerRole
    playerRoles = data.playerRoles
    playerUuid = data.playerUuid

    SendNUIMessage({
        type = "openKitsMenu",
        kitsData = kitData,
        kitTimers = kitTimers,
        playerRole = playerRole,
        playerRoles = playerRoles,
        playerUuid = playerUuid
    })
    
    SetNuiFocus(true, true)
end)

_RegisterNetEvent('kits:updateKitTimer', function(kitName, newTime)
    kitTimers[kitName] = newTime
    
    SendNUIMessage({
        type = "updateKitTimer",
        kitName = kitName,
        newTime = newTime
    })
end)

_RegisterNetEvent('kits:closeMenu', function()
    isMenuOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        type = "closeKitsMenu"
    })
end)