RegisterNUICallback("hudEffects", function(data)
    if data and data.effect == "antizin" and not data.state then
        exports.zombies:UseEffectZom("antizin", { bool = false })
    elseif data and (data.effect == "fleshshot" or data.effect == "flesh") and not data.state then
        exports.zombies:UseEffectZom("fleshshot", { bool = false })
    elseif data and data.effect == "babygod" and not data.state then
        GM.Player.InCombat = false
        SendNUIMessage({
            type = "updatecombatmode",
            combatmode = false
        })
        ShowAboveRadarMessage("🛡️ ~b~You are not in combat anymore.")
    elseif data and data.effect == "safezone" and not data.state then
        -- search safezone to disable it
        GM.Player.InSafezone = false
        inSafe(false)

        for _,v in pairs(m_tblSafe.list) do
            v.inZone = false
        end

        ResetEntityAlpha(PlayerPedId())
        SetPedSuffersCriticalHits(PlayerPedId(), false)
        SetEntityInvincible(PlayerPedId(), false)
        SetRadarZoomPrecise(-1.0)
        SetPedMoveRateOverride(PlayerId(), 1.0)
        SetRunSprintMultiplierForPlayer(PlayerId(),1.0)
        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(PlayerPedId(), true, true)
        SetEntityOnlyDamagedByPlayer(PlayerPedId(), true)
        SetPedSuffersCriticalHits(PlayerPedId(), false)

        
        ShowAboveRadarMessage("~r~You left the safezone.")
    end
end)