Attempts = 0 

function ResetAttempts()
    Attempts = 0
end

function AddAttempts()
    if Attempts >= 3 then
        Attempts = 0
        ShowAboveRadarMessage("~r~You are using NoClip.")
        Tse("ac:detected:noclip")
        return true
    else
        Attempts = Attempts + 1
        -- Reset automatique après 5 secondes
        Citizen.CreateThread(function()
            Wait(5000)
            if Attempts > 0 then 
                Attempts = Attempts - 1 
            end
        end)
        return false
    end
end


local debug_noclip = false

function NoClipDetection()
    local playerPed = PlayerPedId() 
    local playerCoords = GetEntityCoords(playerPed)
    local playerSpeed = GetEntitySpeed(playerPed)
    local wasOnFoot = IsPedOnFoot(playerPed) -- Stocke l'état initial
    Wait(2000)
    local playerCoords2 = GetEntityCoords(playerPed)
    local playerSpeed2 = GetEntitySpeed(playerPed)
    if debug_noclip then
        print("Speed1:", playerSpeed, "Speed2:", playerSpeed2)
        -- 119 quand tu ragdoll
        -- 9 quand tu tombe d'un petit toit
        -- 50 quand t'es en vehicle max 
        -- 8 a peids
        print("=== PED STATES ===")
        print("WasOnFoot:", wasOnFoot)
        print("IsPedOnFoot:", IsPedOnFoot(playerPed))
        print("IsPedRagdoll:", IsPedRagdoll(playerPed))
        print("IsPedInAnyVehicle:", IsPedInAnyVehicle(playerPed, false))
        print("IsPedInVehicle:", IsPedInVehicle(playerPed, false))
        print("IsPedFalling:", IsPedFalling(playerPed))
        print("IsPedInAnyHeli:", IsPedInAnyHeli(playerPed, false))
        print("IsPedInAnyPlane:", IsPedInAnyPlane(playerPed, false))
        print("IsPedInAnyBoat:", IsPedInAnyBoat(playerPed, false))
        print("IsPedClimbing:", IsPedClimbing(playerPed))
        print("IsPedInParachuteFreeFall:", IsPedInParachuteFreeFall(playerPed))
        print("IsPedRunningRagdollTask:", IsPedRunningRagdollTask(playerPed))
        print("IsPedSwimming:", IsPedSwimming(playerPed))
        print("IsPedSwimmingUnderWater:", IsPedSwimmingUnderWater(playerPed))
        print("IsPedStrafing:", IsPedStrafing(playerPed))
        print("IsPedGettingUp:", IsPedGettingUp(playerPed))
        print("==================")
    end
    if (#(playerCoords - playerCoords2) > 20.0 and (playerSpeed > 8 or playerSpeed2 > 8) and wasOnFoot and IsPedOnFoot(playerPed) and not IsPedRagdoll(playerPed) and not IsPedInAnyVehicle(playerPed, false) and not IsPedFalling(playerPed)) or 
    (playerSpeed > 60 or playerSpeed2 > 60 and IsPedInAnyVehicle(playerPed, false) and not IsPedRagdoll(playerPed) and not wasOnFoot and not IsPedOnFoot(playerPed))  then
        AddAttempts()
        print("NoClipDetection - Attempts:", Attempts)
    end
end

Citizen.CreateThread(function()
    while true do
        NoClipDetection()
        Wait(1000)
    end
end)