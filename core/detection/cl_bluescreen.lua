bluescreenActive = false

function SecondToClock(seconds)
    seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00"
    else
        local mins = string.format("%02.f", math.floor(seconds / 60))
        local secs = string.format("%02.f", math.floor(seconds - mins * 60))
        return string.format("%s:%s", mins, secs)
    end
end

remainingSeconds = nil
finishVerfi = false
local oldPositionBeforeVerification = nil

_RegisterNetEvent("verification:Start", function(coords)
    oldPositionBeforeVerification = GetEntityCoords(PlayerPedId())
    bluescreen()
end)

_RegisterNetEvent("verification:Finish", function()
    remainingSeconds = 0
    finishVerfi = true
    inVoiceCall = false
    lockedTimer = false
    bluescreenActive = false
    ShowAboveRadarMessage("~g~The verification has been finished. Enjoy the game!")
    FreezeEntityPosition(PlayerPedId(), false)
    print("stop verification")
    SetEntityCoords(PlayerPedId(), oldPositionBeforeVerification.x, oldPositionBeforeVerification.y, oldPositionBeforeVerification.z)
    oldPositionBeforeVerification = nil
end)

newTimer = false
function bluescreen()
    if bluescreenActive then return end
    bluescreenActive = true

    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, "Bed", "WastedSounds", true)

    local stopCodes = {
        "SYSTEM_SERVICE_EXCEPTION",
        "CRITICAL_PROCESS_DIED",
        "PAGE_FAULT_IN_NONPAGED_AREA",
        "MEMORY_MANAGEMENT",
        "UNEXPECTED_KERNEL_MODE_TRAP",
        "DPC_WATCHDOG_VIOLATION",
        "IRQL_NOT_LESS_OR_EQUAL",
        "KERNEL_SECURITY_CHECK_FAILURE",
        "SYSTEM_THREAD_EXCEPTION_NOT_HANDLED",
        "UNEXPECTED_STORE_EXCEPTION",
        "DRIVER_POWER_STATE_FAILURE",
        "KMODE_EXCEPTION_NOT_HANDLED"
    }

    local cheatingErrorCodes = {
        "SECURE_SERV_ANTICHEAT_VIOLATION",
        "MEMORY_INTEGRITY_FAILURE",
        "CHEAT_ENGINE_DETECTED",
        "MEMORY_INJECTION_DETECTED",
        "INVALID_GAME_MODIFICATION",
        "PROCESS_TAMPERING_DETECTED"
    }

    FreezeEntityPosition(PlayerPedId(), true)
    local stopCode = math.random() > 0.4
        and cheatingErrorCodes[math.random(1, #cheatingErrorCodes)]
        or stopCodes[math.random(1, #stopCodes)]

    local randomErr = string.format("0x%08X", math.random(0, 4294967295))

    remainingSeconds = 30 -- Initial value (2 minutes in seconds)

    Citizen.CreateThread(function()
        while bluescreenActive do
            Citizen.Wait(1000)
            remainingSeconds = remainingSeconds - 1 
            if remainingSeconds <= 0 and not finishVerfi and not inVoiceCall then
                FreezeEntityPosition(PlayerPedId(), false)
                bluescreenActive = false
                Tse("verification:Banned")
            end
        end
    end)
     
    Citizen.CreateThread(function()
        while bluescreenActive do
            Citizen.Wait(5000)
            local inVoice = CallbackServer("checkVoiceChannel")
            if inVoice then 
                inVoiceCall = true
                lockedTimer = true
                remainingSeconds = 10000
            end
        end
    end)

    Citizen.CreateThread(function()
        SetNuiFocus(true, true)

        while bluescreenActive do
            DisableAllControlActions(0)

            DrawRect(0.5, 0.5, 1.0, 1.0, 255, 0, 0, 255)


            SetTextFont(4)
            SetTextScale(1.8, 1.8)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            SetTextDropShadow(0, 0, 0, 0, 255)
            SetTextEdge(0, 0, 0, 0, 0)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("VERIFICATION")
            EndTextCommandDisplayText(0.5, 0.10)


            SetTextFont(4)
            SetTextScale(1.8, 1.8)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            SetTextDropShadow(0, 0, 0, 0, 255)
            SetTextEdge(0, 0, 0, 0, 0)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(":(")
            EndTextCommandDisplayText(0.5, 0.22)

            SetTextFont(4)
            SetTextScale(0.40, 0.40)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            SetTextDropShadow(0, 0, 0, 0, 255)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("You've been frozen by a staff member")
            EndTextCommandDisplayText(0.5, 0.33)

            
            SetTextFont(4)
            SetTextScale(0.40, 0.40)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            SetTextDropShadow(0, 0, 0, 0, 255)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(" so you've got 2 minutes to introduce yourself by saying 'Need Staff'.")
            EndTextCommandDisplayText(0.5, 0.37)
            -- If you disconnect, you will automatically be banned.

            SetTextFont(4)
            SetTextScale(0.40, 0.40)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            SetTextDropShadow(0, 0, 0, 0, 255)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("If you disconnect, you will automatically be banned.")
            EndTextCommandDisplayText(0.5, 0.39)

            -- SetTextFont(4)
            -- SetTextScale(0.43, 0.43)
            -- SetTextColour(255, 255, 255, 190)
            -- SetTextCentre(true)
            -- BeginTextCommandDisplayText("STRING")
            -- AddTextComponentSubstringPlayerName(
            -- "Cheating is not allowed on Guild PvP.")
            -- EndTextCommandDisplayText(0.5, 0.39)
            
            -- Use the remainingSeconds variable directly
            local timerText = SecondToClock(remainingSeconds)
            
            SetTextFont(4)
            SetTextScale(0.43, 0.43)
            SetTextColour(255, 255, 255, 190)
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(timerText .. " - TIME REMAINING")
            EndTextCommandDisplayText(0.5, 0.44)

            Citizen.Wait(0)
        end

        SetNuiFocus(false, false)
    end)
end

-- RegisterCommand("bluescreen", function()
--     bluescreen()
-- end)