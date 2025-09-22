_AddEventHandler("gameEventTriggered", function(eventName, eventArguments)
    if eventName == "CEventNetworkEntityDamage" then
		if GM.Player.InMode.Deluxo then
			local killerEntity = GetPedCauseOfDeath(PlayerPedId()) 
			local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)
			DeathDeluxo({
				killer = GetPlayerServerId(killerClientId),
				dead = GetPlayerServerId(PlayerId())
			})
		else
			local victimEntity, attackEntity, _, fatalBool, weaponUsed, _a, _z, _e, _r, _t, entityType = table.unpack(eventArguments)
			local ped = PlayerPedId()
			if ped ~= victimEntity then
				return
			end
			if attackEntity == victimEntity or attackEntity == -1 then
				return _TriggerEvent(_a ~= 0 and "GM:onPlayerDied" or "GM:onPlayerDied", victimEntity, attackEntity, "suicide")
			end
			local player = GM.Player:Get()

			if not player.Dead then
				_TriggerEvent(_a ~= 0 and "GM:onPlayerDied" or "GM:onPlayerDied", victimEntity, attackEntity, "player")
			end
		end
    end
end)

RegisterCommand("kill", function()
	if not GM.Player.InSelecGamemode and not GM.Player.InSafeZone then 
		local playerPed = PlayerPedId()
		local startPos = GetEntityCoords(playerPed)
		local killTimer = 0
		local isMoving = false
		
		-- Notification de début
		ShowAboveRadarMessage("~r~Do not move for 3 seconds...")
		
		-- Start the kill timer
		Citizen.CreateThread(function()
			while killTimer < 3000 and not isMoving do -- 3000ms = 3 seconds
				Citizen.Wait(100)
				killTimer = killTimer + 100
				
				-- Check if player moved
				local currentPos = GetEntityCoords(playerPed)
				if #(startPos - currentPos) > 0.1 then
					isMoving = true
					-- Notification d'annulation
					ShowAboveRadarMessage("~r~You moved. Death canceled.")
					break
				end
			end
			
			-- Execute kill if timer completed and player didn't move
			if killTimer >= 3000 and not isMoving then
				-- Notification de succès
				-- ShowAboveRadarMessage("~g~Commande kill exécutée !")
				SetEntityHealth(playerPed, 0)
			end
		end)
	end
end)

Citizen.CreateThread(function()
    local player = GM.Player:Get()
	while true do
		Citizen.Wait(0)
		if player.Dead then
			DisableThemAll()
		else
			Citizen.Wait(750)
		end
	end
end)

function DisableThemAll()
	-- DisableControlAction(0, 322, true) -- Disable tilt
			-- DisableControlAction(0, 200, true) -- Disable tilt		
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 31, true) -- S
			DisableControlAction(0, 30, true) -- D
			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?
			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			--DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job
			-- DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen
			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle
			DisableControlAction(2, 36, true) -- Disable going stealth
            DisableControlAction(0, 200, true)  -- ESC
            DisableControlAction(0, 322, true)  -- ESC
            DisableControlAction(0, 191, true)   -- toggle id
			DisableControlAction(0, 201, true) 
            DisableControlAction(0, 215, true)  
			DisableControlAction(0, 18, true) 
            DisableControlAction(0, 176, true)  
			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
			-- DisableControlAction(0,Keys['X'], true) 
            -- DisableControlAction(0,Keys['B'], true)  
			DisableControlAction(0, 73,  true)  -- x
			DisableControlAction(0, 105, true)  -- x
			DisableControlAction(0, 120, true)  -- x
			DisableControlAction(0, 154, true)  -- x
			DisableControlAction(0, 186, true)  -- x
			DisableControlAction(0, 252, true)  -- x
			DisableControlAction(0, 323, true)  -- x
			DisableControlAction(0, 337, true)  -- x
			DisableControlAction(0, 354, true)  -- x
			DisableControlAction(0, 357, true)  -- x
			DisableControlAction(0, 166, true)  -- F5
			DisableControlAction(0, 318, true)  -- F5 
			DisableControlAction(0, 327, true)  -- F5 
			DisableControlAction(0, 243, true)  -- 
			DisableControlAction(0, 137, true)  -- 
			-- EnableControlAction(0, Keys['G'], true)
			-- EnableControlAction(0, Keys['T'], true)
			-- EnableControlAction(0, Keys['E'], true) 
			EnableControlAction(0, 19, true) 
            SetEntityInvincible(PlayerPedId(),true)
end


local pInfo = {
    health = 0,
    armour = 0
}

_AddEventHandler('gameEventTriggered', function(name, data)
    if name == "CEventNetworkEntityDamage" then
        victim = tonumber(data[1])
        attacker = tonumber(data[2])
        victimDied = tonumber(data[6]) == 1 and true or false 
        weaponHash = tonumber(data[7])
        isMeleeDamage = tonumber(data[10]) ~= 0 and true or false 
        vehicleDamageTypeFlag = tonumber(data[11]) 
        local FoundLastDamagedBone, LastDamagedBone = GetPedLastDamageBone(victim)
        local bonehash = -1 
        if FoundLastDamagedBone then
            bonehash = tonumber(LastDamagedBone)
        end
        local PPed = PlayerPedId()
        local isplayer = IsPedAPlayer(attacker)
        local attackerid = isplayer and GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker)) or tostring(attacker==-1 and " " or attacker)

        if victim == attacker or victim ~= PPed or not IsPedAPlayer(victim) or not IsPedAPlayer(attacker) then return end

        local hit = {
            health = 0,
            armour = 0,
        }

        if pInfo.armour > GetPedArmour(PPed) then
            hit.armour = pInfo.armour - GetPedArmour(PPed)
        else
            hit["armour"] = nil
        end

        if pInfo.health > GetEntityHealth(PPed) then
            hit.health = pInfo.health - GetEntityHealth(PPed)
        else
            hit["health"] = nil
        end
        if GetSettingsValue("hitmarker") then 
            Tse("tggggg:bb", attackerid, victimDied)
        end
    end
end)

_RegisterNetEvent("kO:client:writehit")
_AddEventHandler("kO:client:writehit", function(victimDied)
    if GetSettingsValue("killsound") then 
        if victimDied then 
            local volume = (GetSettingsValue("volume_hitmarker") and GetSettingsValue("volume_hitmarker") or 0.30)
            if volume then 
                _TriggerEvent("InteractSound_CL:PlayOnOne", "deadsound", tostring(volume))
            end
        end
    end
end)