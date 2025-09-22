itemLoaded = false 
UseSlotCooldowns = {} -- Add cooldown table for hotbar item usage

GM.Player.Inv = {}

-- Au début du fichier, ajoutons une variable pour suivre l'état de création de véhicule
local isSpawningVehicle = false

function GetPlayerInv()
    return FormatItems(GM.Player.Inv)
end

function Display(data)
    if data.bool and disableInventory then return end
    isOpened = data.bool
    ArrangeControls(data.bool)
    local inventory, inventoryWeight, otherInventory, otherInventoryWeight
    if data.bool then
        openedInventoryType = data.inventoryInfo.name
        inventory, inventoryWeight = FormatItems(PlayerItems["inventory"])
        otherInventory, otherInventoryWeight = FormatItems(PlayerItems[data.inventoryInfo.name])
        if data.inventoryInfo then
            data.inventoryInfo.inventoryWeight = inventoryWeight
            data.inventoryInfo.otherInventoryWeight = otherInventoryWeight
            data.inventoryInfo.maxInvWeight = GM.Player.MaxWeight.."0"
            data.inventoryInfo.maxSafeWeight = GM.Player.MaxSafeWeight.."0"
        end    
    end

    if not itemLoaded then 

        table.sort(Items, function(a, b) return a.price > b.price end)
        SendNUIMessage({
            type = "importItemTbl",
            tbl = Items
        })
        itemLoaded = true 
    end

    GM.Player.Inv = FormatItems(PlayerItems["inventory"])  

    -- LoadLeaderboard()
    SendNUIMessage({
        type = "display",
        bool = data.bool,
        inventory = inventory,
        safeinventory = otherInventory,
        pseudo = GM.Player.Username,
        tokens = GM.Player.Token,
        uuid = GM.Player.UUID,
        coins = GM.Player.Coins,
        inventoryInfo = data.inventoryInfo,
    })

end

local fakeTable = {
    {name = "weapon_assaultrifle", count = 1},
}

_RegisterNetEvent("inventory:openInventoryStaff", function(inventory, safeinventory, data)
    print(json.encode(inventory), "INVENTAIRE")
    hisInventory = FormatItems(inventory)
    hisSafeInventory = FormatItems(safeinventory)

    if not itemLoaded then 
        table.sort(Items, function(a, b) return a.price > b.price end)
        SendNUIMessage({
            type = "importItemTbl",
            tbl = Items
        })
        itemLoaded = true 
    end
    isOpened = true 
    ArrangeControls(true)

    -- LoadLeaderboard()
    SendNUIMessage({
        type = "display",
        bool = true,
        inventory = hisInventory,
        safeinventory = hisSafeInventory,
        pseudo = data.username,
        tokens = data.token,
        uuid = data.uuid,
        coins = data.coins,
    })
end)


function UpdateInventory(inventoryType)
    local inventory, inventoryWeight = FormatItems(PlayerItems["inventory"])
    local otherInventory, otherInventoryWeight = FormatItems(PlayerItems[inventoryType])


    SendNUIMessage({
        type = "updateinventory",
        inventory = inventory,
        safeinventory = otherInventory,
        weights = {
            inventoryWeight = inventoryWeight,
            otherInventoryWeight = otherInventoryWeight,
            maxInvWeight = GM.Player.MaxWeight.."0",
            maxSafeWeight = GM.Player.MaxSafeWeight.."0"
        }
    })
end

function SetHotbar()
    SendNUIMessage({
        type = "hotbar",
        hotbar = HotbarData
    })
end

function FormatItems(inventory, key)
    local returnTable = {}
    local totalWeight = 0
    if inventory ~= nil then
        for i = 1, #inventory do
            if inventory[i] ~= nil then
                inventory[i].image = Items[inventory[i].name].image
                inventory[i].label = Items[inventory[i].name].label
                inventory[i].rarity = Items[inventory[i].name].rarity
                inventory[i].type = Items[inventory[i].name].type
                inventory[i].weight = Items[inventory[i].name].weight
                totalWeight = totalWeight + (inventory[i].count * inventory[i].weight)
            end
        end
    end
    return inventory, totalWeight
end

function DisableInventory(bool)
    disableInventory = bool
    if bool then
        Display({
            bool = false
        })
    end
end
exports("DisableInventory", function(bool)
    DisableInventory(bool)
end)

function CommandFunction()
    if GM.Player.InSelecGamemode then return end
    if not isOpened then
        OpenInventory("protected")
    else
        Display({
            bool = false
        })
    end
end

function HasItem(inventoryType, itemName, count)
    count = count == nil and 1 or count
    if PlayerItems[inventoryType] then
        for i = 1, #PlayerItems[inventoryType] do
            local element = PlayerItems[inventoryType][i]
            if element.name == itemName then
                if count <= element.count then
                    return true
                end
            end
        end
    end
    return false
end



function OpenInventory(inventoryType)
    if disableInventory then return end
    Tse("gamemode:server:OpenInventory", inventoryType)
end

exports("OpenInventory", OpenInventory)

function ClearSafezonePoints()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    for k, v in pairs(Safezone.List) do 
        if v.load then 
            local distance = #(vec3(v.coords.x, v.coords.y, v.coords.z) - vec3(playerCoords.x, playerCoords.y, playerCoords.z))
            if distance <= 20.0 then 
                return true
            end
        end
    end
    return false
end

function UseSlot(id)
    local v = HotbarData[id]
    if GM.Player.InSelecGamemode then return end
    if GM.Player.InGunrace then return end
    if disableInventory then return end 
    -- Get the current timestamp for cooldown check
    local currentTime = GetGameTimer()
    -- Check if the item is a vehicle and if it's on cooldown
    if v and v.type == "vehicle" then
        -- Vérification du cooldown général pour empêcher l'apparition rapide après stockage
        if GM.Player.InFFA then return end 
        local spawnCooldown = GetCooldownProgress("spawn_veh")
        if spawnCooldown > 0 then
            return ShowAboveRadarMessage("~HUD_COLOUR_RED~You must wait " .. spawnCooldown .. " seconds before spawning another vehicle.")
        end
        
        if ClearSafezonePoints() then
            return ShowAboveRadarMessage("~HUD_COLOUR_RED~You cannot spawn a vehicle here.")
        end

        -- Protection contre les utilisations multiples pendant le lag
        if isSpawningVehicle then
            return 
        end
        
        if UseSlotCooldowns[v.name] and (currentTime - UseSlotCooldowns[v.name]) < 200 then
            return -- Ignore if the vehicle item was used less than 200ms ago
        end
    end
    
    if not isDead and not isOpened and v and HasItem("inventory", v.name) then
        -- if v.name == "dukes2" then return ShowAboveRadarMessage("~r~You cannot use this item.") end
        -- Store timestamp of usage to prevent duplicate usage (only for vehicles)
        if v.type == "vehicle" then
            UseSlotCooldowns[v.name] = currentTime
            isSpawningVehicle = true
            -- Réinitialiser après 2 secondes si le véhicule n'a pas été créé (temps réduit)
            Citizen.SetTimeout(2000, function()
                isSpawningVehicle = false
            end)
        end
        Tse("gamemode:OnItemUsed", v.name)
    end
end

function SetDisableInventoryMoveState(bool)
    SendNUIMessage({
        type = "cc",
        movestatus = bool
    })
end

function DisableInventoyFarm(bool)
    disableInventory = bool
    SetDisableInventoryMoveState(bool)
end

-- Ajoutons un gestionnaire d'événements pour réinitialiser l'état quand le véhicule est créé
_RegisterNetEvent("vehicle:VehicleUsed", function(model, vehId, custom)
    -- Réinitialiser l'état de création de véhicule immédiatement quand le véhicule est réellement créé
    isSpawningVehicle = false
end)

-- Ajouter un événement pour réinitialiser l'état quand un véhicule est stocké
_RegisterNetEvent("vehicle:ResetSpawningState", function()
    isSpawningVehicle = false
end)

RegisterNUICallback("deleteItem", function(data, cb)
    Tse("gamemode:server:deleteItem", data)
end)