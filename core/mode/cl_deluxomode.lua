function Request(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
    return model
end

InDeluxo1v1 = false

GM.Player.InMode = {
    Deluxo = false
}


ListVehMod = {}
ListPedMod = { }

-- CreateDeluxoDrive({
--     [1] = vector4(-26.65052, -954.5479, 29.41268, 159.5417),
--     [2] = vector4(-255.4992, -1576.905, 144.9214, 154.7128),
-- }, true)

-- RegisterCommand("testDelux", function()
--     CreateDeluxoDrive({
--         [1] = vector4(-58.38705, -1034.154, 28.43511, 160.5232),
--         [2] = vector4(-107.7178, -1215.661, 63.32598, 170.0712),
--     }, true)

-- end)

function CreateDeluxoDrive(tblCoords, myPlayer)
    local deluxomodel = Request("deluxo")
    local pModel = Request('a_m_m_tranvest_02')
    local delux = CreateVehicle(deluxomodel, tblCoords[1].x, tblCoords[1].y, tblCoords[1].z + 10, tblCoords[1].w, true, false)
    InDeluxo1v1 = true
    table.insert(ListVehMod, {model = delux})
    Logger:trace("Deluxo", delux)
    if myPlayer then 
        
        TeleportPlayerCoords(vector3(tblCoords[1].x, tblCoords[1].y, tblCoords[1].z + 10), PlayerPedId(), true)
        -- SetEntityCoords(PlayerPedId(), tblCoords[1].x, tblCoords[1].y, tblCoords[1].z + 10)
        SetFollowPedCamViewMode(4)
        -- FreezeEntityPosition(PlayerPedId(), true)
    end
    Wait(1000)
    SetEntityAsMissionEntity(delux, true, true) 
    SetModelAsNoLongerNeeded(deluxomodel)
    SetEntityInvincible(delux, true)
    SetEntityDynamic(delux, true)
    SetVehicleDoorsLocked(delux, 2) 
    SetVehicleEngineOn(delux, true, true, true)
    SetEntityProofs(delux, true, true, true, true, true, true, true, true)
    SetHoverModeWingRatio(delux, 1.0)
    SetSpecialFlightModeRatio(delux, 0.75 - GetFrameTime())
    SetVehicleHoverTransformPercentage(delux, 1.0)
    ActivatePhysics(delux)
    SetSpecialFlightModeTargetRatio(delux, 1.0)
    local pedDriver = CreatePed(4, pModel, tblCoords[1].x, tblCoords[1].y, tblCoords[1].z, tblCoords[1].w, false, true)
    if not pedDriver then return end
    table.insert(ListPedMod, {model = pedDriver})
    FreezeEntityPosition(PlayerPedId(), false)
    Logger:trace("Ped", pedDriver)
    SetEntityAsMissionEntity(pedDriver, true, true)
    SetEntityInvincible(pedDriver, true)
    SetModelAsNoLongerNeeded(pModel)
    SetPedKeepTask(pedDriver, true)
    SetDriverAbility(pedDriver, 1.0)
    SetPedConfigFlag(pedDriver, 116, true)
    SetPedConfigFlag(pedDriver, 118, true)
    SetPedIntoVehicle(pedDriver, delux, -1)
    SetBlockingOfNonTemporaryEvents(pedDriver, true)
    -- Corrected line to increase Z coordinate
    TaskVehicleDriveToCoordLongrange(pedDriver, delux, tblCoords[2].x, tblCoords[2].y, tblCoords[2].z + 100.0, 30.0, 21495808, 20.0)
    SetVehicleForwardSpeed(delux, 30.0)
    Logger:trace("Task", "drive to coord")
    -- Citizen.CreateThread(function() 
    --     while InDeluxo1v1 do 
    --         if IsPedFalling(PlayerPedId()) then 
    --             InDeluxo1v1 = false
    --             for k, v in pairs(ListVehMod) do
    --                 DeleteEntity(v.model)
    --             end
    --             for k, v in pairs(ListPedMod) do
    --                 DeleteEntity(v.model)
    --             end
    --         end
    --         Citizen.Wait(1)
    --     end
    -- end)
    while (DoesEntityExist(delux) and DoesEntityExist(pedDriver)) do
        Wait(0)
        SetEntityRotation(delux, 10.0, 0.0, tblCoords[1].w, 2, true)
        local pos = GetEntityCoords(delux)
        local distance = #(pos - vector3(tblCoords[2].x, tblCoords[2].y, tblCoords[2].z))
    end
end

_AddEventHandler("spawnDeluxo", function(tblCoords, myDelux)
    CreateDeluxoDrive(tblCoords, myDelux)
end)    

local idGameDeluxo = nil

_RegisterNetEvent("deluxo:start1v1", function(tblData, myPlace)
    DoScreenFadeIn(500)
    GM.Player.InMode.Deluxo = true
    idGameDeluxo = tblData.sessionId
    if tonumber(myPlace) == tonumber(1) then 
        CreateDeluxoDrive({
            vector4(tblData.Schema.POSITION_1.x, tblData.Schema.POSITION_1.y, tblData.Schema.POSITION_1.z, tblData.Schema.POSITION_1.w),
            vector4(tblData.Schema.POSITION_1_2.x, tblData.Schema.POSITION_1_2.y, tblData.Schema.POSITION_1_2.z, tblData.Schema.POSITION_1_2.w),
        }, myPlace)
    elseif tonumber(myPlace) == tonumber(2) then 
        CreateDeluxoDrive({
            vector4(tblData.Schema.POSITION_1.x, tblData.Schema.POSITION_1.y, tblData.Schema.POSITION_1.z, tblData.Schema.POSITION_1.w),
            vector4(tblData.Schema.POSITION_1_2.x, tblData.Schema.POSITION_1_2.y, tblData.Schema.POSITION_1_2.z, tblData.Schema.POSITION_1_2.w),
        }, myPlace)
    end
end)

_AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(ListVehMod) do
            DeleteEntity(v.model)
        end
        for k, v in pairs(ListPedMod) do
            DeleteEntity(v.model)
        end
    end
end)

_RegisterNetEvent("deluxo:finishGame", function(tblData)
    GM.Player.InMode.Deluxo = false
    idGameDeluxo = false
    for k, v in pairs(ListVehMod) do
        DeleteEntity(v.model)
    end
    for k, v in pairs(ListPedMod) do
        DeleteEntity(v.model)
    end

    if tblData.winner.uuid == GM.Player.uuid then 
        DrawCenterText("~g~You won the match !~s~", 5000)
    else
        DrawCenterText("~r~You lost the match !~s~", 5000)
    end
end)

function DeathDeluxo(tblData)
    for k, v in pairs(ListVehMod) do
        DeleteEntity(v.model)
    end
    for k, v in pairs(ListPedMod) do
        DeleteEntity(v.model)
    end

    DoScreenFadeOut(700)
    Wait(800)
    Tse("deluxo:restartManche", { sessionId = idGameDeluxo, players = tblData } )
end