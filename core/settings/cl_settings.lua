-- Settings = {
--     ["hud_life"] = true,
--     ["kill_feed"] = true,
--     ["hitmarker"] = true,
--     ["hitmarker_size"] = "tenier",
--     ["hitmarker_sound"] = true,
--     ["hitmarker_sound2"] = "classic",
--     ["volume_hitmarker"] = 0.5,
--     ["opacity"] = 0.70,
--     ["deathmessage"] = "",
--     ["voice_chat"] = true,
--     ["killsound"] = true,
--     ["death voice chat"] = false
-- }

Settings = {}

-- UI settings mapping table - maps UI labels to internal setting names
local SettingMappings = {
    ["Guild Status HUD"] = "hud_life",
    ["Kill Feed"] = "kill_feed", 
    ["Hitmarker"] = "hitmarker",
    ["Hitmarker Sound"] = "hitmarker_sound",
    ["Hitmarker Volume"] = "volume_hitmarker",
    ["Kill Sound"] = "killsound",
    ["Bag Interface"] = "voice_chat",
    ["Death Voice Chat"] = "death_voice_chat",
    ["Death Message"] = "deathmessage",
    ["Interface Opacity"] = "opacity",
    ["Hitmarker Size"] = "hitmarker_size",
    ["Optimization"] = "optimization",
    ["Loadout"] = "loadout",
    ["Loadout Kits"] = "loadout_kits",
    ["Music Kill"] = "music_kill",
    ["Hitmarker Type"] = "hitmarker_type",
    -- Add new UI mappings here
}

-- Function to get the UI label for a setting name (reverse mapping)
function GetSettingUILabel(settingName)
    for label, name in pairs(SettingMappings) do
        if name == settingName then
            return label
        end
    end
    return nil
end

-- Function to add a new setting mapping
function AddSettingMapping(uiLabel, settingName)
    SettingMappings[uiLabel] = settingName
end

_RegisterNetEvent("settings:setSettings", function(index, value)
    print(index, value)
    if index == "voice_chat" then 
        -- _TriggerEvent("pma-voice:mutePlayer")
    elseif index == "kill_feed" then 
        SendNUIMessage({
            type = "killfeed_status",
            status = value
        })
    elseif index == "hud_life" then 
        SendNUIMessage({
            type = "hud",
            display = value
        })
    elseif index == "optimization" then  
        if value then
            ExecuteCommand("fps ulow")
        else
            ExecuteCommand("fps reset")
        end
    elseif index == "hitmarker_type" then 
        print("hitmarker_type", value)
        _TriggerEvent("InteractSound_CL:PlayOnOne", value, 0.50)
    elseif index == "music_kill" then
        SendNUIMessage({
            type = "sendKillMusic",
            music = value
        })
    end
    Settings[index] = value
end) 

function GetSettingsValue(index, defaultValue)
    if Settings[index] ~= nil then
        return Settings[index]
    else
        -- If the setting doesn't exist yet but we have a default value, create it
        if defaultValue ~= nil then
            Settings[index] = defaultValue
            Tse("gamemode:setSettings", index, defaultValue)
        end
        return defaultValue
    end
end

-- Function to ensure a setting exists, creating it if necessary
function EnsureSetting(name, defaultValue)
    if Settings[name] == nil then
        Settings[name] = defaultValue
        Tse("gamemode:setSettings", name, defaultValue)
        return defaultValue
    end
    return Settings[name]
end

_RegisterNetEvent("settings:loadSettings", function(settings, add)
    for k, v in pairs(settings) do
        Settings[v.name] = v.value
        print(v.name, v.value)
        Logger:trace("SETTINGS", ("%s ||  %s"):format(v.name, v.value))
    end

    for k, v in pairs(Settings) do
        if v == "true" then
            Settings[k] = true
        elseif v == "false" then
            Settings[k] = false
        end
    end

    if Settings["optimization"] then
        ExecuteCommand("fps ulow")
    else
        ExecuteCommand("fps reset")
    end

    SendNUIMessage({
        type = "hud",
        display = Settings["hud_life"]
    })

    SendNUIMessage({
        type = "killfeed_status",
        status = Settings["kill_feed"]
    })

    SendNUIMessage({
        type = "init",
        settings = Settings
    })
end)

RegisterNUICallback("SetSetting", function(data)
    if data.setting and data.value ~= nil then
        local settingId = SettingMappings[data.setting]
        
        -- If the setting mapping doesn't exist but we want to support dynamic settings
        if not settingId and data.createIfMissing then
            -- Create a reasonable internal name from the UI label
            settingId = data.internalName or string.lower(data.setting:gsub(" ", "_"))
            AddSettingMapping(data.setting, settingId)
        end
        
        if settingId then
            local value = data.value
            if type(value) == "string" then
                if value == "true" then value = true
                elseif value == "false" then value = false
                end
            end
            
            Settings[settingId] = value
            Tse("gamemode:setSettings", settingId, value)
        end
    end
end)

-- New function to create and set a setting directly
RegisterNUICallback("CreateSetting", function(data, cb)
    if data.name and data.value ~= nil then
        local settingId = data.internalName or string.lower(data.name:gsub(" ", "_"))
        
        -- Add the mapping if UI label is provided
        if data.uiLabel then
            AddSettingMapping(data.uiLabel, settingId)
        end
        
        -- Set the setting
        local value = data.value
        if type(value) == "string" then
            if value == "true" then value = true
            elseif value == "false" then value = false
            end
        end
        
        Settings[settingId] = value
        Tse("gamemode:setSettings", settingId, value)
        
        if cb then cb({success = true}) end
    else
        if cb then cb({success = false, error = "Missing name or value"}) end
    end
end)

RegisterNUICallback("GetSettings", function(data, cb)
    for k, v in pairs(Settings) do
        if v == "true" then
            Settings[k] = true
        elseif v == "false" then
            Settings[k] = false
        end
    end
    cb(Settings)
end)

-- Add function to register a default setting on the server
function RegisterDefaultSetting(name, value, uiLabel)
    -- Add the mapping if UI label is provided
    if uiLabel then
        AddSettingMapping(uiLabel, name)
    end
    
    -- Register with server
    Tse("gamemode:addDefaultSetting", name, value)
    
    -- Make sure we have it locally too
    if Settings[name] == nil then
        Settings[name] = value
    end
end

Citizen.CreateThread(function()
    while not GM.Init do 
        print("Waiting initialization")
        Citizen.Wait(1000)
    end
    while true do 
        while not GM.Init do 
            Citizen.Wait(1000)
        end
        local timer = 1000  
        Citizen.Wait(timer)
    end
end)


_RegisterNetEvent("settings:playKillMusic", function(music)
    SendNUIMessage({
        type = "sendKillMusic",
        music = music
    })
end)
