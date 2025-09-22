local SecondsToClock = function(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return hours..":"..mins..":"..secs
    end
end

-- Cooldown de la gift box en secondes (1h30 = 5400 secondes)
local timeGiftBox = 5400

-- Préfixe commun pour toutes les clés KVP liées au gift box
local kvpPrefix = "aaa"

-- Fonction utilitaire pour obtenir le nom complet de la clé KVP
local function getFullKvpKey(uuid, keyName)
    return kvpPrefix..uuid.."_"..keyName
end

-- Fonction pour réinitialiser les KVP d'un joueur spécifique
local function resetPlayerGiftBoxKvp(uuid)
    if uuid then
        DeleteResourceKvp(getFullKvpKey(uuid, "useGiftBox"))
        DeleteResourceKvp(getFullKvpKey(uuid, "useGiftBox_time"))
        return true
    end
    return false
end

-- Commande pour réinitialiser les KVP de la gift box
-- RegisterCommand("resetgiftbox", function(source, args)
--     -- Vérifier si la commande est exécutée par la console ou un admin
--     if source == 0 or IsPlayerAceAllowed(source, "command.resetgiftbox") then
--         local targetId = args[1]
        
--         -- Si un ID cible est spécifié
--         if targetId then
--             local target = tonumber(targetId)
--             local playerData = GetPlayerId(target)
            
--             if playerData and playerData.uuid then
--                 if resetPlayerGiftBoxKvp(playerData.uuid) then
--                     if source > 0 then
--                         TriggerClientEvent('chat:addMessage', source, {
--                             args = {"^2[SYSTEM]", "Gift box reset pour le joueur ID "..targetId}
--                         })
--                     else
--                         print("Gift box reset pour le joueur ID "..targetId)
--                     end
--                 else
--                     if source > 0 then
--                         TriggerClientEvent('chat:addMessage', source, {
--                             args = {"^1[SYSTEM]", "Erreur: Impossible de réinitialiser la gift box pour ce joueur"}
--                         })
--                     else
--                         print("Erreur: Impossible de réinitialiser la gift box pour ce joueur")
--                     end
--                 end
--             else
--                 if source > 0 then
--                     TriggerClientEvent('chat:addMessage', source, {
--                         args = {"^1[SYSTEM]", "Erreur: Joueur non trouvé"}
--                     })
--                 else
--                     print("Erreur: Joueur non trouvé")
--                 end
--             end
--         else
--             -- Réinitialiser pour l'exécuteur de la commande
--             if source > 0 then
--                 local playerData = GetPlayerId(source)
--                 if playerData and playerData.uuid then
--                     if resetPlayerGiftBoxKvp(playerData.uuid) then
--                         TriggerClientEvent('chat:addMessage', source, {
--                             args = {"^2[SYSTEM]", "Votre gift box a été réinitialisée"}
--                         })
--                     else
--                         TriggerClientEvent('chat:addMessage', source, {
--                             args = {"^1[SYSTEM]", "Erreur: Impossible de réinitialiser votre gift box"}
--                         })
--                     end
--                 end
--             else
--                 print("Erreur: Vous devez spécifier un ID joueur depuis la console")
--             end
--         end
--     else
--         TriggerClientEvent('chat:addMessage', source, {
--             args = {"^1[SYSTEM]", "Vous n'avez pas la permission d'utiliser cette commande"}
--         })
--     end
-- end, false)

function OpenGiftBox(src)
    local playerData = GetPlayerId(src) 
    if playerData and playerData.uuid then 
        local useGiftBox = GetResourceKvpString(getFullKvpKey(playerData.uuid, "useGiftBox"))
        
        -- Si useGiftBox est "true", le joueur a déjà utilisé sa gift box aujourd'hui
        if useGiftBox and useGiftBox == "true" then 
            local GetTime = GetResourceKvpInt(getFullKvpKey(playerData.uuid, "useGiftBox_time")) or 0
            
            -- Vérifier si le cooldown est terminé
            if GetTime > os.time() then 
                -- Le cooldown n'est pas encore terminé
                local time = SecondsToClock(GetTime - os.time())
                _TriggerClientEvent("ShowAboveRadarMessage", src, "You need to wait: ~b~"..time) 
                return false, time
            else 
                -- Le cooldown est terminé, on peut réutiliser la gift box
                SetResourceKvp(getFullKvpKey(playerData.uuid, "useGiftBox"), "true")
                SetResourceKvpInt(getFullKvpKey(playerData.uuid, "useGiftBox_time"), os.time() + timeGiftBox)
                return true, (timeGiftBox + os.time())
            end
        else
            -- Première utilisation de la gift box aujourd'hui
            SetResourceKvp(getFullKvpKey(playerData.uuid, "useGiftBox"), "true")
            SetResourceKvpInt(getFullKvpKey(playerData.uuid, "useGiftBox_time"), os.time() + timeGiftBox)
            return true, (timeGiftBox + os.time())
        end
    end 
    return false, "Failed to open gift box"
end

RegisterCallback("OpenGiftBox2", function(source)
    local success, time = CanOpenGiftBox(source)
    return success, time
end)

function CanOpenGiftBox(src)
    local playerData = GetPlayerId(src) 
    if playerData and playerData.uuid then 
        
        local useGiftBox = GetResourceKvpString(getFullKvpKey(playerData.uuid, "useGiftBox"))
        
        -- Si useGiftBox est "true", le joueur a déjà utilisé sa gift box aujourd'hui
        if useGiftBox and useGiftBox == "true" then
            -- Vérifier le temps restant
            local GetTime = GetResourceKvpInt(getFullKvpKey(playerData.uuid, "useGiftBox_time")) or 0
            
            if GetTime > os.time() then 
                -- Le cooldown n'est pas encore terminé
                local time = SecondsToClock(GetTime - os.time())
                return false, time
            else 
                -- Le cooldown est terminé, on peut réutiliser la gift box
                return true, 0
            end
        else
            -- Première utilisation de la gift box aujourd'hui
            return true, 0
        end
    end 
    return false, "Failed to open gift box"
end

RegisterCallback("OpenGiftBox",  function(source)
    local success, time = CanOpenGiftBox(source)
    return success, time
end)

local giftBoxItems = {
    {id = 1, name = "Ped acces", rarity = "legendary", image = "./assets/items/ped_access1week.png", chance = 0, count = 1, item = "ped_access1week"},
    {id = 2, name = "Kill effect", rarity = "legendary", image = "./assets/items/kill_effect1week.png", chance = 0, count = 1, item = "kill_effect1week"},
    {id = 3, name = "AWP", rarity = "legendary", image = "./assets/items/weapon_heavysniper.png", chance = 2, count = 1, item = "weapon_heavysniper"},
    {id = 4, name = "Marksman Rifle Mk II", rarity = "epic", image = "./assets/items/weapon_marksmanrifle_mk2.png", chance = 5, count = 1, item = "weapon_marksmanrifle_mk2"},
    {id = 5, name = "Nightshark", rarity = "common", image = "./assets/items/nightshark.png", chance = 35, count = 1, item = "nightshark"},
    {id = 6, name = "RPG", rarity = "uncommon", image = "./assets/items/weapon_rpg.png", chance = 15, count = 1, item = "weapon_rpg"},
    {id = 7, name = "Deluxo", rarity = "rare", image = "./assets/items/deluxo.png", chance = 8, count = 1, item = "deluxo"},
    {id = 8, name = "Special Carbine", rarity = "common", image = "./assets/items/weapon_specialcarbine.png", chance = 30, count = 20, item = "weapon_specialcarbine"},
    {id = 9, name = "Bullpup Rifle MKII", rarity = "common", image = "./assets/items/weapon_bullpuprifle_mk2.png", chance = 30, count = 20, item = "weapon_bullpuprifle_mk2"},
    {id = 10, name = "M60 MK II", rarity = "common", image = "./assets/items/weapon_combatmg_mk2.png", chance = 15, count = 15, item = "weapon_combatmg_mk2"},
    {id = 11, name = "Scarab", rarity = "common", image = "./assets/items/scarab.png", chance = 28, count = 1, item = "scarab"},
    {id = 12, name = "Marksman Rifle", rarity = "rare", image = "./assets/items/weapon_marksmanrifle.png", chance = 10, count = 1, item = "weapon_marksmanrifle"},
}

function CheckCountItemGood(item, count)
    for k, v in pairs(giftBoxItems) do 
        if v.item == item then 
            if count <= 0 then return false end
            if count > v.count then return false end
            return true
        end
    end
    return false
end

_RegisterServerEvent('giftbox:addItemSpinGiftBox', function(item, count, itemName)
    local playerData = GetPlayerId(source)
    
    if playerData and playerData.uuid then 
        -- Vérifier si le joueur peut encore ouvrir la gift box
        local canOpen, timeRemaining = CanOpenGiftBox(source)
        if not canOpen then
            return DoNotif(source, "~r~You cannot open the gift box yet. Wait: ~b~" .. timeRemaining)
        end
        
        -- Vérifier seulement si le joueur a les items requis (si applicable)
        if not CheckCountItemGood(item, count) then 
            return DoNotif(source, "~r~You don't have enough items") 
        end
        
        -- Donner l'item directement
        exports["gamemode"]:AddItem(source, "protected", item, count, nil, true)
        DoNotif(source, "~y~Congrulation! ~w~You receive ~g~" .. itemName .. " ~w~in the gift box!")
        
        -- Marquer que le joueur a utilisé sa gift box (cooldown de 1h30)
        OpenGiftBox(source)
        
        -- IMPORTANT : Envoyer le nouveau statut au client pour mettre à jour l'interface
        local success, nextTime = CanOpenGiftBox(source)
        TriggerClientEvent('giftbox:updateStatus', source, success, nextTime)
    else
        DoNotif(source, "~r~Player data not found")
    end
end)
