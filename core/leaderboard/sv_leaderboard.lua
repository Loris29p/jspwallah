RegisterCallback("zoliax:getLeaderboard", function(source)
    local results = MySQL.Sync.fetchAll("SELECT * FROM players ORDER BY kills_global DESC, death_global ASC LIMIT 25", {})
    if results[1] ~= nil then
        local leaderboard = {
            pistol = {},
            convoy = {},
            freeroam = {}
        }

        for _, user in ipairs(results) do
            local kd = (math.floor((tonumber(user.kills_global / user.death_global) * 10^2) + 0.5) / (10^2)) or 1.0
            table.insert(leaderboard.pistol, { name = user.username, kills = user.kills_global, deaths = user.death_global, tokens = user.token, kd = user.kills_global })
            table.insert(leaderboard.convoy, { name = user.username, kills = user.kills_global, deaths = user.death_global, tokens = user.token, kd = user.death_global })
            table.insert(leaderboard.freeroam, { name = user.username, kills = user.kills_global, deaths = user.death_global, tokens = user.token, kd = user.token })
        end

        table.sort(leaderboard.pistol, function(a, b) return a.kd > b.kd end)
        table.sort(leaderboard.convoy, function(a, b) return a.kd > b.kd end)
        table.sort(leaderboard.freeroam, function(a, b) return a.kd > b.kd end)

        for i, player in ipairs(leaderboard.pistol) do
            player.position = i
        end
        for i, player in ipairs(leaderboard.convoy) do
            player.position = i
        end
        for i, player in ipairs(leaderboard.freeroam) do
            player.position = i
        end

        leaderboard.pistol = { table.unpack(leaderboard.pistol, 1, 25) }
        leaderboard.convoy = { table.unpack(leaderboard.convoy, 1, 25) }
        leaderboard.freeroam = { table.unpack(leaderboard.freeroam, 1, 25) }

        return leaderboard
    else
        return false
    end 
end)