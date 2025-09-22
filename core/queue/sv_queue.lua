Queue = {}

Queue["1vs1tricks"] = {}

_AddEventHandler("playerDropped", function(reason)
    local source = source

    if Queue["1vs1tricks"][source] then
        Queue["1vs1tricks"][source] = nil
    end
end)

function Queue:Join(source, type)

    if Queue["1vs1tricks"][source] then return _TriggerClientEvent("ShowAboveRadarMessage", source, "~r~You are already in matchmaking. ~b~(/leave)~s~") end

    if Queue[type][source] ~= nil then 
        _TriggerClientEvent("ShowAboveRadarMessage", source, "~r~You in the queue") 
        return 
    end
    Queue[type][source] = true 
end

function Queue:Quit(source, type)
    if not Queue[type][source] then _TriggerClientEvent("ShowAboveRadarMessage", source, "~r~You are not in the Queue.") return end 

    Queue[type][source] = nil
end

function Queue:Test(a, b)
    return 1/(1+math.pow(10,((b-a)/400)));
end

function Queue:SearchPlayer(source, type)
    if not Queue[type][source] then return end 

    local plyDb = Players[source]

    for k, v in pairs(Queue[type]) do
        if k ~= source then
            local plyDbTarget = Players[k]
            if plyDbTarget == nil then return end

            local randomInstance = math.random(1, 200) + source - k
            _TriggerClientEvent("queue:resetFile", source)
            _TriggerClientEvent("queue:resetFile", k)

            Queue[type][source] = nil
            Queue[type][k] = nil


            if type == "1vs1tricks" then 
                CreateDuelBetweenPlayers({
                    {username = GetPlayerId(source).username, id = source, uuid = GetPlayerId(source).uuid},
                    {username = GetPlayerId(k).username, id = k, uuid = GetPlayerId(k).uuid},
                })
            end

            -- _TriggerClientEvent("zoliax:queueStart", k, "first_player", {
            --     gamemode = type,
            -- })

            -- _TriggerClientEvent("zoliax:queueStart", source, "second_player", {
            --     gamemode = type,
            -- })
            
            SetPlayerRoutingBucket(k, randomInstance)
            SetPlayerRoutingBucket(source, randomInstance)

            return true
        end
    end
end


RegisterCallback("queue:searchPlayer", function(source, type)
    local source = source
    if Queue:SearchPlayer(source, type) then
        return true
    end

    return false
end)

_RegisterServerEvent("queue:joinQueue")
_AddEventHandler("queue:joinQueue", function(type)
    Queue:Join(source, type)
end)

_RegisterServerEvent("queue:quitQueue")
_AddEventHandler("queue:quitQueue", function(type)
    Queue:Quit(source, type)
end)

-- _RegisterServerEvent("zoliax:checkQueue")
-- _AddEventHandler("zoliax:checkQueue", function(map) 
--     local player = Players[source]
--     if player ~= nil then
--         if Queue[map][player.id] ~= nil then 
--             return 
--         end    
--         Queue:Join(source, map)
--         _TriggerClientEvent("zoliax:joinQueue", player.id, map)
--     end
-- end)