Redzone = {
    blips = nil,
    leader = {},
}

GM.Player.InRedzone = false
GM.Player.RedZoneId = nil

exports("PlayerInRedZone", function()
    return GM.Player.InRedzone
end)

function SelectRandomRedzone()
    local redzone = RedzoneConfig.CurrentRedZoneInfo[math.random(1, #RedzoneConfig.CurrentRedZoneInfo)]
    return redzone
end


function SpawnRandomInRedzone()
    local redzone = SelectRandomRedzone() 
    local redzonePos = redzone.redzonePos
    local redzoneId = redzone.redzoneId 

    local randomX = redzonePos.x + math.random(-10, 10)
    local randomY = redzonePos.y + math.random(-10, 10)
    local randomZ = redzonePos.z + 300.0 

    TeleportToWp(PlayerPedId(), vector3(randomX, randomY, randomZ), 0.0, false, function()
        para()
    end)
end

Citizen.CreateThread(function()
    local NPC_Redzone = {
        {
            safezone = "Main SafeZone",
            pos = vector4(-539.0478, -214.5629, 37.64979, 31.57043),
        },
        {
            safezone = "Mountain",
            pos = vector4(-428.5611, 1141.288, 325.9052, 349.3187),
        },

        {
            safezone = "Mirror Park",
            pos = vector4(1367.26, -590.8753, 74.19762, 21.46217),
        },
        {
            safezone = "Hospital",
            pos = vector4(246.769, -1405.575, 30.58755, 244.7222),
        },
        {
            safezone = "Paleto",
            pos = vector4(-946.9343, 6186.929, 3.907281, 28.85239),
        },
        {
            safezone = "Sandy Shores Safezone",
            pos = vector4(2770.478, 3449.079, 55.73026, 63.11859),
        },
        {
            safezone = "Cross Field",
            pos = vector4(1204.813, 1859.461, 78.86802, 321.5188),
        },
        {
            safezone = "Beach Safezone",
            pos = vector4(-1076.848511, -1240.068481, 5.188544, 203.995895),
        },
        {
            safezone = "depot",
            pos = vector4(770.50, -1401.37, 26.49, 81.29),
        },
    }

    for k, v in pairs(NPC_Redzone) do
        RegisterSafeZonePedAction({
            safezone = v.safezone,
            pedType = 4,
            model = "u_m_y_juggernaut_01",
            pos = v.pos,
            invisible = true,
            action = function()
                SpawnRandomInRedzone()
            end,
            drawText = "[ ~r~RANDOM REDZONE TELEPORTER ~s~]",
            distanceLimit = 2.0,
            distanceShowText = 20.0, 
            drawTextOffset = -100.0,
            marker = {
                type = 34,
                size = {x = 2.0, y = 2.0, z = 2.0},
                color = {r = 255, g = 0, b = 0, a = 130},
            },
        })
    end
end)

function GetRedzoneInformations(id)
    for k, v in pairs(RedzoneConfig.CurrentRedZoneInfo) do
        if v.redzoneId == id then
            return v
        end
    end
    return nil
end

function InLeaderboard(redzoneId)
    local redzonedata = GetRedzoneInformations(redzoneId)
    local myId = GetPlayerServerId(PlayerId())
    for k, v in pairs(redzonedata.redzoneLeaderboard) do
        if v.source == myId then
            return true
        end
    end
    return false
end


local lastLeaderId = 0

_RegisterNetEvent("redzone:UpdateLeaderboard", function(redzoneId, tblData)
    local redzonedata = GetRedzoneInformations(redzoneId)
    if redzonedata == nil then
        return
    end

    local killsRedzoneLeaderboard = {}
    for playerId, v in pairs(tblData) do 
        table.insert(killsRedzoneLeaderboard, {
            username = v.username,
            kills = v.kills,
            source = v.source,
        })
    end

    table.sort(killsRedzoneLeaderboard, function(a, b) return a.kills > b.kills end)
    lastLeaderId = killsRedzoneLeaderboard[1].source

    if lastLeaderId ~= GetPlayerServerId(PlayerId()) and killsRedzoneLeaderboard[1].source == GetPlayerServerId(PlayerId()) then
        ShowAboveRadarMessage("~r~You are the new kill leader!")
    end

    redzonedata.redzoneLeaderboard = killsRedzoneLeaderboard
end)


_RegisterNetEvent("redzone:loadRedzoneInfo", function(tblData)
    RedzoneConfig.CurrentRedZoneInfo = tblData

    if Redzone.blips ~= nil then
        for k,v in pairs(Redzone.blips) do
            RemoveBlip(v)
        end
    end

    Redzone.blips = {}

    for k, v in pairs(RedzoneConfig.CurrentRedZoneInfo) do
        local blip = AddBlipForRadius(v.redzonePos.x, v.redzonePos.y, v.redzonePos.z, 170.0)
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 150)
        table.insert(Redzone.blips, blip)
    end
    Logger:trace("Redzone", "Loaded Redzone")

    ShowAboveRadarMessage("~r~Red zones moved to a new position")
end)

local LoadedKillleader = false

Citizen.CreateThread(function()
    while true do 
        local timer = 1000
        local isNear = false 
        local serverId = GetPlayerServerId(PlayerId())
        local pCoords = GetEntityCoords(PlayerPedId())
        local pPed = PlayerPedId()
        if Redzone.blips ~= nil then 
            for k, v in pairs(RedzoneConfig.CurrentRedZoneInfo) do 
                local dist = #(vector2(pCoords.x, pCoords.y) - vector2(v.redzonePos.x, v.redzonePos.y))
                if dist <= 170.0 then 
                    if not InLeaderboard(v.redzoneId) then
                        Tse("redzone:joinRedzone", v.redzoneId)
                    end
                    isNear = true 
                    GM.Player.InRedzone = true
                    GM.Player.RedZoneId = v.redzoneId
                    Wait(500)
                    print(v.redzoneId, "Redzone Id")
                    if GetRedzoneInformations(v.redzoneId) then 
                        SendNUIMessage({
                            type = 'updateRedzone',
                            kills = (GetRedzoneInformations(v.redzoneId).redzoneLeaderboard[1].kills) or 0,
                            name = (GetRedzoneInformations(v.redzoneId).redzoneLeaderboard[1].username) or "None",
                        })
                    end
                    timer = 1
                end
            end

            if not isNear and GM.Player.InRedzone then 
                GM.Player.InRedzone = false
                timer = 1000
                GM.Player.RedZoneId = nil
                SendNUIMessage({
                    type = 'hideRedzoneInfo'
                })
            end
        end
        Citizen.Wait(timer) 
    end
end)