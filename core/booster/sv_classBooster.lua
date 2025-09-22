ClassBooster = {
    uuid = nil,
    time = nil, -- Timestamp Unix de fin du booster
    active = false,
    type = "global", -- Global ou Seulement pour le joueur (uuid)
    action = {}, -- Action du booster ("tokens", "xp", "afk", "kills")
    totalDuration = nil, -- Durée totale en secondes
    remainingTime = nil, -- Temps restant en secondes
}

ClassBooster.__index = ClassBooster

function ClassBooster:new(tblData)
    if not tblData then return end
    if type(tblData) ~= "table" then return end
    if not tblData.uuid then return Logger:trace("ClassBooster:new", "Invalid data (UUID)") end
    local self = setmetatable({}, ClassBooster)
    self.uuid = tblData.uuid
    self.totalDuration = (tblData.time and tblData.time or 1800) -- 30 minutes par défaut
    self.remainingTime = self.totalDuration -- Temps restant initial
    self.time = nil -- Sera défini lors de l'activation
    self.active = false
    self.type = (tblData.type and tblData.type or "global")
    self.action = (tblData.action and tblData.action or {})
    return self
end

function ClassBooster:activate()
    if self.active then return false end
    
    self.active = true
    self.time = os.time() + self.remainingTime -- Timestamp de fin
    return true
end

function ClassBooster:deactivate()
    if not self.active then return false end
    
    local currentTime = os.time()
    if self.time and self.time > currentTime then
        self.remainingTime = self.time - currentTime
    else
        self.remainingTime = 0
    end
    
    self.active = false
    self.time = nil
    return true
end

function ClassBooster:isExpired()
    if not self.active then return false end
    return os.time() >= self.time
end

function ClassBooster:getRemainingTime()
    if not self.active then return self.remainingTime end
    
    local currentTime = os.time()
    if self.time and self.time > currentTime then
        return self.time - currentTime
    else
        return 0
    end
end

function ClassBooster:getFormattedTime()
    local remaining = self:getRemainingTime()
    local hours = math.floor(remaining / 3600)
    local minutes = math.floor((remaining % 3600) / 60)
    local seconds = remaining % 60
    
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end