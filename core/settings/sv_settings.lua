SettingsUsers = {}

-- Define default settings that will be used for new players and new settings
local DefaultSettings = {
    {name = "hitmarker", value =  true},
    {name = "hitmarker_size", value = "normal"},
    {name = "hitmarker_sound", value = true},
    {name = "hitmarker_sound2", value = "classic"},
    {name = "volume_hitmarker", value = 0.50},
    {name = "hud_life", value = true},
    {name = "kill_feed", value = true},
    {name = "opacity", value = 0.70},
    {name = "deathmessage", value = ""},
    {name = "voice_chat", value = false},
    {name = "killsound", value = true},
    {name = "death_voice_chat", value = false},
    {name = "optimization", value = false},
    {name = "loadout", value = false},
    {name = "loadout_kits", value = "buffalo4_specialcarbine"},
    {name = "music_kill", value = "none"},
    {name = "hitmarker_type", value = "hitmarker"},
    -- Add new default settings here
}

-- Helper function to get default value for a setting
function GetDefaultSettingValue(name)
    for _, setting in pairs(DefaultSettings) do
        if setting.name == name then
            return setting.value
        end
    end
    return nil
end

-- Function to add a new default setting
function AddDefaultSetting(name, value)
    for _, setting in pairs(DefaultSettings) do
        if setting.name == name then
            setting.value = value
            return
        end
    end
    
    table.insert(DefaultSettings, {name = name, value = value})
end

function LoadSettings(source, license)
    MySQL.Async.fetchAll("SELECT * FROM settings WHERE license = @license", {["@license"] = license}, function(result)
        if result[1] and result[1] ~= "[]" then 
            local settings = json.decode(result[1].settings)
            
            -- Check if new default settings need to be added
            local settingsUpdated = false
            for _, defaultSetting in pairs(DefaultSettings) do
                local found = false
                for _, playerSetting in pairs(settings) do
                    if playerSetting.name == defaultSetting.name then
                        found = true
                        break
                    end
                end
                
                if not found then
                    table.insert(settings, {name = defaultSetting.name, value = defaultSetting.value})
                    print("NEW SETTING ADDED: "..defaultSetting.name.." || "..tostring(defaultSetting.value))
                    settingsUpdated = true
                end
            end
            
            -- If settings were updated, save them back to the database
            if settingsUpdated then
                MySQL.Async.execute("UPDATE settings SET settings = @settings WHERE license = @license", 
                    {["@settings"] = json.encode(settings), ["@license"] = license})
            end
            
            _TriggerClientEvent("settings:loadSettings", source, settings)
            SettingsUsers[GetPlayerId(source).uuid] = settings
            Logger:trace("SETTINGS", ("%s ||  %s"):format(license, json.encode(settings)))
        else
            Logger:trace("SETTINGS", ("%s ||  %s"):format(license, json.encode(DefaultSettings)))
            MySQL.Async.execute("INSERT INTO settings (license, settings) VALUES (@license, @settings)", {["@license"] = license, ["@settings"] = json.encode(DefaultSettings)}, function(rowsChanged)
                if rowsChanged > 0 then 
                    _TriggerClientEvent("settings:loadSettings", source, DefaultSettings)
                end
            end)
        end
    end)
end


function GetSettings(uuid, name)
    local settings = SettingsUsers[uuid]
    if settings then
        for k, v in pairs(settings) do
            if v.name == name then
                return v.value
            end
        end
    end
    return GetDefaultSettingValue(name)
end

function SaveSettings(source, index, value)
    local player = GetPlayerId(source)
    if not player then
        return
    end
    
    MySQL.Async.fetchAll("SELECT * FROM settings WHERE license = @license", {["@license"] = player.license}, function(result)
        if result[1] then 
            local settings = json.decode(result[1].settings)
            local found = false
            
            -- Check if setting exists and update it
            for k, v in pairs(settings) do
                if v.name == index then
                    settings[k].value = value
                    found = true
                    break
                end
            end
            
            -- If setting doesn't exist, add it
            if not found then
                table.insert(settings, {name = index, value = value})
            end
            
            SettingsUsers[player.uuid] = settings
            
            MySQL.Async.execute("UPDATE settings SET settings = @settings WHERE license = @license", {["@settings"] = json.encode(settings), ["@license"] = player.license}, function(rowsChanged)
                if rowsChanged > 0 then 
                    SettingsUsers[player.uuid] = settings
                    _TriggerClientEvent("settings:setSettings", source, index, value)
                end
            end)
        end
    end)
end

-- Expose function to add new default settings that will be applied to all players
_RegisterServerEvent('gamemode:addDefaultSetting', function(name, value)
    if source == 0 or IsPlayerAceAllowed(source, "command") then  -- Only server or admins can add defaults
        AddDefaultSetting(name, value)
    end
end)

_RegisterServerEvent('gamemode:setSettings', function(index, value)
    SaveSettings(source, index, value)
end)