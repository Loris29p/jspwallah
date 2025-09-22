
if AmbianceConfig.active then 
    LoopedParticles = {}
    function SetEffectsAmbiance(tblData)
        if type(tblData) == "table" then
            local particleDict = tblData.dict 
            local particleName = tblData.name
            RequestNamedPtfxAsset(particleDict)
            while not HasNamedPtfxAssetLoaded(particleDict) do
                print("Waiting for particle effect to load...")
                Citizen.Wait(100)
            end
            
            UseParticleFxAssetNextCall(particleDict)
            local particleHandle = StartParticleFxLoopedAtCoord(
            particleName,
            tblData.pos.x, tblData.pos.y, tblData.pos.z,   -- position
            0.0, 0.0, 0.0,         -- rotation
            1.5,                   -- scale
            false, false, false, false
            )

            LoopedParticles[tblData.id].waitTime = 3000
            if particleHandle then
                LoopedParticles[tblData.id].handle = particleHandle
                SetParticleFxLoopedColour(particleHandle, 56, 255, 200, true) -- Red color
            end
            print("Particle started 2 successfully with handle: " .. particleHandle)
        end
    end

    CreateThread(function()
        while true do 
            local timer = 1000
            for k, v in pairs(LoopedParticles) do 
                if v.waitTime > 0 then 
                    v.waitTime = v.waitTime - 1000
                    timer = 1000
                else
                    if DoesParticleFxLoopedExist(v.handle) then
                        Wait(2000)
                        StopParticleFxLooped(v.handle, 0)
                    else
                        SetEffectsAmbiance(v)
                    end
                end
            end
            Wait(timer)
        end
    end)

    function LoadAmbianceEffect(tblData, safezoneId)
        local pos = tblData.pos
        
        local particleDict = tblData.effects.dict
        local particleName = tblData.effects.name  -- Be specific about which effect

        RequestNamedPtfxAsset(particleDict)
        while not HasNamedPtfxAssetLoaded(particleDict) do
            print("Waiting for particle effect to load...")
            Citizen.Wait(100)
        end
        
        UseParticleFxAssetNextCall(particleDict)
        local particleHandle = StartParticleFxLoopedAtCoord(
            particleName,
            pos.x, pos.y, pos.z,   -- position
            0.0, 0.0, 0.0,         -- rotation
            1.5,                   -- scale
            false, false, false, false
        )
        local id  = #LoopedParticles + 1
        LoopedParticles[id] = { handle = particleHandle, dict = particleDict, name = particleName, waitTime = 3000, pos = pos, id = id, safezoneId = safezoneId }
        if particleHandle then
            SetParticleFxLoopedColour(particleHandle, 56, 255, 200, true) -- Red color
        end
    end

    function UnloadAmbianceEffect(safezoneId)
        for k, v in pairs(LoopedParticles) do 
            if safezoneId == v.safezoneId then 
                if DoesParticleFxLoopedExist(v.handle) then
                    StopParticleFxLooped(v.handle, 0)
                    print("Particle stopped successfully with handle: " .. v.handle)
                end
            end
        end
        LoopedParticles = {}
    end

    -- AddEventHandler("onResourceStart", function(resourceName)
    --     if resourceName == GetCurrentResourceName() then
    --         for k, v in pairs(AmbianceConfig.List) do
    --             if v.effects then
    --                 LoadAmbianceEffect(v)
    --             end
    --         end
    --     end
    -- end)

    RegisterCommand("unloadambiance", function()
        UnloadAmbianceEffect()
    end)
end