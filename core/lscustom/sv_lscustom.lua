_RegisterServerEvent("lscustom:refreshOwnedVehicle", function(vehicleProps)

    local PLAYER = GetPlayerId(source)

	MySQL.Async.fetchAll("SELECT * FROM vehicles WHERE model = @model AND identifier = @identifier", {["@model"] = vehicleProps.model, ["@identifier"] = PLAYER.license}, function(result)
		if result[1] then
			MySQL.Async.execute("UPDATE vehicles SET vehicleProps = @vehicleProps WHERE model = @model AND identifier = @identifier", {["@vehicleProps"] = json.encode(vehicleProps), ["@model"] = vehicleProps.model, ["@identifier"] = PLAYER.license}, function(rowsChanged)
				if rowsChanged > 0 then

				end
			end)
		else
			MySQL.Async.execute("INSERT INTO vehicles (model, vehicleProps, identifier) VALUES (@model, @vehicleProps, @identifier)", {["@model"] = vehicleProps.model, ["@vehicleProps"] = json.encode(vehicleProps), ["@identifier"] = PLAYER.license}, function(rowsChanged)
				if rowsChanged > 0 then

				end
			end)
		end
	end)
end)

_RegisterServerEvent("LCS_SaveVehicle", function(vehicleProps)
	local PLAYER = GetPlayerId(source)

	MySQL.Async.fetchAll("SELECT * FROM vehicles WHERE model = @model AND identifier = @identifier", {["@model"] = vehicleProps.model, ["@identifier"] = PLAYER.license}, function(result)
		if result[1] then
			MySQL.Async.execute("UPDATE vehicles SET vehicleProps = @vehicleProps WHERE model = @model AND identifier = @identifier", {["@vehicleProps"] = json.encode(vehicleProps), ["@model"] = vehicleProps.model, ["@identifier"] = PLAYER.license}, function(rowsChanged)
				if rowsChanged > 0 then
					Logger:info("Player: " .. PLAYER.license .. " has updated a vehicle: " .. vehicleProps.model)

                    if not CustomVehicles[PLAYER.license] then
                        CustomVehicles[PLAYER.license] = {}
                    end
                    CustomVehicles[PLAYER.license][tonumber(vehicleProps.model)] = {
                        model = vehicleProps.model,
                        vehicleProps = vehicleProps
                    }
				end
			end)
            
		else
			MySQL.Async.execute("INSERT INTO vehicles (model, vehicleProps, identifier) VALUES (@model, @vehicleProps, @identifier)", {["@model"] = vehicleProps.model, ["@vehicleProps"] = json.encode(vehicleProps), ["@identifier"] = PLAYER.license}, function(rowsChanged)
				if rowsChanged > 0 then
					Logger:info("Player: " .. PLAYER.license .. " has saved a vehicle: " .. vehicleProps.model)
                    if not CustomVehicles[PLAYER.license] then
                        CustomVehicles[PLAYER.license] = {}
                    end
                    CustomVehicles[PLAYER.license][tonumber(vehicleProps.model)] = {
                        model = vehicleProps.model,
                        vehicleProps = vehicleProps
                    }
				end
			end)
            -- LoadVehiclesCustomPlayer(source, PLAYER.license)
		end
	end)
end)

-- RegisterCommand("deletecustoms", function(source, args, rawCommand)
--     MySQL.Async.execute("DELETE FROM vehicles", {}, function(rowsChanged)
--         if rowsChanged > 0 then
--             print(rowsChanged .. " véhicules personnalisés de la base de données.")
--         else
--             print("Aucun véhicule personnalisé trouvé dans la base de données.")
--         end
--     end)
-- end)

_RegisterServerEvent("bucketlscustom", function(type, vehicle)
    if type == "join" then 
        local id = math.random(1, 600)
        SetPlayerRoutingBucket(source, id)
        SetEntityRoutingBucket(NetworkGetEntityFromNetworkId(vehicle), id)
        
    elseif type == "leave" then 
        SetPlayerRoutingBucket(source, 0)
        SetEntityRoutingBucket(NetworkGetEntityFromNetworkId(vehicle), 0)
    end
end)




_RegisterServerEvent("LSC:finished")
_AddEventHandler("LSC:finished", function(veh)
	local model = veh.model --Display name from vehicle model(comet2, entityxf)
	local mods = veh.mods
	--[[
	mods[0].mod - spoiler
	mods[1].mod - front bumper
	mods[2].mod - rearbumper
	mods[3].mod - skirts
	mods[4].mod - exhaust
	mods[5].mod - roll cage
	mods[6].mod - grille
	mods[7].mod - hood
	mods[8].mod - fenders
	mods[10].mod - roof
	mods[11].mod - engine
	mods[12].mod - brakes
	mods[13].mod - transmission
	mods[14].mod - horn
	mods[15].mod - suspension
	mods[16].mod - armor
	mods[23].mod - tires
	mods[23].variation - custom tires
	mods[24].mod - tires(Just for bikes, 23:front wheel 24:back wheel)
	mods[24].variation - custom tires(Just for bikes, 23:front wheel 24:back wheel)
	mods[25].mod - plate holder
	mods[26].mod - vanity plates
	mods[27].mod - trim design
	mods[28].mod - ornaments
	mods[29].mod - dashboard
	mods[30].mod - dial design
	mods[31].mod - doors
	mods[32].mod - seats
	mods[33].mod - steering wheels
	mods[34].mod - shift leavers
	mods[35].mod - plaques
	mods[36].mod - speakers
	mods[37].mod - trunk
	mods[38].mod - hydraulics
	mods[39].mod - engine block
	mods[40].mod - cam cover
	mods[41].mod - strut brace
	mods[42].mod - arch cover
	mods[43].mod - aerials
	mods[44].mod - roof scoops
	mods[45].mod - tank
	mods[46].mod - doors
	mods[48].mod - liveries
	
	--Toggle mods
	mods[20].mod - tyre smoke
	mods[22].mod - headlights
	mods[18].mod - turbo
	
	--]]
	local color = veh.color
	local extracolor = veh.extracolor
	local neoncolor = veh.neoncolor
	local smokecolor = veh.smokecolor
	local plateindex = veh.plateindex
	local windowtint = veh.windowtint
	local wheeltype = veh.wheeltype
	local bulletProofTyres = veh.bulletProofTyres
	--Do w/e u need with all this stuff when vehicle drives out of lsc
end)