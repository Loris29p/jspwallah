GM.Player.InFarm = false 
local pedSpawned = 1
local pedTableList = {}
local pedTableSpawnTime = {}


ZOMBIE_SPAWN_RATES_KEY = {
    DEFAULT = 0,
    COMMON = 1,
    UNCOMMON = 2,
    RARE = 3
}

ZOMBIE_SPAWN_RATES = {
    [ZOMBIE_SPAWN_RATES_KEY.DEFAULT] = 0.7,
    [ZOMBIE_SPAWN_RATES_KEY.COMMON] = 0.2,
    [ZOMBIE_SPAWN_RATES_KEY.UNCOMMON] = 0.1,
    [ZOMBIE_SPAWN_RATES_KEY.RARE] = 0.00,
}

m_tblConfigFarm = {
    closeAttractRange = 100.0,
    canSpawn = false,
    disableHearZom = false,
    isInDungeon = false,
    painFaceAnim = {
		"facials@gen_male@base pain_3",
		"facials@gen_male@base pain_5",
		"facials@gen_male@base shocked_2",
		"facials@gen_male@base coughing_1",
		"facials@gen_male@base mood_normal_1"
	},
    zombieRelationGroup = GetHashKey("GTA_Zombie"),
    zombieMovingClipset = "move_m@hurry@a",
    zombieModels = {
		"s_m_m_marine_01",
		"s_m_y_marine_01",
		"a_m_m_mexcntry_01",
		"a_m_m_polynesian_01",
		"a_m_m_skidrow_01",
		"a_m_y_genstreet_01",
		"a_m_y_genstreet_02",
		"a_m_y_stlat_01",
		"csb_ramp_hic",
		"a_m_m_rurmeth_01",
		"a_m_m_hillbilly_02",
		"a_m_m_hillbilly_01",
		"s_m_y_prisoner_01",
		"s_m_y_prismuscl_01",
		"a_m_m_salton_01",
		-- "a_m_m_salton_02",
		"a_m_y_salton_01",
		"copZ",
		"DocZ",
		"HcopZ",
		-- "ParaZ",
		"u_m_y_corpse_01",
		"u_f_y_corpse_01"
	},
    headshotDisabled = false,
    zombiesList = {},
    safePos = false,
    g_zombieSpawningBoosted = false,
    maxSpawnedPeds = 10,
    disableZombieKill = false,
    disableZombie = false,
}

function BoostZombies(bool)
    if bool then 
        m_tblConfigFarm.maxSpawnedPeds = 10
        m_tblConfigFarm.g_zombieSpawningBoosted = true
    else
        m_tblConfigFarm.maxSpawnedPeds = 10
        m_tblConfigFarm.g_zombieSpawningBoosted = false
    end
end

ZOMBIE_CLASS_ENUM = {
    DEFAULT = 0,
    ARMORED = 1,
    SURVIVOR = 2,
    BOOMER = 3,
    HAZMAT = 4,
    BOSS = 5
}

canCreatedZombie = true

function DrawTetDist(x,y,z, text, scale)
    SetDrawOrigin(x, y, z, 0);
	SetTextFont(4)
	SetTextProportional(0)
	SetTextScale(0.0, scale)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end


function GetZombieClassEnum()
    return ZOMBIE_CLASS_ENUM
end
exports("GetZombieClassEnum", GetZombieClassEnum)

Citizen.CreateThread(function()
    FarmInitizalize()
end)

function FarmInitizalize()
    AddRelationshipGroup("GTA_Zombie")
    RequestAndWaitSet("move_m@hurry@a")
	RequestClipSet("weapons@tennis@male")
	RequestAndWaitDict("facials@gen_female@base")
    SetAudioFlag("IsDirectorModeActive", true)

    DecorRegister("ZOMBIE_SPAWNED", 2)
	DecorRegister("ZOMBIE_TIME", 1)
	DecorRegister("ZOMBIE_CLASS", 3)

    SetAudioFlag("IsDirectorModeActive", true)
    if not DecorIsRegisteredAsType("_ZOMBIE_TARGET", 3) then DecorRegister("_ZOMBIE_TARGET", 3) end
	if not DecorIsRegisteredAsType("_PED_SAFE", 2) then DecorRegister("_PED_SAFE", 2) end
end

function IsPedZombie(p)
	return GetPedRelationshipGroupHash(p) == m_tblConfigFarm.zombieRelationGroup or GetPedConfigFlag(p, 400) or DecorGetBool(p, "ZOMBIE_SPAWNED")
end

function CreateFakePedAttackPlayer(unkVar, model, extraArgs)
    if type(unkVar) ~= "number" then 
        RequestModel(model)
        while not HasModelLoaded(model) do 
            Citizen.Wait(100)
        end 
        local found, safeZ = GetGroundZFor_3dCoord(unkVar.x, unkVar.y, unkVar.z + 4.0, 0, 0)
        local ped = CreatePed(4, model, unkVar.x + .0, unkVar.y + .0, (found and not extraArgs.trust) and safeZ or unkVar.z, 0.0, false, true)
        SetEntityAsMissionEntity(ped, true)
        SetPedRandomComponentVariation(ped, true)
        SetPedRandomProps(ped) 
        local blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, 57)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.5)
        SetBlipAsShortRange(blip, false)
        SetBlipDisplay(blip, 2)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Zombie")
        EndTextCommandSetBlipName(blip)
        applyPedParams(ped, false)
        return ped
    end
end

function SetPedMovementClipsetSafe(ped, movementClipset)
	if not HasAnimSetLoaded(movementClipset) then
		RequestAndWaitSet(movementClipset)
	end

	SetPedMovementClipset(ped, movementClipset, 1.0)
end



m_streamedPedsExtendedData = {}

local function createZombiePedExtendedData(zombie, isOwner)
	m_streamedPedsExtendedData[zombie] = { class = {
        Name = "Default Zombie",
        SpawnRate = math.random(0, 2),
        Default = true,
        ID = ZOMBIE_CLASS_ENUM.DEFAULT,
    }, model = GetEntityModel(zombie), isOwner = isOwner }
end




function applyPedParams(ped, blBloods)
    SetBlockingOfNonTemporaryEvents(ped, true)
	SetPedPathCanUseClimbovers(ped, true)

	SetPedAccuracy(ped, 25)
	SetPedFleeAttributes(ped, 0, 0)
	SetPedEnableWeaponBlocking(ped, true)
	SetPedDiesInWater(ped, false)
	SetPedDiesWhenInjured(ped, false)
	SetPedIsDrunk(ped, true)
	DisablePedPainAudio(ped, true)
	SetPedCanPlayGestureAnims(ped, false)
	SetPedCanPlayAmbientAnims(ped, false)
	SetPedPathCanUseLadders(ped, false)
	SetPedSuffersCriticalHits(ped, not m_tblConfigFarm.headshotDisabled)
    SetPedConfigFlag(ped, 400, true)
    DecorSetBool(ped, "IsZombie", true)
    TaskWanderStandard(ped, 1.0, 10)
    SetEntityMaxHealth(ped, 200)
	SetEntityHealth(ped, 200)
    SetPedKeepTask(ped, true)
	SetPedCanEvasiveDive(ped, false)

	SetPedCombatAttributes(ped, 0, false)
	SetPedCombatAttributes(ped, 1, false)
	SetEntityProofs(ped, false, false, false, true, false, false, false, false)
	SetPedCombatAttributes(ped, 2, false)
	SetPedCombatAttributes(ped, 16, true)
	SetPedCombatAttributes(ped, 46, true)
	-- SetPedCombatAttributes(zombie, 1424, false)
	-- SetEntityAsNoLongerNeeded(zombie)

    SetPedRelationshipGroupDefaultHash(ped, m_tblConfigFarm.zombieRelationGroup)
	SetPedRelationshipGroupHash(ped, m_tblConfigFarm.zombieRelationGroup)

	SetPedCombatMovement(ped, 3)
    ApplyPedDamagePack(ped, "TD_SHOTGUN_FRONT_KILL", 0.0, 1.0)
	ApplyPedDamagePack(ped, "Burnt_Ped_Head_Torso", 0.0, 1.0)
    SetPedMovementClipsetSafe(ped, m_tblConfigFarm.zombieMovingClipset)
    SetPedDefaultComponentVariation(ped)
    SetAmbientVoiceName(ped, "jimmyboston")
    createZombiePedExtendedData(ped, true)
    pedSpawned = pedSpawned + 1 
    pedTableList[tostring(pedSpawned)] = ped
    pedTableSpawnTime[tostring(pedSpawned)] = GetGameTimer()
    print(pedSpawned, "pedSpawned")
end

function tableCount(tbl, checkCount)
	if not tbl or type(tbl) ~= "table" then return not checkCount and 0 end
	local n = 0
	for k,v in pairs(tbl) do
		n = n + 1
		if checkCount and n >= checkCount then return true end
	end
	return not checkCount and n
end

function CreatePedFarm(tblData)

    local maxSpawned = m_tblConfigFarm.maxSpawnedPeds
    for _,v in pairs(tblData) do
        if pedSpawned > maxSpawned then return end
        CreateFakePedAttackPlayer(vector3(v.x, v.y, v.z), "s_m_m_marine_01", {
            trust = true,
            unregistered = false,
        })
    end
end

Citizen.CreateThread(function()
    local queuedPeds = {}
	local minDistance = 20
	local minDistanceOther = 25
	local limit = 10
	local intervalSend = 1000 * 15
	local lastSent = 0

    while true do 
        Citizen.Wait(2000)

        local playerPed = PlayerPedId()
        local plPos = GetEntityCoords(PlayerPedId())

        if m_tblConfigFarm.canSpawn and not IsPedFalling(playerPed) then 
            local wantedCoords 
            if DoesEntityExist(playerPed) then
				local x, y, z = table.unpack(GetEntityCoords(playerPed))
				local heading = GetEntityHeading(playerPed)
				
				-- Convertir le heading en radians
				local headingRad = math.rad(heading)
				
				-- Calculer la position devant le joueur (distance de 25-35 unités)
				local distance = math.random(55, 65)
				local offsetX = math.sin(-headingRad) * distance
				local offsetY = math.cos(-headingRad) * distance
				
				x = x + offsetX
				y = y + offsetY

				local coords = vec3(x, y, z)
				local _found, safeCoords = GetSafeCoordForPed(x, y, z, true, 0, 16)

				local coordsFine = GetDistanceBetweenCoords(plPos.x, plPos.y, 0, coords.x, coords.y, 0) >= minDistance
				local safeCoordsFine = safeCoords.x ~= 0 and safeCoords.y ~= 0 and GetDistanceBetweenCoords(plPos.x, plPos.y, 0, safeCoords.x, safeCoords.y, 0) >= minDistance

				if safeCoordsFine or coordsFine then
					wantedCoords = safeCoordsFine and safeCoords or coords
					print("Zombie spawn position found:", wantedCoords.x, wantedCoords.y, wantedCoords.z)
				else
					print("No valid zombie spawn position found")
				end
			end

            if tableCount(pedTableList) < m_tblConfigFarm.maxSpawnedPeds then 
                if wantedCoords and #queuedPeds < limit then
					local me = PlayerId()
					for _,ply in pairs(GetActivePlayers()) do
						if ply ~= me then
							local playerPed = GetPlayerPed(ply)
							local coords = GetEntityCoords(playerPed)
							if DoesEntityExist(playerPed) and GetDistanceBetweenCoords(coords.x, coords.y, 0, wantedCoords.x, wantedCoords.y, 0) < minDistanceOther then
								break
							end
						end
					end

					queuedPeds[#queuedPeds + 1] = { x = wantedCoords.x, y = wantedCoords.y, z = wantedCoords.z }
					print("Zombie queued. Total queued:", #queuedPeds, "Total spawned:", tableCount(pedTableList))
				end
            else
                print("Max zombies reached:", tableCount(pedTableList), "/", m_tblConfigFarm.maxSpawnedPeds)
            end

            local intervalSpawning = m_tblConfigFarm.g_zombieSpawningBoosted and intervalSend / 2 or intervalSend

            if lastSent + intervalSpawning < GetGameTimer() and #queuedPeds > 0 then
                print("Creating zombies:", #queuedPeds)
                CreatePedFarm(queuedPeds)
                queuedPeds = {}
				lastSent = GetGameTimer()
            end
        else

        end
    end
end)

function CanCreatePed()
    return m_tblConfigFarm.canSpawn
end

function DoAnim(dict, anim, flag, more)
	RequestAndWaitDict(dict)

	local ped = more.p or PlayerPedId()
	TaskPlayAnim(ped, dict,anim, more.s or 8.0, more.sm or 4.0, more.d or -1, flag or 0, 0, 0, 0, 0)
end

function TaskZombieAttack(zombie, zombieDist, veh, zombieClass)
    local ped = PlayerPedId()

    -- if not IsAnySpeechPlaying(zombie) then 
    --     PlayAmbientSpeechWithVoice(zombie, "SHOT_BY_PLAYER", "jimmyboston", "SPEECH_PARAMS_INTERRUPT", 0)
    -- end

    if not zombieClass.OnAttack then 
        local attackAnimation = { "rcmbarry", "bar_1_teleport_aln" }
        DoAnim(attackAnimation[1], attackAnimation[2], 16, {sm = 1000, p = zombie})
    end 

    if veh then 
        if not zombieClass.OnVehicleAttack then
			local vehicleModel = GetEntityModel(veh)

			if IsThisModelABicycle(vehicleModel) or IsThisModelABike(vehicleModel) or IsThisModelAQuadbike(vehicleModel) then
				SetPedToRagdoll(ped, 0, 0, 0, 1, 1, 0)
			end
		end
    else
        Citizen.CreateThread(function()
            Citizen.Wait(900)
			if zombieDist > 2.5 then
				TaskWanderStandard(zombie, 1.0, 10)
			end

            if not IsPedRagdoll(zombie) and not IsPedFatallyInjured(zombie) and zombieDist < 1.5 and not IsPedFalling(zombie) and HasEntityClearLosToEntityInFront(zombie, ped) and IsPedOnFoot(zombie) then
				if not m_tblConfigFarm.disableZombieKill then 
					ApplyDamageToPed(ped, 5, false)
                    print("ApplyDamageToPed")
					-- its kill ?
					-- exports.gamemode:SetLastDamageAtNow()
				end

				SetPedMovementClipset(zombie, m_tblConfigFarm.zombieMovingClipset, 1.0)
			end
        end)

    end
end


zombiesDead = {}
deathZombies = 0

Citizen.CreateThread(function()
    local deadZombies = {}
    local deathRemoveTime = 1000 * 30
    while true do 
        Wait(0)

        local plPos = GetEntityCoords(PlayerPedId())

        for k, v in pairs(pedTableList) do 
            local zombieExists = DoesEntityExist(v) 

            if not deadZombies[v] and DecorGetBool(v, "XP_Rewarded") then 
                deadZombies[v] = true
            end

            if not zombieExists or (GetDistanceBetweenCoords(plPos, GetEntityCoords(v)) >= 300 and (not pedTableSpawnTime[v] or pedTableSpawnTime[v] + 1000 * 60 < currentTime)) or (deadZombies[v] and deadZombies[v] + deathRemoveTime <= currentTime) then
				pedTableList[k] = nil
				pedTableSpawnTime[v] = nil
				zombiesDead[k] = nil
                pedSpawned = pedSpawned - 1
				print('bye - zombieExists: ' .. tostring(zombieExists) .. ' - pos: ' .. GetEntityCoords(v) .. ' dist: ' .. tostring(GetDistanceBetweenCoords(plPos, GetEntityCoords(v))) .. " - spawn: " .. tostring(pedTableSpawnTime[v] or 0))
				if zombieExists then
					SetEntityAsNoLongerNeeded(v)
				end
			end
            
        end

        for zombie, tblExtendedData in pairs(m_streamedPedsExtendedData) do 
            if DoesEntityExist(zombie) then 
                local class = tblExtendedData.class 
                if GetEntityHealth(zombie) <= 0 then 
                    if zombiesDead[zombie] == nil then 
                        zombiesDead[zombie] = {
                            pos = GetEntityCoords(zombie),
                            time = GetGameTimer(),
                            zomId = 0,
                            rarity = m_streamedPedsExtendedData[zombie].class.SpawnRate,
                        }
                        pedSpawned = pedSpawned - 1
                        deathZombies = deathZombies + 1
                        print("Zombie dead")
                    end
                end
            else 
                m_streamedPedsExtendedData[zombie] = nil
            end
        end
    end
end)
antizinDisableZombieSpawn = false

function CanHearPed(zombieDist, ped, zombiePos)
    if m_tblConfigFarm.isInDungeon then return true, false end
	if m_tblConfigFarm.disableHearZom then return false end

	if DoesZombieIgnorePlayer() or not IsEntityVisible(ped) or not g_canCreateZombies then return false end

	local distHear = IsPedInAnyVehicle(ped) and (IsHornActive(GetVehiclePedIsIn(ped)) and 400 or 200) or m_tblConfigFarm.closeAttractRange
	if zombieDist < distHear then
		return true
	end

	return false
end

function DoesZombieIgnorePlayer()
	if antizinDisableZombieSpawn then
		return true
	end

	return false
end


local scriptTaskGoToEntity = 1227113341 -- 0x4924437d
local scriptTaskWander = 3148068810 -- 0xbba3b7ca

function SetZombieCanSpawn(bool)
    m_tblConfigFarm.canSpawn = bool
    print("Zombie spawn set to:", bool)
end

-- Fonction pour activer/désactiver facilement les zombies
function ToggleZombieSpawn()
    m_tblConfigFarm.canSpawn = not m_tblConfigFarm.canSpawn
    print("Zombie spawn toggled to:", m_tblConfigFarm.canSpawn)
    ShowAboveRadarMessage(m_tblConfigFarm.canSpawn and "~g~Zombies enabled" or "~r~Zombies disabled")
end

Citizen.CreateThread(function()
	local Player = GetPlayer()
	local serverId = GetPlayerServerId(PlayerId())

	while true do
		Citizen.Wait(1000)

		g_canCreateZombies  = CanCreatePed()
		m_streamedPeds = GetGamePool("CPed")
		m_nStreamedPeds = tableCount(m_streamedPeds) - tableCount(GetActivePlayers())

		local ped = Player.Ped
		local canControlZombies = not m_tblConfigFarm.disableZombie and not IsPedRagdoll(ped) and not IsPedDeadOrDying(ped)

		if canControlZombies then
			local plyPos, veh = Player.Pos, Player:GetVehicle()

			local zombieSpeed = 4.0
			local playerDead = IsEntityDead(ped) or IsPedRagdoll(ped) or not IsEntityVisible(ped)

			for _, zombie in pairs(m_streamedPeds) do
				if zombie and DoesEntityExist(zombie) and not IsPedAPlayer(zombie) and not CheckIfPedActionExist(zombie) then
					local pedPos = GetEntityCoords(zombie)

					if not IsPedInAnyVehicle(zombie) and IsPedHuman(zombie) and not DecorGetBool(zombie, "_PED_SAFE") and not IsPedDeadOrDying(zombie) then
						local isZombie = IsPedZombie(zombie)
						local isNet = NetworkGetEntityIsNetworked(zombie) == 1

						if not isZombie and g_canCreateZombies then
							applyPedParams(zombie, true)
							isZombie = true
						end

						if isZombie then
							if not m_streamedPedsExtendedData[zombie] then
								createZombiePedExtendedData(zombie)
							end

							local tblZombieData = m_streamedPedsExtendedData[zombie]
							tblZombieData.pos = pedPos

							local zombieDistWithoutZ = GetDistanceBetweenCoords(plyPos.x, plyPos.y, 0, pedPos.x, pedPos.y, 0)
							local zombieDist, zombieTarget, zombieClass = GetDistanceBetweenCoords(plyPos.x, plyPos.y, plyPos.z, pedPos.x, pedPos.y, pedPos.z), DecorGetInt(zombie, "_ZOMBIE_TARGET"), tblZombieData.class or {}
							local canGetTarget, isShooting = CanHearPed(zombieDistWithoutZ, ped, pedPos)

							local targetEntity, targetPos = veh or ped, veh and GetEntityCoords(veh) or plyPos
							local canUpdateTask = true

							local blIgnorePlayer = DoesZombieIgnorePlayer()

							-- if zombieDistWithoutZ < 32 and not IsAmbientSpeechPlaying(zombie) then
							-- 	PlayAmbientSpeechWithVoice(zombie, "SHOT_BY_PLAYER", "jimmyboston", "SPEECH_PARAMS_INTERRUPT", 0)
							-- end

							if not blIgnorePlayer and zombieDist < (veh and 2 or 1.4) and not playerDead then
								DecorRemove(zombie, "_ZOMBIE_TARGET")
								DecorRemove(zombie, "ZOMBIE_TIME")
								NetworkRequestControlOfEntity(zombie)
								if canUpdateTask and GetScriptTaskStatus(zombie, scriptTaskGoToEntity) == 7 then
									TaskGoToEntity(zombie, targetEntity, 15000, 0.0, zombieSpeed, 1073741824, 0)
									--TraceLog('go to entity')
									local clipset = m_tblConfigFarm.zombieMovingClipset
									SetPedMovementClipsetSafe(zombie, clipset)
								end

								if IsPedDeadOrDying(ped, 1) then
									if not IsEntityPlayingAnim(zombie, "amb@world_human_bum_wash@male@high@idle_a", "idle_b", 3) and canUpdateTask then
										DoAnim("amb@world_human_bum_wash@male@high@idle_a", "idle_b", 1, {p = zombie})
									end
									--TraceLog('IsPedDeadOrDying')
								else
									if not IsEntityPlayingAnim(zombie, "rcmbarry", "bar_1_teleport_aln", 3) and HasEntityClearLosToEntityInFront(zombie, ped) and canUpdateTask then
										TaskZombieAttack(zombie, zombieDist, veh, zombieClass)
										--TraceLog('TaskZombieAttack')
									end
								end
							elseif canGetTarget and (not isNet or (zombieTarget == serverId or (zombieTarget ~= serverId and DecorGetInt(zombie, "ZOMBIE_TIME") + 1000 * 10 < GetGameTimer())) or zombieDistWithoutZ < 20) then
								if isShooting then
									if canUpdateTask then
										TaskGoToCoordAnyMeans(zombie, targetPos, zombieSpeed, 15000, 0, 786603, 0)
										--TraceLog('isShooting')
									end
									DecorRemove(zombie, "_ZOMBIE_TARGET")
									DecorRemove(zombie, "ZOMBIE_TIME")
								else
									if canUpdateTask and GetScriptTaskStatus(zombie, scriptTaskGoToEntity) == 7 then
										-- TODO: fix, this is updated every 1-2s
										TaskGoToEntity(zombie, targetEntity, 15000, 0.0, zombieSpeed, 1073741824, 0)
										--TraceLog('TaskGoToEntity dd')
									end
									DecorSetInt(zombie, "_ZOMBIE_TARGET", serverId)
									DecorSetInt(zombie, "ZOMBIE_TIME", GetGameTimer())
								end
							elseif (zombieDist > 300 or not canGetTarget or blIgnorePlayer) and DecorGetInt(zombie, "_ZOMBIE_TARGET") == serverId and not m_tblConfigFarm.isInDungeon then
								DecorRemove(zombie, "_ZOMBIE_TARGET")
								DecorRemove(zombie, "ZOMBIE_TIME")
								if canUpdateTask and zombieDist > 300 and GetScriptTaskStatus(zombie, scriptTaskWander) == 7 then
									TaskWanderStandard(zombie, 10.0, 20)
									SetEntityAsNoLongerNeeded(zombie)
									--TraceLog('TaskWanderStandard dd')
								end
							end
						end
					end
				end
			end

			if IS_DEV then
				-- DrawCenterText("Streaming " .. m_nStreamedPeds .. " ped(s)", 1000)
			end
		end
	end
end)

BPlayerReady = true

CreateThread(function()
    local currentLootingZombie = nil

    while true do
        local time = 1000
        local inDarkzone = GM.Player.inDarkzone

        if zombiesDead then
            for k, v in pairs(zombiesDead) do
                local zombieExists = DoesEntityExist(k)
                if not zombieExists then 
                    zombiesDead[k] = nil 
                else
                    local dist = GetDistanceBetweenCoords(GetPlayer().Pos, GetEntityCoords(k))

                    if dist < 7 then
                        time = 0
                        if dist < 6.5 then
                            DrawTetDist(GetEntityCoords(k).x, GetEntityCoords(k).y, GetEntityCoords(k).z + 1.2, "Press ~r~[E]~s~ to loot", 0.42)

                            if IsControlJustPressed(0, 51) and IsPedOnFoot(PlayerPedId()) then
                                if not currentLootingZombie then
                                    currentLootingZombie = k
                                    local currentZombiePos = GetEntityCoords(k)
                                    local playerPos = GetEntityCoords(PlayerPedId())
                                    print("Zombie pos:", currentZombiePos.x, currentZombiePos.y, currentZombiePos.z)
                                    print("Player pos:", playerPos.x, playerPos.y, playerPos.z)
                                    print("Distance:", #(currentZombiePos - playerPos))
                                    Tse("PREFIX_PLACEHOLDER:z:lootZom", { 
                                        rarity = zombiesDead[k].rarity, 
                                        zomPos = { x = currentZombiePos.x, y = currentZombiePos.y, z = currentZombiePos.z },
                                        playerPos = { x = playerPos.x, y = playerPos.y, z = playerPos.z }
                                    }, inDarkzone)
                                    zombiesDead[k] = nil
                                    DeleteEntity(k)

                                    currentLootingZombie = nil
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

        Wait(BPlayerReady and time or 1500)
    end
end)


function DeleteAllZombies()
    -- Supprimer tous les zombies du pool global
    local allPeds = GetGamePool("CPed")
    for _, ped in pairs(allPeds) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and IsPedZombie(ped) then
            DeleteEntity(ped)
            SetEntityAsNoLongerNeeded(ped)
        end
    end
    
    -- Nettoyer pedTableList
    for k, v in pairs(pedTableList) do 
        local zombieExists = DoesEntityExist(v) 
        pedTableList[k] = nil
        pedTableSpawnTime[v] = nil
        zombiesDead[k] = nil
        pedSpawned = pedSpawned - 1
        print('bye - zombieExists: ' .. tostring(zombieExists) .. ' - pos: ' .. GetEntityCoords(v) .. ' dist: ' .. tostring(GetDistanceBetweenCoords(plPos, GetEntityCoords(v))) .. " - spawn: " .. tostring(pedTableSpawnTime[v] or 0))
        if zombieExists then
            DeleteEntity(v)
            SetEntityAsNoLongerNeeded(v)
        end
    end
    
    -- Nettoyer m_streamedPedsExtendedData
    for zombie, _ in pairs(m_streamedPedsExtendedData) do
        if DoesEntityExist(zombie) then
            DeleteEntity(zombie)
            SetEntityAsNoLongerNeeded(zombie)
        end
        m_streamedPedsExtendedData[zombie] = nil
    end
    
    -- Nettoyer zombiesDead
    for zombie, _ in pairs(zombiesDead) do
        if DoesEntityExist(zombie) then
            DeleteEntity(zombie)
            SetEntityAsNoLongerNeeded(zombie)
        end
        zombiesDead[zombie] = nil
    end
    
    -- Reset des compteurs
    pedSpawned = 1
    deathZombies = 0
    
    print("All zombies deleted successfully")
end

RegisterCommand('deletezombies', function()
    DeleteAllZombies()
end)