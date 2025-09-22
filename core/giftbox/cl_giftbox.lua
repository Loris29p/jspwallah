local canOpenGiftBox = true
local nextGiftBoxTime = 0

-- Fonction de debug
local function Debugprint(...)
    print("[GIFTBOX DEBUG]", ...)
end

-- Function to check if gift box can be opened
function CheckGiftBoxAvailability()
    
    local success, time = CallbackServer("OpenGiftBox")
    
    canOpenGiftBox = success 
    
    -- Si success est true, assurons-nous que nextGiftBoxTime a une valeur
    if success then 
        if time == nil then
            -- Utiliser une valeur par défaut si time est nil
            nextGiftBoxTime = 0
        else
            nextGiftBoxTime = time
        end
    else 
        if type(time) == "string" and time:find(":") then
            nextGiftBoxTime = time
        else
            nextGiftBoxTime = time or 0  -- Assurez-vous que nextGiftBoxTime n'est jamais nil
        end
    end
    
    SendNUIMessage({
        type = "updateGiftBoxStatus",
        canOpen = canOpenGiftBox,
        nextTime = nextGiftBoxTime
    })
    
    return canOpenGiftBox, nextGiftBoxTime
end

function OpenGiftBox()
    local success, time = CallbackServer("OpenGiftBox2")
    
    -- Mettre à jour les variables locales avec le résultat du serveur
    canOpenGiftBox = success
    
    -- S'assurer que nextGiftBoxTime a une valeur valide
    if success then
        nextGiftBoxTime = time or 0
    else
        if type(time) == "string" and time:find(":") then
            nextGiftBoxTime = time
        else
            nextGiftBoxTime = time or 0
        end
    end
    
    -- Si succès, ouvrir la boîte cadeau
    if success then
        SendNUIMessage({
            type = "openGiftBox",
            canOpen = success,
            nextTime = nextGiftBoxTime
        })
    end
    
    -- Mettre à jour le statut du bouton dans tous les cas
    SendNUIMessage({
        type = "updateGiftBoxStatus",
        canOpen = canOpenGiftBox,
        nextTime = nextGiftBoxTime
    })
    
    return success, time
end

-- Register NUI callback for when user clicks the spin button
RegisterNUICallback('spinGiftBox', function(data, cb)
    local success, time = OpenGiftBox()
    
    cb({
        success = success,
        nextTime = time
    })
end)

-- Initialize on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    Citizen.CreateThread(function()
        while not GM.FinishLoading do
            Citizen.Wait(1000) -- Wait a bit to ensure everything is loaded
        end
        
        CheckGiftBoxAvailability()
    end)
end)

RegisterNUICallback('addItemSpinGiftBox', function(data)
    local item = data.item
    local count = data.count 
    local itemName = data.itemName
    Tse("giftbox:addItemSpinGiftBox", item, count, itemName)
end)

-- Écouter la mise à jour du statut après l'ouverture de la gift box
RegisterNetEvent('giftbox:updateStatus')
AddEventHandler('giftbox:updateStatus', function(success, nextTime)
    Debugprint('Received status update from server:', success, nextTime)
    
    -- Mettre à jour les variables locales
    canOpenGiftBox = success
    nextGiftBoxTime = nextTime
    
    -- Envoyer la mise à jour à l'interface NUI
    SendNUIMessage({
        type = "updateGiftBoxStatus",
        canOpen = canOpenGiftBox,
        nextTime = nextGiftBoxTime
    })
end)