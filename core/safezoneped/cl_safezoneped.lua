ListSafeZonePed = {}

function RegisterSafeZonePedAction(tblData)
    if type(tblData) ~= "table" then return end
    table.insert(ListSafeZonePed, {
        info = tblData, 
        ped = 0,
    })
end


function LoadSafeZonePedAction(safezoneName)
    for k, v in pairs(ListSafeZonePed) do
        if v.info.safezone == safezoneName then
            local ped = CreatePedAction(v.info)
            v.ped = ped
        end
    end
end

function UnloadSafeZonePedAction(safezoneName)
    for k, v in pairs(ListSafeZonePed) do
        if v.info.safezone == safezoneName then
            if v.ped then
                DestroyPedAction(v.ped)
                v.ped = nil 
            end
        end
    end
end
            
function ForceUnload()
    for k, v in pairs(ListSafeZonePed) do
        if v.ped then
            DestroyPedAction(v.ped)
            v.ped = nil 
        end
    end
end