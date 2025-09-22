_DeluxoDuelActive = {}


function GenerateDeluxoSchema()
    local randomMaps = math.random(1, #_DeluxoMode.Maps)
    local schema = _DeluxoMode.Maps[randomMaps]
    return schema
end

function CreateDuelBetweenPlayers(tblData)
    if type(tblData) ~= "table" then return end
    local randomIdDuel = math.random(1, 1000)
    local schema = GenerateDeluxoSchema()
    if _DeluxoDuelActive[randomIdDuel] ~= nil then 
        randomIdDuel = math.random(1, 1000)
    end
    _DeluxoDuelActive[randomIdDuel] = {
        sessionId = randomIdDuel,
        Players = {
            { uuid = GetPlayerId(tblData[1].id).uuid, username = tblData[1].username, id = tblData[1].id, position = schema.POSITION_1, player = 1, wins = 0},
            { uuid = GetPlayerId(tblData[2].id).uuid, username = tblData[2].username, id = tblData[2].id, position = schema.POSITION_2, player = 2, wins = 0},
        },
        Schema = schema,
    }

    _TriggerClientEvent("deluxo:start1v1", tblData[1].id, _DeluxoDuelActive[randomIdDuel], tonumber(1))
    _TriggerClientEvent("deluxo:start1v1", tblData[2].id, _DeluxoDuelActive[randomIdDuel], tonumber(2))
end

function GetDeluxoDuelActive()
    return _DeluxoDuelActive
end

function GetDeluxoData(id)
    return _DeluxoDuelActive[id]
end

function GetWinner(id)
    if _DeluxoDuelActive[id] == nil then return end
    for _, v in pairs(_DeluxoDuelActive[id].Players) do
        if v.wins >= 3 then
            return v
        end
    end
end

function FinishGameDeluxo(sessionId)
    if _DeluxoDuelActive[sessionId] == nil then return end
    for _, v in pairs(_DeluxoDuelActive[sessionId].Players) do
        if v.wins >= 3 then
            _TriggerClientEvent("deluxo:finishGame", v.id, { winner = GetWinner(sessionId) })

            SetPlayerRoutingBucket(v.id, 0)
        end
    end
    _DeluxoDuelActive[sessionId] = nil
end

function RestartManche(sessionId)
    if not sessionId then return end
    local sessionData = GetDeluxoData(sessionId)
    if not sessionData then return end

    for _,v in pairs(sessionData.Players) do
        _TriggerClientEvent("deluxo:start1v1", v.id, _DeluxoDuelActive[sessionId], v.player)
    end
end

_RegisterServerEvent("deluxo:restartManche", function(tblData)
    if type(tblData) ~= "table" then return end
    local sessionId = tblData.sessionId
    if _DeluxoDuelActive[sessionId] == nil then return end

    for _, v in pairs(_DeluxoDuelActive[sessionId].Players) do
        if v.id == tblData.killer then
            v.wins = v.wins + 1

            if v.wins >= 3 then
                FinishGameDeluxo(sessionId)
            else
                RestartManche(sessionId)
            end
        end
    end
end)

