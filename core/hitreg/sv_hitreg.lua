-- _RegisterServerEvent("SyncEntityDamage")
-- _AddEventHandler('SyncEntityDamage',function(nowhp,oldhp)
--      _TriggerClientEvent('OnEntityHealthChange',-1,source,nowhp,oldhp)
-- end )

_AddEventHandler("weaponDamageEvent", function (sender, data)
    local taeterID = sender
    local opponentPed = NetworkGetEntityFromNetworkId(data.hitGlobalId)
    local opponentCoords = GetEntityCoords(opponentPed)
    local opponentId = NetworkGetEntityOwner(opponentPed)
    local damage = data.weaponDamage
    local willKill = data.willKill
    local weaponType = data.weaponType
    if IsPedAPlayer(opponentPed) then
        _TriggerClientEvent('niycco_hitmarker:getroffen', taeterID, opponentId, opponentCoords, damage, willKill, weaponType, opponentPed) 
    end
end)