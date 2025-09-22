local function GetWeaponList()
    local returnList = {}
    local currentWeapon = GetSelectedPedWeapon(PlayerPedId())
    for k, v in pairs(WeaponsAttachments) do
        print(currentWeapon, GetHashKey(v.itemName), v.itemName)
        if currentWeapon == GetHashKey(v.itemName) then
            table.insert(returnList, {name = v.Name, label = v.Name, itemName = v.itemName, componentsList = v.Components})
        end
    end

    return returnList
end

-- Fonction pour vérifier si un composant est actif pour une arme
local function IsComponentActive(weaponName, componentHash)
    local activeComponents = GetWeaponActiveComponent(weaponName)
    for _, hash in ipairs(activeComponents) do
        if hash == componentHash then
            return true
        end
    end
    return false
end

local function onSelected(PMenu, MenuData, currentButton, currentSlt)
    if MenuData.currentMenu == "weapon_menu" then
        print(currentButton.label, currentButton.itemName)
        WeaponMenu.Menu.weapon_attachment2.b = {} 
        for k, v in pairs(currentButton.componentsList) do
            table.insert(WeaponMenu.Menu.weapon_attachment2.b, {
                name = v.Name, 
                label = v.Name, 
                hash = v.Hash, 
                checkbox = IsComponentActive(currentButton.itemName, v.Hash), 
                weaponName = currentButton.itemName
            })
        end
        OpenMenu("weapon_attachment2")
    end

    if MenuData.currentMenu == "weapon_attachment2" then
        if currentButton.weaponName then 
            if currentButton.checkbox then
                SetWeaponActiveComponent(currentButton.weaponName, currentButton.name, currentButton.hash)
            else
                RemoveWeaponActiveComponent(currentButton.weaponName, currentButton.hash)
            end
        end
    end
end

WeaponMenu = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, HeaderColor = { 255, 0, 0 }, Title = "Weapon Menu"},
    Data = { currentMenu = "weapon_menu"}, 
    Events = {
        onSelected = onSelected,
    },
    Menu = {
        ["weapon_menu"] = {NewTitle = "Weapon List", label = "Weapon List", b = GetWeaponList, useFilter = true},
        ["weapon_attachment2"] = {NewTitle = "Weapon Attachment", label = "Weapon Attachment", useFilter = true,b = {}},
    }
}

function OpenWeaponMenu()
    CreateMenu(WeaponMenu, {}) 
end

-- RegisterCommand('openweaponmenu', function()
--     OpenWeaponMenu()
-- end)

Citizen.CreateThread(function()
    local NPC_WeaponMenu = {
        safezone = "Hospital",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(224.7957, -1394.138, 30.58747, 265.9811),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end,
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu)

    local NPC_WeaponMenu_Marabunta = {
        safezone = "Marabunta",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(1140.305, -1496.287, 34.69263, 218.4994),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end,
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu_Marabunta)

    local NPC_WeaponMenu_Beach = {
        safezone = "Beach Safezone",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(-1072.957642, -1268.302612, 5.990957, 30.342438),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end,
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu_Beach)

    local NPC_WeaponMenu_CrossField = {
        safezone = "Cross Field",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(1212.526, 1880.876, 78.36908, 243.1518),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end,
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu_CrossField)

    local NPC_WeaponMenu_Sandy = {
        safezone = "Sandy Shores Safezone",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(2758.233, 3441.506, 56.01525, 69.37386),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end,
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu_Sandy)

    local NPC_WeaponMenu_Paleto = {
        safezone = "Hideout",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(1476.963, 6370.45, 23.60243, 188.094),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end,
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu_Paleto)

    local NPC_WeaponMenu_Paleto = {
        safezone = "Paleto",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(-958.3688, 6190.102, 3.625069, 37.25591),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end,
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_WeaponMenu_Paleto)

    local NPC_WeaponMenu_Mountain = {
        safezone = "Mountain",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(-427.3882, 1130.48, 325.904, 169.8232),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end,
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu_Mountain)

    local NPC_WeaponMenu_Main = {
        safezone = "Main SafeZone",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(-529.0065, -219.2694, 37.64971, 33.33926),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end,
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu_Main)

    local NPC_WeaponMenu_Mirror = {
        safezone = "Mirror Park",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(1364.694, -575.8813, 74.38039, 250.343),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end, 
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu_Mirror)

    local NPC_WeaponMenu_Depot = {
        safezone = "depot",
        pedType = 4,
        model = "mp_m_securoguard_01",
        pos = vector4(762.60, -1417.19, 26.50, 356.75),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then 
                OpenWeaponMenu()
            else 
                ShowAboveRadarMessage("~r~You must be on foot to open the weapon menu")
            end
        end, 
        drawText = "[ ~r~WEAPON CUSTOMIZER ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    RegisterSafeZonePedAction(NPC_WeaponMenu_Depot)
end)
