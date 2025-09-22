EventManagerGlobalTitle = "~r~Event Manager - ~w~NO EVENT ACTIVE"
_RegisterNetEvent('EventManager:UpdateEvent',function(data)
    EventManager.Data = data
    if EventManager.Data then 
        EventManagerGlobalTitle = "~r~Event Manager - ~g~"..EventManager.Data.Title
    else 
        EventManagerGlobalTitle = "~r~Event Manager - ~w~NO EVENT ACTIVE"
    end
end)

Citizen.CreateThread(function()

    local NPC_EventManager_Hospital = {
        safezone = "Hospital",
        pedType = 4,
        model = "csb_anita",
        pos = vector4(230.4824, -1397.266, 30.48909, 322.1489),
        weapon = "weapon_heavysniper",
        drawText = function()
           return EventManagerGlobalTitle
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_EventManager_Marabunta = {
        safezone = "Marabunta",
        pedType = 4,
        model = "csb_anita",
        pos = vector4(1147.07, -1500.729, 34.66088, 182.6013),
        weapon = "weapon_heavysniper",
        drawText = function()
            return EventManagerGlobalTitle
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_EventManager_Main = {
        safezone = "Main SafeZone",
        pedType = 4,
        model = "csb_anita",
        pos = vector4(-529.8179, -230.3624, 36.70222, 32.33699),
        weapon = "weapon_heavysniper",
        drawText = function()
            return EventManagerGlobalTitle
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    
    }

    local NPC_EventManager_Depot = {
        safezone = "depot",
        pedType = 4,
        model = "csb_anita",
        pos = vector4(759.75, -1416.95, 26.51, 4.56),
        weapon = "weapon_heavysniper",
        drawText = function()
            return EventManagerGlobalTitle
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    
    }

    local NPC_EventManager_Paleto = {
        safezone = "Paleto",
        pedType = 4,
        model = "csb_anita",
        pos = vector4(-952.4322, 6197.161, 3.763473, 28.14631),
        weapon = "weapon_heavysniper",
        drawText = function()
            return EventManagerGlobalTitle
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_EventManager_Mountain = {
        safezone = "Mountain",
        pedType = 4,
        model = "csb_anita",
        pos = vector4(-424.3547, 1134.622, 325.8548, 173.3029),
        weapon = "weapon_heavysniper",
        drawText = function()
            return EventManagerGlobalTitle
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_EventManager_Mirror = {
        safezone = "Mirror Park",
        pedType = 4,
        model = "csb_anita",
        pos = vector4(1361.959, -590.6208, 74.17728, 334.6018),
        weapon = "weapon_heavysniper",
        drawText = function()
            return EventManagerGlobalTitle
        end,
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_EventManager_Mirror)
    RegisterSafeZonePedAction(NPC_EventManager_Hospital)
    RegisterSafeZonePedAction(NPC_EventManager_Marabunta)
    RegisterSafeZonePedAction(NPC_EventManager_Main)
    RegisterSafeZonePedAction(NPC_EventManager_Paleto)
    RegisterSafeZonePedAction(NPC_EventManager_Mountain)
    RegisterSafeZonePedAction(NPC_EventManager_Depot)
end)
