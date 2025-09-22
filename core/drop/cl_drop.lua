DropData = {}

DropDataProps = nil

function Request(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
    return model
end

dropVehiclesDisable = {
    [GetHashKey("deluxo")] = true,
    [GetHashKey("oppressor")] = true,
    [GetHashKey("buzzard2")] = true,
    [GetHashKey("buzzard")] = true,
    [GetHashKey("frogger")] = true,
    [GetHashKey("maverick")] = true,
    [GetHashKey("swift")] = true,
    [GetHashKey("swift2")] = true,
    [GetHashKey("valkyrie")] = true,
    [GetHashKey("thruster")] = true,
    [GetHashKey("seasparrow")] = true,
}

function CreateDrop(tblData_config)
    if not DropData then return print("DropData is nil") end
    local data = tblData_config

    if not Request(data.model) then return print("Model not found") end
    DropDataProps = CreateObject(data.model, data.coords.x, data.coords.y, data.coords.z, false, false, false)
    SetEntityAsMissionEntity(DropDataProps, true, true)
    if not DoesEntityExist(DropDataProps) then return print("DropDataProps is nil") end
    local blip = AddBlipForEntity(DropDataProps)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 6)
    blipRadius = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, 300.0)
    SetBlipColour(blipRadius, 7)
    SetBlipAlpha(blipRadius, 80)
    SetEntityLodDist(DropDataProps, 9999)
    SetEntityDynamic(DropDataProps, true)
    SetModelAsNoLongerNeeded(data.model)
    PlaceObjectOnGroundProperly(DropDataProps)
    FreezeEntityPosition(DropDataProps, true)
    SetEntityInvincible(DropDataProps, true)

    CreateThread(function() 
        while DoesBlipExist(blipRadius) do 
            Citizen.Wait(1000)

            local playerPed = PlayerPedId()
            local playerVehicle = GetVehiclePedIsIn(playerPed, false)
            local playerCoords = GetEntityCoords(playerPed)

            if IsPedInAnyVehicle(playerPed) and dropVehiclesDisable[GetEntityModel(playerVehicle)] then
                local blipCoords = GetBlipCoords(blipRadius)
                local blipRadius = 300.0
    
                if Vdist(playerCoords.x, playerCoords.y, playerCoords.z, blipCoords.x, blipCoords.y, blipCoords.z) <= blipRadius then
                    SetVehicleEngineOn(playerVehicle, false, true, true)
                end
            end
        end
    end)
end