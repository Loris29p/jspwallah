local ListEffect = {}

RegisterNetEvent("setKillEffectRaw", function(listEffect)
    ListEffect = listEffect
end)


_RegisterNetEvent("use:Effect", function(tblData)
    if tblData.dictName and tblData.particleName then
        EffectOnPlayer(tblData.dictName, tblData.particleName)
    end
    CancelEvent()
end)

_RegisterNetEvent("GM:KillEffect", function(dictTest, particleNameTest, position)
    local dict = dictTest
    local particleName = particleNameTest
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Citizen.Wait(0)
    end
    UseParticleFxAssetNextCall(dict)
    StartParticleFxNonLoopedAtCoord(particleName, position, 0.0, 0.0, 0.0, 1.5, false, false, false)
end)


RegisterCommand("fw", function()
    local hasKillEffect = GM.Player.Data.kill_effect and GM.Player.Data.kill_effect.access
    if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "boss") or hasKillEffect then
        Tse("PLACE_HOLDERPREFIX:d:UseEffect", {dictName = "scr_indep_fireworks", particleName = "scr_indep_firework_fountain"})
    else
        return ShowAboveRadarMessage("~r~You need to be a VIP, VIP+ or MVP or BOSS to use this command")
    end
end)


function OpenMenuEffect()
    MenuEffect = {
        Base = { Title = "Killeffect Menu", Header = {"commonmenu", "interaction_bgd"}, HeaderColor = { 255, 0, 0 }, Color = {color_black}}, -- intX pour menu a droite
        Data = { currentMenu = "List killeffect", "" },

        Events = {
            onOpened = function()
            end,

            onBack = function()
            end,

            onExited = function()
            end,

            onButtonSelected = function(currentMenu, r, p, C, self)
            end,

            onSlider = function(self, r, P, Q)
            end,

            onSlide = function(p, n, q, s)
                local currentMenu = p.currentMenu, GetPlayerPed(-1)
                local t = n.slidenum;
                local F = n.opacity;
                local G = n.name;
                local H = n.parentSlider;
                local y = p.currentMenu, GetPlayerPed(-1)

            end,

            onSelected = function(self, m, button, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
                if button.particleName then
                    EffectOnPlayer(button.dictName, button.particleName)
                    local returntable = {dictname = button.dictName, particlename = button.particleName}
                    Tse("kSettings:saveSettings", "killeffect", returntable)
                end
            end,
        },

        Menu = {
            ["List killeffect"] = {

                useFilter = true,
                b = function()
                    local returnTable = {}
                    for k, v in pairs(ListEffect) do 
                        table.insert(returnTable, {
                            name = v.particleName,
                            particleName = v.particleName,
                            dictName = v.dictName,
                            -- canSee = function()
                            --     if v.isRank then
                            --         if GM.Player.Rank ~= "user" then
                            --             return true
                            --         end
                            --     else 
                            --         return true
                            --     end
                            --     return false
                            -- end,
                            askX = true,
                            ask = ">",
                        })
                    end
                    return returnTable
                end,
            }

        },


    }
    return CreateMenu(MenuEffect)
end

RegisterCommand("killeffect", function()
    print(json.encode(GM.Player.Data))
    local hasKillEffect = GM.Player.Data.kill_effect and GM.Player.Data.kill_effect.access
    if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "boss") or hasKillEffect then
        OpenMenuEffect()
    else
        return ShowAboveRadarMessage("~r~You need to be a VIP, VIP+ or MVP or BOSS to use this command")
    end
end)


RegisterCommand("reloadeffects", function()
    if GM.Player.Group == "owner" or GM.Player.Group == "admin" then
        LoadEffectsFromGitHub()
        ShowAboveRadarMessage("~g~Reloading kill effects from GitHub...")
    else
        ShowAboveRadarMessage("~r~You need to be an admin to use this command")
    end
end)