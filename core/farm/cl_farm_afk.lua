
GM.Player.Afk = false
ListPlayersAfk = nil  

_RegisterNetEvent("afkfarm:update", function(tblData)
    print("afkfarm:update", json.encode(tblData))
    ListPlayersAfk = tblData
end)

local tempCoords = nil

local function drawTxt(text, font, centre, x, y, scale, r, g, b, a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end


function FarmAfk(bool)
    if bool then
        GM.Player.Afk = true
        tempCoords = GetEntityCoords(PlayerPedId())
        Tse("afkfarm:start", "join")
        SetEntityInvincible(PlayerPedId(), true)
        -- vector4(3665.007, 4976.935, 13.96932, 38.43944)
        TeleportPlayerCoords(vector4(3665.007, 4976.935, 13.96932, 38.43944), PlayerPedId())
        Citizen.CreateThread(function()
            while GM.Player.Afk do 
                DrawCenterText("Use ~r~/afk ~w~for leave the mode.")
                Citizen.Wait(0)
            end
        end)
    else
        GM.Player.Afk = false
        Tse("afkfarm:start", "leave")
        SetEntityInvincible(PlayerPedId(), false)
        TeleportPlayerCoords(tempCoords, PlayerPedId())
    end
end

RegisterCommand("afk", function()
    if GM.Player.Afk then
        FarmAfk(false)
    end
end)


local NPC_Afk = {
    pedType = 4,
    safezone = "Hospital",
    model = "a_f_m_beach_01",
    pos = vector4(226.1826, -1390.567, 30.52464, 230.7253),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Afk_Marabunta = {
    pedType = 4,
    safezone = "Marabunta",
    model = "a_f_m_beach_01",
    pos = vector4(1153.041, -1495.073, 34.69258, 179.3089),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Afk_Beach = {
    pedType = 4,
    safezone = "Beach Safezone",
    model = "a_f_m_beach_01",
    pos = vector4(-1074.134, -1654.941, 4.461811, 127.0172),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}   

local NPC_Afk_AA = {
    pedType = 4,
    safezone = "Cross Field",
    model = "a_f_m_beach_01",
    pos = vector4(1203.49, 1868.563, 78.11176, 228.3018),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Afk_Blaine = {
    pedType = 4,
    safezone = "Sandy Shores Safezone",
    model = "a_f_m_beach_01",
    pos = vector4(2766.792, 3462.488, 55.65659, 67.03642),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Afk_Paleto = {
    pedType = 4,
    safezone = "Hideout",
    model = "a_f_m_beach_01",
    pos = vector4(1473.473, 6369.369, 23.63824, 196.0217),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Afk_Paleto2 = {
    pedType = 4,
    safezone = "Paleto",
    model = "a_f_m_beach_01",
    pos = vector4(-956.3287, 6191.229, 3.686811, 35.96812),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Afk_Mountain = {
    pedType = 4,
    safezone = "Mountain",
    model = "a_f_m_beach_01",
    pos = vector4(-430.1723, 1131.285, 325.905, 171.5148),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Afk_Main = {
    pedType = 4,
    safezone = "Main SafeZone",
    model = "a_f_m_beach_01",
    pos = vector4(-532.962, -232.0573, 36.70224, 35.56971),
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}

local NPC_Afk_Mirror = {
    pedType = 4,
    safezone = "Mirror Park",
    model = "a_f_m_beach_01",
    pos = vector4(1373.628, -570.8351, 74.20848, 153.5341),
    weapon = "weapon_combatmg",
    action = function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            FarmAfk(true)
        else
            ShowAboveRadarMessage("~r~You need to exit the vehicle to enter the afk zone")
        end
    end,
    drawText = function()
        if ListPlayersAfk and #ListPlayersAfk > 0 then 
            return "[ ~r~AFK ZONE ~s~] - ~g~"..#ListPlayersAfk.." players"
        else
            return "[ ~r~AFK ZONE ~s~] - ~w~No players"
        end
    end,
    distanceLimit = 2.0,
    distanceShowText = 20.0,
}


Citizen.CreateThread(function()
    RegisterSafeZonePedAction(NPC_Afk)
    RegisterSafeZonePedAction(NPC_Afk_Marabunta)
    RegisterSafeZonePedAction(NPC_Afk_Beach)
    RegisterSafeZonePedAction(NPC_Afk_AA)
    RegisterSafeZonePedAction(NPC_Afk_Blaine)
    RegisterSafeZonePedAction(NPC_Afk_Paleto)
    RegisterSafeZonePedAction(NPC_Afk_Paleto2)
    RegisterSafeZonePedAction(NPC_Afk_Mountain)
    RegisterSafeZonePedAction(NPC_Afk_Main)
    RegisterSafeZonePedAction(NPC_Afk_Mirror)
end)