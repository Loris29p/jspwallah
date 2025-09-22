TeamClass = {
    name = "",
    color = "",
    coords = vector4(0.0, 0.0, 0.0, 0.0),
    players = {},
    kills = 0,
}

TeamClass.__index = TeamClass

function TeamClass:New(tblData)
    if type(tblData) ~= "table" then return end
    local self = setmetatable({}, TeamClass)
    self.name = (tblData.name and tblData.name or "Equipe #"..#TeamClass)
    self.color = (tblData.color and tblData.color or "^#03FFAF")
    self.color2 = (tblData.color2 and tblData.color2 or {r = 3, g = 255, b = 175})
    self.coords = (tblData.coords and tblData.coords or vector4(0.0, 0.0, 0.0, 0.0))
    self.players = {}
    self.kills = 0
    self.sizeEquipe = (tblData.sizeEquipe and tblData.sizeEquipe or 0)
    self.teamId = (tblData.teamId and tblData.teamId or 0)
    print("Team created with id "..self.name)
    return self
end

function TeamClass:AddPlayer(tblData)
    if type(tblData) ~= "table" then return false end
    if not tblData.uuid or not tblData.username or not tblData.source then return false end
    if #self.players >= self.sizeEquipe then 
        return false 
    end
    for _, player in pairs(self.players) do
        if player.uuid == tblData.uuid then
            print("Player already in team!")
            return true
        end
    end

    local PLAYER <const> = GetPlayerId(tblData.source)
    if not PLAYER then return false end

    for _, player in pairs(self.players) do 
        if player.source == PLAYER.source then
            return false, "You are already in team!"
        end
    end

    local playerData = {
        username = PLAYER.username,
        source = PLAYER.source,
        uuid = PLAYER.uuid,
        kills = 0,
    }

    Logger:trace("TEAM CASS (ADD)", "Player " .. playerData.username .. " added to team " .. self.name)
    table.insert(self.players, playerData)
    return true
end

function TeamClass:RemovePlayer(tblData)
    if type(tblData) ~= "table" then return false end
    if not tblData.uuid then return false end
    for k, v in pairs(self.players) do
        if v.uuid == tblData.uuid then
            table.remove(self.players, k)
            return true
        end
    end
    return false
end

function TeamClass:GetPlayer(uuid)
    if not uuid then return false end
    for k, v in pairs(self.players) do
        if v.uuid == uuid then
            return v
        end
    end
    return false
end

function TeamClass:AddKillsToPlayer(uuid)
    if not uuid then return false end
    for k, v in pairs(self.players) do
        if v.uuid == uuid then
            v.kills = v.kills + 1
            self.kills = self.kills + 1
            return true
        end
    end
    return false
end

function TeamClass:GetPlayers()
    return self.players
end

function TeamClass:GetKills()
    return self.kills
end

function TeamClass:GetName()
    return self.name
end

function TeamClass:GetCoords()
    return self.coords
end

function TeamClass:SetCoords(coords)
    if type(coords) ~= "vector4" then return false end
    self.coords = coords
    return true
end