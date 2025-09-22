function LoadLeaderboard()
    local podiumTable = {}
    for k, v in pairs(lbStats.kills) do 
        if k <= 6 then  -- Vérifie si l'index est dans les 6 premiers
                    table.insert(podiumTable, {
            username = v.username, 
            kills = v.kills, 
            deaths = v.deaths or v.death or 0,
            tokens = v.tokens or v.token or 0,
            country = v.country or "GB", 
            prestige = v.prestige or 0
        })
        else
            break  -- Sort de la boucle si l'index est supérieur à 6
        end
    end

    local leaderboard = {}
    for k, v in pairs(lbStats.kills) do 
        if k > 100 then
            break  -- Sort de la boucle si l'index est supérieur à 100
        end
        table.insert(leaderboard, {
            username = v.username, 
            kills = v.kills, 
            deaths = v.deaths or v.death or 0,
            tokens = v.tokens or v.token or 0,
            country = v.country or "GB", 
            prestige = v.prestige or 0
        })
    end

    SendNUIMessage({
        type = "leaderboard",
        podium = podiumTable,
        leaderboard = leaderboard,
    })
end

function LoadLeaderboardDeath()
    local podiumTable = {}
    for k, v in pairs(lbStats.death) do 
        if k <= 6 then  -- Vérifie si l'index est dans les 6 premiers
            table.insert(podiumTable, {
                username = v.username, 
                death = v.death, 
                country = v.country or "GB", 
                prestige = v.prestige or 0
            })
        else
            break  -- Sort de la boucle si l'index est supérieur à 6
        end
    end

    local leaderboard = {}
    for k, v in pairs(lbStats.death) do 
        if k > 100 then
            break  -- Sort de la boucle si l'index est supérieur à 100
        end
        table.insert(leaderboard, {
            username = v.username, 
            death = v.death, 
            country = v.country or "GB", 
            prestige = v.prestige or 0
        })
    end

    SendNUIMessage({
        type = "leaderboard-death",
        podium = podiumTable,
        leaderboard = leaderboard,
    })
end

function LoadLeaderboardToken()
    local podiumTable = {}
    for k, v in pairs(lbStats.token) do 
        if k <= 6 then  -- Vérifie si l'index est dans les 6 premiers
            table.insert(podiumTable, {
                username = v.username, 
                token = v.token, 
                country = v.country or "GB", 
                prestige = v.prestige or 0
            })
        else
            break  -- Sort de la boucle si l'index est supérieur à 6
        end
    end

    local leaderboard = {}
    for k, v in pairs(lbStats.token) do 
        if k > 100 then
            break  -- Sort de la boucle si l'index est supérieur à 100
        end
        table.insert(leaderboard, {
            username = v.username, 
            token = v.token, 
            country = v.country or "GB", 
            prestige = v.prestige or 0
        })
    end

    SendNUIMessage({
        type = "leaderboard-token",
        podium = podiumTable,
        leaderboard = leaderboard,
    })
end

RegisterNUICallback('SelectLeaderboard', function(data, cb)
    if data.type == "player" then
        LoadLeaderboard()
    elseif data.type == "crew" then
        SetLeaderboardCrew()
    elseif data.type == "death" then
        LoadLeaderboardDeath()
    elseif data.type == "token" then
        LoadLeaderboardToken()
    end
    if cb then cb('ok') end
end)

function SetLeaderboardCrew()
    local leaderboard = {}
    local podium = {}
    
    print("Requesting crew leaderboard data...")
    local resultCallback = CallbackServer("callback:crew:getLeaderboard")
    print("Received crew data:", json.encode(resultCallback))
    
    -- Vérifier si resultCallback est valide
    if not resultCallback or type(resultCallback) ~= "table" then
        print("Invalid or missing crew data")
        -- Envoyer un leaderboard vide si pas de données
        SendNUIMessage({
            type = "crew-stats",
            podium = {},
            crewData = {}
        })
        return
    end

    -- Debug: afficher le nombre de crews reçues
    print("Number of crews received:", #resultCallback)
    
    -- Debug: afficher les premières crews
    for i = 1, math.min(5, #resultCallback) do
        if resultCallback[i] then
            print("Crew " .. i .. ":", json.encode(resultCallback[i]))
        end
    end

    -- Trier les crews par kills
    table.sort(resultCallback, function(a, b)
        if not a or not b then return false end
        return (tonumber(a.kills) or 0) > (tonumber(b.kills) or 0)
    end)

    -- Créer le leaderboard
    for k, v in ipairs(resultCallback) do 
        if k > 100 then break end
        
        if v then
            local crewData = {
                crewName = v.crewName or v.name or "Unknown Crew",
                kills = tonumber(v.kills) or 0,
                airdrops = tonumber(v.airdrops) or tonumber(v.airdrop) or 0,
                redzoneKills = tonumber(v.redzoneKills) or tonumber(v.redzone_kills) or tonumber(v.redzone) or 0,
                country = v.flag or v.country or "GB"
            }
            
            print("Adding crew to leaderboard:", json.encode(crewData))
            table.insert(leaderboard, crewData)
            
            -- Ajouter au podium si dans le top 6
            if k <= 6 then
                table.insert(podium, crewData)
            end
        end
    end

    print("Final leaderboard size:", #leaderboard)
    print("Final podium size:", #podium)

    SendNUIMessage({
        type = "crew-stats",
        podium = podium,
        crewData = leaderboard
    })
end

RegisterCommand('getCrewLeaderboard', function()
    SetLeaderboardCrew()
end)
