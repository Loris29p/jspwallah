_RegisterNetEvent("gamemode:OpenInventory", function(data)
    data.bool = true 
    Display(data)
end)

_RegisterNetEvent("gamemode:UpdateInventory", function(value, inventoryType, index, key)
    if inventoryType then
        if index then
            if key then
                PlayerItems[inventoryType][index][key] = value
            else
                if value == nil then
                    table.remove(PlayerItems[inventoryType], index)
                else
                    PlayerItems[inventoryType][index] = value
                end
            end
        else
            PlayerItems[inventoryType] = value
        end
    else
        PlayerItems = value
    end
    -- if isOpened then
    --     UpdateInventory("protected")
    -- end
end)

RegisterNUICallback("CheckItems", function(data)

    -- PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
    Tse("gamemode:server:ItemDragToSafe", data)
end)

RegisterNUICallback("CheckItemsSafe", function(data)

    -- PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
    Tse("gamemode:server:ItemDragToInventory", data)
end)

_RegisterNetEvent("gamemode:SetHotbar", function(value, key, index)
    if key then
        if not index then
            HotbarData[key] = value
        else
            HotbarData[key][index] = value
        end
    else
        HotbarData = value
    end
    for k,v in pairs(HotbarData) do
        if v and v.name and v.hasItem then
            v.image = Items[v.name].image
            v.label = Items[v.name].label
            v.rarity = Items[v.name].rarity
            v.type = (Items[v.name].type and Items[v.name].type or "item")
        end
    end
    SetHotbar()
end)

RegisterNUICallback("Close", function(data)
    isOpened = false
    Display({
        bool = false
    })

    if inDropInventory then
        inDropInventory = false
    end
end)


RegisterNUICallback("SetHotbar", function(data)
    Tse("gamemode:UpdateHotbar", data)
end)

_RegisterNetEvent("gamemode:client:OnItemUsed", function(itemName, info)
    if Items[itemName].type == "weapon" then
        UseWeapon(itemName, info)
    end

    if Items[itemName].type == "item" then
        UseItem(itemName)
    end

    if Items[itemName].type == "heal" then
        UseItem(itemName)
    end
end)

-- Simple 3D text drawer with screen projection and outline
function DrawText3Dx(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	if not onScreen then return end
	SetTextScale(0.40, 0.40)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 255)
	SetTextCentre(true)
	SetTextOutline()
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(_x, _y)
end

-- Returns true if any occupant of the vehicle is a player (driver or passengers)
local function HasPlayerInVehicle(vehicle)
	if not DoesEntityExist(vehicle) then return false end
	if IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then return true end
	local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle) or 0
	for seatIndex = 0, maxPassengers do
		local ped = GetPedInVehicleSeat(vehicle, seatIndex)
		if IsPedAPlayer(ped) then
			return true
		end
	end
	return false
end

function UseItem(itemName)
    local item = Items[itemName]

    if itemName == "ped_access" or itemName == "ped_access1week" or itemName == "ped_access1month" then
        Tse("guildpvpustom:PedAccess", itemName)
    elseif itemName == "kill_effect" or itemName == "kill_effect1week" or itemName == "kill_effect1month" then
        Tse("guildpvpustom:KillEffect", itemName)
    elseif itemName == "kevlar" or itemName == "bandage" then
        _TriggerEvent("cl_heal:custom:UseItem", itemName)
    elseif itemName == "tracker_deluxo" then
		local trackedBlips = {}
		local trackedBlipByVeh = {}
		local trackedVehicles = {}
		local vehicles = GetGamePool('CVehicle')
		local deluxoHash = GetHashKey("deluxo")

		for i = 1, #vehicles do
			local veh = vehicles[i]
			if DoesEntityExist(veh) and GetEntityModel(veh) == deluxoHash and HasPlayerInVehicle(veh) then
				local blip = AddBlipForEntity(veh)
				SetBlipSprite(blip, 225)
				SetBlipColour(blip, 1) -- red
				SetBlipScale(blip, 0.85)
				SetBlipDisplay(blip, 2)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString("Deluxo")
				EndTextCommandSetBlipName(blip)
				table.insert(trackedBlips, blip)
				trackedBlipByVeh[veh] = blip
				table.insert(trackedVehicles, veh)
			end

		end

		local endTime = GetGameTimer() + 60000
		
		-- Activer l'effet trackerdeluxo pour 60 secondes
		SendNUIMessage({
			type = "trackerdeluxo"
		})
		
		Citizen.CreateThread(function()
			while GetGameTimer() < endTime do
				
				local pool = GetGamePool('CVehicle')
				for p = 1, #pool do
					local veh = pool[p]
					if DoesEntityExist(veh) and GetEntityModel(veh) == deluxoHash and HasPlayerInVehicle(veh) then
						if not trackedBlipByVeh[veh] then
							local blip = AddBlipForEntity(veh)
							SetBlipSprite(blip, 225)
							SetBlipColour(blip, 1)
							SetBlipScale(blip, 0.85)
							SetBlipDisplay(blip, 2)
							BeginTextCommandSetBlipName("STRING")
							AddTextComponentString("Deluxo")
							EndTextCommandSetBlipName(blip)
							trackedBlipByVeh[veh] = blip
							table.insert(trackedBlips, blip)
							table.insert(trackedVehicles, veh)
						end
					end
				end
				for i = 1, #trackedVehicles do
					local veh = trackedVehicles[i]
					if DoesEntityExist(veh) then
						if HasPlayerInVehicle(veh) then
							local x, y, z = table.unpack(GetEntityCoords(veh))
							local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
							local dist = math.floor(Vdist(x, y, z, px, py, pz))
							DrawText3Dx(x, y, z + -0.8, ("Deluxo - ~r~%dm"):format(dist))
						else
							local blip = trackedBlipByVeh[veh]
							if blip and DoesBlipExist(blip) then
								RemoveBlip(blip)
							end
							trackedBlipByVeh[veh] = nil
						end
					end
				end
				Citizen.Wait(0)
			end
		end)

		Citizen.SetTimeout(60000, function()
			for _, blip in ipairs(trackedBlips) do
				if blip and DoesBlipExist(blip) then
					RemoveBlip(blip)
				end
			end
		end)
	end

    ShowAboveRadarMessage("You used ~g~"..item.label)
end

_RegisterNetEvent("gamemode:client:RemoveWeapon")
_AddEventHandler("gamemode:client:RemoveWeapon", function(itemName)
    local ped = PlayerPedId()
    local weaponHash = GetHashKey(itemName)
    local isInVehicle = IsPedInAnyVehicle(ped, false)
    
    if HasPedGotWeapon(ped, weaponHash, false) then
        RemoveWeaponFromPed(ped, weaponHash)

        if GetSelectedPedWeapon(ped) == weaponHash or isInVehicle then
            SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
        end
    end
end)


function updateWeight()
    local inventory, inventoryWeight = FormatItems(PlayerItems["inventory"])
    local otherInventory, otherInventoryWeight = FormatItems(PlayerItems["protected"])


    SendNUIMessage({
        type = "updateWeight",
        weights = {
            inventoryWeight = inventoryWeight,
            otherInventoryWeight = otherInventoryWeight,
            maxInvWeight = GM.Player.MaxWeight.."0",
            maxSafeWeight = GM.Player.MaxSafeWeight.."0"
        }
    })
end

_RegisterNetEvent("guild:updateWeight", function()
    updateWeight()
end)

RegisterNUICallback("CheckContainer", function(data)
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
    
    if string.match(data.id, "^bags%-") then
        -- print("BAG EVENT")
        Tse("gamemode:TakeItemFromInvForBag", data.id, data.item)
    elseif string.match(data.id, "^container%-") then
        Tse("gamemode:TakeItemFromInvForStash", data.item)
    else
        Tse("gamemode:TakeItemFromInvForStash", data.item)
    end
end)

RegisterNUICallback("CheckContainer2", function(data)
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
    
    if string.match(data.id, "^bags%-") then
        -- print("BAG EVENT")
        Tse("gamemode:TakeItemsFromBag", data.id, data.item)
    elseif string.match(data.id, "^container%-") then
        print("CONTAINER EVENT: Taking item from stash: " .. data.item)
        Tse("gamemode:TakeItemsFromStash", data.item)
    elseif string.match(data.id, "^airdrop%-") then
        -- print("DROP EVENT")
        local dropId = string.gsub(data.id, "airdrop%-", "")
        data.dropId = dropId
        print("AIRDROP EVENT: " .. json.encode(data))
        Tse("zoliax:dropSrv", "take_item", { itemData = data.item, dropId = (data and data.dropId) or dropId })
    else
        -- Fallback pour les IDs sans préfixe reconnu
        print("UNRECOGNIZED CONTAINER ID FORMAT: " .. data.id .. ", defaulting to stash handling")
        Tse("gamemode:TakeItemsFromStash", data.item)
    end
end)

RegisterNUICallback("openMarket", function()
    SetNuiFocus(true, true)
    Tse("zoliax:marketSrv", "open_market", {})
end)