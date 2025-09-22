function ShowNotificationUI(tblData)
    -- Default values
    local type = tblData.type and tblData.type or "default"
    local duration = tblData.duration and tblData.duration or 5000
    local sound = tblData.sound and tblData.sound or "notification.ogg"
    local progressColor = tblData.progressColor and tblData.progressColor or "#FF0000"
    -- Send message to UI
    SendNUIMessage({
        type = "notification",
        text = tblData.message,
        color = type,
        duration = duration,
        sound = sound,
        progressColor = progressColor
    })
end

exports('ShowNotificationUI', ShowNotificationUI)