ClassGunrace = {
    id = 0,
    name = "",
    players = {},
    leaderboard = {},
}

ClassGunrace.__index = ClassGunrace

function ClassGunrace:new(tblData)
    local self = setmetatable({}, ClassGunrace)
    self.id = (tblData.id and tblData.id or 1)
    self.name = (tblData.name and tblData.name or "Gunrace #" .. self.id)
    self.players = (tblData.players and tblData.players or {})
    self.map = (tblData.map and tblData.map or Gunrace.maps[1])
    _TriggerClientEvent("gunrace:sendingdata", -1, "create", {
        gunraceId = self.id,
        name = self.name,
        map = self.map,
    })
    Logger:trace("GUNRACE", "Gunrace created with id: " .. self.id, "gunraceId", self.id)
    return self
end

function ClassGunrace:Finish()
    self.finished = true

    local leaderboard = self:GetLeaderboard()
    local winner, winnerName = leaderboard[1], leaderboard[1].name

    print(json.encode(leaderboard[1], {indent = true}))

    if winner then
        DoNotif(winner.source, "~g~GG! You won the gunrace!")

        _TriggerClientEvent('chat:addMessage', -1, { 
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(25, 135, 84, 0.8); border-left: 4px solid #198754;"><i class="fas fa-trophy"></i> {0} </div>',
            args = { "^#00FF00🏆 Gun Race Winner: ^#FFFFFF"..winnerName.." ^#00FF00a won the Gun Race with "..winner.kills.." eliminations! 🎉" }, color = { 0, 255, 0 } 
        })

        local intSourceLeader = GetPlayerId(tonumber(winner.source))
        local randomTokens = math.random(2500, 5000)
        -- local bonusCoins = math.random(50, 150)
        intSourceLeader.AddXP(5000)
        intSourceLeader.AddTokens(randomTokens)
        DoNotif(winner.source, "~g~Reward: ~w~" .. randomTokens .. " tokens + 5000 XP!")
        
        -- Message privé pour le gagnant
        _TriggerClientEvent('chat:addMessage', winner.source, { 
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 215, 0, 0.2); border: 1px solid gold;"><i class="fas fa-medal"></i> {0} </div>',
            args = { "^#FFD700Congratulations! You have won the Gun Race! 🏆\n^#FFFFFFRécompenses: ^#00FF00"..randomTokens.." tokens, 5000 XP" }, color = { 255, 215, 0 }
        })
    end

    for k, v in pairs(self.players) do
        self:RemovePlayer({
            source = v.source,
        })
    end

    self.players = {}
    self.leaderboard = {}
    self.finished = false
    self.map = RandomGunraceMap()
    _TriggerClientEvent("gunrace:sendingdata", -1, "finish", {
        gunraceId = self.id,
    })


    _TriggerClientEvent("gunrace:sendingdata", -1, "create", {
        gunraceId = self.id,
        name = self.name,
        map = self.map,
    })
end

function ClassGunrace:GetKillsLeader()
    local leaderboard = self:GetLeaderboard()
    return leaderboard[1].kills, leaderboard[1].name
end

function ClassGunrace:GetPlayer(source)
    for k, v in pairs(self.players) do
        if v.source == source then
            return v
        end
    end
    return false
end

function ClassGunrace:GetLeaderboard()
    local leaderboard = {}

    for k, v in pairs(self.players) do 
        table.insert(leaderboard, {
            source = v.source,
            uuid = v.uuid,
            name = v.username,
            kills = v.kills,
        })
    end

    table.sort(leaderboard, function(a, b) return a.kills > b.kills end)
    return leaderboard
end

function ClassGunrace:SendLeaderboard()
    local leaderboard = {}

    for k, v in pairs(self.players) do 
        table.insert(leaderboard, {
            source = v.source,
            uuid = v.uuid,
            username = v.username,
            kills = v.kills,
        })
    end

    table.sort(leaderboard, function(a, b) return a.kills > b.kills end)

    for k, v in pairs(leaderboard) do
        _TriggerClientEvent("gunrace:sendingdata", v.source, "leaderboard", {
            gunraceId = self.id,
            leaderboard = leaderboard,
        })
    end
end

function ClassGunrace:SendData()
    for k, v in pairs(self.players) do
        _TriggerClientEvent("gunrace:sendingdata", v.source, "update", {
            gunraceId = self.id,
            players = self.players,
        })
    end

    self:SendLeaderboard()
end

function ClassGunrace:AddPlayer(tblData)
    table.insert(self.players, {
        source = tblData.source,
        uuid = tblData.uuid,
        username = (tblData.username and tblData.username or "Unknown"),
        weapon = "none",
        kills = 0,
    })
    self:SendData()
    Wait(1000)
    _TriggerClientEvent("gunrace:sendingdata", tblData.source, "join", {
        gunraceId = self.id,
    })

    SetPlayerRoutingBucket(tblData.source, (9010 + self.id))
end

function ClassGunrace:RemovePlayer(tblData)
    for k, v in pairs(self.players) do
        if v.source == tblData.source then
            table.remove(self.players, k)
            _TriggerClientEvent("gunrace:sendingdata", tblData.source, "remove", {
                gunraceId = self.id,
            })
            SetPlayerRoutingBucket(tblData.source, 0)
            break
        end
    end

    _TriggerClientEvent("gunrace:sendingdata", -1, "mass_update", ListGunrace)
    self:SendData()
    self:SendLeaderboard()
end

function ClassGunrace:AddKills(tblData)
    for k, v in pairs(self.players) do
        if v.source == tblData.source then
            v.kills = v.kills + 1
            _TriggerClientEvent("gunrace:sendingdata", tblData.source, "addkills", {
                gunraceId = self.id,
            })
            break
        end
    end
    self:SendLeaderboard()
end