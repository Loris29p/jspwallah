GameClass = {
    id = 0,
    code = "",
    listPlayers = {},
    map = {},
    ownerUUID = 0,
    ownerUsername = "",
    started = false,
    bet = 0,
    meta = "",
}

GameClass.__index = GameClass


function GameClass:new(tblData)
    if type(tblData) ~= "table" then return end
    local self = setmetatable({}, GameClass)
    self.id = (tblData.id and tblData.id or math.random(6000, 9999999))
    self.code = (tblData.code and tblData.code or "public")
    self.listPlayers = {}
    self.map = (tblData.map and tblData.map or "Beach")
    self.ownerUUID = (tblData.ownerUUID and tblData.ownerUUID or GetPlayerId(source).uuid)
    self.ownerUsername = (tblData.ownerUsername and tblData.ownerUsername or GetPlayerId(source).username)
    self.started = (tblData.started and tblData.started or false)
    self.bet = (tblData.bet and tblData.bet or 100000)
    self.meta = (tblData.meta and tblData.meta or "kuruma_specialcarbine")
    return self
end

function GameClass:StartGame()
    self.started = true
end

function GameClass:StopGame()
    self.started = false
end

function GameClass:AddPlayer(tblData)
    if type(tblData) ~= "table" then return false end
    if not tblData.uuid or not tblData.username then return false end
    local PLAYER <const> = GetPlayerId(tblData.source) 
    if not PLAYER then return false end
    for k, v in pairs(self.listPlayers) do
        if v.uuid == tblData.uuid then
            print("Player already in game", tblData.username, tblData.uuid)
            return false, "~r~You are already in the game"
        end
    end
    table.insert(self.listPlayers, {
        uuid = tblData.uuid,
        username = tblData.username,
        source = tblData.source,
        team = "none",
        teamId = 0,
    })
    print("Player added to game", tblData.username, tblData.uuid)
    return true, "~g~You have been added to the game"
end

function GameClass:GetPlayerList()
    return self.listPlayers
end

function GameClass:RemovePlayer(tblData)
    if type(tblData) ~= "table" then return false end
    if not tblData.uuid then return false end
    for k, v in pairs(self.listPlayers) do
        if v.uuid == tblData.uuid then
            table.remove(self.listPlayers, k)
            return true
        end
    end
    return false
end

function GameClass:GetPlayer(uuid)
    if not uuid then return false end
    for k, v in pairs(self.listPlayers) do
        if v.uuid == uuid then
            return v
        end
    end
    return false
end

function GameClass:GetPlayerTeamId(uuid)
    if not uuid then return false end
    for k, v in pairs(self.listPlayers) do
        if v.uuid == uuid then
            return v.teamId
        end
    end
    return false
end