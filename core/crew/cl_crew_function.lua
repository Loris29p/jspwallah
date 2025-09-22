CrewData = nil 
CrewOnlinePlayer = nil

local GamerTagsCrew = false

local mpGamerTags = {}
local mpGamerTagSettings = {}

local gtComponent = {
    GAMER_NAME = 0,
    CREW_TAG = 1,
    healthArmour = 2,
    BIG_TEXT = 3,
    AUDIO_ICON = 4,
    MP_USING_MENU = 5,
    MP_PASSIVE_MODE = 6,
    WANTED_STARS = 7,
    MP_DRIVER = 8,
    MP_CO_DRIVER = 9,
    MP_TAGGED = 10,
    GAMER_NAME_NEARBY = 11,
    ARROW = 12,
    MP_PACKAGES = 13,
    INV_IF_PED_FOLLOWING = 14,
    RANK_TEXT = 15,
    MP_TYPING = 16
}
function RemoveGamerTags()
    for k,v in pairs(mpGamerTags) do
        RemoveMpGamerTag(v.tag)
    end
    mpGamerTags = {}
end

local function makeSettings()
    return {
        alphas = {},
        colors = {},
        healthColor = false,
        toggles = {},
        wantedLevel = false
    }
end

function RenderNamesCrew(v, isSquad)
    local i = GetPlayerFromServerId(v.id)
    if NetworkIsPlayerActive(i) and i ~= PlayerId() then
        if i ~= -1 then
            -- get their ped
            local ped = GetPlayerPed(i)
            local pedCoords = GetEntityCoords(ped)
            local health = GetEntityHealth(ped) - 100
            health = health >= 0 and health or GetEntityHealth(ped)
            if not mpGamerTagSettings[i] then
                mpGamerTagSettings[i] = makeSettings()
            end
            if not mpGamerTags[i] or mpGamerTags[i].ped ~= ped or not IsMpGamerTagActive(mpGamerTags[i].tag) then
                local nameTag = v.name
                if mpGamerTags[i] then
                    RemoveMpGamerTag(mpGamerTags[i].tag)
                end
                mpGamerTags[i] = {
                    tag = CreateMpGamerTag(GetPlayerPed(i), nameTag, false, false, '', 0),
                    ped = ped
                }
            end
            local tag = mpGamerTags[i].tag
            if mpGamerTagSettings[i].rename then
                SetMpGamerTagName(tag, v.name)
                mpGamerTagSettings[i].rename = nil
            end

            local distance = #(pedCoords - GetEntityCoords(ped))
            if distance < 100 then
                SetMpGamerTagVisibility(tag, gtComponent.GAMER_NAME, true)
                SetMpGamerTagVisibility(tag, gtComponent.healthArmour, true)
                -- SetMpGamerTagVisibility(tag, gtComponent.AUDIO_ICON, NetworkIsPlayerTalking(i))
                -- SetMpGamerTagAlpha(tag, gtComponent.AUDIO_ICON, 255)
                SetMpGamerTagAlpha(tag, gtComponent.healthArmour, 255)

                local settings = mpGamerTagSettings[i]
                for k, v in pairs(settings.toggles) do
                    SetMpGamerTagVisibility(tag, gtComponent[k], v)
                end

                for k, v in pairs(settings.alphas) do
                    SetMpGamerTagAlpha(tag, gtComponent[k], v)
                end

                if health > 66 then
                    SetMpGamerTagHealthBarColour(tag, 18)
                elseif health > 33 then
                    SetMpGamerTagHealthBarColour(tag, 12)
                elseif health > 0 then -- 6 - kırmızı, 8 - bordo, 12 - sarı, 18 - yeşil
                    SetMpGamerTagHealthBarColour(tag, 6)
                end
                if isSquad then
                    SetMpGamerTagColour(tag, 0, 0)
                end
            else
                SetMpGamerTagVisibility(tag, gtComponent.GAMER_NAME, false)
                SetMpGamerTagVisibility(tag, gtComponent.healthArmour, false)
            end
        end
    end
end

function StartLoopsGamertags()
    if not CrewOnlinePlayer then return end
    GamerTagsCrew = true
    Citizen.CreateThread(function()
        while GamerTagsCrew do
            Citizen.Wait(1000)
            if CrewOnlinePlayer then
                for k, v in pairs(CrewOnlinePlayer) do
                    local data = {
                        id = v.source,
                        name = v.username
                    }
                    RenderNamesCrew(data, true)
                end
            end
        end
        RemoveGamerTags()
    end)
end
_RegisterNetEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", function(tblData)
    CrewOnlinePlayer = tblData
    Logger:trace("CREW", "Crew online loaded")

    GamerTagsCrew = false
    RemoveGamerTags()
    StartLoopsGamertags()
end)


_RegisterNetEvent("PREFIX_PLACEHOLDER:c:LoadCrew", function(tblData)
    CrewData = tblData
    CrewData.myRank = GetMyRank()
    Logger:trace("CREW", "Crew loaded")
end)


function GetMyRank()
    if CrewData then 
        for k, v in pairs(CrewData.members) do 
            if v.uuid == GM.Player.UUID then 
                return v.rank
            end
        end
    end
    return false
end

function GetRankPermissions(rank)
    if CrewData then 
        for k, v in pairs(CrewData.rankList) do 
            if v.name == rank then 
                return v.permissions
            end
        end
    end
    return false
end

function hasPermissions(permissionsId)
    local rank = GetMyRank()
    if rank then 
        local myPermissions = GetRankPermissions(rank) or 1
        if myPermissions >= permissionsId then 
            return true
        end
        return false
    end
end