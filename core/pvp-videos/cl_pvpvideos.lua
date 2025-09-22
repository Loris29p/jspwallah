local url = "https://cfx-nui-gamemode/ui/video-rzpvp.html"

local scale = 0.13
local sfName = 'generic_texture_renderer_3'

local width = 1550
local height = 1020

local sfHandle2 = nil
local txdHasBeenSet = false
local duiObj2 = nil
local txdName = 'meows'
local txdTexture = 'woof'

local testCoords = vector3(-1271.84, -3026.137, -48.49021)
local author = false

function loadScaleform(scaleform)
    local scaleformHandle = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleformHandle) do 
        scaleformHandle = RequestScaleformMovie(scaleform)
        Citizen.Wait(0) 
    end
    return scaleformHandle
end

function InitializeYouTubePlayer(pos)
    sfHandle2 = loadScaleform(sfName)
    local txd = CreateRuntimeTxd(txdName) 
    
    if duiObj2 == nil then
        duiObj2 = CreateDui(url, width, height)
        
        Citizen.Wait(500)
        
        local dui = GetDuiHandle(duiObj2)
        if dui then
            local tx = CreateRuntimeTextureFromDuiHandle(txd, txdTexture, dui)
        end
    end
    
    txdHasBeenSet = false

    Citizen.CreateThread(function()
        while sfHandle2 do
            if (sfHandle2 ~= nil and not txdHasBeenSet) then
                print('Définition de la texture dans le scaleform')
                PushScaleformMovieFunction(sfHandle2, 'SET_TEXTURE')
            
                PushScaleformMovieMethodParameterString(txdName)
                PushScaleformMovieMethodParameterString(txdTexture)
            
                PushScaleformMovieFunctionParameterInt(0)
                PushScaleformMovieFunctionParameterInt(0)
                PushScaleformMovieFunctionParameterInt(width)
                PushScaleformMovieFunctionParameterInt(height)
            
                PopScaleformMovieFunctionVoid()
            
                txdHasBeenSet = true
            end
    
            if (sfHandle2 ~= nil and HasScaleformMovieLoaded(sfHandle2)) then
                DrawScaleformMovie_3dNonAdditive(sfHandle2, pos.x, pos.y, pos.z+2, 0, 0, 0, 2, 2, 2, scale * 1, scale * (9/16), 1, 2)
            end
            Citizen.Wait(0)
        end
    end)
end

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        if duiObj2 ~= nil then
            DestroyDui(duiObj2)
            duiObj2 = nil
        end
        if sfHandle2 ~= nil then
            SetScaleformMovieAsNoLongerNeeded(sfHandle2)
            sfHandle2 = nil
        end
    end
end)

_RegisterNetEvent('pvp-videos:loadVideosYoutube', function(pos, link)
    print(pos, link)
    if duiObj2 ~= nil then return end
    if sfHandle2 ~= nil then return end
    print("Avant Load fonction")
    LoadVideosYoutube(pos, link)
end)

function LoadVideosYoutube(pos, link)
    local videoId = link
    if sfHandle2 == nil or duiObj2 == nil then
        InitializeYouTubePlayer(pos)
        Citizen.Wait(1500)
    end
    
    if duiObj2 ~= nil then
        SendDuiMessage(duiObj2, json.encode({
            type = "displayYouTubeVideo",
            videoId = videoId,
        }))
    end
end

function UnloadVideosYoutube()
    if duiObj2 ~= nil then
        SendDuiMessage(duiObj2, json.encode({
            type = "stopYouTubeVideo"
        }))
        if duiObj2 ~= nil then
            DestroyDui(duiObj2)
            duiObj2 = nil
        end
        if sfHandle2 ~= nil then
            SetScaleformMovieAsNoLongerNeeded(sfHandle2)
            sfHandle2 = nil
        end
    end
end

_RegisterNetEvent('pvp-videos:unloadVideosYoutube', function()
    UnloadVideosYoutube()
end)

RegisterCommand("ytb", function(source, args)
    if not GM.Player.InSafeZone then return  end
    if GM.Player.InSelecGamemode then return end
    if GM.Player.Role ~= "mvp" and GM.Player.Role ~= "god" then return end
    if sfHandle2 ~= nil then return end
    if duiObj2 ~= nil then return end
    local videoId = args[1]
    local pos = GetEntityCoords(PlayerPedId())
    Tse("pvpvideos:loadVideosEveryone", {videoId = videoId, pos = pos})
    author = true
end)

RegisterCommand("stopytb", function(source, args)
    if not GM.Player.InSafeZone then return  end
    if GM.Player.InSelecGamemode then return end
    if GM.Player.Role ~= "mvp" and GM.Player.Role ~= "god" then return end
    if author then 
        author = false
        Tse("pvpvideos:unloadVideosEveryone")
    end
end)