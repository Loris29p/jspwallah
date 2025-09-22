ListBags = {}

_RegisterNetEvent("gamemode:updateBags", function(allbags)
    ListBags = allbags
end)

obj = {}

_RegisterNetEvent("gamemode:createBags", function(coords, id, isLegendary)
    if GM.Player.InFarm then return end
    local a, b, c = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z)
    local model = "prop_big_bag_01"
    RequestModel(model)
    while not HasModelLoaded(model) do 
        Citizen.Wait(1)
    end
    local timerBag = 50
    if isLegendary then 
        timerBag = 200 
    end
    obj[id] = {
        id = id,
        prop = CreateObject(model, coords.x, coords.y, b, false, false, true),
        timer = timerBag,
        coords = vector3(coords.x, coords.y, b),
    }


	if isLegendary then 
		Citizen.CreateThread(function()
            if obj[id] ~= nil then 
                while obj[id].timer > 0 do
                    local timer = 1000
                    local pPed = PlayerPedId()
                    local myCoords = GetEntityCoords(pPed)
                    local bagPos = GetEntityCoords(obj[id].prop)

				local dist = #(myCoords - bagPos)

				if dist < 20.0 then
					timer = 0
			
					DrawMarker(25, bagPos.x, bagPos.y, bagPos.z - 0.1, 0, 0, 0, 0, 0, 0, 1.600, 1.600, 1.600, 0, 220, 0, 90, 0, 0, 0, 0)
					DrawMarker(25, bagPos.x, bagPos.y, bagPos.z - 0.1, 0, 0, 0, 0, 0, 0, 1.282, 1.282, 1.282, 0, 220, 0, 100, 0, 0, 0, 0)
					DrawMarker(25, bagPos.x, bagPos.y, bagPos.z - 0.1, 0, 0, 0, 0, 0, 0, 1.029, 1.029, 1.029, 0, 220, 0, 110, 0, 0, 0, 0)
					DrawMarker(25, bagPos.x, bagPos.y, bagPos.z - 0.1, 0, 0, 0, 0, 0, 0, 0.826, 0.826, 0.826, 0, 220, 0, 110, 0, 0, 0, 0)
					DrawMarker(25, bagPos.x, bagPos.y, bagPos.z - 0.1, 0, 0, 0, 0, 0, 0, 0.661, 0.661, 0.661, 0, 220, 0, 110, 0, 0, 0, 0)
					DrawMarker(25, bagPos.x, bagPos.y, bagPos.z - 0.1, 0, 0, 0, 0, 0, 0, 0.530, 0.530, 0.530, 0, 220, 0, 110, 0, 0, 0, 0)
		
				end
                    Citizen.Wait(timer)
                end
            end
		end)
	end
    FreezeEntityPosition(obj[id].prop, true)
    PlaceObjectOnGroundProperly(obj[id].prop)
    SetEntityCollision(obj[id].prop, false, false)
end)

_RegisterNetEvent("gamemode:DeleteProp")
_AddEventHandler("gamemode:DeleteProp", function(k)
	if obj[k] ~= nil and obj[k].prop ~= nil then
		SetEntityAsMissionEntity(obj[k].prop, false, true)
		DeleteObject(obj[k].prop)
		obj[k] = nil
	end
end)


_AddEventHandler("onResourceStop", function(resource)
	if resource == GetCurrentResourceName() then 
		for k,v in pairs(obj) do
			SetEntityAsMissionEntity(v.prop, false, true)
			DeleteObject(v.prop)
		end
		obj = {}
	end
end)


CreateThread(function()
	while true do
        local nearby = false
		local ped = PlayerPedId()
		local pCoords = GetEntityCoords(ped)
        local player = GM.Player:Get()

		for _, v in pairs(obj) do
            if v ~= nil then 
                if v.timer > 0 then 
                    local distance = #(vector2(pCoords.x, pCoords.y) - vector2(v.coords.x, v.coords.y))
                    if distance < 5.0 and not player.Dead and IsPedOnFoot(PlayerPedId()) then 
                        nearby = true
                        DrawTopNotification("Press ~INPUT_PICKUP~ to loot the inventory.")
                        if not IsPedInAnyVehicle(ped, false) and IsControlJustPressed(0, 46) and not player.InFarm and not player.InHostGame and not player.InLeague and not player.InSelecGamemode and not player.Afk then
                            Tse("gamemode:LootBag", v.id)
                        end
                    end
                end
            end
		end
		if not nearby then 
			Citizen.Wait(500)
		end
		Citizen.Wait(1)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k,v in pairs(obj) do
			if v ~= nil then
				if v.timer then
					if v.timer > 0 then
						v.timer = v.timer - 1
						if v.timer <= 0 then
							Tse('gamemode:DeleteBags', k)
						end
					end
				end
			end
		end
	end
end)