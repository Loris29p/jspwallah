Gunrace = {
    limitPlayers = 10,
    maps = {
        {
            coords = vec4(259.367065, 119.727547, 100.999886, 338.272980),
            name = "Downtown Arena",
            respawn = { 
            vec4(232.904083, 130.694946, 102.599854, 220.178177), 
            vec4(237.749695, 113.927681, 102.628593, 299.497040), 
            vec4(374.189789, 162.972824, 103.109360, 110.047226),
            vec4(354.310425, 171.363953, 103.100586, 160.195908),
            vec4(339.519073, 174.029099, 103.144081, 156.483795),
            vec4(312.560760, 173.704742, 103.888191, 141.556122),
            vec4(315.697723, 134.166275, 103.565903, 340.891479),
            vec4(334.297058, 120.020180, 104.307144, 250.081543),
            vec4(328.822235, 96.713615, 99.873138, 251.558746),
            vec4(358.124054, 73.051849, 97.784691, 72.953682),
            vec4(316.763214, 68.142410, 94.361610, 95.957809),
            vec4(289.554688, 60.642670, 94.376472, 330.166809),
            vec4(280.193207, 87.804008, 94.359375, 158.565247),
            vec4(240.236511, 85.640823, 92.794228, 253.703751),
            vec4(248.333466, 70.900864, 89.930244, 77.747002),
            vec4(237.140045, 79.618698, 87.919334, 75.047768),
            vec4(248.801910, 27.449995, 84.123077, 67.541374),
            vec4(239.523422, 5.245995, 81.702049, 64.884521),
            vec4(212.579300, 19.985617, 79.373848, 276.681152),
            vec4(200.261810, 25.456789, 73.433556, 74.311668),
            vec4(177.284378, 57.166061, 83.623390, 0.881345),
            vec4(139.230835, 86.689949, 83.204605, 256.249451),
            vec4(141.416977, 133.601624, 96.592049, 250.615601),
            vec4(167.862625, 144.992966, 100.889549, 249.253601),
            vec4(174.621414, 186.385025, 105.679611, 264.330383),
            vec4(195.296844, 221.114319, 105.581543, 218.248154),
            vec4(229.182358, 224.357864, 105.548370, 156.240097),
            vec4(237.687592, 214.123428, 106.286629, 86.225899),
            vec4(261.247925, 197.737717, 104.912590, 164.763351),
            },
            radius = 130.0,
        },
        {
            coords = vec4(1436.87, 1107.94, 114.09, 338.272980),
            name = "Madrazo",
            respawn = { 
            vec4(1460.66, 1087.53, 114.33, 220.178177), 
            vec4(1442.26, 1156.75, 114.33, 299.497040), 
            vec4(1338.58, 1144.47, 112.54, 110.047226),
            vec4(1491.59, 1102.58, 114.33, 160.195908),
            vec4(1530.67, 1055.08, 111.15, 156.483795),
            vec4(1396.11, 1042.63, 114.33, 141.556122),
            vec4(1408.64, 1084.62, 114.33, 340.891479),
            vec4(1411.08, 1129.09, 114.33, 250.081543),
            vec4(1390.84, 1179.30, 114.34, 251.558746),
            vec4(1389.68, 1155.59, 114.34, 72.953682),
            vec4(1400.20, 1215.61, 109.35, 95.957809),
            vec4(1492.13, 1212.43, 113.05, 330.166809),
            },
            radius = 130.0,
        },
        {
            coords = vec4(-1672.74, -1094.57, 18.07, 328.941),
            name = "Fête foraine",
            respawn = {
                vec4(-1619.28, -1100.90, 13.02, 328.941),
                vec4(-1677.34, -1168.17, 13.02, 148.583),
                vec4(-1712.15, -1129.60, 13.16, 238.110),
                vec4(-1728.18, -1098.05, 13.03, 58.724),
                vec4(-1686.76, -1040.61, 13.02, 148.583),
                vec4(-1644.24, -1037.77, 13.15, 238.110),
                vec4(-1608.65, -1011.71, 13.02, 328.941),
                vec4(-1593.53, -1070.62, 13.02, 58.724),
                vec4(-1658.71, -1128.66, 13.02, 148.583),
            },
            radius = 90.0,
        },
    },
    -- Structure pour le gungame - progression par kills
    gungameWeapons = {
        -- Niveau 1: 0 kills
        {
            weapon = "weapon_pistol",
            killsRequired = 0,
            ammo = 12,
        },
        -- Niveau 2: 2 kills
        {
            weapon = "weapon_smg",
            killsRequired = 2,
            ammo = 30,
        },
        -- Niveau 3: 4 kills
        {
            weapon = "weapon_snspistol_mk2",
            killsRequired = 4,
            ammo = 30,
        },

        {
            weapon = "weapon_tacticalrifle",
            killsRequired = 8,
            ammo = 30,
        },
        -- Niveau 5: 8 kills
        {
            weapon = "weapon_assaultrifle",
            killsRequired = 12,
            ammo = 30,
        },
        -- Niveau 6: 10 kills - Arme finale
        {
            weapon = "weapon_specialcarbine_mk2",
            killsRequired = 16,
            ammo = 301,
        },
        {
            weapon = "weapon_bullpuprifle_mk2",
            killsRequired = 20,
            ammo = 30,
        },
        {
            weapon = "weapon_specialcarbine",
            killsRequired = 25,
            ammo = 30,
        },
        {
            weapon = "weapon_mg",
            killsRequired = 28,
            ammo = 200,
        },
        {
            weapon = "weapon_combatmg",
            killsRequired = 32,
            ammo = 200,
        },
        {
            weapon = "weapon_heavyshotgun",
            killsRequired = 34,
            ammo = 30,
        },
        {
            weapon = "weapon_heavysniper",
            killsRequired = 36,
            ammo = 12,
        },
        {
            weapon = "WEAPON_SAWNOFFSHOTGUN",
            killsRequired = 37,
            ammo = 30,
        },
        
    },
    
    -- Configuration du gungame
    gungameConfig = {
        maxKillsToWin = 10,
        respawnTime = 3000, -- 3 secondes
        weaponProgression = true, -- Activer la progression d'armes
        showKillMessage = true,
        allowKnifeKill = true, -- Permettre le kill au couteau pour reculer d'une arme
        knifeWeapon = "weapon_knife"
    },

}