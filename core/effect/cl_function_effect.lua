function EffectOnPlayer(dictTest, particleNameTest)
    local dict = dictTest
    local particleName = particleNameTest
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Citizen.Wait(0)
    end
    UseParticleFxAssetNextCall(dict)
    StartParticleFxNonLoopedAtCoord(particleName, GetEntityCoords(PlayerPedId()), 0.0, 0.0, 0.0, 1.5, false, false, false)
end