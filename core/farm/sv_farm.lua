tblItems = {
    [0] = {
        rarityLevel = 0,
        items = {
            "weapon_assaultsmg",
            "weapon_heavyshotgun",
            "weapon_carbinerifle",
            "weapon_combatpdw",
            "weapon_molotov",
            "weapon_smg",
            "weapon_tacticalrifle",
            "weapon_combatmg",
            "brioso",
            "jugular",
            "deathbike",
            "weapon_bullpuprifle_mk2",
            "weapon_specialcarbine",
            "weapon_specialcarbine_mk2",
            "revolter",
            "ztype",
            "dominator4",
            "revolter",
            "brioso",
            "jugular",
            "deathbike",
            math.random(250, 350)
        }
    },
    [1] = {
        rarityLevel = 1,
        items = {
            "weapon_bullpuprifle_mk2",
            "weapon_specialcarbine",
            "weapon_specialcarbine_mk2",
            "revolter",
            math.random(250, 350)
        }
    },
    [2] = {
        rarityLevel = 2,
        items = {
            "weapon_mg",
            "ztype",
            "dominator4",
            "revolter",
            "brioso",
            "jugular",
            "deathbike",
            math.random(250, 350)
        }
    },
    [3] = {
        rarityLevel = 3,
        items = {
            "weapon_sniperrifle",
            "weapon_marksmanrifle",
            math.random(250, 350)
        }
    },
    [4] = {
        rarityLevel = 4,
        items = {
            "weapon_hominglauncher",
            "weapon_rpg",
            "weapon_marksmanrifle_mk2",
            "deluxo",
            "weapon_compactlauncher",
            "oppressor",
            math.random(250, 350)
        }
    }
}

ListFarmZone = {}

_RegisterServerEvent("enterFarmZone", function()
    SetPlayerRoutingBucket(source, math.random(1, 900000000))
end)

_RegisterServerEvent("leaveFarmZone", function()
    SetPlayerRoutingBucket(source, 0)
end)

local function getRandomItem(tbl)
    return tbl[math.random(#tbl)]
end

local function getLootByRarity(rarity, inDarkzone)
    if inDarkzone and math.random() < 0.5 then
        rarity = math.min(rarity + 1, 3)
    end

    if math.random() < 0.35 then
        local tokenAmounts = {
            [0] = math.random(250, 350),  
            [1] = math.random(250, 350), 
            [2] = math.random(250, 350),  
            [3] = math.random(250, 350),   
            [4] = math.random(250, 350)
        }
        return {item = tokenAmounts[rarity] or math.random(500, 1000), rarityLevel = rarity, isToken = true}
    end

    -- 20% de chance d'obtenir un item d'arme
    local loot = tblItems[rarity]
    if not loot then return nil end

    local selectedItem = getRandomItem(loot.items)
    return {item = selectedItem, rarityLevel = loot.rarityLevel, isToken = false}
end

afkFarmPlayers = {}

-- Table pour suivre le nombre de zombies tués par joueur
zombieKillCount = {}

_RegisterServerEvent("afkfarm:GetData", function()
    _TriggerClientEvent("afkfarm:update", source, afkFarmPlayers)
end)

_RegisterServerEvent("afkfarm:start", function(type)
    local intSource = source
    local player = GetPlayerId(intSource)
    if type == "join" then 
        SetPlayerRoutingBucket(intSource, 62100)
        table.insert(afkFarmPlayers, {
            source = intSource,
            uuid = player.uuid,
        })
        _TriggerClientEvent("afkfarm:update", -1, afkFarmPlayers)
    elseif type == "leave" then
        SetPlayerRoutingBucket(intSource, 0)
        for k, v in pairs(afkFarmPlayers) do
            if v.source == intSource then
                table.remove(afkFarmPlayers, k)
                break
            end
        end
        _TriggerClientEvent("afkfarm:update", -1, afkFarmPlayers)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1*1000*10) -- 10 seconds
        for k, v in pairs(afkFarmPlayers) do
            if v then
                local playerData = GetPlayerId(v.source)
                local tokensAdded = 130
                if playerData then
                    if playerData.role == "user" then 
                        tokensAdded = 130
                    elseif playerData.role == "support" then 
                        tokensAdded = 200
                    elseif playerData.role == "invite" then 
                        tokensAdded = 250
                    elseif playerData.role == "vip" then 
                        tokensAdded = 300
                    elseif playerData.role == "vip+" then 
                        tokensAdded = 350
                    elseif playerData.role == "mvp" then 
                        tokensAdded = 400
                    elseif playerData.role == "god" then 
                        tokensAdded = 450
                    end
                    playerData.AddTokens(tonumber(tokensAdded))
                    _TriggerClientEvent("ShowAboveRadarMessage", k, ("You received ~g~%s Tokens ~s~"):format(tokensAdded))
                end
            end
        end
    end
end)

AddEventHandler("playerDropped", function()
    local intSource = source
    for k, v in pairs(afkFarmPlayers) do
        if v.source == intSource then
            table.remove(afkFarmPlayers, k)
            _TriggerClientEvent("afkfarm:update", -1, afkFarmPlayers)
            break
        end
    end
    
    -- Nettoyer le compteur de zombies tués
    if zombieKillCount[intSource] then
        zombieKillCount[intSource] = nil
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:z:lootZom", function(tblData, inDarkzone)
    local intSource = source

    local loot = getLootByRarity(tonumber(tblData.rarity), inDarkzone)
    if not loot then return print("not loot") end
    
    local listItems = exports.gamemode:ItemListInventory()
    local player = GetPlayerId(intSource)
    
    if not player then 
        print("Player not found for source:", intSource)
        return 
    end
    
    -- Incrémenter le compteur de zombies tués
    if not zombieKillCount[intSource] then
        zombieKillCount[intSource] = 0
    end
    zombieKillCount[intSource] = zombieKillCount[intSource] + 1
    
    -- Vérifier si le joueur a tué 300 zombies
    if zombieKillCount[intSource] >= 300 then
        -- Réinitialiser le compteur
        zombieKillCount[intSource] = 0
        
        -- Choisir un des 3 items spéciaux
        local specialItems = {"oppressor", "weapon_marksmanrifle", "weapon_rpg"}
        local specialItem = specialItems[math.random(#specialItems)]
        
        -- Noms d'affichage personnalisés
        local displayNames = {
            ["oppressor"] = "Oppressor",
            ["weapon_marksmanrifle"] = "Marksman Rifle",
            ["weapon_rpg"] = "RPG"
        }
        
        -- Donner l'item spécial
        _TriggerClientEvent("ShowAboveRadarMessage", intSource, ("You found ~g~x1 %s ~s~"):format(displayNames[specialItem]))
        exports.gamemode:AddItem(intSource, "inventory", specialItem, 1, nil, true)
    end
    
    if loot.isToken then
        -- Gestion des tokens avec bonus selon le rôle
        local baseTokens = loot.item
        if player.role == "invite" then 
            baseTokens = math.floor(baseTokens * 1.1)
        elseif player.role == "vip" then 
            baseTokens = math.floor(baseTokens * 1.2)
        elseif player.role == "vip+" then 
            baseTokens = math.floor(baseTokens * 1.25)
        elseif player.role == "mvp" then 
            baseTokens = math.floor(baseTokens * 1.30)
        elseif player.role == "god" then 
            baseTokens = math.floor(baseTokens * 1.40)
        end

        if player.isBooster then 
            baseTokens = math.floor(baseTokens * 1.22)
        end
        
        _TriggerClientEvent("ShowAboveRadarMessage", intSource, ("You found ~g~%s Tokens ~s~"):format(baseTokens))
        exports["gamemode"]:AddTokensByZombie(source, tonumber(baseTokens))
    else
        -- Gestion des armes/items (20% de chance)
        local rarityColor
        if loot.rarityLevel == 2 then
            rarityColor = tonumber(9)
        elseif loot.rarityLevel == 3 then
            rarityColor = tonumber(127)
        end
        
        if string.match(loot.item, "WEAPON_") then
            if rarityColor then
                _TriggerClientEvent("ShowAboveRadarMessage", intSource, ("You found ~g~%s ~s~"):format(listItems[loot.item].label))
                exports.gamemode:AddItem(intSource, "inventory", loot.item, 1, nil, true)
            else
                _TriggerClientEvent("ShowAboveRadarMessage", intSource, ("You found ~g~%s ~s~"):format(listItems[loot.item].label))
                exports.gamemode:AddItem(intSource, "inventory", loot.item, 1, nil, true)
            end
        else
            if rarityColor then
                _TriggerClientEvent("ShowAboveRadarMessage", intSource, ("You found ~g~%s ~s~"):format(listItems[loot.item].label))
                exports.gamemode:AddItem(intSource, "inventory", loot.item, 1, nil, true)
            else
                _TriggerClientEvent("ShowAboveRadarMessage", intSource, ("You found ~g~%s ~s~"):format(listItems[loot.item].label))
                exports.gamemode:AddItem(intSource, "inventory", loot.item, 1, nil, true)
            end
        end
    end
    
    exports["gamemode"]:AddXPByZombies(intSource, math.random(100, 500))
end)

-- Command to display player coordinates
RegisterCommand("coords", function(source, args, rawCommand)
    local player = source
    if player then
        local ped = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        
        TriggerClientEvent("ShowAboveRadarMessage", player, ("~w~Coordonnées: ~g~X: %.2f, Y: %.2f, Z: %.2f, Heading: %.2f"):format(coords.x, coords.y, coords.z, heading))
    end
end, false)