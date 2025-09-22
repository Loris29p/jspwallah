local badgeMenu = false

RegisterCommand("badges", function(source, args)
    if GM.Player.Data["badge"] then
        if GM.Player.Data["badge"].access then
            if not badgeMenu then
                badgeMenu = true
                SendNUIMessage({
                    action = "toggleBadgeContainer",
                    show = true
                })
                SetNuiFocus(true, true)
                SetCursorLocation(0.5, 0.5)
            end
        end
    end
end)

RegisterNUICallback("closeMenuBadge", function(data, cb)
    badgeMenu = false
    SetNuiFocus(false, false)
end)



RegisterNUICallback("equipBadge", function(data, cb)
    local badge = data.badge
    Tse("equipBadge", badge)
end)

RegisterNUICallback("removeBadge", function(data, cb)
    Tse("removeBadge")
end)



Citizen.CreateThread(function()
    local NPC_Badge = {
        safezone = "Hospital",
        pedType = 4,
        model = "ig_milton",
        pos = vector4(238.2035, -1406.479, 30.58436, 325.7118),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if GM.Player.Data["badge"] then
                    if GM.Player.Data["badge"].access then
                        if not badgeMenu then
                            badgeMenu = true
                            SendNUIMessage({
                                action = "toggleBadgeContainer",
                                show = true
                            })
                            SetNuiFocus(true, true)
                            SetCursorLocation(0.5, 0.5)
                        end
                    end
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open badges menu")
            end
        end,
        drawText = "[ ~r~BADGES ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Badge)

    local NPC_Badge_Mara = {
        safezone = "Marabunta",
        pedType = 4,
        model = "ig_milton",
        pos = vector4(1141.08, -1489.753, 34.69257, 269.1483),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if GM.Player.Data["badge"] then
                    if GM.Player.Data["badge"].access then
                        if not badgeMenu then
                            badgeMenu = true
                            SendNUIMessage({
                                action = "toggleBadgeContainer",
                                show = true
                            })
                            SetNuiFocus(true, true)
                            SetCursorLocation(0.5, 0.5)
                        end
                    end
                else 
                    ShowAboveRadarMessage("~r~You don't have access to badges")
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open badges menu")
            end
        end,
        drawText = "[ ~r~BADGES ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Badge_Mara)


    local NPC_Badge_Main = {
        safezone = "Main SafeZone",
        pedType = 4,
        model = "ig_milton",
        pos = vector4(-526.9844, -228.5986, 36.70222, 34.40978),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if GM.Player.Data["badge"] then
                    if GM.Player.Data["badge"].access then
                        if not badgeMenu then
                            badgeMenu = true
                            SendNUIMessage({
                                action = "toggleBadgeContainer",
                                show = true
                            })
                            SetNuiFocus(true, true)
                            SetCursorLocation(0.5, 0.5)
                        end
                    end
                else 
                    ShowAboveRadarMessage("~r~You don't have access to badges. Buy it on tebex.")
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open badges menu")
            end
        end,
        drawText = "[ ~r~BADGES ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_Badge_Main)

    local NPC_Badge_Paleto = {
        safezone = "Paleto",
        pedType = 4,
        model = "ig_milton",
        pos = vector4(-945.5768, 6192.807, 3.847874, 32.44751),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if GM.Player.Data["badge"] then
                    if GM.Player.Data["badge"].access then
                        if not badgeMenu then
                            badgeMenu = true
                            SendNUIMessage({
                                action = "toggleBadgeContainer",
                                show = true
                            })
                            SetNuiFocus(true, true)
                            SetCursorLocation(0.5, 0.5)
                        end
                    end
                else 
                    ShowAboveRadarMessage("~r~You don't have access to badges. Buy it on tebex.")
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open badges menu")
            end
        end,
        drawText = "[ ~r~BADGES ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_Badge_Paleto)


    local NPC_Badge_Mountain = {
        safezone = "Mountain",
        pedType = 4,
        model = "ig_milton",
        pos = vector4(-427.6907, 1135.414, 325.9049, 166.9867),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if GM.Player.Data["badge"] then
                    if GM.Player.Data["badge"].access then
                        if not badgeMenu then
                            badgeMenu = true
                            SendNUIMessage({
                                action = "toggleBadgeContainer",
                                show = true
                            })
                            SetNuiFocus(true, true)
                            SetCursorLocation(0.5, 0.5)
                        end
                    end
                else 
                    ShowAboveRadarMessage("~r~You don't have access to badges. Buy it on tebex.")
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open badges menu")
            end
        end,
        drawText = "[ ~r~BADGES ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_Badge_Mountain)

    local NPC_Badge_Mirror = {
        safezone = "Mirror Park",
        pedType = 4,
        model = "ig_milton",
        pos = vector4(1361.861, -582.9445, 74.3802, 257.9062),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if GM.Player.Data["badge"] then
                    if GM.Player.Data["badge"].access then
                        if not badgeMenu then
                            badgeMenu = true
                            SendNUIMessage({
                                action = "toggleBadgeContainer",
                                show = true
                            })
                            SetNuiFocus(true, true)
                            SetCursorLocation(0.5, 0.5)
                        end
                    end
                else 
                    ShowAboveRadarMessage("~r~You don't have access to badges. Buy it on tebex.")
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open badges menu")
            end
        end,
        drawText = "[ ~r~BADGES ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Badge_Mirror)


    local NPC_Badge_Depot = {
        safezone = "depot",
        pedType = 4,
        model = "ig_milton",
        pos = vector4(770.26, -1416.84, 26.47, 343.57),
        
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                if GM.Player.Data["badge"] then
                    if GM.Player.Data["badge"].access then
                        if not badgeMenu then
                            badgeMenu = true
                            SendNUIMessage({
                                action = "toggleBadgeContainer",
                                show = true
                            })
                            SetNuiFocus(true, true)
                            SetCursorLocation(0.5, 0.5)
                        end
                    end
                else 
                    ShowAboveRadarMessage("~r~You don't have access to badges. Buy it on tebex.")
                end
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open badges menu")
            end
        end,
        drawText = "[ ~r~BADGES ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_Badge_Depot)
end)