isOpened = false

function ArrangeControls(bool)
    SetNuiFocus(bool, bool)
    SetNuiFocusKeepInput(bool)
    if bool then
        Citizen.CreateThread(function()
            while isOpened do
                Citizen.Wait(0)
                DisableControlAction(0, 1, true) -- disable mouse look
                DisableControlAction(0, 2, true) -- disable mouse look
                DisableControlAction(0, 3, true) -- disable mouse look
                DisableControlAction(0, 4, true) -- disable mouse look
                DisableControlAction(0, 5, true) -- disable mouse look
                DisableControlAction(0, 6, true) -- disable mouse look

                -- DisableControlAction(0, 46, true) -- e
                -- DisableControlAction(0, 38, true) -- e
                -- DisableControlAction(0, 51, true) -- e
                DisableControlAction(0, 1, true) -- disable aim
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 156, true) -- disable aim
                DisableControlAction(0, 25, true) -- disable aim
                DisableControlAction(0, 26, true)
                DisableControlAction(0, 79, true)
                DisableControlAction(0, 80, true)
                DisableControlAction(0, 263, true) -- disable melee
                DisableControlAction(0, 264, true) -- disable melee
                DisableControlAction(0, 257, true) -- disable melee
                DisableControlAction(0, 140, true) -- disable melee
                DisableControlAction(0, 141, true) -- disable melee
                DisableControlAction(0, 142, true) -- disable melee
                DisableControlAction(0, 143, true) -- disable melee
                DisableControlAction(0, 24, true) -- disable attack
                DisableControlAction(0, 25, true) -- disable aim
                DisableControlAction(0, 47, true) -- disable weapon
                DisableControlAction(0, 58, true) -- disable weapon
                DisableControlAction(0, 245, true) -- chat
                DisableControlAction(0, 303, true) -- U

                DisableControlAction(0, 36, true) -- ctrl
                DisableControlAction(0, 29, true) -- b
                DisableControlAction(0, 73, true) -- X
                DisableControlAction(0, 85, true) -- Q
                DisableControlAction(0, 18, true) -- left click
                DisableControlAction(0, 69, true) -- left click
                DisableControlAction(0, 122, true) -- left click
                DisableControlAction(0, 229, true) -- left click
                DisableControlAction(0, 237, true) -- left click
                DisableControlAction(0, 329, true) -- left click
                DisableControlAction(0, 346, true) -- left click
                DisableControlAction(0, 92, true) -- left click
                DisableControlAction(0, 106, true) -- left click
                DisableControlAction(0, 135, true) -- left click
                DisableControlAction(0, 144, true) -- left click
                DisableControlAction(0, 176, true) -- left click
                DisableControlAction(0, 223, true) -- left click
                -- DisablePlayerFiring(PlayerId(), true)

                DisableControlAction(0, 199, true) -- P
                DisableControlAction(0, 200, true) -- esc
                DisableControlAction(0, 177, true) -- esc
                DisableControlAction(0, 202, true) -- esc
                DisableControlAction(0, 322, true) -- esc
            end
        end)
    end
end

exports("ArrangeControls", ArrangeControls)


isGamemodeSelector = false
function ArrangeControlsGameselector(bool)
    SetNuiFocus(bool, bool)
    SetNuiFocusKeepInput(bool)
    if bool then
        Citizen.CreateThread(function()
            while isGamemodeSelector do
                Citizen.Wait(0)
                DisableControlAction(0, 1, true) -- disable mouse look
                DisableControlAction(0, 2, true) -- disable mouse look
                DisableControlAction(0, 3, true) -- disable mouse look
                DisableControlAction(0, 4, true) -- disable mouse look
                DisableControlAction(0, 5, true) -- disable mouse look
                DisableControlAction(0, 6, true) -- disable mouse look

                -- DisableControlAction(0, 46, true) -- e
                -- DisableControlAction(0, 38, true) -- e
                -- DisableControlAction(0, 51, true) -- e
                DisableControlAction(0, 1, true) -- disable aim
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 156, true) -- disable aim
                DisableControlAction(0, 25, true) -- disable aim
                DisableControlAction(0, 26, true)
                DisableControlAction(0, 79, true)
                DisableControlAction(0, 80, true)
                DisableControlAction(0, 263, true) -- disable melee
                DisableControlAction(0, 264, true) -- disable melee
                DisableControlAction(0, 257, true) -- disable melee
                DisableControlAction(0, 140, true) -- disable melee
                DisableControlAction(0, 141, true) -- disable melee
                DisableControlAction(0, 142, true) -- disable melee
                DisableControlAction(0, 143, true) -- disable melee
                DisableControlAction(0, 24, true) -- disable attack
                DisableControlAction(0, 25, true) -- disable aim
                DisableControlAction(0, 47, true) -- disable weapon
                DisableControlAction(0, 58, true) -- disable weapon
                DisableControlAction(0, 245, true) -- chat
                DisableControlAction(0, 303, true) -- U

                DisableControlAction(0, 36, true) -- ctrl
                DisableControlAction(0, 29, true) -- b
                DisableControlAction(0, 73, true) -- X
                DisableControlAction(0, 85, true) -- Q
                DisableControlAction(0, 18, true) -- left click
                DisableControlAction(0, 69, true) -- left click
                DisableControlAction(0, 122, true) -- left click
                DisableControlAction(0, 229, true) -- left click
                DisableControlAction(0, 237, true) -- left click
                DisableControlAction(0, 329, true) -- left click
                DisableControlAction(0, 346, true) -- left click
                DisableControlAction(0, 92, true) -- left click
                DisableControlAction(0, 106, true) -- left click
                DisableControlAction(0, 135, true) -- left click
                DisableControlAction(0, 144, true) -- left click
                DisableControlAction(0, 176, true) -- left click
                DisableControlAction(0, 223, true) -- left click
                -- DisablePlayerFiring(PlayerId(), true)

                DisableControlAction(0, 199, true) -- P
                DisableControlAction(0, 200, true) -- esc
                DisableControlAction(0, 177, true) -- esc
                DisableControlAction(0, 202, true) -- esc
                DisableControlAction(0, 322, true) -- esc
            end
        end)
    end
end