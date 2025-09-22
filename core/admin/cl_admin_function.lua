local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
  }
  
  local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
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
  
  function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
  end
  
  function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
  end
  
  function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
  end
  
  function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
  end



showName = false

gamertags = {}

function showNames()
    -- showName = not showName
    Citizen.CreateThread(function()
        while showName do 
            Wait(0)
            for _, player in pairs(AdminPlayers) do 
                local serverId = GetPlayerFromServerId(player.source)
                if serverId ~= -1 then 
                    local targetPed = GetPlayerPed(serverId)
                    local targetCoords = GetEntityCoords(targetPed)
                    local sourcePed = PlayerPedId()
                    local sourceCoords = GetEntityCoords(sourcePed)
                    if player.flag == nil then 
                        player.flag = "🇬🇧"
                    end
                    DrawText3DAdmin(targetCoords.x, targetCoords.y, targetCoords.z + 1.0, ("(%s) [%s] - %s %s"):format(player.source, player.uuid, player.username, player.flag))
                end
            end
        end
    end)
end

function DrawText3DAdmin(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

-- function showNames()
--     Citizen.CreateThread(function()
--         while showName do 
--             Wait(0)
--             for _, player in pairs(AdminPlayers) do 
--                 local playerId = GetPlayerFromServerId(player.source)
--                 local serverId = player.source

--                 if playerId ~= -1 then 
--                     local playerPed = GetPlayerPed(playerId)

--                     if NetworkIsPlayerActive(playerId) then
--                         local HasMarker = gamertags[serverId]

--                         if not HasMarker or (HasMarker.gamertag and not IsMpGamerTagActive(HasMarker.gamertag)) then
--                             local mpGamerTag = CreateMpGamerTag(playerPed, ("(%s) [%s] - %s %s"):format(player.source, player.uuid, player.username, player.flag), false, false, "", 0)
--                             SetMpGamerTagVisibility(mpGamerTag, 0, true)
--                             SetMpGamerTagColour(mpGamerTag, 0, 0)

--                             SetMpGamerTagVisibility(mpGamerTag, 2, true)
--                             SetMpGamerTagAlpha(mpGamerTag, 2, 255)

--                             gamertags[serverId] = { gamertag = mpGamerTag, ped = playerPed, id = serverId }
--                         else
--                             local xBase = HasMarker.gamertag

--                             if NetworkIsPlayerTalking(playerId) then
--                                 SetMpGamerTagColour(xBase, 0, 12) 
--                                 -- SetMpGamerTagColour(xBase, 0, 6) STAFF
--                             elseif IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(playerPed, false), -1) == playerPed then
--                                 SetMpGamerTagColour(xBase, 0, 18) 
--                             else
--                                 SetMpGamerTagColour(xBase, 0, 0) 
--                             end

--                             SetMpGamerTagVisibility(xBase, 4, NetworkIsPlayerTalking(playerId))
--                             SetMpGamerTagAlpha(xBase, 4, 255)
--                         end
--                     end
--                 end
--             end
--         end

--         if not showName then
--             for serverId, tag in pairs(gamertags) do
--                 if tag.gamertag then
--                     SetMpGamerTagVisibility(tag.gamertag, 0, false)
--                     SetMpGamerTagVisibility(tag.gamertag, 2, false)
--                     gamertags[serverId] = nil
--                 end
--             end
--         end
--     end)
-- end

-- function toggleShowNames()
--     showName = not showName
--     showNames() 
-- end