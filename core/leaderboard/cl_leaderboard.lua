local function loadScaleform(scaleform)
    local scaleformHandle = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleformHandle) do
        print("waiting scaleform", scaleform)
        Citizen.Wait(0) 
    end
    print("scaleform loaded", scaleform)
    return scaleformHandle
end

local duiUrl = "https://cfx-nui-gamemode/ui/leaderboard.html"
local scale = 0.15
local sfName = 'generic_texture_renderer'
local sfName2 = 'generic_texture_renderer_2'
local width = 1240
local height = 1487
local sfHandle = nil
local duiObj = nil


local pos = vector3(243.8252, -1399.588, 30.53009 + 3.5)

-- vector4(16.94205, -648.6871, 16.0881, 327.7849)

local w, h = 512, 512
local sleep
-- CreateThread(function()
--     Wait(5000)
--     while not GM.Init do Wait(5) end
--     sfHandle = loadScaleform(sfName)

--     local txd = CreateRuntimeTxd('meows')

--     duiObj = CreateDui(duiUrl, width, height)

--     local dui = GetDuiHandle(duiObj)
--     local tx = CreateRuntimeTextureFromDuiHandle(txd, 'woof', dui)

--     PushScaleformMovieFunction(sfHandle, 'SET_TEXTURE')

--     PushScaleformMovieMethodParameterString('meows')
--     PushScaleformMovieMethodParameterString('woof')

--     PushScaleformMovieFunctionParameterInt(0)
--     PushScaleformMovieFunctionParameterInt(0)
--     PushScaleformMovieFunctionParameterInt(width)
--     PushScaleformMovieFunctionParameterInt(height)

--     PopScaleformMovieFunctionVoid()

--     print("Leaderboard loading...")

--     Wait(2500)


--     local result = CallbackServer("zoliax:getLeaderboard")
--     if result then 
--         SendDuiMessage(duiObj, json.encode({
--             type = "updateLeaderboard",
--             pistol = result.pistol,
--             freeroam = result.freeroam,
--             convoy = result.convoy,
--         }))
--     end

--     while true do
--         local pCoords = GetEntityCoords(PlayerPedId())
--         sleep = 1000

--         if GM.Player.InSafeZone then
--             sleep = 0

--             DrawScaleformMovie_3dNonAdditive(sfHandle, pos.x, pos.y, pos.z, 0.0, 120.0, 0.0, 0, 0, 0, scale * 2.5, scale * (25/35), 1, 2)
--         end

--         Wait(sleep)
--     end
-- end)

RegisterCommand("debug_safe", function()
    DestroyDui(duiObj)
    SetScaleformMovieAsNoLongerNeeded(sfHandle)
    duiObj = nil
    sfHandle = nil
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    DestroyDui(duiObj)
    SetScaleformMovieAsNoLongerNeeded(sfHandle)
    duiObj = nil
    sfHandle = nil
end)