TELEPORTER = TELEPORTER or {}
TELEPORTER.Config = TELEPORTER.Config or {}

AddEventHandler("gamemode:OpenTeleporter", function(block)
    block = block or false
    exports["guild-ui"]:OpenUI(true, "spawnselector", {}, {
        title = TELEPORTER.Config.title,
        subtitle = TELEPORTER.Config.subtitle,
        serverLogo = TELEPORTER.Config.serverLogo,
        color = TELEPORTER.Config.color,
        spawns = TELEPORTER.Config.spawns,
        translate = TELEPORTER.Config.translate
    }, block)
end)

RegisterNetEvent('GUILD.UI:spawnselector:spawn', function(data)
    local pPed = PlayerPedId()

    if not data then return end
    local spawn = data.spawn
    if not spawn then return end
    spawn = TELEPORTER.Config.spawns[spawn + 1]

    if spawn.position then
        exports["guild-ui"]:CloseUI()
        TeleportToWp(pPed, spawn.position, spawn.position.w)
    end
end)