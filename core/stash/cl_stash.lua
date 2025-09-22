MyStash = {}

_RegisterNetEvent("gamemode:UpdateStash", function(value, index, key)
    if index then
        if key then
            MyStash[index][key] = value
        else
            if value == nil then
                table.remove(MyStash, index)
            else
                MyStash[index] = value
            end
        end
    else
        MyStash = value
    end
end)




-- Citizen.CreateThread(function()
--     while true do 
--         local timer = 1000
--         local playerPed = PlayerPedId()
--         local coords = GetEntityCoords(playerPed)
--         for k, v in pairs(m_tblSafe.list) do 
--             local SafeZoneCoords = vector3(v.StashPosition.x, v.StashPosition.y, v.StashPosition.z)
--             if GetDistanceBetweenCoords(coords, SafeZoneCoords, true) < 4.0 then
--                 timer = 0
--                 DrawTopNotification("Press ~INPUT_PICKUP~ to open stash.")
--                 if IsControlJustPressed(0, 38) then
--                     Tse("gamemode:OpenStash")
--                 end
--             end
--         end
--         Citizen.Wait(timer)
--     end
-- end)