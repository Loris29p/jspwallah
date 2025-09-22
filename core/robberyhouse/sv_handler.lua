ListRobberyActive = {}

function GetRobberyData(id) 
    if ListRobberyActive[id] then 
        return ListRobberyActive[id] 
    else
        return false 
    end
end


function Deepcopy(orig)
	local orig_type, copy = type(orig)
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[Deepcopy(orig_key)] = Deepcopy(orig_value)
		end
		setmetatable(copy, Deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end


function CreateRobbery(tblData)
    if #ListRobberyActive == 2 then return false end
    -- if type(tblData) ~= "table" then return Logger:error("CreateRobbery", "tblData isn't a table") end
    local tempItems = Deepcopy(RobberyHouse.listItems)

    -- Temps Items
    for i = #tempItems, 2, -1 do
        local j = math.random(i)
        tempItems[i], tempItems[j] = tempItems[j], tempItems[i]
    end
    
    local listItems = {}
    for i = 1, math.min(7, #tempItems) do
        table.insert(listItems, tempItems[i])
    end

    --- Events 
    local randomEventIndex = math.random(#RobberyHouse.events)
    local randomEvent = RobberyHouse.events[randomEventIndex]
    local randomId = math.random(0, 5000)
    
    ListRobberyActive[randomId] = RobberyClass:new({
        pos = randomEvent.pos,
        ipl = randomEvent.ipl,
        enterPos = randomEvent.enterPos,
        canAcces = randomEvent.canAcces,    
        robList = randomEvent.robList,
        id = randomId,
        items = listItems,
    })
    ListRobberyActive[randomId].playerIn = {}
    GetRobberyData(randomId):SetAcces({
        access = true
    })
    _TriggerClientEvent("PREFIX_PLACEHOLDER:rh:SetRobberyInfos", -1, "add", {
        pos = randomEvent.pos,
        ipl = randomEvent.ipl,
        enterPos = randomEvent.enterPos,
        canAcces = randomEvent.canAcces,
        robList = randomEvent.robList,
        id = randomId,
        items = listItems,
    })
    return true
end


-- Citizen.CreateThread(function()
--     Wait(8000)
--     CreateRobbery()
-- end)

-- RegisterCommand("startRob", function()
--     CreateRobbery()
-- end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:rh:CreateRobbery", function(tblData)
    if type(tblData) ~= "table" then return DoNotif(source, "data_notenought") end 

    local src =  source 
    local PLAYER = GetPlayerId(src)
    if PLAYER then 
        if PLAYER.group ~= "user" then 

            if #ListRobberyActive == 2 then 
                return DoNotif(src, "robberyhouse_eventsfull") 
            end

            if CreateRobbery(tblData) then 
                DoNotif(src, "robberyhouse_success")
            else
                DoNotif(src, "robberyhouse_error")
            end
        else
            return DropPlayer(src, "TGGGGGGGGGGGGGG")
        end
    end

end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:rh:SetBucket", function(id)
    local src = source 
    SetPlayerRoutingBucket(src, id)
    local HouseData = GetRobberyData(id)
    HouseData:SetAcces({
        access = false
    })
    ListRobberyActive[id].playerIn[#ListRobberyActive[id].playerIn+1] = {
        username = GetPlayerId(src).username,
        uuid = GetPlayerId(src).uuid,
        source = src,
    }
    _TriggerClientEvent("PREFIX_PLACEHOLDER:rh:SetRobberyInfos", -1, "modifyAccess", {
        id = id,
        canAcces = false,
    })
end)


_RegisterServerEvent("PREFIX_PLACEHOLDER:rh:LeaveHouse", function(id)
    local src = source 
    SetPlayerRoutingBucket(src, 0)
    local HouseData = GetRobberyData(id)
    HouseData:SetAcces({
        access = true
    })
    _TriggerClientEvent("PREFIX_PLACEHOLDER:rh:SetRobberyInfos", -1, "modifyAccess", {
        id = id,
        canAcces = true,
    })
    for k, v in pairs(ListRobberyActive[id].playerIn) do 
        if v.source == src then 
            table.remove(ListRobberyActive[id].playerIn, k)
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:rh:DebugEvent", function(id)
    local intSource = source 
    if GetPlayerId(intSource).group == "user" then 
        return DropPlayer(intSource, "TGGGGGGGGGGGGGG")
    end
    local HouseData = GetRobberyData(id)

    HouseData:SetAcces({
        access = true
    })
    _TriggerClientEvent("PREFIX_PLACEHOLDER:rh:SetRobberyInfos", -1, "modifyAccess", {
        id = id,
        canAcces = true,
    })
    for k, v in pairs(ListRobberyActive[id].playerIn) do 
        SetPlayerRoutingBucket(v.source, 0)
        _TriggerClientEvent("PREFIX_PLACEHOLDER:rh:SetRobberyInfos", v.source, "event_debug", {
            id = id
        })
        table.remove(ListRobberyActive[id].playerIn, k)
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:rh:DeleteEvent", function(id)
    local intSource = source 
    if GetPlayerId(intSource).group == "user" then 
        return DropPlayer(intSource, "TGGGGGGGGGGGGGG")
    end

    _TriggerClientEvent("PREFIX_PLACEHOLDER:rh:SetRobberyInfos", -1, "remove", {
        id = id
    })

    for k, v in pairs(ListRobberyActive[id].playerIn) do 
        if v.source == src then 
            table.remove(ListRobberyActive[id].playerIn, k)
        end
    end
    ListRobberyActive[id] = nil

end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:rh:HouseFinish", function(id)
    local src = source 
    _TriggerClientEvent("PREFIX_PLACEHOLDER:rh:SetRobberyInfos", -1, "remove", {
        id = id
    })

    TriggerClientEvent('chat:addMessage', -1, { 
        template = '<div style="padding: 0.2vw; margin: 0.2vw; background-color: rgba(255, 76, 0, 0.6); border-radius: 5px;"><i class="fas fa-user-crown"></i> {0} </div>',
        args = { "^3House Robbery: ^7\n"..GetPlayerId(src).username.." rob the house!" }, color = { 0, 76, 200 } 
    })

    for k, v in pairs(ListRobberyActive[id].playerIn) do 
        if v.source == src then 
            table.remove(ListRobberyActive[id].playerIn, k)
        end
    end
    ListRobberyActive[id] = nil
end)

AddEventHandler("playerDropped", function(reason)
    local src = source 
    for k, v in pairs(ListRobberyActive) do 
        if v.playerIn then 
            for a, player in pairs(v.playerIn) do 
                if player.source == src then 
                    table.remove(ListRobberyActive[k].playerIn, a) 
                end
            end
        end
    end
end)