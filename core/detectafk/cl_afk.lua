local afkTimeDetect = 900

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
    end
end)


Citizen.CreateThread(function()
	while true do
        local timer = 5000
		local playerPed = PlayerPedId()
        if GM.Player.InSafeZone then 
            timer = 1000
            if playerPed then
                local currentPos = GetEntityCoords(playerPed, true)

                if prevPos and currentPos == prevPos and not GM.Player.InSelecGamemode and not Admin.InSpec and not GM.Player.Afk and not GM.Player.InFarm and not GM.Player.InLeague and not GM.Player.LeagueLobby and not GM.Player.InFFA and not GM.Player.InGunrace and not GM.Player.InSafeZone then
                    if timeLeft > 0 then 
                        timeLeft = timeLeft - 1 
                    else 
                        ExecuteCommand("lobby")
                    end
                else
                    timeLeft = afkTimeDetect
                end

                prevPos = currentPos
            end 
        end
        Wait(timer) 
	end 
end)