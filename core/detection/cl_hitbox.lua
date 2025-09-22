-- Citizen.CreateThread(function()
--     while true do
--         local id = PlayerPedId()
--         local ped = GetEntityModel(id)

--         local min, max = GetModelDimensions(ped)
--         if (min.x > -0.58)
--             or (min.x < -0.62)
--             or (min.y < -0.252)
--             or (min.y < -0.29)
--             or (max.z > 0.98) then
--             Tse("ac:detected", "Anti Bigger Hit Box")
--         end

--         Citizen.Wait(15000)
--     end
-- end)