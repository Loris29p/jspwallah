m_tblSafe = {
    list = {}
}


safezoneId = nil


function loadSafes()
    for _, v in pairs(Safezone.List) do
        if v.load then
            local SafeZoneBlips, SafeZoneblips2 = GM.Blips:CreateBlip(v.coords, v.name, v.sprite, v.color, 0.9, false, false, false, v.radius, v.color, 120)
            table.insert(m_tblSafe.list, { blips = SafeZoneBlips, blips2 = SafeZoneblips2, coords = v.coords, radius = v.radius, sprite = v.sprite, color = v.color, name = v.name, inZone = false, StashPosition = v.StashPosition })
        end
    end
end

function UnloadSafeZone()
    for _, v in pairs(m_tblSafe.list) do
        v.inZone = false
        if DoesBlipExist(v.blips) then
            RemoveBlip(v.blips)
        end
        if DoesBlipExist(v.blips2) then
            RemoveBlip(v.blips2)
        end

        UnloadSafeZonePedAction(v.name)
        ForceUnload()
        if v.name == "Hospital" then 
            RemoveCubeSpawn()
        end
    end
    
    -- Réinitialiser l'état global du joueur
    GM.Player.InSafeZone = false
    inSafe(false)
    Tse("safezone:action", "leave")
    
    -- Réinitialiser les propriétés du joueur
    ResetEntityAlpha(PlayerPedId())
    SetPedSuffersCriticalHits(PlayerPedId(), false)
    SetEntityInvincible(PlayerPedId(), false)
    SetRadarZoomPrecise(-1.0)
    SetPedMoveRateOverride(PlayerId(), 1.0)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
    SetEntityOnlyDamagedByPlayer(PlayerPedId(), true)
    
    m_tblSafe.list = {}
end

-- RegisterCommand("unload_safezone", function()
--     UnloadSafeZone()
-- end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local inAnySafeZone = false

        for _, v in pairs(m_tblSafe.list) do
            if GetDistanceBetweenCoords(playerCoords, v.coords, true) <= v.radius then
                if not v.inZone then
                    v.inZone = true
                    if v.name == "Hospital" then 
                        LoadCubeSpawn()
                        -- InitializeLeaderboard()
                    end
                    LoadSafeZonePedAction(v.name)
                    ShowAboveRadarMessage("~g~You are in safe-zone~s~")
                    -- Tse("safezone:action", "join")
                end
                GM.Player.InSafeZone = true
                inSafe(true, v.name)
                inAnySafeZone = true

                safezoneId = v.name


                break
            else
                if v.inZone then
                    if v.name == "Hospital" then 
                        RemoveCubeSpawn()
                        -- CleanupResources()
                    end
                    ForceUnload()
                    UnloadSafeZonePedAction(v.name)
                    v.inZone = false
                end
            end
        end

        if not inAnySafeZone and GM.Player.InSafeZone and not GM.Player.InSelecGamemode and not GM.Player.LeagueLobby and not GM.Player.InFarm and not GM.Player.Afk and not GM.Player.InGunrace and not GM.Player.InFFA then
            GM.Player.InSafeZone = false
            inSafe(false)
            -- Tse("safezone:action", "leave")
            
            for _,v in pairs(m_tblSafe.list) do
                v.inZone = false
            end

            -- Activer l'effet safezone pendant le décompte de protection
            SendNUIMessage({
                type = "startEffect",
                effect = "safezone"
            })

            for i = 3, 1, -1 do 
                if i == 1 then
                    ShowAboveRadarMessage("~r~Safe protection will end in ~r~1 second.")
                else
                    ShowAboveRadarMessage("~r~Safe protection will end in ~r~"..i.." seconds.")
                end
                Citizen.Wait(1000)
            end
            
            -- Désactiver l'effet safezone après le décompte
            SendNUIMessage({
                type = "stopEffect",
                effect = "safezone"
            })
            
            ResetEntityAlpha(PlayerPedId())
            SetPedSuffersCriticalHits(PlayerPedId(), false)
            SetEntityInvincible(PlayerPedId(), false)
            SetRadarZoomPrecise(-1.0)
            SetPedMoveRateOverride(PlayerId(), 1.0)
            SetRunSprintMultiplierForPlayer(PlayerId(),1.0)
            NetworkSetFriendlyFireOption(true)
            SetCanAttackFriendly(PlayerPedId(), true, true)
            SetEntityOnlyDamagedByPlayer(PlayerPedId(), true)
            SetPedSuffersCriticalHits(PlayerPedId(), false)
    
            GM.Player.InSafeZone = false

        end

        Wait(500)
    end
end)


function NearSafeZone(position, all, isSpawn)

    if isSpawn and CrewData ~= nil then
        Tse("crew:setBucketCrew", CrewData)
        return { coords = vector3(887.3425, -3245.724, -98.2765) }
    else
        Tse("crew:leftCrewBunker")
        local lastCoord = vector3(0, 0, 0)
        local lastDist = 10000 
        local safezone = nil 
        for k, v in pairs(m_tblSafe.list) do 
            if all then 
                local dist = Vdist(position, v.coords.x, v.coords.y, v.coords.z)
                if dist < lastDist then 
                    lastDist = dist
                    safezone = v
                end
            else
                if v.sprite then 
                    local dist = Vdist(position, v.coords.x, v.coords.y, v.coords.z)
                    if dist < lastDist then 
                        lastDist = dist
                        safezone = v
                    end
                end
            end
        end
        return safezone
    end
end

exports("nearSafe", NearSafeZone)

function PlayerInSafeZone()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local safezone = NearSafeZone(coords)
    if safezone then 
        local dist = Vdist(coords, safezone.coords.x, safezone.coords.y, safezone.coords.z)
        if dist < safezone.radius then 
            return true
        end
    end
    return false
end

exports("PlayerInSafeZone", PlayerInSafeZone)

local entityEnumerator = {
	__gc = function(enum)
	if enum.destructor and enum.handle then
		enum.destructor(enum.handle)
	end
	enum.destructor = nil
	enum.handle = nil
	end
}

local EnumerateEntities = function(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
	local iter, id = initFunc()
	if not id or id == 0 then
		disposeFunc(iter)
		return
	end
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
	end)
end

local EnumeratePeds = function()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

local EnumerateVehicles = function()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

local EnumerateObjects = function()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

-- Citizen.CreateThread(function()
-- 	local player = GM.Player:Get()
-- 	while true do 
-- 		Wait(1200)
-- 		local pPed = PlayerPedId()

-- 		for peds in EnumeratePeds() do 
-- 			SetEntityLodDist(peds, 40)
-- 		end
-- 		for vehicles in EnumerateVehicles() do 
-- 			SetEntityLodDist(vehicles, 40)
-- 		end

-- 		if not player.InSafeZone then
--             local coords = GetEntityCoords(PlayerPedId())
--             local found, floorZ = GetGroundZFor_3dCoord_2(coords.x, coords.y, coords.z, 0, 0)
--             local distanceRender = 140
--             if found and (coords.z - floorZ) >= 50.0 then
--                 distanceRender = 400
--             else
--                 distanceRender = (GetSettingsValue("optimization") == true and 175 or 250)
--             end

--             for peds in EnumeratePeds() do 
-- 				SetEntityLodDist(peds, distanceRender)
-- 			end
-- 			for vehicles in EnumerateVehicles() do 
-- 				SetEntityLodDist(vehicles, distanceRender)
-- 			end

-- 		end
-- 	end
-- end)

local Vehicles = {}
local Players = {}

local listSafeVehicles = {
    "deluxo",
    "oppressor",
    "scarab",
    "nightshark",
}

local SetCollisions = function(toggle)
    local playerPed = PlayerPedId()
    local pVehicle = IsPedInAnyVehicle(playerPed) and GetVehiclePedIsUsing(playerPed) or nil

    for k,v in pairs(Vehicles) do
        -- Check if the vehicle model is in the listSafeVehicles
        local vehicleModel = GetEntityModel(k)
        local modelName = GetDisplayNameFromVehicleModel(vehicleModel):lower()
        local isSafeVehicle = false

        -- Check if the vehicle is in the safe vehicles list
        for _, safeModel in ipairs(listSafeVehicles) do
            if modelName == safeModel:lower() then
                isSafeVehicle = true
                break
            end
        end

        -- Only modify collision if it's not a safe vehicle
        if not isSafeVehicle then
            SetEntityNoCollisionEntity(k, playerPed, toggle)
            SetEntityNoCollisionEntity(playerPed, k, toggle)
            if pVehicle then
                SetEntityNoCollisionEntity(k, pVehicle, toggle)
            end
        end
    end

    for k,v in pairs(Players) do
        SetEntityNoCollisionEntity(k, playerPed, toggle)
    end

    return
end


local UpdateCollisionsTable = function()
    for pl in EnumeratePeds() do
        local otherPlayerPed = IsPedAPlayer(pl) and pl or nil
        if otherPlayerPed and not Players[otherPlayerPed] and otherPlayerPed ~= PlayerPedId() then
            Players[otherPlayerPed] = true
        end
    end 

    for vehicle in EnumerateVehicles() do 
        if not Vehicles[vehicle] then
            Vehicles[vehicle] = true
        end
    end

    return 
end

local function GetListPlayers()
    local result = ListPlayersServerGlobal
    if result then 
        return result
    end
    return {}
end

local function ListPlayersNearby()
    local players = GetListPlayers()
    local players2 = GetNearbyPlayers(100)
    local returnTable = {}
    for k, v in pairs(players) do 
        for k2, v2 in pairs(players2) do 
            if v.source == GetPlayerServerId(v2) then 
                table.insert(returnTable, {
                    username = v.username,
                    id = GetPlayerServerId(v2),
                    uuid = v.uuid,
                    playerId = v2,
                })
            end
        end
    end

    return returnTable
end


local function Draw3DText(x, y, z, text, scale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function inSafe(bool, safezoneId) 
    UpdateCollisionsTable()
    local pPed = PlayerPedId()
    if bool then 
        SetCollisions(false)
        SetEntityInvincible(pPed, true)
        SetPlayerInvincible(PlayerPedId(), true)
        SetRadarZoomPrecise(70.0)
        if GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "boss" then 
            SetPedMoveRateOverride(PlayerId(), 10.0)
            SetRunSprintMultiplierForPlayer(PlayerId(),1.70)
        end
        NetworkSetFriendlyFireOption(false)
		SetCanAttackFriendly(pPed, false, false)
    else 
        SetCollisions(true)
    end
end

Citizen.CreateThread(function()
    local timer = 1000
    while true do 
        if GM.Player.InSafeZone then 
            local isSomeoneTalking = false
            local playersTable = ListPlayersNearby()
            local pPed = PlayerPedId()
            for k , v in pairs(playersTable) do     
                if NetworkIsPlayerTalking(v.playerId) then 
                    local targetPed = GetPlayerPed(v.playerId) 
                    local playerCoords = GetEntityCoords(pPed)
                    local targetCoords = GetEntityCoords(targetPed) 
                    local distance = #(playerCoords - targetCoords)
                    if distance <= 15.0 then 
                        isSomeoneTalking = true
                        timer = 1
                        Draw3DText(targetCoords.x, targetCoords.y, targetCoords.z + 0.950, "[" .. v.uuid.."] "..v.username, 0.4)
                    end
                end
            end
            timer = isSomeoneTalking and 1 or 100
        else
            timer = 1000 
        end
        Citizen.Wait(timer)
    end
end)

local function DrawText3D(data)
    SetTextScale(0.50, 0.50)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextDropShadow()
    local totalLenght = string.len(data.text)
    local textMaxLenght = data.textMaxLenght or 99 -- max 99
    local text = totalLenght > textMaxLenght and data.text:sub(1, totalLenght - (totalLenght - textMaxLenght)) or data.text
    AddTextComponentString(text)
    SetDrawOrigin(data.coords.x, data.coords.y, data.coords.z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    local timer = 1000
    while true do 
        if GM.Player.InSafeZone then 
            local vehicleNear = false
            local playersTable = ListPlayersNearby()
            local pPed = PlayerPedId()
            for k , v in pairs(playersTable) do     
                local targetPed = GetPlayerPed(v.playerId) 
                local playerCoords = GetEntityCoords(pPed)
                local targetCoords = GetEntityCoords(targetPed) 
                local distance = #(playerCoords - targetCoords)
                if distance <= 3.0 and IsPedInAnyVehicle(pPed, false) and IsPedInAnyVehicle(targetPed, false) and GetEntityModel(GetVehiclePedIsIn(targetPed, false)) == GetEntityModel(GetVehiclePedIsIn(pPed, false)) then 
                    local vehicle = GetVehiclePedIsIn(targetPed, false)
                    local customVehicle = GetVehicleData(vehicle)
                    DrawText3D({
                        coords = vec3(targetCoords.x, targetCoords.y, targetCoords.z + 1.0),
                        text = "PRESS ~r~H~s~ TO COPY THE CUSTOM VEHICLE",
                    })
                    if IsControlPressed(0, 74) then
                        SetVehicleData(GetVehiclePedIsIn(pPed, false), customVehicle)
                        Tse('LCS_SaveVehicle', customVehicle)
                    end
                    vehicleNear = true
                end
            end
            
            timer = vehicleNear and 1 or 1000
        else
            timer = 1000
        end
        Citizen.Wait(timer)
    end
end)

function IsCurrentPositionProtected(position, radius)
    for k, v in pairs(m_tblSafe.list) do 
        local dist = Vdist(position, v.coords.x, v.coords.y, v.coords.z)
        if radius then 
            if dist < radius then 
                return true
            end
        end
    end
    return false
end

exports("IsCurrentPositionProtected", IsCurrentPositionProtected)


-- Citizen.CreateThread(function()
--     while true do 
--         local timer = 1000
--         local playerPed = PlayerPedId() 
--         local playerCoords = GetEntityCoords(playerPed)
--         local coordsCompare = vector4(194.1077, -942.0842, 30.69178, 325.4779)
--         local dist = #(playerCoords - vector3(coordsCompare.x, coordsCompare.y, coordsCompare.z))
--         if dist <= 15.0 then 
--             timer = 1
--             DrawText3d2(0, "Welcome on ~r~Guild PvP~s~.", coordsCompare.x, coordsCompare.y, coordsCompare.z + 2.0, 15.0, 1.0, 0.5, false)
--             DrawText3d2(0, "~r~/kit ~s~to unlock the kits you can access.", coordsCompare.x, coordsCompare.y, coordsCompare.z + 1.5, 15.0, 0.8, 0.5, false)
--             DrawText3d2(0, "You can change your character's appearance in the ~r~inventory ~s~by going to ~r~My Locker", coordsCompare.x, coordsCompare.y, coordsCompare.z + 1.3, 15.0, 0.8, 0.5, false)
--             DrawText3d2(0, "~r~/createcrew~s~ & ~r~/crew ~s~to ~r~create~s~ or ~r~manage~s~ your crew", coordsCompare.x, coordsCompare.y, coordsCompare.z + 1.1, 15.0, 0.8, 0.5, false)
--             DrawText3d2(0, "~r~/prestige~s~ to see your prestiges, or pass them on.", coordsCompare.x, coordsCompare.y, coordsCompare.z + 0.9, 15.0, 0.8, 0.5, false)
--         end
--         Citizen.Wait(timer)
--     end
-- end)

local url = "https://cfx-nui-gamemode/ui/spawn.html"

local scale = 0.13
local sfName = 'generic_texture_renderer_5'

local width = 1920
local height = 1080

local sfHandle = nil
local txdHasBeenSet = false
local duiObj = nil

local testCoords = vector3(227.4014, -1401.897, 30.28226)
duiLoadedSpawn = false


function loadScaleform(scaleform)
    local scaleformHandle = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleformHandle) do 
        scaleformHandle = RequestScaleformMovie(scaleform)
        Citizen.Wait(0) 
    end
    return scaleformHandle
end

function LoadCubeSpawn()
    duiLoadedSpawn = true
    sfHandle = loadScaleform(sfName)
    runtimeTxd = 'meows'

    local txd = CreateRuntimeTxd('meows')
    duiObj = CreateDui(url, width, height)
    local dui = GetDuiHandle(duiObj)
    local tx = CreateRuntimeTextureFromDuiHandle(txd, 'woof', dui)

    Citizen.CreateThread(function()
        while duiLoadedSpawn do 
            if (sfHandle ~= nil and not txdHasBeenSet) then
                print('SET_TEXTURE')
                PushScaleformMovieFunction(sfHandle, 'SET_TEXTURE')
            
                PushScaleformMovieMethodParameterString('meows')
                PushScaleformMovieMethodParameterString('woof')
            
                PushScaleformMovieFunctionParameterInt(0)
                PushScaleformMovieFunctionParameterInt(0)
                PushScaleformMovieFunctionParameterInt(width)
                PushScaleformMovieFunctionParameterInt(height)
            
                PopScaleformMovieFunctionVoid()
            
                txdHasBeenSet = true
            end
    
            if (sfHandle ~= nil and HasScaleformMovieLoaded(sfHandle)) then
                DrawScaleformMovie_3dNonAdditive(sfHandle, testCoords.x, testCoords.y, testCoords.z+2, 0.0, 215.0, 0.0, 2, 2, 2, scale * 1, scale * (9/16), 1, 2)
            end
            Citizen.Wait(0)
        end
    end)

    Citizen.CreateThread(function()
        while duiLoadedSpawn do 
            Wait(6000)
            SendDuiMessage(duiObj, json.encode({type = "displayTextSpawn", message = ColorTableHex["red"].."Join the discord discord.gg/guildpvp", typingSpeed = 40}))
            Wait(5000)
            SendDuiMessage(duiObj, json.encode({type = "deleteAllText"}))
            Wait(1000)
            SendDuiMessage(duiObj, json.encode({type = "displayTextSpawn", message = ColorTableHex["red"].."If you need help just /report", typingSpeed = 40}))
            SendDuiMessage(duiObj, json.encode({type = "displayTextSpawn", message = ColorTableHex["red"].."/kits or F4 to unlock the kits you can access.", typingSpeed = 40}))
            Wait(5000)
            SendDuiMessage(duiObj, json.encode({type = "deleteAllText"}))

        end
    end)
    
end

function RemoveCubeSpawn()
    duiLoadedSpawn = false
    sfHandle = nil
    txdHasBeenSet = false
    DestroyDui(duiObj)
    duiObj = nil
end
