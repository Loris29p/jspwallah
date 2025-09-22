RobberyClass = {
    id = 0,
    pos = vector4(0, 0, 0, 0),
    ipl = "",
    enterPos = vector4(0, 0, 0, 0),
    canAcces = true,
    robList = {},
    items = {},
}


RobberyClass.__index = RobberyClass

local automaticItemsSelec = {
    "deluxo",
    "nightshark",
    "buzzard2",
    "weapon_combatmg_mk2",
    "weapon_marksmanrifle_mk2",
    "weapon_bullpuprifle_mk2",
    "weapon_assaultrifle_mk2",
    "weapon_combatmg",
    "weapon_carbinerifle_mk2",
    "weapon_knife",
    "buffalo2",
}

function RobberyClass:new(tblData)
    local self = setmetatable({}, RobberyClass)
    self.id = tblData.id and tblData.id or 0
    self.pos = tblData.pos and tblData.pos or vector4(0, 0, 0, 0)
    self.ipl = tblData.ipl and tblData.ipl or nil 
    self.enterPos = tblData.enterPos and tblData.enterPos or vector4(0, 0, 0, 0)
    self.canAcces = tblData.canAcces and tblData.canAcces or true 
    self.robList = tblData.robList and tblData.robList or {}
    self.items = tblData.items and tblData.items or automaticItemsSelec
    return self
end

function RobberyClass:SetAcces(tblData)
    if type(tblData) ~= "nil" then 
        self.canAcces = tblData.access
    else 
        Logger:error("Robbery", "Access isn't a table") 
    end
end
