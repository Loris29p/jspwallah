Airdrop = {}

function RandomAirdropSpawn()
    local airdropIndex = math.random(1, #AirdropList)
    local airdropSelected = AirdropList[airdropIndex]
    return airdropSelected
end

function RandomAirdropItems()
    local AirdropItems = {}

    local itemIndex = math.random(1, #AirdropListItems)
    local itemSelected = AirdropListItems[itemIndex]

    table.insert(AirdropItems, itemSelected[1])
    table.insert(AirdropItems, itemSelected[2])


    return AirdropItems
end

-- RegisterCommand("drop", function(source, args)
--     local PLAYER = GetPlayerId(source)
--     if PLAYER and PLAYER.group ~= "user" then
--         CreateAirdrop()
--     end
-- end)

function CreateAirdrop()
    local airdropPos = RandomAirdropSpawn()
    local airdropItems = RandomAirdropItems()
    local airdropId = math.random(9000, 100000)
    if Airdrop[airdropId] ~= nil then 
        airdropId = math.random(9000, 100000)
    end
    Airdrop[airdropId] = {
        airdropId = airdropId,
        airdropPos = airdropPos,
        airdropItems = airdropItems,
        startTimer = os.time(),
        startDrop = 0,
    }
    local startAAA = os.time()
    _TriggerClientEvent("test:Event", -1)
    _TriggerClientEvent("kAirdrop:client:CreateDrop", -1, airdropPos, airdropId, startAAA)

    AddItemDrop(airdropItems[1].name, airdropItems[1].count, airdropId)
    AddItemDrop(airdropItems[2].name, airdropItems[2].count, airdropId)
end

_RegisterServerEvent("setDropData", function(id, coordsZ)
    if Airdrop[id] == nil then return end
    Airdrop[id].airdropPos["drop"].z = coordsZ
end)

_RegisterServerEvent("kAirdrop:server:syncDeleteDrop", function(drop)
    _TriggerClientEvent("kAirdrop:client:syncDeleteDrop", -1, drop)
end)

_RegisterServerEvent("kAirdrop:server:syncNpc", function(entityid)
    _TriggerClientEvent("kAirdrop:client:syncNpc", -1, entityid)
end)

_RegisterServerEvent("kAirdrop:server:createBox", function(dropCoords, id, timer)
    if Airdrop[id] == nil then return end
    Airdrop[id].startDrop = timer
    _TriggerClientEvent("kAirdrop:client:createBox", source, dropCoords, id, timer)
end)

function GetDropItemInfo(item, dropId)
    local dropData = Airdrop[dropId].airdropItems
    for k, v in pairs(dropData) do
        if v.name == item then
            return v, k
        end
    end
    return false, nil
end

function AddItemDrop(item, count, dropId)
    _TriggerClientEvent("gamemode:updateDrop", -1, Airdrop[dropId].airdropItems, nil, dropId)
    return true
end

function RemoveItemDrop(item, count, dropId)
    return true
end

_RegisterServerEvent("zoliax:dropSrv", function(eventName, eventData)
    local intSource = source
    local player = GetPlayerId(intSource)
    if not player then return end
    if not eventName or not eventData then return end

    if tonumber(eventData.dropId) == nil then return end
    if Airdrop[tonumber(eventData.dropId)] == nil then return end

    if eventName == "open_drop" then
        _TriggerClientEvent("inventory:OpenContainer", intSource, Airdrop[eventData.dropId].airdropItems, "airdrop-"..eventData.dropId, "airdrop")
    elseif eventName == "take_item" then
        local dropId = tonumber(eventData.dropId)

        for _,v in pairs(Airdrop[dropId].airdropItems) do
            if v.name == eventData.itemData then
                if v.count <= 1 then
                    table.remove(Airdrop[dropId].airdropItems, _)
                else
                    v.count = v.count - 1
                end
            end
        end

        if RemoveItemDrop(eventData.itemData, 1, dropId) then
            if AddItem(intSource, "inventory", eventData.itemData, 1) then
                _TriggerClientEvent("ShowAboveRadarMessage", intSource, "You took ~g~1x ~b~"..Items[eventData.itemData].label.."~s~ from the airdrop")
                _TriggerClientEvent("chat:addMessage", -1, { -- chat notification to inform all players
                    color = { 255, 255, 255 },
                    multiline = false,
                    args = { "^4("..player.uuid..") "..player.username.."^0 ", "^1"..player.username.." has taken "..Items[eventData.itemData].label.." from the airdrop." }
                })

                writeLog(intSource, "https://discord.com/api/webhooks/1295825489252057271/rzVtH8lKA60v9B8d-RbOg8pVSHlFewVCTQXnko2rZJuV7I9E96yQMvW5KZRUzP9SQUIl", false, "Airdrop loot", "**"..player.username.." ("..player.uuid..")** took **1x "..Items[eventData.itemData].label.."** from the airdrop")
            end
        end

        _TriggerClientEvent("gamemode:updateDrop", -1, Airdrop[dropId].airdropItems, nil, dropId)
        
        if #Airdrop[dropId].airdropItems <= 0 then
            _TriggerClientEvent("kAirdrop:client:syncDeleteDrop", -1, dropId)
            Airdrop[dropId] = nil
            return
        end
    end
end)

local timesDrop = {
    ["00:00:00"] = true,
    ["02:00:00"] = true,
    ["04:00:00"] = true,
    ["06:00:00"] = true,
    ["08:00:00"] = true,
    ["09:30:00"] = true,
    ["11:00:00"] = true,
    ["13:00:00"] = true,
    ["14:00:00"] = true,
    ["16:00:00"] = true,
    ["17:30:00"] = true,
    ["18:30:00"] = true,
    ["20:00:00"] = true,
    ["22:00:00"] = true,
    ["23:00:00"] = true,
}

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(700)
--         local utcTime = os.date('%X')

--         if timesDrop[utcTime] then
--             if GetNumPlayerIndices() >= tonumber(5) then
--                 CreateAirdrop()
--             end
--         end
--     end
-- end)