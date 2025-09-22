Admin = Admin or {}
Admin.Cam = nil 
Admin.InSpec = false
Admin.SpeedNoclip = 1
Admin.CamCalculate = nil
Admin.CamTarget = {}
Admin.Scalform = nil 

Admin.DetailsScalform = {
    speed = {
        control = 178,
        label = "Vitesse"
    },
    spectateplayer = {
        control = 24,
        label = "Spectate le joueur"
    },
    gotopos = {
        control = 51,
        label = "Revenir ici"
    },
    sprint = {
        control = 21,
        label = "Rapide"
    },
    slow = {
        control = 36,
        label = "Lent"
    },
}

Admin.DetailsInSpec = {
    exit = {
        control = 45,
        label = "Quitter"
    },
}

function DrawTextAdmin(msg, font, size, posx, posy)
    SetTextFont(font) 
    SetTextProportional(0) 
    SetTextScale(size, size) 
    SetTextDropShadow(0, 0, 0, 0,255) 
    SetTextEdge(1, 0, 0, 0, 255) 
    SetTextEntry("STRING") 
    AddTextComponentString(msg or "null") 
    DrawText(posx, posy) 
end

function Admin:TeleportCoords(vector, peds)
	if not vector or not peds then return end
	local x, y, z = vector.x, vector.y, vector.z + 0.98
	peds = peds or PlayerPedId()

	RequestCollisionAtCoord(x, y, z)
	NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)

	local TimerToGetGround = GetGameTimer()
	while not IsNewLoadSceneLoaded() do
		if GetGameTimer() - TimerToGetGround > 3500 then
			break
		end
		Citizen.Wait(0)
	end

	SetEntityCoordsNoOffset(peds, x, y, z)

	TimerToGetGround = GetGameTimer()
	while not HasCollisionLoadedAroundEntity(peds) do
		if GetGameTimer() - TimerToGetGround > 3500 then
			break
		end
		Citizen.Wait(0)
	end

	local retval, GroundPosZ = GetGroundZCoordWithOffsets(x, y, z)
	TimerToGetGround = GetGameTimer()
	while not retval do
		z = z + 5.0
		retval, GroundPosZ = GetGroundZCoordWithOffsets(x, y, z)
		Wait(0)

		if GetGameTimer() - TimerToGetGround > 3500 then
			break
		end
	end

	SetEntityCoordsNoOffset(peds, x, y, retval and GroundPosZ or z)
	NewLoadSceneStop()
	return true
end

function SetScaleformParams(scaleform, data)
	data = data or {}
	for k,v in pairs(data) do
		PushScaleformMovieFunction(scaleform, v.name)
		if v.param then
			for _,par in pairs(v.param) do
				if math.type(par) == "integer" then
					PushScaleformMovieFunctionParameterInt(par)
				elseif type(par) == "boolean" then
					PushScaleformMovieFunctionParameterBool(par)
				elseif math.type(par) == "float" then
					PushScaleformMovieFunctionParameterFloat(par)
				elseif type(par) == "string" then
					PushScaleformMovieFunctionParameterString(par)
				end
			end
		end
		if v.func then v.func() end
		PopScaleformMovieFunctionVoid()
	end
end
function CreateScaleform(name, data) -- Créer un scalform
	if not name or string.len(name) <= 0 then return end
	local scaleform = RequestScaleformMovie(name)

	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end

	SetScaleformParams(scaleform, data)
	return scaleform
end

function Admin:TeleporteToPoint(ped)
    local pPed = ped or PlayerPedId()
    local bInfo = GetFirstBlipInfoId(8)
    if not bInfo or bInfo == 0 then
        return
    end
    local entity = IsPedInAnyVehicle(pPed, false) and GetVehiclePedIsIn(pPed, false) or pPed
    local bCoords = GetBlipInfoIdCoord(bInfo)
    Admin:TeleportCoords(bCoords, entity)
end

function Admin:ActiveScalform(bool)
    local dataSlots = {
        {
            name = "CLEAR_ALL",
            param = {}
        }, 
        {
            name = "TOGGLE_MOUSE_BUTTONS",
            param = { 0 }
        },
        {
            name = "CREATE_CONTAINER",
            param = {}
        } 
    }
    local dataId = 0
    for k, v in pairs(bool and Admin.DetailsInSpec or Admin.DetailsScalform) do
        dataSlots[#dataSlots + 1] = {
            name = "SET_DATA_SLOT",
            param = {dataId, GetControlInstructionalButton(2, v.control, 0), v.label}
        }
        dataId = dataId + 1
    end
    dataSlots[#dataSlots + 1] = {
        name = "DRAW_INSTRUCTIONAL_BUTTONS",
        param = { -1 }
    }
    return dataSlots
end

function Admin:ControlInCam()
    local p10, p11 = IsControlPressed(1, 10), IsControlPressed(1, 11)
    local pSprint, pSlow = IsControlPressed(1, Admin.DetailsScalform.sprint.control), IsControlPressed(1, Admin.DetailsScalform.slow.control)
    if p10 or p11 then
        Admin.SpeedNoclip = math.max(0, math.min(100, Admin.SpeedNoclip + (p10 and 0.01 or -0.01), 2))
    end
    if Admin.CamCalculate == nil then
        if pSprint then
            Admin.CamCalculate = Admin.SpeedNoclip * 2.0
        elseif pSlow then
            Admin.CamCalculate = Admin.SpeedNoclip * 0.1
        end
    elseif not pSprint and not pSlow then
        if Admin.CamCalculate ~= nil then
            Admin.CamCalculate = nil
        end
    end
    if IsControlJustPressed(0, Admin.DetailsScalform.speed.control) then
        DisplayOnscreenKeyboard(false, "FMMC_KEY_TIP8", "", Admin.SpeedNoclip, "", "", "", 5)
        while UpdateOnscreenKeyboard() == 0 do
            Citizen.Wait(10)
            if UpdateOnscreenKeyboard() == 1 and GetOnscreenKeyboardResult() and string.len(GetOnscreenKeyboardResult()) >= 1 then
                Admin.SpeedNoclip = tonumber(GetOnscreenKeyboardResult()) or 1.0
                break
            end
        end
    end
end

function Admin:ManageCam()
    local p32, p33, p35, p34 = IsControlPressed(1, 32), IsControlPressed(1, 33), IsControlPressed(1, 35), IsControlPressed(1, 34)
    local g220, g221 = GetDisabledControlNormal(0, 220), GetDisabledControlNormal(0, 221)
    if g220 ~= 0.0 or g221 ~= 0.0 then
        local cRot = GetCamRot(Admin.Cam, 2)
        new_z = cRot.z + g220 * -1.0 * 10.0;
        new_x = cRot.x + g221 * -1.0 * 10.0
        SetCamRot(Admin.Cam, new_x, 0.0, new_z, 2)
        SetEntityHeading(PlayerPedId(), new_z)
    end
    if p32 or p33 or p35 or p34 then
        local rightVector, forwardVector, upVector = GetCamMatrix(Admin.Cam)
        local cPos = (GetCamCoord(Admin.Cam)) + ((p32 and forwardVector or p33 and -forwardVector or vector3(0.0, 0.0, 0.0)) + (p35 and rightVector or p34 and -rightVector or vector3(0.0, 0.0, 0.0))) * (Admin.CamCalculate ~= nil and Admin.CamCalculate or Admin.SpeedNoclip)
        SetCamCoord(Admin.Cam, cPos)
        SetFocusPosAndVel(cPos)
    end
end

function Admin:StartSpectate(player)
    Admin.CamTarget = player
    Admin.CamTarget.PedHandle = GetPlayerPed(player.id)
    if not DoesEntityExist(Admin.CamTarget.PedHandle) then
        ShowAboveRadarMessage("~r~Vous êtes trop loin de la cible.")
        return
    end
    NetworkSetInSpectatorMode(1, Admin.CamTarget.PedHandle)
    SetCamActive(Admin.Cam, false)
    RenderScriptCams(false, false, 0, false, false)
    SetScaleformParams(Admin.Scalform, Admin:ActiveScalform(true))
    ClearFocus()
end

function Admin:startSpec(player)
    playerPedIdGolmon = player
    playerPedIdGolmon.pedHandle = GetPlayerPed(player.id)
    if not DoesEntityExist(playerPedIdGolmon.pedHandle) then
        ShowAboveRadarMessage("~r~Vous êtes trop loin de la cible~w~")
        return
    end
    NetworkSetInSpectatorMode(1, playerPedIdGolmon.pedHandle)
    SetCamActive(Admin.Cam, false)
    RenderScriptCams(false, false, 0, false, false)
    SetScaleformParams(Admin.Scalform, Admin:ActiveScalform(true))
    ClearFocus()
end

function Admin:StartSpectateList(player)
    Admin.CamTarget.PedHandle = player
    NetworkSetInSpectatorMode(1, Admin.CamTarget.PedHandle)
    SetCamActive(Admin.Cam, false)
    RenderScriptCams(false, false, 0, false, false)
    SetScaleformParams(Admin.Scalform, Admin:ActiveScalform(true))
    ClearFocus()
end

function Admin:ExitSpectate()
    local pPed = PlayerPedId()
    if DoesEntityExist(Admin.CamTarget.PedHandle) then
        SetCamCoord(Admin.Cam, GetEntityCoords(Admin.CamTarget.PedHandle))
    end
    NetworkSetInSpectatorMode(0, pPed)
    SetCamActive(Admin.Cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Admin.CamTarget = {}
    SetScaleformParams(Admin.Scalform, Admin:ActiveScalform(true))
end

function Admin:SpecAndPos()
    if not Admin.CamTarget.id and IsControlJustPressed(0, Admin.DetailsScalform.spectateplayer.control) then
        local qTable = {}
        local CamCoords = GetCamCoord(Admin.Cam)
        local pId = PlayerId()
        for k, v in pairs(GetActivePlayers()) do
            local vPed = GetPlayerPed(v)
            local vPos = GetEntityCoords(vPed)
            local vDist = GetDistanceBetweenCoords(vPos, CamCoords)
            if v ~= pId and vPed and vDist <= 20 and (not qTable.pos or GetDistanceBetweenCoords(qTable.pos, CamCoords) > vDist) then
                qTable = {
                    id = v,
                    pos = vPos
                }
            end
        end
        if qTable and qTable.id then
            Admin:StartSpectate(qTable)
        end
    end
    if IsControlJustPressed(1, Admin.DetailsScalform.gotopos.control) then
        -- Admin:Spectate(camActive)
        coordsToTp = GetCamCoord(Admin.Cam)
    end
end

function Admin:ScalformSpectate()
    if IsControlJustPressed(0, Admin.DetailsInSpec.exit.control) then
        Admin:ExitSpectate()
    end
    SetFocusPosAndVel(GetEntityCoords(GetPlayerPed(Admin.CamTarget.id)))
end

function Admin:RenderCam()
    if not NetworkIsInSpectatorMode() then
        Admin:ControlInCam()
        Admin:ManageCam()
        Admin:SpecAndPos()
    else
        Admin:ScalformSpectate()
        CreateThread(function() 
            while not NetworkIsInSpectatorMode() do
                if Admin.CamTarget.id then
                    SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(Admin.CamTarget.id)))
                    SetCamCoord(Admin.Cam, GetEntityCoords(GetPlayerPed(Admin.CamTarget.id)))
                end
                Wait(500)
            end
        end)
    end
    if Admin.Scalform then
        DrawScaleformMovieFullscreen(Admin.Scalform, 255, 255, 255, 255, 0)
    end
end

function Admin:CreateCam()
    Admin.Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(Admin.Cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Admin.Scalform = CreateScaleform("INSTRUCTIONAL_BUTTONS", Admin:ActiveScalform())
end

function Admin:DestroyCam()
    DestroyCam(Admin.Cam)
    RenderScriptCams(false, false, 0, false, false)
    ClearFocus()
    SetScaleformMovieAsNoLongerNeeded(Admin.Scalform)
    if NetworkIsInSpectatorMode() then
        NetworkSetInSpectatorMode(false, Admin.CamTarget.id and GetPlayerPed(Admin.CamTarget.id) or 0)
    end
    Admin.Scalform = nil
    Admin.Cam = nil
    lockEntity = nil
    Admin.CamTarget = {}
end

function Admin:TeleportCoords(vector, peds)
	if not vector or not peds then return SetEntityCoords(peds, vector) end
	local x, y, z = vector.x, vector.y, vector.z + 0.98
	peds = peds or PlayerPedId()

	RequestCollisionAtCoord(x, y, z)
	NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)

	local TimerToGetGround = GetGameTimer()
	while not IsNewLoadSceneLoaded() do
		if GetGameTimer() - TimerToGetGround > 3500 then
			break
		end
		Citizen.Wait(0)
	end

	SetEntityCoordsNoOffset(peds, x, y, z)

	TimerToGetGround = GetGameTimer()
	while not HasCollisionLoadedAroundEntity(peds) do
		if GetGameTimer() - TimerToGetGround > 3500 then
			break
		end
		Citizen.Wait(0)
	end

	local retval, GroundPosZ = GetGroundZCoordWithOffsets(x, y, z)
	TimerToGetGround = GetGameTimer()
	while not retval do
		z = z + 5.0
		retval, GroundPosZ = GetGroundZCoordWithOffsets(x, y, z)
		Wait(0)

		if GetGameTimer() - TimerToGetGround > 3500 then
			break
		end
	end

	SetEntityCoordsNoOffset(peds, x, y, retval and GroundPosZ or z)
	NewLoadSceneStop()
	return true
end

function Admin:Spectate(pPos)
    local player = PlayerPedId()
    local pPed = player
    Admin.InSpec = not Admin.InSpec
    Wait(0)
    if not Admin.InSpec then
        Admin:DestroyCam()
        -- SetEntityVisible(pPed, true, true)
        SetEntityInvincible(pPed, false)
        DrawCenterText("~g~Invincible~s~", 10)
        SetEntityCollision(pPed, true, true)
        FreezeEntityPosition(pPed, false)

        if coordsToTp then
            SetEntityCoords(PlayerPedId(), coordsToTp.x, coordsToTp.y, coordsToTp.z+0.20)
        end
    else
        Admin:CreateCam()

        -- SetEntityVisible(pPed, false, false)
        SetEntityInvincible(pPed, true)
        DrawCenterText("~g~Invincible~s~", 9999999999999)
        SetEntityCollision(pPed, false, false)
        FreezeEntityPosition(pPed, true)
        SetCamCoord(Admin.Cam, GetEntityCoords(player))
        CreateThread(function()
            while Admin.InSpec do
                Wait(0)
                Admin:RenderCam()
            end
        end)
    end
end


RegisterKeyMapping("spectate_admin", "Mode Spectate", "keyboard", "F6")

RegisterCommand("spectate_admin", function()
    if GM.Player.Group == "user" then return end
    Admin:Spectate()
end)