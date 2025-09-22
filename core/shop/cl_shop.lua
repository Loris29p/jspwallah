local legendaryItems = {
    ["weapon_heavysniper"] = true,
    ["weapon_heavysniper_mk2"] = true,
    ["weapon_hominglauncher"] = true,
    ["weapon_rpg"] = true,
    ["weapon_marksmanrifle_mk2"] = true,
    ["weapon_marksmanrifle"] = true,
    ["weapon_compactlauncher"] = true,
    ["weapon_sniperrifle"] = true,

    -- vehicles
    ["deluxo"] = true,
    ["oppressor"] = true,
    ["scarab"] = true,
    ["nightshark"] = true,
    ["dukes2"] = true,
}


function OpenShop()

    local shopItems = {}
    for key, v in pairs(Items) do
        -- print(key, "OEPN SHOP")
        -- if not legendaryItems[key] then
        --     table.insert(shopItems, {
        --         name = key,
        --         price = v.price,
        --         label = v.label,
        --         type = v.type,
        --     })
        -- end

        table.insert(shopItems, {
            name = key,
            price = v.price,
            label = v.label,
            type = v.type,
            hide = (v.hide and v.hide or false),
        })
    end

    if not itemLoaded then 
        table.sort(Items, function(a, b) return a.price > b.price end)
        SendNUIMessage({
            type = "importItemTbl",
            tbl = Items
        })
        itemLoaded = true 
    end
    SendNUIMessage({
        type = "shop",
        bool = true,
        shopsItems = shopItems, -- // shopItems
        tokens = GM.Player.Token
    })
    ArrangeControls(true)
    isOpened = true
end

RegisterNUICallback("openShop", function()
    OpenShop()
end)

RegisterCommand('+shop', function()
    if GM.Player.InLeague then return end
    if GM.Player.LeagueLobby then return end
    if GM.Player.InSelecGamemode then return end
    if GM.Player.InFarm then return end
    if GM.Player.InDarkzone then return end
    if GM.Player.InGunrace then return end
    if GM.Player.InFFA then return end
    if GM.Player.InSafeZone then 
        OpenShop()
    else
        return
    end
end)
RegisterKeyMapping("+shop", "Open Shop Items", "keyboard", "B")


RegisterNUICallback("buyItem", function(data)
    local itemName = data.item 
    local price = data.price
    local shift = data.shift
    if GM.Player.InMode.Deluxo then 
        return
    end

    if not GM.Player.InSafeZone then return ShowAboveRadarMessage("~r~You can't buy items outside of the safezone") end

    Logger:trace("SHOP MODULE", "Item: %s, Price: %s", itemName, price)
    Tse("shop:buyItems", itemName, price, shift)
end)

RegisterNUICallback("sellAll", function()
    if not GM.Player.InSafeZone then return ShowAboveRadarMessage("~r~You can't sell items outside of the safezone") end
    Tse("shop:SellAll")
end)



-- Wrapper Shop
local ShopHighway = {
    safezone = "Highway",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(734.2133, -1202.217, 44.96028, 273.5482),
    weapon = "weapon_combatmg",
    action = function()
        if not GM.Player.InDarkzone and not GM.Player.InFarm then
            OpenShop() 
        end
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopMain = {
    safezone = "Hospital",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(224.4864, -1396.835, 30.58747, 291.1703),
    weapon = "weapon_combatmg",
    action = function()
        if not GM.Player.InDarkzone and not GM.Player.InFarm then
            OpenShop() 
        end
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopMara = {
    safezone = "Marabunta",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(1147.089, -1495.022, 34.6607, 167.2107),
    weapon = "weapon_combatmg",
    action = function()
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopBeach = {
    safezone = "Beach Safezone",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(-1069.872314, -1266.484741, 5.957625, 31.931362),
    weapon = "weapon_combatmg",
    action = function() 
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopEASTLS = {
    safezone = "Cross Field",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(1207.464, 1874.184, 78.27534, 224.3397),
    weapon = "weapon_combatmg",
    action = function()
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopSandy = {
    safezone = "Sandy Shores Safezone",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(2760.312, 3447.756, 55.91374, 71.98061),
    weapon = "weapon_combatmg",
    action = function()
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopPaleto = {
    safezone = "Hideout",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(1467.629, 6358.06, 23.80264, 283.7413),
    weapon = "weapon_combatmg",
    action = function()
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopPaleto2 = {
    safezone = "Paleto",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(-950.6561, 6193.955, 3.810305, 29.09536),
    weapon = "weapon_combatmg",
    action = function()
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopMountain = {
    safezone = "Mountain",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(-419.9292, 1128.363, 325.9049, 166.5978),
    weapon = "weapon_combatmg",
    action = function()
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopMain = {
    safezone = "Main SafeZone",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(-533.8508, -223.5736, 37.64981, 30.91387),
    weapon = "weapon_combatmg",
    action = function()
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopMirror = {
    safezone = "Mirror Park",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos = vector4(1362.664, -580.7628, 74.38039, 251.9201),
    weapon = "weapon_combatmg",
    action = function()
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local ShopDepot = {
    safezone = "depot",
    pedType = 4,
    model = "a_f_y_beach_01",
    pos =  vector4(754.63, -1416.58, 26.53, 321.65),
    weapon = "weapon_combatmg",
    action = function()
        OpenShop()
    end,
    drawText = "[ ~r~ITEM MARKET ~s~]", 
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}





Citizen.CreateThread(function()
    -- RegisterSafeZonePedAction(ShopHighway)
    RegisterSafeZonePedAction(ShopMirror)
    RegisterSafeZonePedAction(ShopMain)
    RegisterSafeZonePedAction(ShopMara)
    RegisterSafeZonePedAction(ShopBeach)
    RegisterSafeZonePedAction(ShopEASTLS)
    RegisterSafeZonePedAction(ShopSandy)
    RegisterSafeZonePedAction(ShopPaleto)
    RegisterSafeZonePedAction(ShopPaleto2)
    RegisterSafeZonePedAction(ShopMountain)
end)


RegisterNUICallback("BuyOthersItem", function(data, cb)
    local itemName = data.item 
    local itemPrice = data.price 

    local result, coins = CallbackServer("BuyOthersItem", {item = itemName, price = tonumber(data.number)})
    if result then 
        cb({
            status = "success",
            coins = coins,
        })
    else
        cb(false)
    end
end)