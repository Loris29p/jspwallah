_RegisterNetEvent("kAirdrop:client:CreateDrop")
_AddEventHandler("kAirdrop:client:CreateDrop", function(drops, id, timer)
    ShowAboveRadarMessage("~r~An airdrop is coming check your map.")
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
    CreateAirship(drops, id, timer)

end)

local setSpeed = SetVehicleForwardSpeed

local soundID

function GetHeadingBetweenVector(fromPosition, targetPosition)
	return math.deg(math.atan2(targetPosition.y - fromPosition.y, fromPosition.x - targetPosition.x))
end

function Request(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
    return model
end

dropVehiclesDisable = {
    [GetHashKey("deluxo")] = true,
    [GetHashKey("oppressor")] = true,
    [GetHashKey("buzzard2")] = true,
    [GetHashKey("buzzard")] = true,
    [GetHashKey("frogger")] = true,
    [GetHashKey("maverick")] = true,
    [GetHashKey("swift")] = true,
    [GetHashKey("swift2")] = true,
    [GetHashKey("valkyrie")] = true,
    [GetHashKey("thruster")] = true,
    [GetHashKey("seasparrow")] = true,
}

props = {}

local _in = Citizen.InvokeNative
DrawGameRect = function(x, y, width, height, r, g, b, a)
	return _in(0x3A618A217E5154F0, x, y, width, height, r, g, b, a)
end

local propName = "bkr_prop_rt_clubhouse_plan_01a"
local screenRD = "clubhouse_plan_01a"

local startTimer = 60 * 7

local endTimer = 60 * 7


local entities = {}
local function createLightStatusProp(crate, enabled)
	local lightModel = enabled and "prop_runlight_g" or "prop_runlight_r"
	Request(lightModel)

	local cratePosition = GetEntityCoords(crate)
	local prop = CreateObjectNoOffset(GetHashKey(lightModel), cratePosition.x, cratePosition.y, cratePosition.z, false, false, false)
	SetEntityInvincible(prop, true)
	FreezeEntityPosition(prop, true)
	entities[#entities + 1] = prop

	AttachEntityToEntity(prop, crate, 0.0, vec3(0.4, 0, 0.52), vec3(0, 0, 0), 0, 0, 0, 0, 2, 1)

	return prop
end

function RequestScene(x, y, z)
	NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
	local tempTimer = GetGameTimer()
	while not IsNewLoadSceneLoaded() and tempTimer + 3000 > GetGameTimer() do
		Citizen.Wait(100)
	end
	return true
end

local function createRenderTargetProp(crate)
	Request(propName)

	local cratePosition = GetEntityCoords(crate)
	local prop = CreateObjectNoOffset(GetHashKey(propName), cratePosition.x, cratePosition.y, cratePosition.z, false, false, false)
	SetEntityInvincible(prop, true)
	FreezeEntityPosition(prop, true)
	entities[#entities + 1] = prop

	AttachEntityToEntity(prop, crate, 0.0, vec3(0, 0, 0.57), vec3(-90, 90, 0), 0, 0, 0, 0, 2, 1)

	local renderTarget = CreateNamedRenderTargetForModel(screenRD, GetHashKey(propName))

	return prop, renderTarget
end

function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

function DrawText3D(coords, text, scl) 
    local onScreen,_x,_y=World3dToScreen2d(coords.x,coords.y,coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz) - coords)
 
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
		SetTextScale(0.0*scale, 1.1*scale)
		SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function Request(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
    return model
end

function StartPtfx(entity)
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Citizen.Wait(1)
        end
    end
    SetPtfxAssetNextCall("core")
    local smoke = StartParticleFxLoopedOnEntity("exp_grd_flare", entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75, false, false, false, false)
    SetEntityVelocity(crate, 0.0, 0.0, -0.2)
    SetParticleFxLoopedAlpha(smoke, 0.8)
    SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
    FreezeEntityPosition(box, true)
    Citizen.CreateThread(function()
        Citizen.Wait(60000*4)
        StopParticleFxLooped(smoke, 0)
    end)
end

_RegisterNetEvent("kAirdrop:client:syncNpc")
_AddEventHandler("kAirdrop:client:syncNpc", function(k)
    local entity = NetworkGetEntityFromNetworkId(k)
    if DoesEntityExist(entity) then 
        DeleteEntity(entity)
    end
end)

_RegisterNetEvent("kAirdrop:client:syncDeleteDrop")
_AddEventHandler("kAirdrop:client:syncDeleteDrop", function(k)
    if props[k] ~= nil then 
        if props[k].renderProp then
            DeleteEntity(props[k].renderProp)
        end
        if props[k].lightProp then
            DeleteEntity(props[k].lightProp)
        end
        if props[k].entity then
            DeleteEntity(props[k].entity)
        end
        props[k] = nil
        if IsNamedRendertargetRegistered(screenRD) then
            ReleaseNamedRendertarget(screenRD)
        end
    end
    if blipRadius then
        RemoveBlip(blipRadius)
    end
    StopSound(soundID)
    ReleaseSoundId(soundID)
end)

_RegisterNetEvent("kAirdrop:client:createBox", function(coords, id, timer)
    CreateDropBox(coords, id, timer)
end)

function CreateDropBox(coords, id, timer)
    Citizen.CreateThread(function()
        RequestScene(coords.x, coords.y, coords.z)
    end)
    local model = Request('prop_mil_crate_01')  --prop_drop_crate_01
    local object = {
        x = coords.x, 
        y = coords.y,
        z = coords.z,
        entity = CreateObject(model, coords.x, coords.y, coords.z, false, true),
        startTimer = timer,
        endTimer = "nil",
        isOpen = false,
        hitFloor = true
    }
    SetEntityAsMissionEntity(object.entity, true, true)
    if not DoesEntityExist(object.entity) then return end
    local blip = AddBlipForEntity(object.entity)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 6)
    blipRadius = AddBlipForRadius(coords.x, coords.y, coords.z, 300.0)
    SetBlipColour(blipRadius, 7)
    SetBlipAlpha(blipRadius, 80)
    SetEntityLodDist(object.entity, 9999)
    ActivatePhysics(object.entity)
    SetEntityDynamic(object.entity, true)
    SetDamping(object.entity, 2, 0.1) 
    SetEntityVelocity(object.entity, 0.0, 0.0, -50.8) 
    SetModelAsNoLongerNeeded(model)
    PlaceObjectOnGroundProperly(object.entity)
    FreezeEntityPosition(object.entity, true)

    CreateThread(function() 
        while DoesBlipExist(blipRadius) do 
            Citizen.Wait(0)
    
            local playerPed = PlayerPedId()
            local playerVehicle = GetVehiclePedIsIn(playerPed, false)
            local playerCoords = GetEntityCoords(playerPed)
    
            if IsPedInAnyVehicle(playerPed) and dropVehiclesDisable[GetEntityModel(playerVehicle)] then
                local blipCoords = GetBlipCoords(blipRadius)
                local blipRadius = 300.0
    
                if Vdist(playerCoords.x, playerCoords.y, playerCoords.z, blipCoords.x, blipCoords.y, blipCoords.z) <= blipRadius then
                    SetVehicleEngineOn(playerVehicle, false, true, true)
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        props[id] = object
        -- checkHitFloor()
        airdropMain()
        -- while not object.hitFloor do 
        --     Citizen.Wait(250)
        -- end
        StartPtfx(props[id].entity)    
    end)
end

function DrawText2(intFont, strText, floatScale, intPosX, intPosY, color, boolShadow, intAlign, addWarp)
	SetTextFont(intFont)
	SetTextScale(floatScale, floatScale)

	if boolShadow then
		SetTextDropShadow(0, 0, 0, 0, 0)
	end

	SetTextColour(color[1], color[2], color[3], 255)
	if intAlign == 0 then
		SetTextCentre(true)
	else
		SetTextJustification(intAlign or 1)
		if intAlign == 2 then
			SetTextWrap(0.0, addWarp or intPosX)
		end
	end

	BeginTextCommandDisplayText("jamyfafi")
	AddLongString(strText)

	EndTextCommandDisplayText(intPosX, intPosY)
end

function AddLongString(txt)
	if not txt then return end
	local maxLen = 100
	for i = 0, string.len(txt), maxLen do
		local sub = string.sub(txt, i, math.min(i + maxLen, string.len(txt)))
		AddTextComponentSubstringPlayerName(sub)
	end
end

function drawTimer(sec)
	local isOpen = sec <= 0
	local backgroundColor = isOpen and { 0, 200, 0, 100 } or { 150, 0, 0, 100 }

	if not isOpen then
		DrawText2(2, "LOCKED", 1.35, 0.425, 0.53, {255, 255, 255, 255}, 0, 0)
		DrawText2(0, SecondsToClock(sec), 1.0, 0.425, 0.60, {150, 150, 150, 255}, 0, 0)
	else
		DrawText2(2, "🔓", 1.5, 0.425, 0.55, {255, 255, 255, 255}, 0, 0)
	end

	DrawGameRect(0.425, 0.6, 0.15, 0.2, 0, 0, 0, 200)
	local offset = 0.04
	DrawGameRect(0.425, 0.6, 0.15 - offset / 2, 0.2 - offset, backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4])
end

function SecondsToClock(seconds)
	seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00"
	else
		local mins = string.format("%02.f", math.floor(seconds / 60))
		local secs = string.format("%02.f", math.floor(seconds - mins * 60))
		return string.format("%s:%s", mins, secs)
	end
end

IS_DEV = true
function checkHitFloor()
    Citizen.CreateThread(function()
        local dropIntervalCheckTime = 20
        local zOffset = 1.0 or 0.05
        local zInterval = 7 or 25
        local function hasCrateHitFloor(crate, tblAirdropCrateState, position)
            if GetEntityHeightAboveGround(crate) <= 1.5 or tblAirdropCrateState.z <= 1.0 then return true end

            if tblAirdropCrateState.floorZ and (position.z - 1.8) <= tblAirdropCrateState.floorZ then
                return true
            end

            return false
        end
        while true do  
            local waitTime = 200
            local currentTime = GetGameTimer()
            for k, v in pairs(props) do 
                local crate = v.entity
                if crate and DoesEntityExist(crate) then 
                    if not v.hitFloor then 
                        local position = GetEntityCoords(crate)
                        if not v.lastMovedAt or v.lastMovedAt + zInterval <= GetGameTimer() then
                            SetEntityCoordsNoOffset(crate, position.x, position.y, position.z - zOffset)
                            v.lastMovedAt = GetGameTimer()
                        end

                        if v.z and (not v.lastCheckAt or v.lastCheckAt + dropIntervalCheckTime <= currentTime) then
                            if not v.floorZ then
                                local found, floorZ = GetGroundZFor_3dCoord_2(position.x, position.y, position.z, 0, 0)
                                if found then
                                    v.floorZ = floorZ + 1.0
                                end
                            end

                            if hasCrateHitFloor(crate, v, position) then
                                v.hitFloor = true

                                local currentZPosition = position.z
                                PlaceObjectOnGroundProperly(crate)

                                local newPosition = GetEntityCoords(crate)
                                local bestZ = v.floorZ and (newPosition.z >= v.floorZ and newPosition.z or v.floorZ) or currentZPosition
                                Tse("setDropData", k, bestZ)
                            end

                            v.lastCheckAt = currentTime

                            v.z = position.z
                            waitTime = 0
                        end
                    end
                end
            end
            Citizen.Wait(waitTime)
        end
    end)
end

function airdropMain()
    Citizen.CreateThread(function()
        while true do 
            local nearby = false
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            for k,v in pairs(props) do 
                if v ~= nil and k ~= nil and DoesEntityExist(v.entity) then
                    local boxCoords = GetEntityCoords(v.entity)
                    local dist = #(coords - boxCoords)
                    nearby = true
                    if dist < 16.0 then 
                        local time = (v.startTimer - GetCloudTimeAsInt() + startTimer)
                        local isOpen = time < 0
                        if not v.lightProp or v.isOpen ~= isOpen then
                            if v.lightProp then DeleteEntity(v.lightProp) end
                            v.lightProp = createLightStatusProp(v.entity, isOpen)
                            v.isOpen = isOpen 
                        end
                        if not v.renderTarget then 
                            local prop, handle = createRenderTargetProp(v.entity)
                            v.renderTarget = handle
                            v.renderProp = prop
                        end
                        if v.renderTarget then
                            SetTextRenderId(v.renderTarget)
                            SetScriptGfxDrawOrder(4)
                            SetScriptGfxDrawBehindPausemenu(true)
                            drawTimer(time)
                            SetTextRenderId(GetDefaultScriptRendertargetRenderId())
                            SetScriptGfxDrawBehindPausemenu(false)
                        end


                        local heightDiff = coords.z - boxCoords.z
                        local canLoot = dist <= 2.5 and heightDiff <= 3.0 and heightDiff >= -1.0
                                        
                        if canLoot and isOpen and not IsPedInAnyVehicle(PlayerPedId(), false) then
                            DrawTopNotification("Press ~INPUT_CONTEXT~ to open the airdrop")

                            if IsControlJustPressed(0, 51) and isOpen and canLoot and not IsPedInAnyVehicle(PlayerPedId(), false) and not inDropInventory then 
                                Tse("zoliax:dropSrv", "open_drop", { dropId = k } )
                                inDropInventory = true
                            end
                        
                        end
    

                    elseif v.renderTarget then 
                        DeleteEntity(v.renderProp)
                        if v.lightProp then DeleteEntity(v.lightProp) end
                        v.lightProp = nil
                        v.renderTarget = nil
                        if IsNamedRendertargetRegistered(screenRD) then
                            ReleaseNamedRendertarget(screenRD)
                        end
                    end
                end
            end
            if not nearby then 
                Citizen.Wait(1000)
            end
            Citizen.Wait(1)
        end
    end)
end

function CreateAirship(dropCoords, id, timer)
    EventManagerGlobalTitle = "~r~Event Manager - ~r~ AIRDROP"
    local airshipmodel = Request('titan')
    local pModel = Request('u_m_y_pogo_01')
    local rHeading = 360.0
    local planeSpawnDistance = (planeSpawnDistance and tonumber(planeSpawnDistance) + 0.0) or 400.0 -- this defines how far away the plane is spawned
    local theta = (rHeading / 180.0) * 3.14
    local rPlaneSpawn = vector3(dropCoords['start'].x, dropCoords['start'].y, dropCoords['start'].z) - vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance, -500.0) -- the plane is spawned at
    local dx = dropCoords['start'].x - rPlaneSpawn.x
    local dy = dropCoords['start'].y - rPlaneSpawn.y
    local heading = GetHeadingFromVector_2d(dx, dy) -- determine plane heading from coordinates
    local aircraft = CreateVehicle(airshipmodel, rPlaneSpawn.x, rPlaneSpawn.y,  rPlaneSpawn.z, heading, false, true)
	if not DoesEntityExist(aircraft) then return false, "plane does not exist" end

    SetEntityAsMissionEntity(aircraft, true, true)
    SetModelAsNoLongerNeeded(airshipmodel)
    local blip = AddBlipForEntity(aircraft)
    SetBlipSprite(blip, 64)
    SetBlipColour(blip, 6)
    SetEntityHeading(aircraft, heading)
    SetVehicleDoorsLocked(aircraft, 2) -- lock the doors so pirates don't get in
    SetEntityDynamic(aircraft, true)
    ActivatePhysics(aircraft)
    setSpeed(aircraft, 120.0)
    SetHeliBladesFullSpeed(aircraft) -- works for planes I guess
    SetVehicleEngineOn(aircraft, true, true, true)
    ControlLandingGear(aircraft, 3) -- retract the landing gear
    OpenBombBayDoors(aircraft) -- opens the hatch below the plane for added realism
    SetEntityProofs(aircraft, true, false, true, false, false, false, false, false)
	SetEntityInvincible(aircraft, true)
	SetEntityCollision(aircraft, false, true)
	SetPlaneTurbulenceMultiplier(aircraft, 0.0)
	SetHeliBladesFullSpeed(aircraft)
	SetEntityLodDist(aircraft, 2000)
	SetVehicleIsConsideredByPlayer(aircraft, false)
	SetVehicleCanBeVisiblyDamaged(aircraft, false)
	SetVehicleEngineCanDegrade(aircraft, false)
	SetEntitySomething(aircraft, false)
	SetVehicleJetEngineOn(aircraft, true)
	SetTaskVehicleGotoPlaneMinHeightAboveTerrain(aircraft, 1.0)

    local pilot = CreatePed(4, pModel, rPlaneSpawn.x, rPlaneSpawn.y,  rPlaneSpawn.z, 0.0, false, true)

    if not pilot then return print('no pilot') end
    SetEntityAsMissionEntity(pilot, true, true)
    SetModelAsNoLongerNeeded(pModel)


    FreezeEntityPosition(pilot, true, true)
    SetEntityAsMissionEntity(pilot, true, true)
	SetBlockingOfNonTemporaryEvents(pilot, true)
	TaskSetBlockingOfNonTemporaryEvents(pilot, true)
	SetEntityLodDist(pilot, 2000)
    SetPedRandomComponentVariation(pilot, false)
    SetPedKeepTask(pilot, true)
	SetDriverAbility(pilot, 0.5)
	SetPedConfigFlag(pilot, 116, true)
	SetPedConfigFlag(pilot, 118, true)
	SetPedIntoVehicle(pilot, aircraft, -1)

    SetBlockingOfNonTemporaryEvents(pilot, true) -- ignore explosions and other shocking events
    SetPedRandomComponentVariation(pilot, false)
    TaskVehicleDriveToCoord(pilot, aircraft, vector3(dropCoords['drop'].x, dropCoords['drop'].y, dropCoords['drop'].z) + vector3(0.0, 0.0, 500.0), 30.0, 8.0, 'cuban800', 262144, 20.0) -- to the dropsite, could be 
    
    local vehicleDriveToCoordTask = 2477085294
    local taskDoneStatus = 7
    local planeCoords = GetEntityCoords(aircraft)
    local planeLocation = vector2(planeCoords.x, planeCoords.y)
    local dropC = vector2(dropCoords['drop'].x, dropCoords['drop'].y)
    -- print(DoesEntityExist(aircraft), #(planeLocation - dropC), json.encode(planeCoords))

    while (DoesEntityExist(aircraft) and #(planeLocation - dropC) > 20.0) do
        planeCoords = GetEntityCoords(aircraft)
        planeLocation = vector2(planeCoords.x, planeCoords.y)
        -- print(#(planeLocation - dropC), DoesEntityExist(aircraft), json.encode(planeCoords))

        Citizen.Wait(200)
    end
    TaskVehicleDriveToCoord(pilot, aircraft, vector3(dropCoords['drop'].x, dropCoords['drop'].y, dropCoords['drop'].z) + vector3(0.0, 0.0, 500.0), 60.0, 8.0, 'cuban800', 262144, 20.0) -- to the dropsite, could be 
    Tse('kAirdrop:server:createBox', dropCoords['drop'], id, timer ~= nil and timer or GetCloudTimeAsInt())
    Citizen.Wait(5000)
    SetEntityAsNoLongerNeeded(pilot)
    delEntity(pilot)
    SetEntityAsNoLongerNeeded(aircraft)
    delEntity(aircraft)

    -- print('all done')
end

function delEntity(entity)
    local owner = NetworkGetEntityOwner(entity)
    if owner == -1 or owner == PlayerId() then
        DeleteEntity(entity)
    else
        DeleteEntity(entity)
        StopSound(soundID)
        ReleaseSoundId(soundID)
        Tse('kAirdrop:server:syncNpc', NetworkGetNetworkIdFromEntity(entity))
    end
end


function deleteEntity(entity)
    return DeleteEntity(entity)--retval
end

Citizen.CreateThread(function()
    while true do 
        for k,v in pairs(props) do 
            if v ~= nil and v.startTimer ~= nil and v.endTimer ~= nil then 
                local startT = (v.startTimer - GetCloudTimeAsInt() + startTimer) 
                if startT < 0 then 
                    if v.endTimer == "nil" then
                        v.endTimer = GetCloudTimeAsInt()
                    else
                        local endT = (v.endTimer - GetCloudTimeAsInt() + endTimer)
                        if endT < 0 then
                            StopSound(soundID)
                            ReleaseSoundId(soundID)
                            Tse('kAirdrop:server:syncDeleteDrop', k)
                        end
                    end
                end
            end
        end
        Citizen.Wait(1000)
    end
end)