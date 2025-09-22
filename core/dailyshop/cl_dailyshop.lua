_RegisterNetEvent("dailyshop:setInformations", function(value)
    dailyshop.ActualShop = value
    Logger:info("DAILY SHOP", "Shop is set")
end)


RegisterNUICallback("GetDailyShop", function(data, cb)
    cb(dailyshop.ActualShop)
end)

RegisterNUICallback("BuyDaily", function(data, cb)
    if GM.Player.InSafeZone then 
        Tse("dailyshop:BuyDaily", data.id)
    else
        return ShowAboveRadarMessage("~r~You must be in a safe zone to buy in the daily shop", 2)
    end
end)


RegisterNUICallback("GetMySkins", function(data, cb)
    cb(GM.Player.Data)
end)

RegisterNUICallback("EquipSkin", function(data, cb)
    if GM.Player.InSafeZone then 
        if data.id == "mp_f_freemode_01" or data.id == "mp_m_freemode_01" then
            changeModel(data.id)
        else
            for k, v in pairs(GM.Player.Data["peds"]) do
                if v.id == data.id then
                    changeModel(v.model)
                    break
                end
            end
        end
    else
        return ShowAboveRadarMessage("~r~You must be in a safe zone to equip a skin", 2)
    end
end)  

RegisterNUICallback("OldSkin", function(data, cb)
    if GM.Player.InSafeZone then 
        _TriggerEvent("skinchanger:loadSkin", GM.Player.Skin)
    else
        return ShowAboveRadarMessage("~r~You must be in a safe zone to equip a skin", 2)
    end
end)

local oldCoords = nil
isCustomizing = false
exports("isCustomizing", function()
    return isCustomizing
end)

function CustomizeSkin()
    if not GM.Player.InSafeZone then 
        return ShowAboveRadarMessage("~r~You must be in a safe zone to customize your skin", 2)
    end
    isCustomizing = true


    DoScreenFadeOut(2000)
    Citizen.Wait(2000)
    oldCoords = GetEntityCoords(PlayerPedId())
    RequestCollisionAtCoord(-783.5693, 336.8892, 216.8511)
    TeleportPlayerCoords(vector3(-783.5693, 336.8892, 216.8511), PlayerPedId(), false)
    local headingT = 240.3475
    SetEntityHeading(PlayerPedId(), headingT)
    Tse("PREFIX_PLACEHOLDER:custom:Skin", "enter")
    DoScreenFadeIn(2000)

    local config = {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        allowExit = true,
        tattoos = true
      }
    
      exports['fivem-appearance']:startPlayerCustomization(function (appearance)
        if (appearance) then
          Tse("gamemode:saveAppearance", appearance)
          DoScreenFadeOut(2000)
          Citizen.Wait(2000)
          TeleportPlayerCoords(oldCoords, PlayerPedId(), true)
          Tse("PREFIX_PLACEHOLDER:custom:Skin", "leave")
          DoScreenFadeIn(2000)
          isCustomizing = false
        else
          DoScreenFadeOut(2000)
          Citizen.Wait(2000)
          TeleportPlayerCoords(oldCoords, PlayerPedId(), true)
          Tse("PREFIX_PLACEHOLDER:custom:Skin", "leave")
          DoScreenFadeIn(2000)
          isCustomizing = false
        end
      end, config)
end

RegisterNUICallback("CustomizeSkin", function()
    if not GM.Player.InSafeZone then 
        return ShowAboveRadarMessage("~r~You must be in a safe zone to customize your skin", 2)
    end
    isCustomizing = true


    DoScreenFadeOut(2000)
    Citizen.Wait(2000)
    oldCoords = GetEntityCoords(PlayerPedId())
    RequestCollisionAtCoord(-783.5693, 336.8892, 216.8511)
    TeleportPlayerCoords(vector3(-783.5693, 336.8892, 216.8511), PlayerPedId(), false)
    local headingT = 240.3475
    SetEntityHeading(PlayerPedId(), headingT)
    Tse("PREFIX_PLACEHOLDER:custom:Skin", "enter")
    DoScreenFadeIn(2000)

    local config = {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        allowExit = true,
        tattoos = true
      }
    
      exports['fivem-appearance']:startPlayerCustomization(function (appearance)
        if (appearance) then
          Tse("gamemode:saveAppearance", appearance)
          DoScreenFadeOut(2000)
          Citizen.Wait(2000)
          TeleportPlayerCoords(oldCoords, PlayerPedId(), true)
          Tse("PREFIX_PLACEHOLDER:custom:Skin", "leave")
          DoScreenFadeIn(2000)
          isCustomizing = false
        else
          DoScreenFadeOut(2000)
          Citizen.Wait(2000)
          TeleportPlayerCoords(oldCoords, PlayerPedId(), true)
          Tse("PREFIX_PLACEHOLDER:custom:Skin", "leave")
          DoScreenFadeIn(2000)
          isCustomizing = false
        end
      end, config)
end)

function changeModel(skin)
	local model = GetHashKey(skin)
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetPedDefaultComponentVariation(PlayerPedId())
        SetModelAsNoLongerNeeded(model)
    end
end