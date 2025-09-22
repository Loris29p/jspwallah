local nbrDisplaying = 1
DisplayMarker = true 
SoundHitMarker = false
SoundHitTMR = false 

-- _AddEventHandler('gameEventTriggered', function(event, data)
--     if event == 'CEventNetworkEntityDamage' then
--         local victim, attacker, damage, _, _, victimDied, weapon, _, _, _, entityType = table.unpack(data)
--         victimDied = tonumber(data[6]) == 1 and true or false 
--         victim = tonumber(data[1])
--         attacker = tonumber(data[2])
--         weaponHash = tonumber(data[7])
--         isMeleeDamage = tonumber(data[10]) ~= 0 and true or false 
--         vehicleDamageTypeFlag = tonumber(data[11]) 
--         damage = math.floor(string.unpack("f", string.pack("i4", damage)))
--         if IsEntityDead(victim) then return end
-- 		if damage == 3 then return end
-- 		if IsEntityAPed(victim) and IsPedAPlayer(victim) then
--             if attacker == PlayerPedId() and victim ~= attacker then
-- 				-- _TriggerEvent("InteractSound_CL:PlayOnOne", "hitmarker", "0.20")
--                 local hitPosition
--                 if bone ~= 0 then
--                     hitPosition = GetWorldPositionOfEntityBone(victim, GetPedBoneIndex(victim, bone))
--                 end
--                 if not hitPosition or (hitPosition.x == 0 and hitPosition.y == 0) then
--                     hitPosition = GetEntityCoords(victim)
--                 else
--                     if bone ~= 31086 then
--                         hitPosition = hitPosition - vector3(0,0,0.75)
--                     else
--                         hitPosition = hitPosition - vector3(0,0,0.35) 
--                     end
--                 end
--                 local offset = 1 + (nbrDisplaying * 0.25)
-- 				local isArmor = GetPedArmour(victim) > 0
--                 local health = GetEntityHealth(victim) < 1
--                 if DisplayMarker then 
--                     Display(victim, hitPosition, damage, offset, nbrDisplaying, isArmor)
--                 end
--                 -- if SoundHitMarker then 
--                 _TriggerEvent("InteractSound_CL:PlayOnOne", "hitmarker", "0.20")
--                 print("victimDIED", victimDied)
--                 if victimDied then 
--                     _TriggerEvent("InteractSound_CL:PlayOnOne", "deadsound", "0.20")
--                 end

--                 if health then 
--                     _TriggerEvent("InteractSound_CL:PlayOnOne", "deadsound", "0.20")
--                 end
--                 -- elseif SoundHitTMR then 
--                 --     _TriggerEvent("InteractSound_CL:PlayOnOne", "tmr", "0.20")
--                 -- end
--                 -- Display(victim, hitPosition, damage, offset, nbrDisplaying, isArmor)
--                 -- Tse("rz:deaths:combatLog", GetPlayerServerId(PlayerId()))
--             end
--         end
--     end
-- end)

-- _AddEventHandler('gameEventTriggered', function(event, data)
--     if event == 'CEventNetworkEntityDamage' then
--         local victim, attacker, damage, _, _, victimDied, weapon, _, _, _, entityType = table.unpack(data)
--         victimDied = tonumber(data[6]) == 1 and true or false 
--         victim = tonumber(data[1])
--         attacker = tonumber(data[2])
--         weaponHash = tonumber(data[7])
--         isMeleeDamage = tonumber(data[10]) ~= 0 and true or false 
--         vehicleDamageTypeFlag = tonumber(data[11]) 
--         damage = math.floor(string.unpack("f", string.pack("i4", damage)))
--         if IsEntityDead(victim) then return end
-- 		if damage == 3 then return end
-- 		if IsEntityAPed(victim) and IsPedAPlayer(victim) then
--             if attacker == PlayerPedId() and victim ~= attacker then
--                 local boneIndex = GetPedLastDamageBone(victim)
--                 local hitPosition = GetWorldPositionOfEntityBone(victim, boneIndex)
--                 local offset = 1 + (nbrDisplaying * 0.25)
-- 				local isArmor = GetPedArmour(victim) > 0
--                 local health = GetEntityHealth(victim) < 1
--                 if DisplayMarker then 
--                     DisplayHitreg(victim, hitPosition, damage, offset, nbrDisplaying, isArmor)
--                 end

--                 if victimDied then 
--                     return _TriggerEvent("InteractSound_CL:PlayOnOne", "deadsound", "0.20")
--                 end
                
--                 if health then 
--                     return _TriggerEvent("InteractSound_CL:PlayOnOne", "deadsound", "0.20")
--                 end
--                 _TriggerEvent("InteractSound_CL:PlayOnOne", "hitmarker", "0.20")
--             end
--         end
--     end
-- end)




-- function DrawText3D2D(x,y,z, text, armored)
--     local onScreen, _x, _y = World3dToScreen2d(x, y, z + 0.75)
--     local p = GetGameplayCamCoords()
--     local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
--     local scale = (1 / distance) * 2
--     local fov = (1 / GetGameplayCamFov()) * 100
--     local scale = scale * fov
--     if onScreen then
--         SetTextScale(0.6, 0.6)
--         SetTextFont(4)
--         SetTextOutline(1)
--         SetTextProportional(0)
--         SetTextColour(255, 100, 100, 215)
--         if armored then
--             SetTextColour(0, 255, 255, 215)
--         end
--         SetTextEntry("STRING")
--         SetTextCentre(1)
--         AddTextComponentString(text)
--         DrawText(_x,_y)
--         local factor = (string.len(text)) / 370
--         --   DrawRect(_x,_y+0.0125, 0.030+ factor, 0.03, 20,10,20, 200)
--     end
-- end

function DrawXPRedzone(x,y,z, text)
    local onScreen, _x, _y = World3dToScreen2d(x+0.40, y, z + 0.50)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        RequestStreamedTextureDict("guild_content")
        while not HasStreamedTextureDictLoaded("guild_content") do
            Wait(1)
        end
        DrawSprite("guild_content", "mp_anim_rp", _x, _y, .02, .02, 0.0, 255, 255, 255, 255)
        SetTextScale(0.5, 0.5)
        SetTextFont(4)
        SetTextOutline(1)
        SetTextProportional(0)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x-0.022,_y-0.01)
    end
end

local fontId
Citizen.CreateThread(function()
    RegisterFontFile('test') -- the name of your .gfx, without .gfx
    fontId = RegisterFontId('purista') -- the name from the .xml
end)


local DrawText2D2 = function(text, scale, x, y, a, color, isRedzone)
    SetTextFont(4)
    SetTextScale(0.5, 0.4)
    SetTextColour(color and tonumber(color.r or 0) or 0, color and tonumber(color.g or 0) or 0, color and tonumber(color.b or 0) or 0, 255)
    SetTextCentre(true)
    SetTextDropShadow()
    SetTextOutline(1)
    SetTextProportional(1)
	BeginTextCommandDisplayText('STRING')
	-- AddTextComponentSubstringPlayerName("<FONT FACE='purista'>"..text)
    AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x-0.022, y-0.01)
    if isRedzone then 
        RequestStreamedTextureDict("guild_content")
        while not HasStreamedTextureDictLoaded("guild_content") do
            Wait(1)
        end
        DrawSprite("guild_content", "mp_anim_rp", x, y, .02, .02, 0.0, 255, 255, 255, 255)
    end
	ClearDrawOrigin()
end

function DrawText3D2(text, x, y, z, color, isRedzone)
	local onScreen, _x, _y = World3dToScreen2d(x+0.40, y, z + 0.50)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    --print(onScreen, _x, _y)
	if onScreen then
		DrawText2D2(text, 11, _x, _y, nil, color, isRedzone)
	end
end

local lastHit =  vector3(0, 0, 0)
local DrawText3DTweenUp = function(text, scale, x, y, z, moveheight, speed, color)
    if #(lastHit - vector3(x, y, z)) < 0.3 then 
        z = z + 0.2
    end
    --print(x,y,z)
    Citizen.CreateThread(function()
        local height = z
        local total_ = height - (z - moveheight) 
        local total = height - (z - moveheight)
        while height < (z + moveheight) do 
            DrawText3D2(text, x, y, height, color, true)
            height = height + 0.01 * speed
            total = total + 0.01 * speed
            Citizen.Wait(1)
        end
    end)
end


-- RegisterCommand("hitmarker", function(source, args, rawCommand)
--     local myCoords = GetEntityCoords(PlayerPedId())
--     Wait(300)
--     -- DrawText3DTweenUp("+50", 11, myCoords.x + math.random(-500, 500)/1000, myCoords.y, myCoords.z + 0.650, 0.3, 0.10, {r = 255, g = 255, b = 255})
--     DrawText3DTweenUp("+50", 11, myCoords.x, myCoords.y, myCoords.z + 0.350, 0.3, 0.10, {r = 255, g = 255, b = 255})

-- end)

function DisplayHitreg(entity, coordsMe, text, offset, nbrDisplaying, armored, lastHit)
    if not GetSettingsValue("hitmarker") then 
        return 
    end
    local ped = PlayerPedId()
    local displaying = {}
    displaying[entity] = true
    local coords = GetEntityCoords(ped, false)
    local dist = #(coordsMe - coords)

    Citizen.CreateThread(function()
        Wait(1000)
        displaying[entity] = nil
    end)

    if lastHit then 
        if GM.Player.InRedzone then 
            DrawText3DTweenUp("+50", 11, coordsMe['x'], coordsMe['y'], coordsMe['z']+offset-1.250, 0.3, 0.10, {r = 255, g = 255, b = 255})
        end
    end

    Citizen.CreateThread(function()
        nbrDisplaying = nbrDisplaying + 1
        while displaying[entity] do
            Citizen.Wait(1)
            local coords = GetEntityCoords(ped, false)
            local dist = #(coordsMe - coords)
            -- if dist < 150 then
                -- if HasEntityClearLosToEntity(ped, entity, 17 ) then
                DrawText3D2D(coordsMe['x'], coordsMe['y'], coordsMe['z']+offset-1.250, text, armored)
                -- DrawXPRedzone(coordsMe['x'], coordsMe['y'], coordsMe['z']+offset-1.250, text2)
                -- end
            -- end
        end
        nbrDisplaying = nbrDisplaying - 1
    end)
end

function DrawText3D2D(x,y,z, text, armored)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z + 1.40)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) *1.5
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        if GetSettingsValue("hitmarker_size") == "big" then 
            SetTextScale(0.6, 0.6)
        elseif GetSettingsValue("hitmarker_size") == "normal" then
            SetTextScale(0.3, 0.3)
        elseif GetSettingsValue("hitmarker_size") == "tenier" then
            SetTextScale(0.2, 0.2)
        else 
            SetTextScale(0.3, 0.3)
        end
        SetTextFont(4)
        SetTextOutline(1)
        SetTextProportional(0)
        -- SetTextColour(211, 106, 108, 215)
        SetTextColour(239, 82, 104, 215)
        if armored then
            --SetTextColour(63, 199, 211, 215) 
            SetTextColour(63, 199, 211, 215)
        end
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end


_RegisterNetEvent("niycco_hitmarker:getroffen")
_AddEventHandler("niycco_hitmarker:getroffen", function(opponentId, opponentCoords, text, lastHit, weaponType, opponentPed)
    local weaponGroupe = GetWeapontypeGroup(weaponType)
    if (weaponGroupe == -728555052 or weaponGroupe == -1609580060) then 
        return 
    else
        -- print("hitmarker", opponentId, opponentCoords, text, lastHit, weaponType)    
        -- print('Player entity:', opponentPed)
        local opponentPedId = GetPlayerFromServerId(opponentId)
        local pedOpponent = GetPlayerPed(opponentPedId)

        -- if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("weapon_unarmed") and tonumber(text) > 0 then
        --     return Tse('ac:detected', "SPOOF WEAPON")
        -- end

        if IsEntityAPed(pedOpponent) and IsPedAPlayer(pedOpponent) then
            local boneIndex = GetPedLastDamageBone(pedOpponent)
            local hitPosition = GetWorldPositionOfEntityBone(pedOpponent, boneIndex)
            local offset = 1 + (nbrDisplaying * 0.25)
            local isArmor = GetPedArmour(pedOpponent) > 0
            local health = GetEntityHealth(pedOpponent) < 1

            DisplayHitreg(pedOpponent, hitPosition, text, offset, nbrDisplaying, isArmor, lastHit)
            if GetSettingsValue("hitmarker_sound") then 
                local volume = (GetSettingsValue("volume_hitmarker") and GetSettingsValue("volume_hitmarker") or 0.20)
                local hitmarkerType = (GetSettingsValue("hitmarker_type") and GetSettingsValue("hitmarker_type") or "hitmarker")
                _TriggerEvent("InteractSound_CL:PlayOnOne", hitmarkerType, tostring(volume))
            end
        end
    end
end)