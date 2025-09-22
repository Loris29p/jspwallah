local tebexMenu = false

RegisterCommand("tebex", function(source, args, rawCommand)
    if not tebexMenu then
        tebexMenu = true
        SendNUIMessage({
            action = "tebex-site",
            show = true
        })
        SetNuiFocus(true, true)
        SetCursorLocation(0.5, 0.5)
    else 
        tebexMenu = false
        SendNUIMessage({
            action = "tebex-site",
            show = false
        })
        SetNuiFocus(false, false)
    end
end)

RegisterNUICallback("CloseTebex", function(data, cb)
    tebexMenu = false
    SendNUIMessage({
        action = "tebex-site",
        show = false
    })
    SetNuiFocus(false, false)
end)


Citizen.CreateThread(function()
    local NPC_Tebex = {
        safezone = "Hospital",
        pedType = 4,
        model = "csb_tomcasino",
        pos = vector4(242.2206, -1400.728, 30.56372, 57.54866),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if not tebexMenu then
                    tebexMenu = true
                    SendNUIMessage({
                        action = "tebex-site",
                        show = true
                    })
                    SetNuiFocus(true, true)
                    SetCursorLocation(0.5, 0.5)
                else 
                    tebexMenu = false
                    SendNUIMessage({
                        action = "tebex-site",
                        show = false
                    })
                    SetNuiFocus(false, false)
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open tebex menu")
            end
        end,
        drawText = "[ ~r~TEBEX ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Tebex)

    local NPC_Tebex_Mara = {
        safezone = "Marabunta",
        pedType = 4,
        model = "csb_tomcasino",
        pos = vector4(1153.552, -1489.702, 34.6926, 95.4127),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if not tebexMenu then
                    tebexMenu = true
                    SendNUIMessage({
                        action = "tebex-site",
                        show = true
                    })
                    SetNuiFocus(true, true)
                    SetCursorLocation(0.5, 0.5)
                else 
                    tebexMenu = false
                    SendNUIMessage({
                        action = "tebex-site",
                        show = false
                    })
                    SetNuiFocus(false, false)
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open tebex menu")
            end
        end,
        drawText = "[ ~r~TEBEX ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Tebex_Mara)

    local NPC_Tebex_Main = {
        safezone = "Main SafeZone",
        pedType = 4,
        model = "csb_tomcasino",
        pos = vector4(-544.0743, -217.4347, 37.64981, 302.5757),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if not tebexMenu then
                    tebexMenu = true
                    SendNUIMessage({
                        action = "tebex-site",
                        show = true
                    })
                    SetNuiFocus(true, true)
                    SetCursorLocation(0.5, 0.5)
                else 
                    tebexMenu = false
                    SendNUIMessage({
                        action = "tebex-site",
                        show = false
                    })
                    SetNuiFocus(false, false)
                end
            end
        end,
        drawText = "[ ~r~TEBEX ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_Tebex_Main)


    local NPC_Tebex_Paleto = {
        safezone = "Paleto",
        pedType = 4,
        model = "csb_tomcasino",
        pos = vector4(-949.0697, 6190.79, 3.847764, 29.2433),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if not tebexMenu then
                    tebexMenu = true
                    SendNUIMessage({
                        action = "tebex-site",
                        show = true
                    })
                    SetNuiFocus(true, true)
                    SetCursorLocation(0.5, 0.5)
                else 
                    tebexMenu = false
                    SendNUIMessage({
                        action = "tebex-site",
                        show = false
                    })
                    SetNuiFocus(false, false)
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open tebex menu")
            end
        end,
        drawText = "[ ~r~TEBEX ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_Tebex_Paleto)

    local NPC_Tebex_Mountain = {
        safezone = "Mountain",
        pedType = 4,
        model = "csb_tomcasino",
        pos = vector4(-420.6338, 1134.073, 325.8709, 171.5657),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if not tebexMenu then
                    tebexMenu = true
                    SendNUIMessage({
                        action = "tebex-site",
                        show = true
                    })
                    SetNuiFocus(true, true)
                    SetCursorLocation(0.5, 0.5)
                else 
                    tebexMenu = false
                    SendNUIMessage({
                        action = "tebex-site",
                        show = false
                    })
                    SetNuiFocus(false, false)
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open tebex menu")
            end
        end,
        drawText = "[ ~r~TEBEX ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_Tebex_Mountain)

    local NPC_Tebex_Mirror = {
        safezone = "Mirror Park",
        pedType = 4,
        model = "csb_tomcasino",
        pos = vector4(1360.92, -584.4578, 74.36537, 246.7128),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if not tebexMenu then
                    tebexMenu = true
                    SendNUIMessage({
                        action = "tebex-site",
                        show = true
                    })
                    SetNuiFocus(true, true)
                    SetCursorLocation(0.5, 0.5)
                else 
                    tebexMenu = false
                    SendNUIMessage({
                        action = "tebex-site",
                        show = false
                    })
                    SetNuiFocus(false, false)
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open tebex menu")
            end
        end,
        drawText = "[ ~r~TEBEX ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Tebex_Mirror)

    local NPC_Tebex_Depot = {
        safezone = "depot",
        pedType = 4,
        model = "csb_tomcasino",
        pos = vector4(772.77, -1417.03, 26.58, 356.20),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if not tebexMenu then
                    tebexMenu = true
                    SendNUIMessage({
                        action = "tebex-site",
                        show = true
                    })
                    SetNuiFocus(true, true)
                    SetCursorLocation(0.5, 0.5)
                else 
                    tebexMenu = false
                    SendNUIMessage({
                        action = "tebex-site",
                        show = false
                    })
                    SetNuiFocus(false, false)
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open tebex menu")
            end
        end,
        drawText = "[ ~r~TEBEX ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Tebex_Depot)
end)