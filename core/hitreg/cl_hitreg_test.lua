-- --Client
-- DecorRegister("lasthp",3) 
-- DecorRegisterLock()

-- CreateThread(function()
--     while true do 
--         Wait(0)
--         if not DecorExistOn(PlayerPedId(),"lasthp") then 
--             DecorSetInt(PlayerPedId(),"lasthp",GetEntityHealth(PlayerPedId(), false))
--         end 
--     end 
-- end )

-- _AddEventHandler('gameEventTriggered',function(name,args)
--    GameEventTriggered(name,args)
-- end)

-- function GameEventTriggered(eventName, data)
--     if eventName == "CEventNetworkEntityDamage" then
--         victim = tonumber(data[1])
--         attacker = tonumber(data[2])
--         victimDied = tonumber(data[4]) == 1 and true or false 
--         weaponHash = tonumber(data[5])
--         isMeleeDamage = tonumber(data[10]) ~= 0 and true or false 
--         vehicleDamageTypeFlag = tonumber(data[11]) 
--         local FoundLastDamagedBone, LastDamagedBone = GetPedLastDamageBone(victim)
--         local bonehash = nil 
--         if FoundLastDamagedBone then
--             bonehash = tonumber(LastDamagedBone)
--         end
        
--         if victim == PlayerPedId() then 
--             CreateThread(function()

--                 while not DecorExistOn(PlayerPedId(),"lasthp") do 
--                     Wait(0)
--                 end 
--                 if DecorExistOn(PlayerPedId(),"lasthp") then 
--                     local nowhp = victimDied and 0 or GetEntityHealth(victim)
--                     local oldhp = DecorGetInt(victim,"lasthp")
--                     if nowhp  < oldhp then
--                         Tse("SyncEntityDamage",nowhp,oldhp)
                        
--                     end 
--                     if victimDied then 
--                         DecorRemove(victim,"lasthp")
--                     else
--                         DecorSetInt(victim,"lasthp",nowhp)
--                     end 
--                 end 
                
--                 return
--             end )
            
--         end 
--     end
-- end

-- _RegisterNetEvent("OnEntityHealthChange", function(source,nowhp,oldhp)
--     if source == PlayerPedId() then 
--         local hp = GetEntityHealth(PlayerPedId())
--         if hp > nowhp then 
--             SetEntityHealth(PlayerPedId(),nowhp)
--         end 
--     end 
-- end)