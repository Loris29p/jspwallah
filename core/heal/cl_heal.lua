local Time = {
    kevlar = {
        ["user"] = 1500,
        ["support"] = 1400,
        ["invite"] = 1500,
        ["vip"] = 1300,
        ["vip+"] = 1200,
        ["mvp"] = 700,
        ["god"] = 600,
    },
    medkit = {
        ["user"] = 1500,
        ["support"] = 1400,
        ["invite"] = 1500,
        ["vip"] = 1300,
        ["vip+"] = 1200,
        ["mvp"] = 700,
        ["god"] = 600,
    },
    bandage = {
        ["user"] = 1200,
        ["support"] = 1200,
        ["invite"] = 1200,
        ["vip"] = 1200,
        ["vip+"] = 1200,
        ["mvp"] = 700,
        ["god"] = 600,
    },
}

-- RegisterCommand("removehealth", function()
--     local ped = PlayerPedId()
--     SetEntityHealth(ped, GetEntityHealth(ped) - 10)
-- end)

-- RegisterCommand("removekev", function()
--     local ped = PlayerPedId()
--     SetPedArmour(ped, 0)
-- end)

local ActionCancel = false
local alreadyUse = false

Citizen.CreateThread(function()
    local pedId = PlayerId()
    local ped = PlayerPedId()
    SetPlayerCanDoDriveBy(pedId, false)
    SetMaxHealthHudDisplay(200)
    SetPedSuffersCriticalHits(PlayerPedId(), false)
    SetPedParachuteTintIndex(ped, 3)
    SetPlayerParachuteSmokeTrailColor(pedId, 0, 255, 0)
    SetPlayerHealthRechargeMultiplier(pedId, 0.0)
    ResetPlayerStamina(pedId)
    SetPedMaxHealth(ped, 200)
    SetPlayerMaxArmour(pedId, 100)
end)

function RequestAnimLoad(animDict)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Wait(0)
		end
	end

    return true
end

-- Register NUI callbacks
RegisterNUICallback('cancelProgress', function(data, cb)
    if data and data.progressType then
        if data.progressType == "medkit" or data.progressType == "kevlar" then
            ActionCancel = true
        end
    end
    cb('ok')
end)

RegisterNUICallback('progressComplete', function(data, cb)
    -- This callback is handled automatically in the useItem function
    cb('ok')
end)

function useItem(type)
    RequestAnimLoad("amb@medic@standing@kneel@base")
    RequestAnimLoad("misstattoo_parlour@shop_ig_4")
    if type == "medkit" then 
        local myCooldown = GetCooldownProgress("medkit")

        if myCooldown > 0 then
            ShowAboveRadarMessage("~r~You must wait "..myCooldown.." seconds before medkit.")
            return
        end
        ActionCancel = false
        print(GM.Player.Role, "ROLE DEBUG ") 
        local time = Time[type][GM.Player.Role]
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        print(health, "HEALTH")
        if health >= 200 then return end
        if not IsPedInAnyVehicle(ped) then 
            TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base", "base", 8.0, 8.0, -1, 1, 1, 0, 0, 0)                
        end
        
        AddCooldown("medkit", 3)
        
        alreadyUse = true
        
        -- Send message to UI to start progress bar
        SendNUIMessage({
            type = "startProgress",
            progressType = "medkit",
            duration = time
        })
        
        -- Create a shared variable to track remaining time
        local sharedRemainingTime = time
        
        -- Thread pour afficher la notification et gérer l'annulation
        Citizen.CreateThread(function()
            while not ActionCancel and sharedRemainingTime > 0 do 
                Citizen.Wait(0)
                DrawTopNotification("Press ~INPUT_PARACHUTE_SMOKE~ to cancel the action~w~.")
                if IsControlJustPressed(0, 154) then 
                    if not IsPedInAnyVehicle(ped) then
                        ClearPedTasksImmediately(ped)
                        ActionCancel = true
                        alreadyUse = false
                        -- Send message to UI to cancel progress bar
                        SendNUIMessage({
                            type = "cancelProgress"
                        })
                    end
                    break
                end
            end
        end)

        -- Thread pour le décompte et l'application de la guérison à la fin
        Citizen.CreateThread(function()
            -- Attendons que le timer se termine
            while not ActionCancel and sharedRemainingTime > 0 do
                Citizen.Wait(100)
                sharedRemainingTime = sharedRemainingTime - 100
            end
            
            -- Si l'action n'a pas été annulée et que le temps est écoulé
            if not ActionCancel then
                -- Appliquer la guérison en une seule fois
                local currentHealth = GetEntityHealth(ped)
                if currentHealth < 200 then
                    SetEntityHealth(ped, 200)
                    ActionCancel = true -- Heal complet
                end
                
                -- Nettoyage
                if not IsPedInAnyVehicle(ped) then
                    ClearPedTasksImmediately(ped)
                end
            else
                -- Si l'action a été annulée, s'assurer que la progress bar est cachée
                SendNUIMessage({
                    type = "hideProgress"
                })
            end
            
            -- Réinitialiser les variables
            alreadyUse = false
            ActionCancel = false
        end)
    elseif type == "kevlar" then 
        -- Vérifier si une guérison est déjà en cours
        if alreadyUse then
            ShowAboveRadarMessage("~r~You are already using a healing item!")
            return
        end
        
        ActionCancel = false
        local myCooldown = GetCooldownProgress("armour")

        if myCooldown > 0 then
            ShowAboveRadarMessage("~HUD_COLOUR_RED~You must wait "..myCooldown.." seconds before armour.")
            return
        end
        print(GM.Player.Role, "ROLE DEBUG") 
        local time = Time[type][GM.Player.Role]
        local ped = PlayerPedId()
        local armour = GetPedArmour(ped)
        print(armour, "ARMOUR", GetPlayerMaxArmour(PlayerId()))
        local maxArmour = GetPlayerMaxArmour(PlayerId())
        -- Permettre l'utilisation même à 100% d'armure
        
        if not IsPedInAnyVehicle(ped) then 
            TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base", "base", 8.0, 8.0, -1, 1, 1, 0, 0, 0)                
        end
        
        if not GM.Player.InLeague and not GM.Player.InFFA then
            Tse("gamemode:RemoveItem", {
                itemName = "kevlar",
                fromType = "inventory",
                count = 1
            })
        end
        AddCooldown("armour", 3)

        alreadyUse = true
        
        -- Send message to UI to start progress bar
        SendNUIMessage({
            type = "startProgress",
            progressType = "kevlar",
            duration = time
        })
        
        -- Create a shared variable to track remaining time
        local sharedRemainingTime = time
        
        -- Thread pour afficher la notification et gérer l'annulation
        Citizen.CreateThread(function()
            while not ActionCancel and sharedRemainingTime > 0 do 
                Citizen.Wait(0)
                DrawTopNotification("Press ~INPUT_PARACHUTE_SMOKE~ to cancel the action~w~.")
                if IsControlJustPressed(0, 154) then 
                    if not IsPedInAnyVehicle(ped) then
                        ClearPedTasksImmediately(ped)
                        ActionCancel = true
                        alreadyUse = false
                        -- Send message to UI to cancel progress bar
                        SendNUIMessage({
                            type = "cancelProgress"
                        })
                    end
                    break
                end
            end
        end)

        -- Thread pour le décompte et l'application de l'armure à la fin
        Citizen.CreateThread(function()
            -- Attendons que le timer se termine
            while not ActionCancel and sharedRemainingTime > 0 do
                Citizen.Wait(100)
                sharedRemainingTime = sharedRemainingTime - 100
            end
            
            -- Si l'action n'a pas été annulée et que le temps est écoulé
            if not ActionCancel then
                -- Appliquer l'armure en une seule fois
                SetPedArmour(ped, maxArmour)
                ActionCancel = true -- Armure complète
                
                -- Nettoyage
                if not IsPedInAnyVehicle(ped) then
                    ClearPedTasksImmediately(ped)
                end
            else
                -- Si l'action a été annulée, s'assurer que la progress bar est cachée
                SendNUIMessage({
                    type = "hideProgress"
                })
            end
            
            -- Réinitialiser les variables
            alreadyUse = false
            ActionCancel = false
        end)
    elseif type == "bandage" then
        -- Vérifier si une guérison est déjà en cours
        if alreadyUse then
            ShowAboveRadarMessage("~r~You are already using a healing item!")
            return
        end
        
        ActionCancel = false
        local myCooldown = GetCooldownProgress("bandage")

        if myCooldown > 0 then
            ShowAboveRadarMessage("~r~You must wait "..myCooldown.." seconds before bandage.")
            return
        end
        local time = Time[type][GM.Player.Role]
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        print(health, "HEALTH")
        -- Permettre l'utilisation même à 100% de santé
        if not IsPedInAnyVehicle(ped) then 
            TaskPlayAnim(PlayerPedId(), "misstattoo_parlour@shop_ig_4", "shop_ig_4_tattooist", 8.0, 8.0, -1, 49, 1, 0, 0, 0)                
        end
        
        if not GM.Player.InLeague and not GM.Player.InFFA then
            Tse("gamemode:RemoveItem", {
                itemName = "bandage",
                fromType = "inventory",
                count = 1
            })
        end
        AddCooldown("bandage", 1)
        
        alreadyUse = true
        
        -- Send message to UI to start progress bar
        SendNUIMessage({
            type = "startProgress",
            progressType = "bandage",
            duration = time
        })
        
        -- Create a shared variable to track remaining time
        local sharedRemainingTime = time
        
        -- Thread pour afficher la notification et gérer l'annulation
        Citizen.CreateThread(function()
            while not ActionCancel and sharedRemainingTime > 0 do 
                Citizen.Wait(0)
                DrawTopNotification("Press ~INPUT_PARACHUTE_SMOKE~ to cancel the action~w~.")
                if IsControlJustPressed(0, 154) then 
                    if not IsPedInAnyVehicle(ped) then
                        ClearPedTasksImmediately(ped)
                        ActionCancel = true
                        alreadyUse = false
                        -- Send message to UI to cancel progress bar
                        SendNUIMessage({
                            type = "cancelProgress"
                        })
                    end
                    break
                end
            end 
        end)

        Citizen.CreateThread(function()
            while not ActionCancel and sharedRemainingTime > 0 do
                Citizen.Wait(100)
                sharedRemainingTime = sharedRemainingTime - 100
            end

            if not ActionCancel then
                local currentHealth = GetEntityHealth(ped)
                if currentHealth < 200 then
                    SetEntityHealth(ped, currentHealth + 30)
                    ActionCancel = true -- Heal complet
                end
                
                -- IMPORTANT : Arrêter l'animation immédiatement après application du bandage
                if not IsPedInAnyVehicle(ped) then
                    ClearPedTasks(ped)
                end
            else 
                SendNUIMessage({
                    type = "hideProgress"
                })
            end

            alreadyUse = false
            ActionCancel = false
        end)
    end
end

RegisterCommand("+heal", function()
    local player = GM.Player:Get()
    if player.Dead then return end
    useItem("bandage")
end)
RegisterKeyMapping("+heal", "Heal", "keyboard", "F1")

RegisterCommand("+kevlar", function()
    local player = GM.Player:Get()
    if player.Dead then return end
    useItem("kevlar")
end)
RegisterKeyMapping("+kevlar", "Armour", "keyboard", "F2")

_RegisterNetEvent("cl_heal:custom:UseItem", function(itemName)
    if itemName == "kevlar" then
        useItem("kevlar")
    elseif itemName == "bandage" then
        useItem("bandage")
    end
end)