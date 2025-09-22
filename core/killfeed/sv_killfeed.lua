_RegisterServerEvent("killfeed:event")
_AddEventHandler("killfeed:event", function(killer, victim, weapon, isRedzone, isFFA)
    local src = source
    local usernameTest = ReturnUsernameWithTagAndColor(src)
    if RateLimitCheck(src) > 3 then return BanUUID(0, GetPlayerId(src).uuid, "Killfeed SPAM", "99y") end 

    local crewKiller = GetPlayerCrew(src)
    local killerUsername = ""
    if crewKiller then 
        local CREW_DAT = GetCrewData(crewKiller.crewId)
        if CREW_DAT then 
            killerUsername = CREW_DAT.crewTag
        end
    end
    _TriggerClientEvent("gamemode:killfeed:sendEvent", -1, GetTextWithGameColors(killerUsername, false).." "..usernameTest, GetTextWithGameColors(killerUsername, false).." "..usernameTest, weapon, isRedzone, 0, 0, (isFFA and true or false))
end)

_RegisterServerEvent("killfeed:event:test")
_AddEventHandler("killfeed:event:test", function(killerId, weaponkiller, isRedZone, isFFA)
    local src = source
    local KILLER = GetPlayerId(killerId)
    local victim = GetPlayerId(src)

    if not KILLER or not victim then
        return
    end
    
    if RateLimitCheck(src) > 3 then return BanUUID(0, victim.uuid, "Killfeed SPAM", "99y") end 
    local crewKiller, crewVictim = GetPlayerCrew(killerId), GetPlayerCrew(src) 
    local killerUsername, victimUsername = "", ""

    if crewKiller then 
        local CREW_DAT = GetCrewData(crewKiller.crewId)
        if CREW_DAT then 
            killerUsername = CREW_DAT.crewTag
        end
    end

    if crewVictim then 
        local CREW_DAT = GetCrewData(crewVictim.crewId)
        if CREW_DAT then 
            victimUsername = CREW_DAT.crewTag
        end
    end

    _TriggerClientEvent("gamemode:killfeed:sendEvent", -1, GetTextWithGameColors(killerUsername, false).." "..ReturnUsernameWithTagAndColor(tonumber(killerId)), GetTextWithGameColors(victimUsername, false).." "..ReturnUsernameWithTagAndColor(tonumber(src)), weaponkiller, isRedZone, victim.prestige, KILLER.prestige, (isFFA and true or false))
end)