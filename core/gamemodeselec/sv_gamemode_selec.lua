Gamemode = {
    ["PvP"] = {},
    ["FFA"] = {},
}

function AddPlayerInGamemode(src, gamemode) 
    -- print(gamemode, json.encode(Gamemode[gamemode]))
    for k, v in pairs(Gamemode[gamemode]) do 
        if v.source == src then return end
    end
    table.insert(Gamemode[gamemode], {
        source = src,
    })
    GetPlayerId(src).setGamemode(gamemode)
    _TriggerClientEvent("gamemode:client:UpdateConnected", -1,  Gamemode)
    if gamemode == "FFA" then 
        JoinArena(src)
    end
end

function RemovePlayerInGamemode(src)
    for gamemodeName, players in pairs(Gamemode) do 
        for i, player in ipairs(players) do
            if player.source == src then 
                table.remove(Gamemode[gamemodeName], i)
                if GetPlayerId(src) then
                    GetPlayerId(src).setGamemode("Lobby")
                end
                return
            end
        end
    end
end

_RegisterServerEvent("gamemode:GetConnected", function()
    _TriggerClientEvent("gamemode:client:UpdateConnected", -1, Gamemode)
end)

_RegisterServerEvent("gamemode:ConnectToGame", function(gamemode)
    AddPlayerInGamemode(source, gamemode)
end)

_RegisterServerEvent("gamemode:LeaveGamemode", function()
    RemovePlayerInGamemode(source)
end)

AddEventHandler("playerDropped", function(reason)
    RemovePlayerInGamemode(source)
end)


RegisterCommand("leave", function(source, args, rawCommand)
    local FFA_DATA = GetFFAPlayer(source)
    if FFA_DATA then 
        FFA_DATA:RemovePlayer({
            source = source,
        })
    end

    if FoundPlayerInGunrace(source) then
        FoundPlayerInGunrace(source):RemovePlayer({
            source = source,
        })
    end

    for k, v in pairs(afkFarmPlayers) do
        if v.source == source then
            table.remove(afkFarmPlayers, k)
            _TriggerClientEvent("afkfarm:update", -1, afkFarmPlayers)
            break
        end
    end
end)