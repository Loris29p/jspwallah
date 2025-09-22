ListCrew = {}
OnlineCrewPlayers = {}


function LoadAllCrew()

    MySQL.Async.fetchAll("SELECT * FROM crew", {}, function(result)
        if result[1] then 
            for k, v in pairs(result) do 
                ListCrew[v.crewId] = ClassCrew:CreateCrewData({
                    crewId = v.crewId,
                    members = json.decode(v.members),
                    crewName = v.crewName,
                    crewTag = v.crewTag,
                    stash = json.decode(v.stash),
                    rankList = json.decode(v.rankList),
                    kills = v.kills,
                    killsRedzone = v.killsRedzone,
                    aidropTaken = v.aidropTaken,
                    cupWin = v.cupWin,
                    description = v.description,
                    flag = v.flag,
                })
                -- Logger:trace("ListCrew", "Crew loaded: " .. v.crewName)
            end
        end
    end)
end

function GetAllCrew()
    return ListCrew
end

RegisterCallback("callback:crew:getLeaderboard", function(src)
    local CrewDat = GetAllCrew()
    local leaderboardData = {}

    -- Convertir les objets crew en tables simples pour le JavaScript
    for crewId, crew in pairs(CrewDat) do
        if crew then
            -- Essayer de trouver le flag du leader actuel
            local crewFlag = crew.flag or "GB"

            -- Si possible, récupérer le flag du leader actuel
            if crew.members and #crew.members > 0 then
                for _, member in pairs(crew.members) do
                    if member.rank == "leader" then
                        -- Si le leader est en ligne, récupérer son flag actuel
                        local leaderPlayer = GetPlayerUUID(member.uuid)
                        if leaderPlayer and leaderPlayer.flag then
                            crewFlag = leaderPlayer.flag
                            -- Mettre à jour le flag du crew si différent
                            if crew.flag ~= crewFlag then
                                crew.flag = crewFlag
                                crew.need_save = true
                            end
                        end
                        break
                    end
                end
            end

            table.insert(leaderboardData, {
                crewId = crewId,
                crewName = crew.crewName or "Unknown Crew",
                name = crew.crewName or "Unknown Crew", -- Alternative name field
                kills = crew.kills or 0,
                airdrops = crew.aidropTaken or 0,
                airdrop = crew.aidropTaken or 0, -- Alternative field name
                redzoneKills = crew.killsRedzone or 0,
                redzone_kills = crew.killsRedzone or 0, -- Alternative field name
                redzone = crew.killsRedzone or 0, -- Alternative field name
                country = crewFlag,
                flag = crewFlag -- Alternative field name
            })
        end
    end

    print("Leaderboard callback returning " .. #leaderboardData .. " crews")
    return leaderboardData
end)

RegisterServerEvent("PREFIX_PLACEHOLDER:c:AddAidropTaken", function()
    local intSource = source 
    local CrewDat = GetMyCrewInfo(intSource) 
    print("CREW TAKEN AIDROP")
    if CrewDat then 
        CrewDat:AddAidropTaken()
    end
end)

function GetMyCrewInfo(src)
    local PLAYER_DATA = GetPlayerId(src)
    if PLAYER_DATA == nil then return false end
    for k, v in pairs(ListCrew) do 
        for _, player in pairs(v.members) do 
            if player.uuid == PLAYER_DATA.uuid then 
                return v
            end
        end
    end
    return false
end

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:LoadMyCrew", function()
    local intSource = source
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then
        local PLAYER_DATA = GetPlayerId(intSource)

        -- Si c'est le leader qui se connecte, mettre à jour le flag du crew
        local playerRole = CrewDat:GetMemberRole(PLAYER_DATA.uuid)
        if playerRole == "leader" and PLAYER_DATA.flag then
            if CrewDat.flag ~= PLAYER_DATA.flag then
                CrewDat.flag = PLAYER_DATA.flag
                CrewDat.need_save = true
                print("Updated crew flag to leader's flag:", PLAYER_DATA.flag)
            end
        end

        if OnlineCrewPlayers[CrewDat.crewId] == nil then
            OnlineCrewPlayers[CrewDat.crewId] = {}
        end
        table.insert(OnlineCrewPlayers[CrewDat.crewId], {
            username = GetPlayerId(intSource).username,
            source = intSource,
        })

        CrewDat:ChangeNamePlayer({
            uuid = GetPlayerId(intSource).uuid,
            username = GetPlayerId(intSource).username,
        })

        CrewDat:ChangeOnline({
            uuid = GetPlayerId(intSource).uuid,
            online = true,
        })

        CrewDat:ChangeLastOnline({
            uuid = GetPlayerId(intSource).uuid,
            lastOnline = os.time(),
        })

        for k, v in pairs(OnlineCrewPlayers[CrewDat.crewId]) do
            _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", v.source, OnlineCrewPlayers[CrewDat.crewId])
        end
        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", intSource, CrewDat)
    end
end)

_AddEventHandler("playerDropped", function(reason)
    local intSource = source 
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        for k, v in pairs(OnlineCrewPlayers[CrewDat.crewId]) do 
            if v.source == intSource then 
                table.remove(OnlineCrewPlayers[CrewDat.crewId], k)
            end
            CrewDat:ChangeOnline({
                uuid = GetPlayerId(intSource).uuid,
                online = false,
            })
            -- Update gamertags
            _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", v.source, OnlineCrewPlayers[CrewDat.crewId])
        end
    end
end)

function DeleteCrew(crewId)
    -- Supprimer le crew de la base de données
    MySQL.Async.execute("DELETE FROM crew WHERE crewId = @crewId", {
        ["@crewId"] = crewId,
    })

    -- Mettre à jour tous les joueurs en ligne du crew
    if OnlineCrewPlayers[crewId] then
        for k, v in pairs(OnlineCrewPlayers[crewId]) do 
            _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", v.source, nil)
            _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, nil)
            _TriggerClientEvent("PREFIX_PLACEHOLDER:c:ReceiveLeaveCrew", v.source)
        end
    end

    -- Nettoyer les données en mémoire
    OnlineCrewPlayers[crewId] = nil
    ListCrew[crewId] = nil
    
    return true
end

-- Fonction pour vérifier si un crew est vide et le supprimer si nécessaire
function CheckAndDeleteEmptyCrew(crewId)
    local crew = ListCrew[crewId]
    if crew and #crew.members == 0 then
        print("Crew " .. crew.crewName .. " is empty, deleting...")
        DeleteCrew(crewId)
        return true
    end
    return false
end

-- RegisterCommand("deletecrew", function(src, args)
--     local CrewDat = GetMyCrewInfo(src)
--     if CrewDat then 
--        if CrewDat:GetMemberRole(GetPlayerId(src).uuid) == "leader" then 
--         DeleteCrew(CrewDat.crewId)
--        else 
--         DoNotif(src,"~HUD_COLOUR_RED~You are not the leader of this crew")
--        end
--     end
-- end)

-- Table pour stocker les confirmations en attente
local pendingLeaveConfirmations = {}

RegisterCommand("leavecrew", function(src, args)
    local CrewDat = GetMyCrewInfo(src)
    if not CrewDat then
        return DoNotif(src, "~HUD_COLOUR_RED~You are not in a crew")
    end

    local playerRole = CrewDat:GetMemberRole(GetPlayerId(src).uuid)

    if playerRole == "leader" then
        -- Pour le leader, demander confirmation
        pendingLeaveConfirmations[src] = {
            time = os.time() + 30, -- 30 secondes pour confirmer
            crewName = CrewDat.crewName
        }
        DoNotif(src, "~HUD_COLOUR_RED~WARNING: You are the leader! Your crew will be DELETED!")
        DoNotif(src, "~HUD_COLOUR_YELLOW~Type /confirmleave within 30 seconds to confirm")
    else
        -- Pour les membres normaux, quitter directement avec actualisation
        if LeaveCrew(src) then
            -- Actualiser l'UI pour tous les membres restants
            UpdateAllCrewMembersUI(CrewDat.crewId)
        end
    end
end)

RegisterCommand("confirmleave", function(src, args)
    if not pendingLeaveConfirmations[src] then
        return DoNotif(src, "~HUD_COLOUR_RED~No pending leave confirmation")
    end

    if os.time() > pendingLeaveConfirmations[src].time then
        pendingLeaveConfirmations[src] = nil
        return DoNotif(src, "~HUD_COLOUR_RED~Confirmation expired. Use /leavecrew again")
    end

    local CrewDat = GetMyCrewInfo(src)
    if CrewDat then
        local crewId = CrewDat.crewId
        if LeaveCrew(src) then
            DoNotif(src, "~HUD_COLOUR_RED~You have left and deleted your crew: " .. pendingLeaveConfirmations[src].crewName)
        end
    end

    pendingLeaveConfirmations[src] = nil
end)

-- Nettoyer les confirmations expirées
Citizen.CreateThread(function()
    while true do
        Wait(5000)
        local currentTime = os.time()
        for playerId, data in pairs(pendingLeaveConfirmations) do
            if currentTime > data.time then
                pendingLeaveConfirmations[playerId] = nil
            end
        end
    end
end)

function LeaveCrew(src)
    local CrewDat = GetMyCrewInfo(src)
    if CrewDat then
        local playerRole = CrewDat:GetMemberRole(GetPlayerId(src).uuid)
        local crewId = CrewDat.crewId

        -- Si le joueur est le leader, supprimer le crew entier
        if playerRole == "leader" then
            if DeleteCrew(CrewDat.crewId) then
                DoNotif(src,"~HUD_COLOUR_RED~You have left your crew and it has been deleted")
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:ReceiveLeaveCrew", src)
                return true
            end
        end

        -- Si ce n'est pas le leader, juste retirer le membre
        CrewDat:RemoveMembers({
            uuid = GetPlayerId(src).uuid,
        })
        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:ReceiveLeaveCrew", src)
        DoNotif(src,"~HUD_COLOUR_GREEN~You have left your crew")

        -- Vérifier si le crew est maintenant vide et le supprimer si nécessaire
        if #CrewDat.members == 0 then
            print("Crew " .. CrewDat.crewName .. " is now empty after member left, deleting...")
            DeleteCrew(CrewDat.crewId)
            return true
        end

        -- Mettre à jour la liste des joueurs en ligne et actualiser l'UI
        if OnlineCrewPlayers[crewId] then
            for k, v in pairs(OnlineCrewPlayers[crewId]) do
                if v.source == src then
                    table.remove(OnlineCrewPlayers[crewId], k)
                    _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", src, nil)
                else
                    -- Actualiser l'UI pour les membres restants
                    _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
                    _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", v.source, OnlineCrewPlayers[crewId])
                end
            end
        end
        return true
    end
    return false
end

-- Fonction pour actualiser l'UI de tous les membres du crew
function UpdateAllCrewMembersUI(crewId)
    local CrewDat = GetCrewData(crewId)
    if CrewDat and OnlineCrewPlayers[crewId] then
        for k, v in pairs(OnlineCrewPlayers[crewId]) do
            _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", v.source, OnlineCrewPlayers[crewId])
        end
    end
end

RegisterCallback("callback:crew:LeaveCrew", function(src)
    local intSource = source 
    if LeaveCrew(intSource) then 
        return true
    end
    return false
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:LeaveCrew", function()
    local intSource = source 
    LeaveCrew(intSource)
end)

function GetOnlineCrew(crewId)
    return OnlineCrewPlayers[crewId]
end


function GetCrewData(crewId)
    return ListCrew[crewId]
end

function GetPlayerCrew(src)
    local PLAYER_DATA = GetPlayerId(src)
    for k, v in pairs(ListCrew) do 
        for _, player in pairs(v.members) do 
            if player.uuid == PLAYER_DATA.uuid then 
                return v
            end
        end
    end
    return false
end

-- Fonction utilitaire pour récupérer les informations du joueur dans le crew
function GetPlayerCrewInfo(src)
    local PLAYER_DATA = GetPlayerId(src)
    for k, v in pairs(ListCrew) do 
        for _, player in pairs(v.members) do 
            if player.uuid == PLAYER_DATA.uuid then 
                return {
                    crew = v,
                    player = player,
                    role = player.rank
                }
            end
        end
    end
    return false
end

function PlayerInCrew(src)
    local PLAYER_DATA = GetPlayerId(src)
    for k, v in pairs(ListCrew) do 
        for _, player in pairs(v.members) do 
            if player.uuid == PLAYER_DATA.uuid then 
                return true
            end
        end
    end
    return false
end

function PlayerInCrewUUID(uuid)
    for k, v in pairs(ListCrew) do 
        for _, player in pairs(v.members) do 
            if player.uuid == uuid then return true end
        end
    end
    return false
end

function CreateCrew(src, tblData)
    if type(tblData) ~= "table" then return Logger:warn("CreateCrew", "Invalid data") end
    if not tblData.crewName or not tblData.crewTag then return Logger:warn("CreateCrew", "Invalid data") end

    local OWNER_DATA = GetPlayerId(src)

    -- Récupérer le flag du leader
    local leaderFlag = OWNER_DATA.flag or "GB"

    local crewId = MySQL.Sync.fetchScalar("SELECT MAX(crewId) FROM crew")

    if not crewId then
        crewId = 0
    end

    crewId = crewId + 1

    MySQL.Async.execute("INSERT INTO crew (crewId, members, crewName, crewTag, stash, rankList, kills, killsRedzone, aidropTaken, cupWin, description, flag) VALUES (@crewId, @members, @crewName, @crewTag, @stash, @rankList, @kills, @killsRedzone, @aidropTaken, @cupWin, @description, @flag)", {
        ["@crewId"] = crewId,
        ["@members"] = json.encode({}),
        ["@crewName"] = tblData.crewName,
        ["@crewTag"] = tblData.crewTag,
        ["@stash"] = json.encode({}),
        ["@rankList"] = json.encode({}),
        ["@kills"] = 0,
        ["@killsRedzone"] = 0,
        ["@aidropTaken"] = 0,
        ["@cupWin"] = 0,
        ["@description"] = (tblData.crewDesc) or "",
        ["@flag"] = leaderFlag,
    }, function(result)
        ListCrew[crewId] = ClassCrew:CreateCrewData({
            crewId = crewId,
            members = {},
            crewName = tblData.crewName,
            crewTag = tblData.crewTag,
            stash = {},
            rankList = {},
            kills = 0,
            killsRedzone = 0,
            aidropTaken = 0,
            description = (tblData.crewDesc) or "",
            flag = leaderFlag,
            cupWin = 0,
        })
        local CrewDat = GetCrewData(crewId)
        if CrewDat then
            CrewDat:AddRank({
                name = "leader",
                label = "Leader",
                permissions = 20,
            })
            CrewDat:AddRank({
                name = "coleader",
                label = "Co-Leader",
                permissions = 15,
            })
            CrewDat:AddRank({
                name = "recruit",
                label = "Recruiter",
                permissions = 10,
            })
            CrewDat:AddRank({
                name = "newbie",
                label = (tblData.NewbieRanklabel) or "Newbie",
                permissions = 1,
            })

            CrewDat:AddMembers({
                uuid = OWNER_DATA.uuid,
                username = OWNER_DATA.username,
                rank = "leader",
            })

            OWNER_DATA.sendTrigger("ShowAboveRadarMessage", ("Crew %s created"):format(tblData.crewName))
            OWNER_DATA.sendTrigger("PREFIX_PLACEHOLDER:c:LoadCrew", CrewDat)
        end
    end)
end

MySQL.ready(function() 
    LoadAllCrew()
end)

Citizen.CreateThread(function()
    while true do 
        for k, v in pairs(ListCrew) do 
            if v.need_save then

                MySQL.Async.fetchAll("SELECT * FROM crew WHERE crewId = @crewId", {
                    ["@crewId"] = v.crewId,
                }, function(result)
                    if result[1] then 
                        MySQL.Async.execute("UPDATE crew SET members = @members, crewName = @crewName, crewTag = @crewTag, stash = @stash, rankList = @rankList, kills = @kills, killsRedzone = @killsRedzone, aidropTaken = @aidropTaken, cupWin = @cupWin, description = @description, flag = @flag WHERE crewId = @crewId", {
                            ["@members"] = json.encode(v.members),
                            ["@crewName"] = v.crewName,
                            ["@crewTag"] = v.crewTag,
                            ["@stash"] = json.encode(v.stash),
                            ["@rankList"] = json.encode(v.rankList),
                            ["@kills"] = v.kills,
                            ["@killsRedzone"] = v.killsRedzone,
                            ["@aidropTaken"] = v.aidropTaken,
                            ["@cupWin"] = v.cupWin,
                            ["@description"] = v.description,
                            ["@flag"] = v.flag,
                            ["@crewId"] = v.crewId,
                        }, function(result)
                            v.need_save = false
                        end)
                    end
                end)
            end
        end
        Wait(1000)
    end
end)

_RegisterServerEvent('PREFIX_PLACEHOLDER:c:UpgradeCrewMembers', function(tlbData)
    local intSource = source 

    local intTarget = tlbData.targetUUID
    if not PlayerInCrew(intSource) then return end
    if not PlayerInCrewUUID(intTarget) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        if CrewDat:GetMemberRole(GetPlayerId(intSource).uuid) ~= "leader" then
            return DoNotif(intSource, "~HUD_COLOUR_RED~You can't upgrade this player rank (You are not the leader)")
        end

        if CrewDat:GetMemberRole(intTarget) == "leader" then
            return DoNotif(intSource, "~HUD_COLOUR_RED~You can't upgrade this player rank (Already leader)")
        end

        if CrewDat:GetMemberRole(intTarget) == "newbie" then 
            CrewDat:ChangeRankMembers({
                uuid = tlbData.targetUUID,
                rank = "recruit",
            })

            if GetPlayerUUID(tlbData.targetUUID) then 
                local PlayerData = GetPlayerUUID(tlbData.targetUUID)
                PlayerData.sendTrigger("ShowAboveRadarMessage", ("Your rank has been changed to %s"):format("Recruiter"))
                PlayerData.sendTrigger("PREFIX_PLACEHOLDER:c:LoadCrew", CrewDat)
            end 
    
            if OnlineCrewPlayers[CrewDat.crewId] then
                for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                    _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
                end
            end

        elseif CrewDat:GetMemberRole(intTarget) == "recruit" then 
            CrewDat:ChangeRankMembers({
                uuid = tlbData.targetUUID,
                rank = "coleader",
            })

            if GetPlayerUUID(tlbData.targetUUID) then 
                local PlayerData = GetPlayerUUID(tlbData.targetUUID)
                PlayerData.sendTrigger("ShowAboveRadarMessage", ("Your rank has been changed to %s"):format("Co Leader"))
                PlayerData.sendTrigger("PREFIX_PLACEHOLDER:c:LoadCrew", CrewDat)
            end 
    
            if OnlineCrewPlayers[CrewDat.crewId] then
                for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                    _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
                end
            end

        elseif CrewDat:GetMemberRole(intTarget) == "coleader" then 
            return DoNotif(intSource, "~HUD_COLOUR_RED~You can't upgrade this player rank (Max upgrade)")
        elseif CrewDat:GetMemberRole(intTarget) == "leader" then 
            return DoNotif(intSource, "~HUD_COLOUR_RED~You can't upgrade this player rank (Already leader)")
        end

        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:ReloadUICrew", intSource, CrewDat)
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:DemoteCrewMembers", function(tlbData)
    local intSource = source 

    local intTarget = tlbData.targetUUID
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if not PlayerInCrewUUID(intTarget) then return end
    if CrewDat then 
        if CrewDat:GetMemberRole(GetPlayerId(intSource).uuid) ~= "leader" then
            return DoNotif(intSource, "~HUD_COLOUR_RED~You can't demote this player rank (You are not the leader)")
        end

        if CrewDat:GetMemberRole(intTarget) == "leader" or CrewDat:GetMemberRole(intTarget) == "coleader" then 
            return DoNotif(intSource, "~HUD_COLOUR_RED~You can't demote this player rank (Leader/Co Leader)")
        end

        CrewDat:ChangeRankMembers({
            uuid = intTarget,
            rank = "newbie",
        })

        if GetPlayerUUID(tlbData.targetUUID) then 
            local PlayerData = GetPlayerUUID(tlbData.targetUUID)
            PlayerData.sendTrigger("ShowAboveRadarMessage", ("Your rank has been changed to %s"):format("Newbie"))
            PlayerData.sendTrigger("PREFIX_PLACEHOLDER:c:LoadCrew", CrewDat)
        end 

        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            end
        end

        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:ReloadUICrew", intSource, CrewDat)
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:ChangeFlag", function(tlbData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:ChangeFlag({
            flag = tlbData.flag,
        })
        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            end
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:InvitePlayer", function(tblData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end 
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        local PlayerTarget = GetPlayerId(tblData.target)
        if not PlayerTarget then return DoNotif(intSource, "~HUD_COLOUR_RED~Player not found") end

        local crewDataTarget = GetMyCrewInfo(tblData.target)
        if crewDataTarget then 
            return DoNotif(intSource, "~HUD_COLOUR_RED~Player already in a crew")
        end

        _TriggerClientEvent("ShowAboveRadarMessage", intSource, ("Invitation sent to %s"):format(PlayerTarget.username))
        PlayerTarget.sendTrigger("PREFIX_PLACEHOLDER:c:ReceiveInviteCrew", { crewName = CrewDat.crewName, crewId = CrewDat.crewId, sender = GetPlayerId(intSource).username })
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:AcceptInviteCrew", function(tblData)
    local intSource = source
    if PlayerInCrew(intSource) then return end
    local CrewDat = GetCrewData(tblData.crewId)

    if CrewDat then 
        CrewDat:AddMembers({
            uuid = GetPlayerId(intSource).uuid,
            username = GetPlayerId(intSource).username,
            rank = "newbie",
        })

        if OnlineCrewPlayers[CrewDat.crewId] == nil then 
            OnlineCrewPlayers[CrewDat.crewId] = {}
        end


        _TriggerClientEvent("ShowAboveRadarMessage", intSource, ("You have joined %s"):format(CrewDat.crewName))
        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", intSource, CrewDat)
        table.insert(OnlineCrewPlayers[CrewDat.crewId], {
            username = GetPlayerId(intSource).username,
            source = intSource,
        })

        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", v.source, OnlineCrewPlayers[CrewDat.crewId])
            end
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:ChangeCrewTag", function(tlbData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:ChangeCrewTag({
            crewTag = tlbData.crewTag,
        })
        CrewDat = GetCrewData(CrewDat.crewId)
        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", intSource, CrewDat)
        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:ReloadUICrew", intSource, CrewDat)

        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            end
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:ChangeCrewName", function(tlbData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:ChangeCrewName({
            crewName = tlbData.crewName,
        })
        CrewDat = GetCrewData(CrewDat.crewId)
        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", intSource, CrewDat) 
        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:ReloadUICrew", intSource, CrewDat)

        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            end
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:ChangeCrewDesc", function(tlbData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:ChangeCrewDesc({
            description = tlbData.description,
        })
        CrewDat = GetCrewData(CrewDat.crewId)
        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", intSource, CrewDat)
        _TriggerClientEvent("PREFIX_PLACEHOLDER:c:ReloadUICrew", intSource, CrewDat)

        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            end
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:ChangeRankMembers", function(tlbData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:ChangeRankMembers({
            uuid = tlbData.uuid,
            rank = tlbData.rank,
        })

        if GetPlayerUUID(tlbData.uuid) then 
            local PlayerData = GetPlayerUUID(tlbData.uuid)
            PlayerData.sendTrigger("ShowAboveRadarMessage", ("Your rank has been changed to %s"):format(tlbData.rank))
            PlayerData.sendTrigger("PREFIX_PLACEHOLDER:c:LoadCrew", CrewDat)
        end 

        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            end
        end
    end
end)


_RegisterServerEvent("PREFIX_PLACEHOLDER:c:CreateRank", function(tblData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:AddRank({
            name = string.lower(tblData.rankname),
            label = string.gsub(tblData.rankname, "^%l", string.upper),
            permissions = tonumber(tblData.permissions),
        })
        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            end
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:DeleteRank", function(tblData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:RemoveRank({
            name = string.lower(tblData.rankname),
        })

        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            end
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:RenameRank", function(tblData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:RenameRank({
            name = tblData.oldname,
            label = string.gsub(tblData.rankname, "^%l", string.upper),
        })

        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
            end
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:RemoveMembers", function(tblData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:RemoveMembers({
            uuid = tblData.uuid,
        })
        
        Logger:info("RemoveMembers", tblData.uuid)

        -- Retirer le joueur de la liste des joueurs en ligne
        if GetPlayerUUID(tblData.uuid) then 
            for k, v in pairs(OnlineCrewPlayers[CrewDat.crewId]) do 
                if v.source == GetPlayerUUID(tblData.uuid).source then 
                    table.remove(OnlineCrewPlayers[CrewDat.crewId], k)
                end
            end
        end

        -- Notifier le joueur expulsé
        if GetPlayerUUID(tblData.uuid) then 
            local PlayerData = GetPlayerUUID(tblData.uuid)
            PlayerData.sendTrigger("ShowAboveRadarMessage", ("You have been kicked from %s"):format(CrewDat.crewName))
            PlayerData.sendTrigger("PREFIX_PLACEHOLDER:c:LoadCrew", nil)
            PlayerData.sendTrigger("PREFIX_PLACEHOLDER:c:LoadCrewOnline", nil)
        end 

        -- Vérifier si le crew est maintenant vide et le supprimer si nécessaire
        if #CrewDat.members == 0 then
            print("Crew " .. CrewDat.crewName .. " is now empty, deleting...")
            DeleteCrew(CrewDat.crewId)
            return
        end

        -- Mettre à jour l'interface pour les autres membres
        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                Logger:info("RemoveMembers Update", v.source)
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", v.source, OnlineCrewPlayers[CrewDat.crewId])
            end
        end
    end
end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:AddMembers", function(tblData)
    local intSource = source 
    if not PlayerInCrew(intSource) then return end
    local CrewDat = GetMyCrewInfo(intSource)
    if CrewDat then 
        CrewDat:AddMembers({
            uuid = tblData.uuid,
            username = GetPlayerUUID(tblData.uuid).username,
            rank = "newbie",
        })

        table.insert(OnlineCrewPlayers[CrewDat.crewId], {
            username = GetPlayerUUID(tblData.uuid).username,
            source = GetPlayerUUID(tblData.uuid).source,
        })

        if GetPlayerUUID(tblData.uuid) then 
            local PlayerData = GetPlayerUUID(tblData.uuid)
            PlayerData.sendTrigger("ShowAboveRadarMessage", ("You have been added to %s"):format(CrewDat.crewName))
            PlayerData.sendTrigger("PREFIX_PLACEHOLDER:c:LoadCrew", CrewDat)
            PlayerData.sendTrigger("PREFIX_PLACEHOLDER:c:LoadCrewOnline", OnlineCrewPlayers[CrewDat.crewId])
        end 

        if OnlineCrewPlayers[CrewDat.crewId] then
            for k, v in pairs(GetOnlineCrew(CrewDat.crewId)) do 
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrew", v.source, CrewDat)
                _TriggerClientEvent("PREFIX_PLACEHOLDER:c:LoadCrewOnline", v.source, OnlineCrewPlayers[CrewDat.crewId])
            end
        end
    end

end)

_RegisterServerEvent("PREFIX_PLACEHOLDER:c:CreateCrew", function(tlbData)
    local intSource = source 
    if PlayerInCrew(intSource) then return end

    CreateCrew(intSource, tlbData)
end)


RegisterCallback("callback:crew:getData", function(src)
    local CrewDat = GetMyCrewInfo(src)
    if CrewDat then 
        return CrewDat
    end
    return false
end)

_RegisterServerEvent("crew:setBucketCrew", function(tblData)
    if type(tblData) ~= "table" then return end
    local intSource = source

    SetPlayerRoutingBucket(intSource, tonumber(tblData.crewId))
    _TriggerClientEvent("ShowAboveRadarMessage", intSource, "You joined your ~g~"..tblData.crewName.."~s~ bunker")
end)

_RegisterServerEvent("crew:leftCrewBunker", function()
    local intSource = source
    SetPlayerRoutingBucket(intSource, 0)
end)


function GetTableLength(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

-- Système d'annonce crew
RegisterCommand("crewannounce", function(src, args)
    if src == 0 then return end -- Empêcher l'utilisation depuis la console

    local CrewDat = GetMyCrewInfo(src)
    if not CrewDat then
        return DoNotif(src, "~HUD_COLOUR_RED~You are not in a crew")
    end

    local playerRole = CrewDat:GetMemberRole(GetPlayerId(src).uuid)

    -- Vérifier les permissions (leader, co-leader et recruiter peuvent annoncer)
    if playerRole ~= "leader" and playerRole ~= "coleader" and playerRole ~= "recruit" then
        return DoNotif(src, "~HUD_COLOUR_RED~You don't have permission to send crew announcements")
    end

    -- Joindre tous les arguments en un seul message
    local message = table.concat(args, " ")

    if message == "" or message == " " then
        return DoNotif(src, "~HUD_COLOUR_RED~Usage: /crewannounce <message>")
    end

    -- Envoyer l'annonce à tous les membres du crew en ligne
    if OnlineCrewPlayers[CrewDat.crewId] then
        local senderName = GetPlayerId(src).username
        local roleLabel = ""

        -- Obtenir le label du rôle
        for _, rank in pairs(CrewDat.rankList) do
            if rank.name == playerRole then
                roleLabel = rank.label
                break
            end
        end

        for k, v in pairs(OnlineCrewPlayers[CrewDat.crewId]) do
            _TriggerClientEvent("ShowAboveRadarMessage", v.source,
                string.format("~b~[CREW] ~y~[%s] ~g~%s: ~w~%s", roleLabel, senderName, message))

            -- Jouer un son de notification
            _TriggerClientEvent("PlaySound", v.source, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET")
        end
    end
end)

-- Alias pour la commande
RegisterCommand("ca", function(src, args)
    -- Rediriger vers la commande principale
    ExecuteCommand("crewannounce " .. table.concat(args, " "))
end)

-- Fonction d'annonce serveur pour les événements automatiques
function SendCrewAnnouncement(crewId, message)
    if OnlineCrewPlayers[crewId] then
        for k, v in pairs(OnlineCrewPlayers[crewId]) do
            _TriggerClientEvent("ShowAboveRadarMessage", v.source,
                string.format("~b~[CREW] ~w~%s", message))
        end
    end
end

-- Event pour les annonces depuis le client (si besoin)
_RegisterServerEvent("PREFIX_PLACEHOLDER:c:SendCrewAnnounce", function(message)
    local src = source
    local CrewDat = GetMyCrewInfo(src)

    if not CrewDat then return end

    local playerRole = CrewDat:GetMemberRole(GetPlayerId(src).uuid)

    if playerRole ~= "leader" and playerRole ~= "coleader" and playerRole ~= "recruit" then
        return
    end

    if OnlineCrewPlayers[CrewDat.crewId] then
        local senderName = GetPlayerId(src).username
        for k, v in pairs(OnlineCrewPlayers[CrewDat.crewId]) do
            _TriggerClientEvent("ShowAboveRadarMessage", v.source,
                string.format("~b~[CREW] ~g~%s: ~w~%s", senderName, message))
        end
    end
end)