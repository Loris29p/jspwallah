GM.Player.InSpectateModeLeague = false 

local listGamertags = {}
local listPlayersLeague = {}
local coordsBeforeSpectate = nil

local function InstructionalButton(controlButton, text)
    ScaleformMovieMethodAddParamPlayerNameString(controlButton)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function GoToSpectateModeLeague()
    GM.Player.InSpectateModeLeague = true 
    local spectatingId = 1
    local currentlySpectating = nil
    local scaleformSpectating = RequestScaleformMovie("instructional_buttons")
    while not HasScaleformMovieLoaded(scaleformSpectating) do
        Wait(1)
    end

    coordsBeforeSpectate = GetEntityCoords(PlayerPedId())
    -- Thread pour mettre à jour la liste des joueurs
    Citizen.CreateThread(function()
        while GM.Player.InSpectateModeLeague and GM.League.started do 
            -- Vider la liste avant de la remplir pour éviter les doublons
            listPlayersLeague = {}
            for k, v in pairs(GM.League.teams) do 
                for a, player in pairs(v.players) do 
                    table.insert(listPlayersLeague, {
                        uuid = player.uuid,
                        src = player.src,
                        username = player.username,
                        kills = player.kills,
                        team = v.name,
                        teamColor = v.color,
                    })
                end
            end
            Wait(1000)
        end
    end)

    -- Start spectate mode
    Wait(250)
    local pos = GM.League.map.coordsRespawn
    SetEntityCoordsNoOffset(PlayerPedId(), pos.x, pos.y, pos.z, false, false, false, true)
    NetworkResurrectLocalPlayer(pos, 0.0, true, false)
    ClearPedBloodDamage(PlayerPedId())
    SetEntityInvincible(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), false)
    FreezeEntityPosition(PlayerPedId(), true)
    RemoveAllPedWeapons(PlayerPedId())

    -- Thread pour gérer le mode spectateur
    Citizen.CreateThread(function()
        while GM.Player.InSpectateModeLeague and GM.League.started do 
            -- Configuration des instructions à l'écran
            PushScaleformMovieFunction(scaleformSpectating, "CLEAR_ALL")
            PopScaleformMovieFunctionVoid()
            
            PushScaleformMovieFunction(scaleformSpectating, "SET_CLEAR_SPACE")
            PushScaleformMovieFunctionParameterInt(200)
            PopScaleformMovieFunctionVoid()
            
            -- Ajouter bouton pour quitter
            PushScaleformMovieFunction(scaleformSpectating, "SET_DATA_SLOT")
            PushScaleformMovieFunctionParameterInt(0)
            InstructionalButton(GetControlInstructionalButton(1, 194, true), "Quit the Game")
            PopScaleformMovieFunctionVoid()
            
            -- Ajouter boutons pour naviguer entre les joueurs si la liste n'est pas vide
            if #listPlayersLeague > 0 then
                -- Bouton pour joueur précédent
                PushScaleformMovieFunction(scaleformSpectating, "SET_DATA_SLOT")
                PushScaleformMovieFunctionParameterInt(1)
                InstructionalButton(GetControlInstructionalButton(1, 21, true), "Previous Player")
                PopScaleformMovieFunctionVoid()
                
                -- Bouton pour joueur suivant
                PushScaleformMovieFunction(scaleformSpectating, "SET_DATA_SLOT")
                PushScaleformMovieFunctionParameterInt(2)
                InstructionalButton(GetControlInstructionalButton(1, 22, true), "Next Player")
                PopScaleformMovieFunctionVoid()
            end
            
            PushScaleformMovieFunction(scaleformSpectating, "DRAW_INSTRUCTIONAL_BUTTONS")
            PopScaleformMovieFunctionVoid()
            
            PushScaleformMovieFunction(scaleformSpectating, "SET_BACKGROUND_COLOUR")
            PushScaleformMovieFunctionParameterInt(0)
            PushScaleformMovieFunctionParameterInt(0)
            PushScaleformMovieFunctionParameterInt(0)
            PushScaleformMovieFunctionParameterInt(80)
            PopScaleformMovieFunctionVoid()
            
            DrawScaleformMovieFullscreen(scaleformSpectating, 255, 255, 255, 255, 0)
            
            -- Si nous avons des joueurs à spectater
            if #listPlayersLeague > 0 then
                -- Vérifier si le spectatingId est dans les limites valides
                if spectatingId > #listPlayersLeague then 
                    spectatingId = 1
                elseif spectatingId < 1 then
                    spectatingId = #listPlayersLeague
                end
                
                -- Obtenir le joueur à spectater
                local playerToSpec = listPlayersLeague[spectatingId]
                if playerToSpec then
                    -- On vérifie si on regarde déjà ce joueur pour éviter de réinitialiser inutilement
                    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerToSpec.src))
                    if currentlySpectating ~= playerToSpec.src and DoesEntityExist(targetPed) then
                        NetworkSetInSpectatorMode(false, PlayerPedId()) -- Reset spectator mode
                        Wait(10)
                        NetworkSetInSpectatorMode(true, targetPed)
                        currentlySpectating = playerToSpec.src
                    end
                    DrawCenterText("~b~Spectating: ~w~" .. playerToSpec.username .. " - Team: " .. playerToSpec.team .. " - Kills: " .. playerToSpec.kills, 1000)
                end
                
                -- Gérer les contrôles pour changer de joueur
                if IsControlJustPressed(1, 21) then -- LEFT key
                    spectatingId = spectatingId - 1
                    if spectatingId < 1 then spectatingId = #listPlayersLeague end
                    Wait(200) -- Petit délai pour éviter de changer trop rapidement
                elseif IsControlJustPressed(1, 22) then -- RIGHT key
                    spectatingId = spectatingId + 1
                    if spectatingId > #listPlayersLeague then spectatingId = 1 end
                    Wait(200)
                end
            else
                DrawCenterText("~r~No players available to spectate", 1000)
            end
            
            -- Vérifier si le joueur veut quitter le mode spectateur
            if IsControlJustPressed(1, 194) then -- BACKSPACE key
                GM.Player.InSpectateModeLeague = false
                break
            end
            
            Wait(0) -- Permet de vérifier les contrôles à chaque frame
        end
    end)

    while GM.Player.InSpectateModeLeague do 
        Wait(1000)
    end

    -- Stop spectate mode
    NetworkSetInSpectatorMode(false, PlayerPedId())
    SetEntityVisible(PlayerPedId(), true)
    SetEntityInvincible(PlayerPedId(), false)
    FreezeEntityPosition(PlayerPedId(), false)
    SetScaleformMovieAsNoLongerNeeded(scaleformSpectating)
    GM.Player.InSpectateModeLeague = false 
    Tse("league:LeaveSpectate")
    SetEntityCoordsNoOffset(PlayerPedId(), coordsBeforeSpectate.x, coordsBeforeSpectate.y, coordsBeforeSpectate.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coordsBeforeSpectate, 0.0, true, false)
end


_RegisterNetEvent("league:GoSpectate", function()
    GoToSpectateModeLeague()
end)