function AddBadge(uuid)
    if not uuid then return false end
    local result = MySQL.query.await("SELECT * FROM players WHERE `uuid` = @uuid", {["@uuid"] = uuid})
    if result[1] then 
        print(result[1].username)
        local dataPlayer = json.decode(result[1].data)
        if not dataPlayer["badge"] then 
            dataPlayer["badge"] = {
                access = true
            }
            if PlayersIsOnlineUUID(uuid) then 
                print("ADD BADGE TO PLAYER, IS ONLINE")	
                PlayersIsOnlineUUID(uuid).AddNewData("badge", {access = true})
            end
        else 
            return false, "Badge access already exists"
        end
        MySQL.update("UPDATE players SET data = @data WHERE uuid = @uuid", {["@data"] = json.encode(dataPlayer), ["@uuid"] = uuid})
        return true, "Badge access added"
    end
    return false, "Player not found"
end

function CheckBadgeForRemove(uuid)
    if not uuid then
        print("^1[ERROR]^7 CheckBadgeForRemove: UUID is nil")
        return false, "Invalid UUID"
    end

    local success, result = pcall(function()
        return MySQL.query.await("SELECT * FROM players WHERE `uuid` = @uuid", {["@uuid"] = uuid})
    end)

    if not success then
        print("^1[ERROR]^7 CheckBadgeForRemove: MySQL error for UUID " .. uuid)
        return false, "Database error"
    end

    if result and result[1] then 
        local success, dataPlayer = pcall(json.decode, result[1].data)
        if not success then
            print("^1[ERROR]^7 CheckBadgeForRemove: JSON decode error for UUID " .. uuid)
            return false, "Data corruption"
        end

        if dataPlayer["badge"] then 
            print("^2[INFO]^7 Removing badge for UUID " .. uuid)
            dataPlayer["badge"] = nil
            
            local success = pcall(function()
                MySQL.update("UPDATE players SET data = @data WHERE uuid = @uuid", {
                    ["@data"] = json.encode(dataPlayer),
                    ["@uuid"] = uuid
                })
            end)

            if not success then
                print("^1[ERROR]^7 CheckBadgeForRemove: Failed to update database for UUID " .. uuid)
                return false, "Failed to update database"
            end

            print("^2[SUCCESS]^7 Badge removed for UUID " .. uuid)
            if PlayersIsOnlineUUID(uuid) then 
                print("REMOVE BADGE TO PLAYER, IS ONLINE")
                PlayersIsOnlineUUID(uuid).RemoveData("badge")
            end
            return true, "Badge access removed"
        else
            print("^3[INFO]^7 No badge found for UUID " .. uuid)
        end
    end
    return false, "No badge to remove"
end

RegisterCommand("addbadge_tebex", function(source, args, rawCommand)
    local src = source
    if src ~= 0 then return end
    local uuid = tonumber(args[1])
    if not uuid then return end
    local success, message = AddBadge(uuid)
    if success then 
        print(message)
    else 
        print(message)
    end
end, true)

RegisterCommand("removebadge_tebex", function(source, args, rawCommand)
    local src = source
    if src ~= 0 then return end
    local uuid = tonumber(args[1])
    if not uuid then return end
    local success, message = CheckBadgeForRemove(uuid)
    if success then 
        print(message)
    end
end, true)

_RegisterServerEvent("removeBadge", function(badge)
    local src = source
    local PLAYER <const> = GetPlayerId(src)
    if not PLAYER then return end
    if PLAYER.data["badge"] then
        if PLAYER.data["badge"].access then
            PLAYER.prestige = 0
            DoNotif(src, "~g~You have removed your actual badge")
        end
    end
end)

_RegisterServerEvent("equipBadge", function(badge)
    local src = source
    local PLAYER <const> = GetPlayerId(src)
    if not PLAYER then return end
    if PLAYER.data["badge"] then
        if PLAYER.data["badge"].access then
            PLAYER.prestige = badge
            DoNotif(src, "~g~You have equipped the Badge #" .. badge .. " !")
        end
    end
end)