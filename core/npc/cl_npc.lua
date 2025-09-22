ConfigNPC = {
    -- MARA 
    {
        safezone = "Marabunta",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(1138.745, -1498.667, 34.69251, 239.2315),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },
    -- HIGHWAY
    -- {
    --     pedType = 4,
    --     model = "s_m_m_pilot_02",
    --     pos = vector4(734.2469, -1196.956, 44.81728, 272.3087),
    --     weapon = "weapon_combatmg",
    --     action = function()
    --         _TriggerEvent("gamemode:OpenTeleporter")
    --     end,
    --     drawText = "[ ~r~SAFEZONES LIST ~s~]", 
    --     distanceLimit = 2.0,
    --     distanceShowText = 20.0,
    -- },
    -- MAIN
    {
        safezone = "Hospital",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(233.7666, -1404.769, 30.50321, 351.3157),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },
    -- BEACH
    {
        safezone = "Beach Safezone",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(-1082.350708, -1258.706421, 5.537984, 301.116302),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },
    -- AA
    {
        safezone = "Cross Field",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(1196.99, 1861.329, 77.89687, 251.2376),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },
    -- BLAINE
    {
        safezone = "Sandy Shores Safezone",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(2759.311, 3444.02, 55.97073, 75.04089),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },
     -- PALETO
    {
        safezone = "Hideout",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(1470.167, 6366.422, 23.66358, 228.0194),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },

    -- PALETO 2
    {
        safezone = "Paleto",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(-952.5654, 6193.058, 3.780329, 36.28586),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },

    {
        safezone = "Mountain",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(-423.8824, 1129.478, 325.8554, 167.5272),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },

    {
        safezone = "Main SafeZone",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(-533.7204, -211.5523, 37.6497, 123.432),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },

    {
        safezone = "Mirror Park",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(1363.372, -578.4102, 74.38044, 239.0983),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },

    {
        safezone = "depot",
        pedType = 4,
        model = "s_m_m_pilot_02",
        pos = vector4(765.50, -1416.97, 26.49, 0.22),
        weapon = "weapon_combatmg",
        action = function()
            _TriggerEvent("gamemode:OpenTeleporter")
        end,
        drawText = "[ ~r~SAFEZONES LIST ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },











    -- SAFEZONE MAIN  CUSTOM YOUR PEDS
    {
        safezone = "Hospital",
        pedType = 4,
        model = "a_f_y_smartcaspat_01",
        pos = vector4(217.9266, -1387.867, 30.58748, 317.2739),
        weapon = "weapon_combatmg",
        action = function()
            if not isOpened then 
                -- isOpened = true
                -- ArrangeControls(true)
                -- SendNUIMessage({
                --     type = "show-peds",
                -- })
                CustomizeSkin()
            end
        end,
        drawText = "[ ~r~CHARACTER CUSTOMIZER ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },
    -- SAFEZONE MARA CUSTOM YOUR PEDS
    {
        safezone = "Marabunta",
        pedType = 4,
        model = "a_f_y_smartcaspat_01",
        pos = vector4(1155.452, -1500.619, 34.69261, 91.40268),
        weapon = "weapon_combatmg",
        action = function()
            if not isOpened then 
                -- isOpened = true
                -- ArrangeControls(true)
                -- SendNUIMessage({
                --     type = "show-peds",
                -- })
                CustomizeSkin()
            end
        end,
        drawText = "[ ~r~CHARACTER CUSTOMIZER ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },

    -- SAFEZONE BEACH CUSTOM YOUR PEDS
    {
        safezone = "Beach Safezone",
        pedType = 4,
        model = "a_f_y_smartcaspat_01",
        pos = vector4(-1080.586426, -1262.343750, 5.681724, 307.064423),
        weapon = "weapon_combatmg",
        action = function()
            if not isOpened then 
                -- isOpened = true
                -- ArrangeControls(true)
                -- SendNUIMessage({
                --     type = "show-peds",
                -- })
                CustomizeSkin()
            end
        end,
        drawText = "[ ~r~CHARACTER CUSTOMIZER ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },
    -- SAFEZONE AA CUSTOM YOUR PEDS
    {
        safezone = "Cross Field",
        pedType = 4,
        model = "a_f_y_smartcaspat_01",
        pos = vector4(1198.729, 1863.711, 77.92052, 242.2285),
        weapon = "weapon_combatmg",
        action = function()
            if not isOpened then 
                -- isOpened = true
                -- ArrangeControls(true)
                -- SendNUIMessage({
                --     type = "show-peds",
                -- })
                CustomizeSkin()
            end
        end,
        drawText = "[ ~r~CHARACTER CUSTOMIZER ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },
    -- SAFEZONE BLAINE CUSTOM YOUR PEDS
    {
        safezone = "Sandy Shores Safezone",
        pedType = 4,
        model = "a_f_y_smartcaspat_01",
        pos = vector4(2770.042, 3469.488, 55.5353, 81.92973),
        weapon = "weapon_combatmg",
        action = function()
            if not isOpened then 
                -- isOpened = true
                -- ArrangeControls(true)
                -- SendNUIMessage({
                --     type = "show-peds",
                -- })
                CustomizeSkin()
            end
        end,
        drawText = "[ ~r~CHARACTER CUSTOMIZER ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },
    -- SAFEZONE PALETO CUSTOM YOUR PEDS
    {
        safezone = "Hideout" ,
        pedType = 4,
        model = "a_f_y_smartcaspat_01",
        pos = vector4(1474.324, 6351.431, 23.6548, 12.35538),
        weapon = "weapon_combatmg",
        action = function()
            if not isOpened then 
                -- isOpened = true
                -- ArrangeControls(true)
                -- SendNUIMessage({
                --     type = "show-peds",
                -- })
                CustomizeSkin()
            end
        end,
        drawText = "[ ~r~CHARACTER CUSTOMIZER ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },


    {
        safezone = "Paleto" ,
        pedType = 4,
        model = "a_f_y_smartcaspat_01",
        pos = vector4(-948.3592, 6195.265, 3.799379, 27.98007),
        weapon = "weapon_combatmg",
        action = function()
            if not isOpened then 
                -- isOpened = true
                -- ArrangeControls(true)
                -- SendNUIMessage({
                --     type = "show-peds",
                -- })
                CustomizeSkin()
            end
        end,
        drawText = "[ ~r~CHARACTER CUSTOMIZER ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },

    {
        safezone = "Mountain",
        pedType = 4,
        model = "a_f_y_smartcaspat_01",
        pos = vector4(-433.9989, 1132.583, 325.9047, 166.2406),
        weapon = "weapon_combatmg",
        action = function()
            if not isOpened then 
                -- isOpened = true
                -- ArrangeControls(true)
                -- SendNUIMessage({
                --     type = "show-peds",
                -- })
                CustomizeSkin()
            end 
        end,
        drawText = "[ ~r~CHARACTER CUSTOMIZER ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    },

    {
        safezone = "Main SafeZone",
        pedType = 4,
        model = "a_f_y_smartcaspat_01",
        pos = vector4(-520.5368, -225.8016, 36.5278, 57.03537),
        weapon = "weapon_combatmg",
        action = function()
            if not isOpened then 
                -- isOpened = true
                -- ArrangeControls(true)
                -- SendNUIMessage({
                --     type = "show-peds",
                -- })
                CustomizeSkin()
            end
        end,
        drawText = "[ ~r~CHARACTER CUSTOMIZER ~s~]",
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
}

ConfigBlips = {
    -- vector3(1138.653, -1498.76, 34.69262)

    {
        sprite = 280,
        color = 2,
        pos = vector3(723.1542, -2083.688, 28.29166), 
    },
    {
        sprite = 280,
        color = 2,
        pos = vector3(1221.742, 1870.031, 77.89737), 
    },
    {
        sprite = 280,
        color = 2,
        pos = vector3(1138.653, -1498.76, 34.69262), 
    },
    {
        sprite = 280,
        color = 2,
        pos = vector3(734.3512, -1196.957, 44.81839), 
    },
    {
        sprite = 280,
        color = 2,
        pos = vector3(186.4234, -934.3836, 29.68687), 
    },
    {
        sprite = 280,
        color = 2,
        pos = vector3(-1088.774, -1633.517, 3.73274), 
    },
    {
        sprite = 280,
        color = 2,
        pos = vector3(1283.275, -2559.392, 42.91526), 
    },
    {
        sprite = 280,
        color = 2,
        pos = vector3(1532.644, 1718.88, 109.0079), 
    },
    {
        sprite = 280,
        color = 2,
        pos = vector3(2736.932, 3436.738, 55.41888), 
    },
    {
        sprite = 280,
        color = 2,
        pos = vector3(1470.242, 6366.331, 22.66782), 
    },


    --- PED CUSTOM
    {
        sprite = 480,
        color = 50,
        pos = vector3(203.5946, -946.4703, 29.69989)
    },


    -- CHEST 

    {
        sprite = 587,
        color = 28,
        pos = vector3(190.0687, -930.4805, 30.68683)
    },
    {
        sprite = 587,
        color = 28,
        pos = vector3(-1075.861, -1648.739, 3.501214)
    },

    {
        sprite = 587,
        color = 28,
        pos = vector3(1259.654, -2574.112, 41.91989)
    },
    {
        sprite = 587,
        color = 28,
        pos = vector3(1530.909, 1700.689, 108.7976)
    },
    {
        sprite = 587,
        color = 28,
        pos = vector3(2764.38, 3458.979, 54.73006)
    },
    {
        sprite = 587,
        color = 28,
        pos = vector3(1469.194, 6365.903, 21.99999)
    },
}


Citizen.CreateThread(function()
    for k,v in pairs(ConfigNPC) do
        RegisterSafeZonePedAction(v)
    end

    for k, v in pairs(ConfigBlips) do
        CreateCBlip(v.pos, v.sprite, v.color, "", false, 1.0, 5, 200)
    end
end)