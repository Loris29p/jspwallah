ClassFFA = {
    id = 0,
    name = "",
    map = {},
    players = {},
    leaderboard = {},
}

ClassFFA.__index = ClassFFA

function ClassFFA:new(tblData)
    if type(tblData) ~= "table" then return end
    if not tblData.id then return Logger:trace("FFA", "You need to provide an id for the FFA") end
    local self = setmetatable({}, ClassFFA)
    self.id = tblData.id
    self.name = (tblData.name and tblData.name or "FFA #" .. self.id)
    self.map = (tblData.map and tblData.map or FFA_Config.listMaps[1])
    self.players = {}
    self.leaderboard = {}

    _TriggerClientEvent('ffa:sendingdata', -1, "create", self)

    return self
end

function ClassFFA:GetLeaderboard()
    local leaderboard = {}
    
    for k,v in pairs(self.players) do
        table.insert(leaderboard, {
            source = v.source,
            username = v.username,
            kills = v.kills,
        })
    end

    table.sort(leaderboard, function(a, b) return a.kills > b.kills end)

    self.leaderboard = leaderboard

    return leaderboard
end

function ClassFFA:UpdatePlayersCount()
    _TriggerClientEvent("ffa:sendingdata", -1, "update", {
        id = self.id,
        players = self.players,
    })
end

function ClassFFA:SendLeaderboard()
    local leaderboard = self:GetLeaderboard()
    for k, v in pairs(self.players) do
        _TriggerClientEvent("ffa:sendingdata", v.source, "leaderboard", {
            id = self.id,
            leaderboard = leaderboard,
        })
    end
end

function ClassFFA:SendData()
    for k, v in pairs(self.players) do
        _TriggerClientEvent("ffa:sendingdata", v.source, "update", {
            id = self.id,
            players = self.players,
        })
    end

    self:SendLeaderboard()
end


function ClassFFA:GetPlayer(source)
    for k, v in pairs(self.players) do
        if v.source == source then
            return v
        end
    end
    return false
end

function ClassFFA:SendLoadoutFFA(source)
    if not source then return end
    local weapons = self.map.items 

    local inventory = exports["gamemode"]:GetInventory(source, "inventory")
    for i = 1, #inventory do 
        local name, count = inventory[i].name, inventory[i].count 
        local bool, remove = exports["gamemode"]:RemoveItem(source, "inventory",name, count, remove or nil, true)
        if bool then
            exports["gamemode"]:AddItem(source, "protected", name, count, remove or nil, true)
        end
    end

    -- Générer un ID unique pour cette session FFA
    local ffaSessionId = "FFA_" .. self.id .. "_" .. os.time() .. "_" .. source
    
    for k, v in pairs(weapons) do 
        local name = v
        -- Ajouter l'arme avec un badge FFA unique
        local weaponInfo = {
            ffa_badge = ffaSessionId,
            ffa_map = self.map.id,
            ffa_timestamp = os.time()
        }
        exports["gamemode"]:AddItem(source, "inventory", name, 1, weaponInfo, true)
    end
    
    -- Stocker l'ID de session FFA pour ce joueur
    if not self.ffaSessions then self.ffaSessions = {} end
    self.ffaSessions[source] = ffaSessionId
end

function ClassFFA:RemoveLoadoutFFA(source)
    if not source then return end
    
    -- Nettoyer spécifiquement les armes FFA avant de vider l'inventaire
    self:CleanFFAWeapons(source)
    
    local inventory = exports["gamemode"]:ClearInventory(tonumber(source), "inventory")
    if inventory then 
        Logger:trace("FFA", "Clear loadout of the player " .. source .. " in the FFA " .. self.id)
    end
    
    -- Nettoyer la session FFA
    if self.ffaSessions and self.ffaSessions[source] then
        self.ffaSessions[source] = nil
    end
end

-- Nouvelle fonction pour nettoyer les armes FFA
function ClassFFA:CleanFFAWeapons(source)
    if not source then return end
    
    local inventory = exports["gamemode"]:GetInventory(source, "inventory")
    if not inventory then return end
    
    local ffaSessionId = self.ffaSessions and self.ffaSessions[source]
    if not ffaSessionId then return end
    
    local itemsToRemove = {}
    
    -- Identifier tous les items avec le badge FFA de ce joueur
    for i = 1, #inventory do
        local item = inventory[i]
        if item.info and item.info.ffa_badge == ffaSessionId then
            table.insert(itemsToRemove, {
                name = item.name,
                count = item.count,
                index = i
            })
        end
    end
    
    -- Supprimer les items FFA identifiés
    for _, itemData in ipairs(itemsToRemove) do
        exports["gamemode"]:RemoveItem(source, "inventory", itemData.name, itemData.count)
    end
    
    if #itemsToRemove > 0 then
        Logger:trace("FFA", "Cleaned " .. #itemsToRemove .. " FFA weapons from player " .. source)
    end
end

-- Fonction pour nettoyer les armes FFA d'un joueur spécifique (utilisée lors des déconnexions)
function ClassFFA:CleanPlayerFFAWeapons(source)
    if not source then return end
    
    local ffaSessionId = self.ffaSessions and self.ffaSessions[source]
    if not ffaSessionId then return end
    
    -- Vérifier si le joueur est toujours connecté
    local player = GetPlayerPing(source)
    if player == 0 then
        -- Joueur déconnecté, nettoyer sa session
        self.ffaSessions[source] = nil
        return
    end
    
    -- Nettoyer les armes FFA
    self:CleanFFAWeapons(source)
end

function ClassFFA:Finish()
    self.finished = true

    local leaderboard = self:GetLeaderboard()
    
    if #leaderboard > 0 then
        local winner = leaderboard[1]
        local winnerName = winner.username

        DoNotif(winner.source, "~g~GG! you won the FFA!")

        -- Message de chat amélioré pour le gagnant
        _TriggerClientEvent('chat:addMessage', -1, { 
            template = '<div style="padding: 0.8vw; margin: 0.5vw; background-color: rgba(255, 215, 0, 0.8); border: 2px solid #FFD700; border-radius: 8px;"><i class="fas fa-trophy" style="color: #FFD700;"></i> {0} </div>',
            args = { "^0🏆 ^#FFD700WINNER FFA: ^7" .. winnerName .. " ^#FFD700a he won the match " .. self.name .. " with " .. winner.kills .. " kills! " }, 
            color = { 255, 215, 0 } 
        })

        local intSourceLeader = GetPlayerId(tonumber(winner.source))
        local randomTokens = math.random(2000, 3000)
        -- local randomCoins = math.random(500, 1500)
        
        intSourceLeader.AddXP(5000)
        intSourceLeader.AddTokens(randomTokens)
        -- intSourceLeader.AddCoins(randomCoins)
        
        DoNotif(winner.source, "~g~Reward: ~y~" .. randomTokens .. " tokens ~s~+ ~p~5000 XP!")
    end

    for k, v in pairs(self.players) do
        self:RemovePlayer({
            source = v.source,
        })
        
        -- Close inventory for each player when FFA finishes
        _TriggerClientEvent("gamemode:closeInventory", v.source)
    end
    
    while #self.players > 0 do
        Wait(100)
    end

    self.players = {}
    self.leaderboard = {}
    self.finished = false
    
    -- Rotation automatique des maps
    local currentMapIndex = 1
    for i, map in ipairs(FFA_Config.listMaps) do
        if map.id == self.map.id then
            currentMapIndex = i
            break
        end
    end
    
    -- Passer à la map suivante, revenir à la première si on est à la fin
    local nextMapIndex = (currentMapIndex % #FFA_Config.listMaps) + 1
    self.map = FFA_Config.listMaps[nextMapIndex]
    self.name = self.map.name

    Logger:trace("FFA", "Map rotation: Changing to " .. self.map.name .. " (ID: " .. self.map.id .. ")")

    _TriggerClientEvent("ffa:sendingdata", -1, "finish", {
        id = self.id,
    })

    _TriggerClientEvent("ffa:sendingdata", -1, "create", {
        id = self.id,
        name = self.name,
        map = self.map,
    })
end

function ClassFFA:GetKillsLeader()
    local leaderboard = self:GetLeaderboard()
    if leaderboard[1] then
        return leaderboard[1].kills
    end
    return 0
end

function ClassFFA:AddPlayer(tblData)
    if type(tblData) ~= "table" then return end
    if not tblData.source then return end 
    if self:GetPlayer(tblData.source) then return end

    table.insert(self.players, {
        source = tblData.source,
        username = GetPlayerId(tblData.source).username,
        kills = 0,
    })

    _TriggerClientEvent('ffa:sendingdata', tonumber(tblData.source), "join", {
        id = self.id,
        name = self.name,
        map = self.map,
        players = self.players,
    })

    SetPlayerRoutingBucket(tblData.source, (9000 + self.id))

    self:SendLoadoutFFA(tblData.source)

    self:SendData()
    self:UpdatePlayersCount()
end

function ClassFFA:RemovePlayer(tblData)
    if type(tblData) ~= "table" then return end
    if not tblData.source then return end
    if not self:GetPlayer(tblData.source) then return end

    for k, v in pairs(self.players) do
        if v.source == tblData.source then
            self:RemoveLoadoutFFA(tblData.source)
            table.remove(self.players, k)
            _TriggerClientEvent('ffa:sendingdata', tblData.source, "leave", {
                id = self.id,
            })
            SetPlayerRoutingBucket(tblData.source, 0)
            break
        end
    end

    self:SendData()
    self:UpdatePlayersCount()
end

function ClassFFA:AddKills(source) 
    if not source then return end 
    local player = self:GetPlayer(source)
    if not player then return end  

    player.kills = player.kills + 1
    self:SendData()
end