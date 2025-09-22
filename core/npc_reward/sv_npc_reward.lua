ListNPC = {
    [1] = {
        location = "Mirror Park",
        coords = vector4(1144.055542, -771.895691, 57.621078, 358.149231),
        id = "mirrorpark",
        locked = false,
        reward = nil, 
        cooldown = 0,
        captureinfo = {
            progress = 0,
            playerUsername = "",
            playerSource = 0,
            playerUUID = 0,
        },
        model = "a_m_m_genfat_02",
    },
    [2] = {
        location = "Beach",
        coords = vector4(-847.579346, -1091.182495, 9.174812, 115.592751),
        id = "beach",
        locked = false,
        reward = nil, 
        cooldown = 0,
        captureinfo = {
            progress = 0,
            playerUsername = "",
            playerSource = 0,
            playerUUID = 0,
        },
        model = "a_m_m_genfat_02",
    },
    [3] = {
        location = "Arcadius",
        coords = vector4(-235.8484, -326.6388, 30.07517, 102.3531),
        id = "arcadius",
        locked = false,
        reward = nil, 
        cooldown = 0,
        captureinfo = {
            progress = 0,
            playerUsername = "",
            playerSource = 0,
            playerUUID = 0,
        },
        model = "a_m_m_genfat_02",
    }
}

local RandomReward = {
    {item = "weapon_combatmg", count = 6},           -- Combat MG x6
    {item = "weapon_carbinerifle", count = 10},      -- Carbine Rifle x10
    {item = "weapon_specialcarbine", count = 6},     -- Special Carbine x6
    {item = "weapon_specialcarbine_mk2", count = 3}, -- Special Carbine MK2 x3
    {item = "revolter", count = 5},                  -- Revolter x5
    {item = "brioso", count = 10},                   -- Brioso x10
    {item = "jugular", count = 10},                  -- Jugular x10
    {item = "deathbike", count = 10},                -- Deathbike x10
    {item = "dominator4", count = 10},               -- Dominator4 x10
    {item = "kuruma", count = 10},                   -- Kuruma x10
    {item = "weapon_combatpdw", count = 10},         -- Combat PDW x10
    {item = "weapon_musket", count = 1},                   -- Musket x1
    {item = "deluxo", count = 1},                  -- Deluxo x1
    {item = "thruster", count = 1},                -- Thruster x1
    {item = "weapon_sniperrifle", count = 1},               -- Sniper rifle x1
    {item = "weapon_compactlauncher", count = 1},                   -- Compact Launcher x1
    {item = "policet", count = 3},         -- Police transporter x3
}

_RegisterServerEvent('npc_reward:GetNPCData', function()
    _TriggerClientEvent('npc_reward:updateNPCData', source, ListNPC)
    _TriggerClientEvent('npc_reward:CreatePeds', source, ListNPC)
end)

_RegisterServerEvent('npc_reward:StartCapture', function(npcId)
    local npc = ListNPC[npcId]
    if not npc then return end
    if PlayerIsCapturing(source) then return DoNotif(source, "~r~You are already capturing a NPC") end
    if npc.locked then return DoNotif(source, "~r~NPC is already being captured") end
    if npc.cooldown > 0 then return DoNotif(source, "~r~This NPC is on cooldown for " .. math.ceil(npc.cooldown/60) .. " minutes") end
    GoCaptureNPC(source, npcId)
end)

function GetRandomReward()
    return RandomReward[math.random(1, #RandomReward)]
end

function PlayerIsCapturing(source)
    for i, npc in pairs(ListNPC) do
        if npc.captureinfo.playerSource == source then
            return i
        end
    end
    return false
end

_RegisterServerEvent('npc_reward:RemoveCapture', function(npcId)
    local npc = ListNPC[npcId] 
    if npc then
        if npc.captureinfo.playerSource == source then
            RemoveNPCReward(npcId)
        end
    end
end)

function GoCaptureNPC(source, npcId)
    local npc = ListNPC[npcId]
    if npc.locked then return DoNotif(source, "~r~NPC is already being captured") end
    if #PlayersListSafeMode <= 10 then return DoNotif(source, "~r~You need to be 10 players in the server to capture a NPC") end
    if npc then
        npc.locked = true
        npc.reward = nil
        npc.captureinfo = {
            progress = 0,
            playerUsername = GetPlayerId(source).username,
            playerSource = source,
            playerUUID = GetPlayerId(source).uuid
        }
        _TriggerClientEvent('ShowAboveRadarMessage', source, "~r~You are now capturing ~s~" .. npc.location)
        _TriggerClientEvent('npc_reward:updateNPCData', -1, ListNPC)
    end
end

function RemoveNPCReward(npcId)
    local npc = ListNPC[npcId]
    if npc and npc.captureinfo and npc.captureinfo.playerSource then
        DoNotif(npc.captureinfo.playerSource, "~r~You have lost the capture of ~s~" .. npc.location)
    end
    npc.reward = nil
    npc.locked = false
    npc.cooldown = 0 -- No cooldown when capture is interrupted
    npc.captureinfo = {
        progress = 0,
        playerUsername = "",
        playerSource = 0,
        playerUUID = 0,
    }
    _TriggerClientEvent('npc_reward:updateNPCData', -1, ListNPC)
end

function ResetNPC(npcId)
    local npc = ListNPC[npcId]
    npc.locked = false
    npc.cooldown = 300 -- 5 minutes cooldown (300 seconds)
    npc.captureinfo = {
        progress = 0,
        playerUsername = "",
        playerSource = 0,
        playerUUID = 0,
    }
    _TriggerClientEvent('npc_reward:updateNPCData', -1, ListNPC)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000*5)
        for i, npc in pairs(ListNPC) do
            -- Handle cooldown reduction
            if npc.cooldown > 0 then
                npc.cooldown = npc.cooldown - 5
                _TriggerClientEvent('npc_reward:updateNPCData', -1, ListNPC)
                if npc.cooldown <= 0 then
                    npc.cooldown = 0
                    _TriggerClientEvent('npc_reward:updateNPCData', -1, ListNPC)
                end
            end
            
            -- Handle capture progress
            if npc.locked then
                npc.captureinfo.progress = npc.captureinfo.progress + 10
                _TriggerClientEvent('ShowAboveRadarMessage', npc.captureinfo.playerSource,"Progress: ~r~"..npc.captureinfo.progress.."%")
                _TriggerClientEvent('npc_reward:updateNPCData', -1, ListNPC)
                if npc.captureinfo.progress >= 100 then
                    local playerSource = npc.captureinfo.playerSource
                    local playerUsername = npc.captureinfo.playerUsername
                    
                    local reward = GetRandomReward()
                    
                    _TriggerClientEvent('ShowAboveRadarMessage', -1, "NPC ~r~" .. npc.location .. "~s~ has been captured by ~r~" .. playerUsername)
                    _TriggerClientEvent('ShowAboveRadarMessage', playerSource, "You loot ~g~"..reward.count.."x ~r~"..Items[reward.item].label)
                    
                    if playerSource and playerSource > 0 then
                        exports["gamemode"]:AddItem(playerSource, "inventory", reward.item, reward.count, nil, true)
                    end
                    
                    ResetNPC(i)
                end
            end
        end
    end
end)

AddEventHandler('onPlayerDropped', function()
    local playerId = source
    local player = GetPlayerId(playerId)
    if player then
        if PlayerIsCapturing(source) then
            RemoveNPCReward(PlayerIsCapturing(source))
        end
    end
end)