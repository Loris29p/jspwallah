CooldownEffect = {}
ListEffect = {}
local function LoadEffectsFromGitHub()
    local url = "https://raw.githubusercontent.com/V3SC/FiveM-Particles/main/particles.json"
    PerformHttpRequest(url, function(statusCode, responseText, headers)
        if statusCode == 200 then
            local success, particleData = pcall(json.decode, responseText)
            
            if success and particleData then
                -- Clear existing effects
                ListEffect = {}
                
                -- Process all dictionaries and effects
                for _, dict in ipairs(particleData) do
                    local dictName = dict.DictionaryName
                    
                    -- Add each effect from this dictionary
                    for _, effectName in ipairs(dict.EffectNames) do
                        table.insert(ListEffect, {
                            dictName = dictName,
                            particleName = effectName
                        })
                    end
                end
                
                print("[KillEffect] Successfully loaded " .. #ListEffect .. " particle effects from GitHub")
                return ListEffect
            else
                return false
            end
        else
            print("[KillEffect] Failed to fetch particle data. Status code: " .. statusCode)
            return false
        end
    end, "GET")
end

Citizen.CreateThread(function()
    Wait(2000)
    LoadEffectsFromGitHub()
end)

RegisterServerEvent("effect:GetListEffect", function()
    TriggerClientEvent('setKillEffectRaw', source, ListEffect)
end)



function CreateCooldown(source, time)
    CooldownEffect[source] = time
    Citizen.CreateThread(function()
        while CooldownEffect[source] > 0 do
            CooldownEffect[source] = CooldownEffect[source] - 1
            Citizen.Wait(1000)
        end
    end)
end

function GetEffectPlayerCooldown(source)
    if not CooldownEffect[source] then
        return false
    end
    return CooldownEffect[source]
end

_RegisterServerEvent("PLACE_HOLDERPREFIX:d:UseEffect", function(tblData)
    local ply = GetPlayerId(source)
    if ply.role ~= "vip" and ply.role ~= "vip+" and ply.role ~= "mvp" and ply.role ~= "boss" or ply.GetData()["kill_effect"] and ply.GetData()["kill_effect"].access then
        return _TriggerClientEvent("ShowAboveRadarMessage", source, "~r~You need to be a VIP, VIP+ or MVP or BOSS to use this command")
    end

    if GetEffectPlayerCooldown(source) then
        return _TriggerClientEvent("ShowAboveRadarMessage", source, "~r~You need to wait before using this command again")
    end

    CreateCooldown(source, 20)
    _TriggerClientEvent("use:Effect", -1, tblData)
end)

_RegisterServerEvent("kSettings:saveSettings", function(type, data)
    local src = source
    local PLAYER = GetPlayerId(src)

    MySQL.Async.fetchAll("SELECT * FROM settings WHERE license = @license", {["@license"] = PLAYER.license}, function(result)
        if result[1] then 
            if type == "killeffect" then
                MySQL.Async.execute("UPDATE settings SET killeffect = @killeffect WHERE license = @license", {["@killeffect"] = json.encode(data), ["@license"] = PLAYER.license}, function(rowsChanged)
                    if rowsChanged > 0 then 
                        
                    end
                end)
            end
        else
            CreateSettingsUser(src)
        end
    end)
end)

function CreateSettingsUser(source)
    local PLAYER = GetPlayerId(source)

    MySQL.Async.execute("INSERT INTO settings (license, killeffect, settings, others) VALUES (@license, @killeffect, @settings, @others)", {["@license"] = PLAYER.license, ["@killeffect"] = json.encode({}), ["@settings"] = json.encode({}), ["@others"] = json.encode({})}, function(rowsChanged)
        if rowsChanged > 0 then 
            
        end
    end)
end


function AddAccessEffect(source, item)
    local PLAYER <const> = GetPlayerId(source)
    if PLAYER then 
        local dataPlayer = PLAYER.GetData()
        if not dataPlayer["kill_effect"] then 
            if item == "kill_effect1month" then 
                PLAYER.AddNewData("kill_effect", {access = true, time = os.time() + 60 * 60 * 24 * 30})
                DoNotif(source, "Kill effect access granted ~g~(" .. os.date("%d/%m/%Y %H:%M:%S", os.time() + 60 * 60 * 24 * 30) .. ")")
            elseif item == "kill_effect1week" then 
                PLAYER.AddNewData("kill_effect", {access = true, time = os.time() + 60 * 60 * 24 * 7})
                DoNotif(source, "Kill effect access granted ~g~(" .. os.date("%d/%m/%Y %H:%M:%S", os.time() + 60 * 60 * 24 * 7) .. ")")
            elseif item == "kill_effect" then 
                PLAYER.AddNewData("kill_effect", {access = true, time = os.time() + 60 * 60 * 24 * 30})
                DoNotif(source, "Kill effect access granted ~g~(" .. os.date("%d/%m/%Y %H:%M:%S", os.time() + 60 * 60 * 24 * 30) .. ")")
            end
            return true, "~g~Kill effect access granted"
        end
        return false, "~r~Kill effect access already granted"
    end
    return false, "~r~Player not found"
end


function AddAccessEffectAll()
    local result = MySQL.query.await("SELECT * FROM players")
    for k, v in pairs(result) do
        local data = json.decode(v.data)
        if not data.kill_effect then
            data.kill_effect = {access = true, time = os.time() + 60 * 60 * 24}
            MySQL.update("UPDATE players SET data = @data WHERE uuid = @uuid", {["@data"] = json.encode(data), ["@uuid"] = v.uuid})
            print(v.username, "^8KILL EFFECT ACCESS GRANTED", data.kill_effect.time)
        else 
            print(v.username, "^2KILL EFFECT ACCESS ALREADY GRANTED", data.kill_effect.time)
        end
    end
end

RegisterCommand("add_access_effect_every", function(source, args)
    if source == 0 then
        AddAccessEffectAll()
    end
end)

function CheckAccessEffect(source)
    local PLAYER <const> = GetPlayerId(source)
    if PLAYER then 
        local dataPlayer = PLAYER.GetData()
        if dataPlayer["kill_effect"] and dataPlayer["kill_effect"].access then
            if dataPlayer["kill_effect"].time and dataPlayer["kill_effect"].time > os.time() then 
                return true, "Kill effect access granted ~g~(" .. os.date("%d/%m/%Y %H:%M:%S", dataPlayer["kill_effect"].time) .. ")"
            else 
                PLAYER.RemoveData("kill_effect")
                DoNotif(source, "~r~Kill effect access expired")
                return false
            end
        end
    end
    return false
end

_RegisterServerEvent("guildpvpustom:KillEffect", function(item)
    local success, message = AddAccessEffect(source, item)
    if success then 
        print("KILLEFFECT ACCESS GRANTED")
    end
end)

_RegisterServerEvent("CheckAccessEffect", function()
    local success, message = CheckAccessEffect(source)
    if success then 
        return _TriggerClientEvent("ShowAboveRadarMessage", source, message)
    end
end)