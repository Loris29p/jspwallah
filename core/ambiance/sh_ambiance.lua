AmbianceConfig = {
    active = false,
    List = {
        {
            ped = "a_m_y_hipster_01", -- Or any other ped model you prefer
            pos = vector4(24.318, -652.8655, 16.08804, 230.3206), -- Example coordinates
            animation = {
                dict = "special_ped@mountain_dancer@monologue_3@monologue_3a",
                name = "mnt_dnc_buttwag"
            },
            effects = {
                dict = "scr_indep_fireworks", -- Leave empty if no effects needed
                name = "scr_indep_firework_fountain",
                looping = true
            },
            distanceLimit = 50.0, -- Only show when player is within 50 units
            safezoneId = "Hospital",
        }
    }
}