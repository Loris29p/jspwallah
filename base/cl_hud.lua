

Citizen.CreateThread(function()
    while true do 
        local timer = 1000  
        if Settings["hud_life"] then
            timer = 100
            SendNUIMessage({
                type = "updateStatus",
                armor = math.floor(GetPedArmour(PlayerPedId())) ,
                health = (math.floor(GetEntityHealth(PlayerPedId())) / 2),
            })
            SendNUIMessage({
                type = "showHud",
                show = true,
            })
        else 
            SendNUIMessage({
                type = "showHud",
                show = false,
            })
        end
        -- timer = 100
        -- SendNUIMessage({
        --     type = "updateStatus",
        --     armor = math.floor(GetPedArmour(PlayerPedId())) ,
        --     health = (math.floor(GetEntityHealth(PlayerPedId())) / 2),
        -- })
        -- SendNUIMessage({
        --     type = "showHud",
        --     show = true,
        -- })
        Citizen.Wait(timer)
    end
end)

local HUD_ELEMENTS = {
    HUD = { id = 0, hidden = false },
    HUD_WANTED_STARS = { id = 1, hidden = true },
    HUD_WEAPON_ICON = { id = 2, hidden = false },
    HUD_CASH = { id = 3, hidden = true },
    HUD_MP_CASH = { id = 4, hidden = true },
    HUD_MP_MESSAGE = { id = 5, hidden = true },
    HUD_VEHICLE_NAME = { id = 6, hidden = true },
    HUD_AREA_NAME = { id = 7, hidden = true },
    HUD_VEHICLE_CLASS = { id = 8, hidden = true },
    HUD_STREET_NAME = { id = 9, hidden = true },
    HUD_HELP_TEXT = { id = 10, hidden = false },
    HUD_FLOATING_HELP_TEXT_1 = { id = 11, hidden = false },
    HUD_FLOATING_HELP_TEXT_2 = { id = 12, hidden = false },
    HUD_CASH_CHANGE = { id = 13, hidden = true },
    HUD_SUBTITLE_TEXT = { id = 15, hidden = false },
    HUD_RADIO_STATIONS = { id = 16, hidden = false },
    HUD_SAVING_GAME = { id = 17, hidden = false },
    HUD_GAME_STREAM = { id = 18, hidden = false },
    MAX_SCRIPTED_HUD_COMPONENTS = { id = 141, hidden = false }
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for key, val in pairs(HUD_ELEMENTS) do
            if val.hidden then
                HideHudComponentThisFrame(val.id)
            else
                ShowHudComponentThisFrame(val.id)
            end
        end
    end
end)
