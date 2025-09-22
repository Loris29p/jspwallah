ConfigAI = {}

ConfigAI.PlayerCheck = true
ConfigAI.kickActive = true
ConfigAI.banActive = false

ConfigAI.PlayerLoadedEvent = "player:LoadPlayer" --"QBCore:Client:OnPlayerLoaded", "esx:playerLoaded"
ConfigAI.DefaultSpawnLocation = vector3(-1267.074, -3021.941,-48.49023)
ConfigAI.magicTestCommand = "magicTest"

ConfigAI.BypassPlayerList = {
    ["steam"] = {
        
    }
}

ConfigAI.LogMessages = {
    ["magic"] = {
        ["message"] = "Magic Bullet Usage. %s",
        ["detected"] = "Wall Magic Detected",
        ["notdetected"] = "Wall Magic Not Detected",
        ["detectedColor"] = 16711680,
        ["notDetectedColor"] = 65280,
    },
    ["accuracy"] = {
        ["message"] = "Ped Accuracy Usage. %s",
        ["detected"] = "Accuracy Detected",
        ["notdetected"] = "Accuracy Not Detected",
        ["detectedColor"] = 16711680,
        ["notDetectedColor"] = 65280,
    },
    ["magicKickMsg"] = "Citizen Modified Detected.",
    ["accuracyKickMsg"] = "Citizen Modified Detected.",
    ["magicBanMsg"] = "You are banned.",
    ["accuracyBanMsg"] = "You are banned.",
}

ConfigAI.Discord = {
    LogActive = true,
    DiscordWebhook = "https://discord.com/api/webhooks/1386071560628080831/0Bu9CDUQq6lWZEAGpt-qgaV5cSu8UBkQIXnmf4J8lnSDEHpcrBnypf2CPMJgI0EzELth",
    BotName      = "Guild PvP - AI Checker",
    BotAvatar    = "https://cdn.discordapp.com/attachments/1370180070555127878/1386079918252757022/LOGOBASE.png?ex=68586704&is=68571584&hm=207eff4147b237edd371325e2d4f5398487d0724321ba1d3be4aac155cbb025b&",
    BotAuthorURL = "https://cdn.discordapp.com/attachments/1370180070555127878/1386079918252757022/LOGOBASE.png?ex=68586704&is=68571584&hm=207eff4147b237edd371325e2d4f5398487d0724321ba1d3be4aac155cbb025b&",
    BotFooterURL = "https://cdn.discordapp.com/attachments/1370180070555127878/1386079918252757022/LOGOBASE.png?ex=68586704&is=68571584&hm=207eff4147b237edd371325e2d4f5398487d0724321ba1d3be4aac155cbb025b&",
}


