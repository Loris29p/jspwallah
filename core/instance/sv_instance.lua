_RegisterServerEvent('instance:joinInstance', function(instanceId)
    local src = source
    local PLAYER_DATA = GetPlayerId(src)
    if PLAYER_DATA then
       SetPlayerRoutingBucket(src, instanceId)
    end
end)

_RegisterServerEvent('instance:leaveInstance', function()
    local src = source
    local PLAYER_DATA = GetPlayerId(src)
    if PLAYER_DATA then
        SetPlayerRoutingBucket(src, 0)
    end
end)

