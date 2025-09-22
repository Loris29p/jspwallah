-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(15000)
        
--         if GM.Player.Rank ~= "user" then
--             goto continue
--         end
        
--         if GetEntityAlpha(PlayerPedId()) < 100 and not IsEntityDead(PlayerPedId()) and not GM.Player:Get().dead and not isCustomizing and not GM.Player.InSafeZone and not GM.Player.InSpectateModeLeague and not GM.Player.InSelecGamemode then
--             Tse("ac:detected", "Invisible")
--         end
        
--         ::continue::
--     end
-- end)