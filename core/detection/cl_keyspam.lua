ListKeysSpam = {
    ["E"] = 38, 
}
HitSpamKey = 0
keySpam = false
function CheckKeySpam()
   local intervalCheck = 1000
   local lastCheck = 0
   keySpam = true
   
   Citizen.CreateThread(function()
        while keySpam do 
            local currentTime = GetGameTimer()
            if currentTime - lastCheck >= intervalCheck then
                -- Vérifier le nombre d'appuis dans la dernière seconde
                if HitSpamKey >= 3 then 
                    ApplyDamageToPed(PlayerPedId(), 10, true)
                    print("Spam détecté! Dégâts appliqués.")
                end
                
                -- Réinitialiser le compteur après chaque intervalle
                HitSpamKey = 0
                lastCheck = currentTime
            end
            
            -- Vérifier si les touches sont pressées
            for k, v in pairs(ListKeysSpam) do
                if IsControlJustPressed(0, v) then
                    print("Touche " .. k .. " pressée")
                    HitSpamKey = HitSpamKey + 1
                end
            end
            
            Citizen.Wait(0) -- Pause pour éviter d'utiliser trop de ressources CPU
        end
    end)
end

function StopKeySpam()
    keySpam = false
end