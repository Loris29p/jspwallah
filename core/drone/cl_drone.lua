-- -- local m_tblState = {
-- --     active = false,
-- --     returnDrone = false,
-- -- }

-- -- RegisterKeyMapping("drone", "Drone", "keyboard", "o")

-- -- RegisterCommand("drone", function()
-- --     if not m_tblState.active and GetCooldown("drone") == tonumber(0) then
-- --         m_tblState.active = true

-- --         RequestModel("v_serv_abox_02")
        
-- --         while not HasModelLoaded("v_serv_abox_02") do Wait(0) end

-- --         local playerCoords = GetEntityCoords(PlayerPedId())
-- --         local spawnCoords = vector3(playerCoords.x, playerCoords.y + 20.5, playerCoords.z + 10.0)
-- --         local drone = CreateObject("v_serv_abox_02", spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
-- --         local droneReal = CreateObject("ch_prop_arcade_drone_01a", spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)

-- --         ShowAboveRadarMessage("~y~You spawned your drone~s~.")

-- --         SetEntityInvincible(drone, true)
-- --         SetEntityCollision(drone, false)

-- --         local targetCoords = vector3(playerCoords.x, playerCoords.y + 2.0, playerCoords.z + 0.2)
-- --         local speed = 0.015

-- --         local blip = AddBlipForEntity(drone)
-- --         SetBlipSprite(blip, 57)
-- --         SetBlipColour(blip, 1)
-- --         SetBlipScale(blip, 0.3)
-- --         SetBlipAsShortRange(blip, false)
-- --         SetBlipDisplay(blip, 2)
-- --         BeginTextCommandSetBlipName("STRING")
-- --         AddTextComponentSubstringPlayerName("Drone")
-- --         EndTextCommandSetBlipName(blip)

-- --         while m_tblState.active do
-- --             Wait(0)

-- --             local droneCoords = GetEntityCoords(drone)
-- --             local dist = GetDistanceBetweenCoords(droneCoords, targetCoords, true)

-- --             if dist > 0.1 then
-- --                 local direction = (targetCoords - droneCoords)
-- --                 direction = direction / #(direction)
-- --                 local newCoords = droneCoords + direction * speed
-- --                 SetEntityCoords(drone, newCoords.x, newCoords.y, newCoords.z)
-- --             else
                
-- --                 local playerDist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(drone), true)
-- --                 if playerDist <= 2.5 then
-- --                     DrawTopNotification("~INPUT_CONTEXT~ to open the drone\n~INPUT_CELLPHONE_CAMERA_EXPRESSION~ to return stash")

-- --                     if IsControlJustPressed(0, 186) and not m_tblState.returnDrone then
-- --                         m_tblState.returnDrone = true
-- --                         AddCooldown("drone", 60 * 5)
-- --                         RemoveBlip(blip)
-- --                     end

-- --                     if IsControlJustPressed(0, 38) then
-- --                         Tse("gamemode:OpenStash")
-- --                     end
-- --                 end

-- --                 if m_tblState.returnDrone then
-- --                     SetEntityCoords(drone, GetEntityCoords(drone).x, GetEntityCoords(drone).y, GetEntityCoords(drone).z + 0.05)
-- --                     SetEntityCoords(drone, GetEntityCoords(drone).x + 0.05, GetEntityCoords(drone).y, GetEntityCoords(drone).z)
-- --                     if GetEntityCoords(drone).z >= GetEntityCoords(PlayerPedId()).z + 4.5 and GetEntityCoords(drone).x >= GetEntityCoords(PlayerPedId()).x + 10.0 then
-- --                         m_tblState.active = false
-- --                         m_tblState.returnDrone = false
        
-- --                         ShowAboveRadarMessage("You sent your drone back to the stash.", 18)
        
-- --                         DeleteEntity(drone)
-- --                     end
-- --                 end
-- --             end
-- --         end
-- --     else
-- --         if GetCooldown("drone") > tonumber(0) then
-- --             ShowAboveRadarMessage("~r~You can't spawn your drone now.~s~ ~b~("..GetCooldownProgress("drone").."s)~s~")
-- --         else
-- --             ShowAboveRadarMessage("~r~You can't spawn your drone now.~s~")            
-- --         end
-- --     end
-- -- end)

-- local m_tblState = {
--     active = false,
--     returnDrone = false,
-- }

-- RegisterKeyMapping("drone", "Drone", "keyboard", "o")

-- RegisterCommand("drone", function()
--     if GM.Player.InSelecGamemode then return end
--     if GM.Player.InArena then return end
--     if GM.Player.InRedzone then return end
--     if GM.Player.InSafeZone then return end
--     if not m_tblState.active and GetCooldown("drone") == tonumber(0) then
--         m_tblState.active = true

--         RequestModel("v_serv_abox_02")
--         RequestModel("ch_prop_arcade_drone_01a")
--         while not HasModelLoaded("v_serv_abox_02") or not HasModelLoaded("ch_prop_arcade_drone_01a") do Wait(0) end

--         local playerCoords = GetEntityCoords(PlayerPedId())
--         local spawnCoords = vector3(playerCoords.x, playerCoords.y + 20.5, playerCoords.z + 10.0)
--         drone = CreateObject("v_serv_abox_02", spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
--         droneReal = CreateObject("ch_prop_arcade_drone_01a", spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)

--         ShowAboveRadarMessage("~y~You spawned your drone~s~.")

--         SetEntityInvincible(drone, true)
--         SetEntityCollision(drone, false)

--         AttachEntityToEntity(droneReal, drone, 0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

--         local targetCoords = vector3(playerCoords.x, playerCoords.y + 2.0, playerCoords.z + 0.2)
--         local speed = 0.015

--         blipDrone = AddBlipForEntity(drone)
--         SetBlipSprite(blipDrone, 57)
--         SetBlipColour(blipDrone, 1)
--         SetBlipScale(blipDrone, 0.3)
--         SetBlipAsShortRange(blipDrone, false)
--         SetBlipDisplay(blipDrone, 2)
--         BeginTextCommandSetBlipName("STRING")
--         AddTextComponentSubstringPlayerName("Drone")
--         EndTextCommandSetBlipName(blipDrone)

--         while m_tblState.active do
--             Wait(0)

--             -- update drone size
--             local _, _, upTemp = GetEntityMatrix(droneReal)
--             local forward, right, up, position = GetEntityMatrix(droneReal)
--             SetEntityMatrix(droneReal, forward, right, upTemp + vector3(0, 0, 50.0), position)

--             local droneCoords = GetEntityCoords(drone)
--             local dist = GetDistanceBetweenCoords(droneCoords, targetCoords, true)

--             if dist > 0.1 and not m_tblState.returnDrone then
--                 local direction = (targetCoords - droneCoords)
--                 direction = direction / #(direction)
--                 local newCoords = droneCoords + direction * speed
--                 SetEntityCoords(drone, newCoords.x, newCoords.y, newCoords.z)
--             else
                
--                 local playerDist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(drone), true)
--                 if playerDist <= 2.5 then
--                     DrawTopNotification("~INPUT_CONTEXT~ to open the drone\n~INPUT_CELLPHONE_CAMERA_EXPRESSION~ to return stash")

--                     if IsControlJustPressed(0, 186) and not m_tblState.returnDrone then
--                         m_tblState.returnDrone = true
--                         AddCooldown("drone", 60 * 5)
--                         RemoveBlip(blipDrone)
--                     end

--                     if IsControlJustPressed(0, 38) then
--                         Tse("gamemode:OpenStash")
--                     end
--                 end

--                 if m_tblState.returnDrone then
--                     SetEntityCoords(drone, GetEntityCoords(drone).x, GetEntityCoords(drone).y, GetEntityCoords(drone).z + 0.02)
--                     SetEntityCoords(drone, GetEntityCoords(drone).x + 0.02, GetEntityCoords(drone).y, GetEntityCoords(drone).z)
--                     if GetEntityCoords(drone).z >= GetEntityCoords(PlayerPedId()).z + 7.5 and GetEntityCoords(drone).x >= GetEntityCoords(PlayerPedId()).x + 15.0 then
--                         m_tblState.active = false
--                         m_tblState.returnDrone = false
        
--                         ShowAboveRadarMessage("You sent your drone back to the stash.", 18)
        
--                         DeleteEntity(drone)
--                         DeleteEntity(droneReal)
--                     end
--                 end
--             end
--         end
--     else
--         if GetCooldown("drone") > tonumber(0) then
--             ShowAboveRadarMessage("~r~You can't spawn your drone now.~s~ ~b~("..GetCooldownProgress("drone").."s)~s~")
--         else
--             ShowAboveRadarMessage("~r~You can't spawn your drone now.~s~")            
--         end
--     end
-- end)

-- RegisterCommand("debug_drone", function()

--     if not m_tblState.active then
--         ShowAboveRadarMessage("~r~You don't have a drone to debug~s~.")
--         return
--     end

--     if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(drone), true) < 35.0 then
--         ShowAboveRadarMessage("~r~You already have a drone~s~.")
--         return
--     end

--     m_tblState.active = false
--     m_tblState.returnDrone = false

--     if DoesEntityExist(drone) then
--         DeleteEntity(drone)
--     end
--     if DoesEntityExist(droneReal) then
--         DeleteEntity(droneReal)
--     end
--     if DoesBlipExist(blipDrone) then
--         RemoveBlip(blipDrone)
--     end

--     DeleteCooldown("drone")

--     ShowAboveRadarMessage("~r~Your drone has been debugged~s~.")
-- end)