LeagueTeam = {
    name = "",
    color = "",
    coords = vector3(0.0, 0.0, 0.0),
    ped = "",
    players = {},
    kills = 0,
}


LeagueTeam.__index = LeagueTeam

function LeagueTeam:CreateTeam(tblData)
    local self = setmetatable({}, LeagueTeam)
    self.name = (tblData.name and tblData.name or "Equipe #"..#LeagueTeam)
    self.color = (tblData.color and tblData.color or "^#03FFAF")
    self.color2 = (tblData.color2 and tblData.color2 or {r = 3, g = 255, b = 175})
    self.coords = (tblData.coords and tblData.coords or vector3(0.0, 0.0, 0.0))
    self.ped = (tblData.ped and tblData.ped or "a_m_m_bennys_01")
    self.players = {}
    self.kills = 0
    self.sizeEquipe = (tblData.sizeEquipe and tblData.sizeEquipe or 0)
    self.id = tblData.id
    return self
end

function LeagueTeam:AddPlayer(tblData)
    if #self.players >= self.sizeEquipe then 
        print("Team " .. self.name .. " is full!")
        return false 
    end
    
    if not tblData.src and not tblData.source then 
        print("Player data missing source!")
        return false 
    end
    
    -- Check if player is already in the team
    local source = tblData.src or tblData.source
    for _, player in pairs(self.players) do
        if player.src == source then
            print("Player already in team!")
            return true -- Already in the team, no need to add again
        end
    end
    
    -- Standardize player data
    local playerData = {
        username = tblData.username,
        src = source,
        uuid = tblData.uuid,
        kills = 0,
    }
    
    table.insert(self.players, playerData)
    
    -- Don't increment sizeEquipe, it should be the maximum allowed players
    -- self.sizeEquipe = self.sizeEquipe + 1
    
    return true
end

function LeagueTeam:RemovePlayer(source)
    print("Attempting to remove player with source " .. tostring(source) .. " from team " .. self.name)
    print("Current players in team: " .. tostring(#self.players))
    
    for k, v in pairs(self.players) do
        if v.src == source then
            print("Found player at index " .. k .. " (Username: " .. v.username .. ")")
            table.remove(self.players, k)
            print("Player removed. Team now has " .. tostring(#self.players) .. " players")
            return true
        end
    end
    
    print("Player not found in team " .. self.name)
    return false
end

function LeagueTeam:GetPlayer(source)
    for k, v in pairs(self.players) do
        if v.src == source then
            return v 
        end
    end
    return false
end

function LeagueTeam:AddKillsToPlayer(source)
    for k, v in pairs(self.players) do
        if v.src == source then
            v.kills = v.kills + 1
        end
    end
end

function LeagueTeam:GetPlayers()
    return self.players
end

function LeagueTeam:GetKills()
    return self.kills
end

function LeagueTeam:GetName()
    return self.name
end

function LeagueTeam:GetColor()
    return self.color
end

function LeagueTeam:GetCoords()
    return self.coords
end

function LeagueTeam:GetPed()
    return self.ped
end

function LeagueTeam:AddKills()
    self.kills = self.kills + 1
    return
end