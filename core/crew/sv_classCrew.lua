ClassCrew = {
    crewId = 0,
    members = {},
    crewName = "",
    crewTag = "",
    stash = {},
    rankList = {},
    description = "",
    flag = "",

    kills = 0,
    killsRedzone = 0,
    aidropTaken = 0,
    cupWin = 0,
    need_save = false,

}

ClassCrew.__index = ClassCrew
---@return ClassCrew


function ClassCrew:CreateCrewData(data)
    local self = setmetatable({}, ClassCrew)
    self.crewId = data.crewId
    self.members = (data.members) or {}
    self.crewName = (data.crewName) or "None"
    self.crewTag = (data.crewTag) or "NONE" 
    self.stash = (data.stash) or {}
    self.rankList = (data.rankList) or {}
    self.description = (data.description) or ""
    self.flag = (data.flag) or "GB"

    self.kills = (data.kills) or 0
    self.killsRedzone = (data.killsRedzone) or 0
    self.aidropTaken = (data.aidropTaken) or 0

    return self
end

function ClassCrew:AddAidropTaken()
    self.aidropTaken = self.aidropTaken + 1
    self.need_save = true
    return true
end

function ClassCrew:AddRank(tblData)
    if type(tblData) == "table" then 
        for k, v in pairs(self.rankList) do 
            if v.name == tblData.name then 
                return false
            end
        end

        table.insert(self.rankList, { 
            name = tblData.name,
            label = tblData.label,
            rankId = #self.rankList + 1,
            permissions = tblData.permissions,
        })
        self.need_save = true
        return true
    end
end

function ClassCrew:RemoveRank(tblData)
    if type(tblData) == "table" then 
        for k, v in pairs(self.rankList) do 
            if v.name == tblData.name then 
                table.remove(self.rankList, k)
                return true
            end
        end
    end
    return false
end

function ClassCrew:RenameRank(tblData)
    if type(tblData) == "table" then 
        for k, v in pairs(self.rankList) do 
            if v.name == tblData.name then 
                self.rankList[k].label = tblData.label
                return true
            end
        end
    end
    return false
end

function ClassCrew:UpdatePermissionsRank(tblData)
    if type(tblData) == "table" then 
        for k, v in pairs(self.rankList) do 
            if v.name == tblData.name then 
                self.rankList[k].permissions = tblData.permissions
                return true
            end
        end
    end
    return false
end

function ClassCrew:AddMembers(tblData)
    if type(tblData) == "table" then 

        for k, v in pairs(self.members) do 
            if v.uuid == tblData.uuid then 
                return false
            end
        end

        table.insert(self.members, {
            uuid = tblData.uuid,
            username = tblData.username,
            rank = tblData.rank,
            aidropTaken = 0,
            kills = 0,
            killsRedzone = 0,
            lastOnline = os.time(),
            online = true,
        })
        self.need_save = true
    end
end

function ClassCrew:ChangeFlag(tblData)
    if type(tblData) == "table" then 
        self.flag = tblData.flag
        self.need_save = true

        return true
    end
    return false
end

function ClassCrew:ChangeCrewDesc(tblData)
    if type(tblData) == "table" then 
        self.description = tblData.description
        self.need_save = true

        return true
    end
    return false
end

function ClassCrew:ChangeCrewName(tblData)
    if type(tblData) == "table" then 
        self.crewName = tblData.crewName
        self.need_save = true
        return true
    end
    return false
end

function ClassCrew:ChangeCrewTag(tblData)
    if type(tblData) == "table" then 
        self.crewTag = tblData.crewTag
        self.need_save = true
        return true
    end
    return false
end

function ClassCrew:RemoveMembers(tblData)
    if type(tblData) == "table" then 
        for k, v in pairs(self.members) do 
            if v.uuid == tblData.uuid then 
                table.remove(self.members, k)
                self.need_save = true
                return true
            end
        end
    end
    return false
end

function ClassCrew:GetMemberRole(uuid)
    for k, v in pairs(self.members) do 
        if v.uuid == uuid then 
            return v.rank
        end
    end
    return false
end

function ClassCrew:ChangeRankMembers(tblData)
    if type(tblData) == "table" then 
        for k, v in pairs(self.members) do 
            if v.uuid == tblData.uuid then 
                self.members[k].rank = tblData.rank
                self.need_save = true
                return true
            end
        end
    end
    return false
end

function ClassCrew:ChangeNamePlayer(tblData)
    if type(tblData) == "table" then 
        for k, v in pairs(self.members) do 
            if v.uuid == tblData.uuid then 
                self.members[k].username = tblData.username
                self.need_save = true
                return true
            end
        end
    end
    return false
end

function ClassCrew:ChangeLastOnline(tblData)
    if type(tblData) == "table" then 
        for k, v in pairs(self.members) do 
            if v.uuid == tblData.uuid then 
                self.members[k].lastOnline = tblData.lastOnline
                self.need_save = true
                return true
            end
        end
    end
    return false
end

function ClassCrew:ChangeOnline(tblData)
    if type(tblData) == "table" then 
        for k, v in pairs(self.members) do 
            if v.uuid == tblData.uuid then 
                self.members[k].online = tblData.online
                return true
            end
        end
    end
    return false
end

function ClassCrew:AddKills(tblData)
    if type(tblData) == "table" then 
        if tblData.type == "global" then 
            self.kills = self.kills + 1
            self.need_save = true
            return true
        elseif tblData.type == "redzone" then
            self.killsRedzone = self.killsRedzone + 1
            self.need_save = true
            return true
        end
    end

    return false
end