---@param data table
---@field transid string
---@field packagename string
---@field packageId string
---@field date string
---@field time string
---@field uuid string
---@field username string
---@field price string
function CreateTebexLog(data)
    if data then

        if data.price then 

        end
        local querry = "INSERT INTO `tebex-history` (id, idtebex, packagename, date_purchase, price, username) VALUES (NULL, @idtebex, @packagename, @date_purchase, @price, @username)" 
        local params = {
            ["@idtebex"] = data.transid,
            ["@packagename"] = data.packagename,
            ["@date_purchase"] = data.date.." "..data.time,
            ["@price"] = data.price,
            ["@username"] = data.username,
        }
        local result = MySQL.query.await(querry, params)
        if result then
            Logger:trace("TEBEX", "Tebex log created")
        else
            Logger:error("TEBEX", "Failed to create tebex log")
        end
    else
        print("^1ERROR: Received nil data in CreateTebexLog^7")
    end
end

function RedeemTebex(source, tblData)
    local PLAYER_DATA <const> = GetPlayerId(source)
    if PLAYER_DATA then 
        local packageName = tblData.packagename
        local isToken = string.find(packageName, "Tokens")
        local isCoins = string.find(packageName, "Coins")
        if isToken and TebexConfig.PackageList[packageName].tokens then 
            local tokensGived = TebexConfig.PackageList[packageName].tokens
            PLAYER_DATA.AddTokens(tokensGived)
            DoNotif(source, "~g~You have received "..tokensGived.." tokens", 2)
        elseif isCoins and TebexConfig.PackageList[packageName].coins then 
            local coinsGived = TebexConfig.PackageList[packageName].coins
            PLAYER_DATA.AddCoins(coinsGived)
            DoNotif(source, "~g~You have received "..coinsGived.." coins", 2)
        else 
            DoNotif(source, "~r~This package is not valid", 2)
        end
    end
end

-- RegisterCommand("redeem_tebex", function(source, args)
--    local tebex_id = args[1] 
--    if not tebex_id then 
--     return DoNotif(source, "~r~Please provide a valid tebex id", 2)
--    end
--    local result = MySQL.query.await("SELECT * FROM `tebex-history` WHERE `idtebex` = @idtebex", {["@idtebex"] = tebex_id})
--    if result[1] then
--         local data = result[1] 
--         if data.redeem_purchase ~= nil then 
--             return DoNotif(source, "~r~This package has already been redeemed", 2)
--         end
--         local sendResponse = MySQL.query.await("UPDATE `tebex-history` SET `redeem_purchase` = @redeem_purchase WHERE `idtebex` = @idtebex", {["@redeem_purchase"] = os.date("%Y-%m-%d %H:%M:%S"), ["@idtebex"] = tebex_id})
--         local PLAYER_DATA <const> = GetPlayerId(source)
--         if PLAYER_DATA then 
--             local result2 = MySQL.query.await("UPDATE `tebex-history` SET `username` = @username, `uuid` = @uuid WHERE `idtebex` = @idtebex", {["@username"] = PLAYER_DATA.username, ["@uuid"] = PLAYER_DATA.uuid, ["@idtebex"] = tebex_id})
--             if result2 then 
--                 DoNotif(source, "~g~You have successfully redeemed the package ("..data.packagename..")", 2)
--                 RedeemTebex(source, data)
--             else
--                 DoNotif(source, "~r~Failed to redeem the package ("..data.packagename..")", 2)
--             end
--         end
--     else 
--         DoNotif(source, "~r~Please provide a valid tebex id", 2)
--     end
-- end)

RegisterCommand("tebex_buy_package", function(source, args, rawCommand)
    if source ~= 0 then return end
    
    if not args[1] then
        print("ERROR: Missing JSON data in tebex_buy_package command")
        return
    end
    
    local success, tblData_tebex = pcall(function() 
        return json.decode(args[1]) 
    end)
    
    if not success or not tblData_tebex then
        print("ERROR: Failed to parse JSON data:", args[1])
        return
    end
    
    CreateTebexLog(tblData_tebex)
end, true)


-- tebex_add_tokens {"uuid": "1234567890", "tokens":  100}
RegisterCommand("tebex_add_tokens", function(source, args, rawCommand)
    if source ~= 0 then return end

    local success, tblData_tebex = pcall(function() 
        return json.decode(args[1]) 
    end)
    
    if not success or not tblData_tebex then
        print("ERROR: Failed to parse JSON data:", args[1])
        return
    end

    if tonumber(tblData_tebex.uuid) then 

        local tokens = 0 
        local packageName = tblData_tebex.packagename
        local isToken = string.find(packageName, "Tokens")

        if isToken and TebexConfig.PackageList[packageName].tokens then 
            tokens = TebexConfig.PackageList[packageName].tokens
        end

        local result = MySQL.query.await("SELECT * FROM `players` WHERE `uuid` = @uuid", {["@uuid"] = tblData_tebex.uuid})
        if result[1] then
            if PlayersIsOnlineUUID(tonumber(tblData_tebex.uuid)) then
                PlayersIsOnlineUUID(tonumber(tblData_tebex.uuid)).AddTokens(tokens)
                DoNotif(tonumber(tblData_tebex.uuid), "~g~You have received "..tokens.." tokens", 2)
            else
                local data = result[1]
                data.token = data.token + tokens
                MySQL.update("UPDATE `players` SET `token` = @token WHERE `uuid` = @uuid", {["@token"] = data.token, ["@uuid"] = tonumber(tblData_tebex.uuid)})
                Logger:trace("TEBEX", "Tokens added to player "..tblData_tebex.uuid)
            end
        else
            print("^1ERROR: Player not found in tebex_add_tokens^7")
        end
    else
        print("^1ERROR: Received nil data in tebex_add_tokens^7")
    end
end, true)