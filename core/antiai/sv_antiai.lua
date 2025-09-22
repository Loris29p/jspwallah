
function RegisterCallback(name, cb)
    RegisterNetEvent(name, function(id, args)
        local src = source
        local eventName = "gfx-antiMagicandAntiAccuracy:triggerCallback:" .. id
        CreateThread(function()
            local result = cb(src, table.unpack(args))
            TriggerClientEvent(eventName, src, result)
        end)
    end)
end

local bucket = {}
local players = {}


RegisterCallback("gfx-antiMagicandAntiAccuracy:isBypass", function(source)
    local id = GetId(source)
    for key, value in pairs(ConfigAI.BypassPlayerList) do
        if id[key] then
            for i = 1, #value do
                if id[key] == value[i] then
                    return true
                end
            end
        end
    end
    return false
end)


RegisterNetEvent("gfx-anticheat:server:discordLog")
AddEventHandler("gfx-anticheat:server:discordLog", function(type, detected)
    local src = source
    MagicTestDiscordLog(src, type, detected)
end)

RegisterNetEvent("gfx-anticheat:server:kickPlayer")
AddEventHandler("gfx-anticheat:server:kickPlayer", function(reason)
    DropPlayer(source, reason)
end)


RegisterNetEvent("gfx-anticheat:server:changebucket")
AddEventHandler("gfx-anticheat:server:changebucket", function()
    local src = source
    local bucketId = math.random(1, 100000)
    repeat
        bucketId = math.random(1, 100000)
    until bucket[bucketId] == nil
    SetPlayerRoutingBucket(src, bucketId)
    bucket[bucketId] = src
    players[src] = bucketId
end)

RegisterNetEvent("gfx-anticheat:server:DefaultBucket")
AddEventHandler("gfx-anticheat:server:DefaultBucket", function()
    local src = source
    if players[src] then
        bucket[players[src]] = nil
        players[src] = nil
    end
    SetPlayerRoutingBucket(src, 0)
end)

RegisterNetEvent("gfx-anticheat:server:banPlayer")
AddEventHandler("gfx-anticheat:server:banPlayer", function(reason)
    local src = source
    banEvent(src, reason)
end)

RegisterCommand(ConfigAI.magicTestCommand, function(source, args, rawCommand)
    local src = source
    if not isAdmin(src) then return end
    local target = tonumber(args[1])
    TriggerClientEvent("gfx-antiMagicandAntiAccuracy:TestStart", target, true)
end, false)