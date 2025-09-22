function GetAllWeaponActiveComponent(jsonString)
    -- If a JSON string is provided directly (e.g. from console), use it
    local weaponActiveComponent
    
    if jsonString and type(jsonString) == "string" then
        weaponActiveComponent = jsonString
    else
        -- Otherwise get it from the resource KVP
        weaponActiveComponent = GetResourceKvpString("weapon_active_component")
    end
    
    if weaponActiveComponent then
        local success, result = pcall(json.decode, weaponActiveComponent)
        if success and type(result) == "table" then
            return result
        else
            print("Erreur de décodage JSON pour weapon_active_component, réinitialisation")
            return {}
        end
    else
        return {}
    end
end


function SetWeaponActiveComponent(weaponName, componentName, componentHash)
    if not weaponName or not componentHash then
        return
    end

    local weaponActiveComponent = GetAllWeaponActiveComponent()
    if not weaponActiveComponent then
        weaponActiveComponent = {}
    end
    
    if not weaponActiveComponent[weaponName] then
        weaponActiveComponent[weaponName] = {}
    end
    
    -- Vérifie si le composant existe déjà dans la liste
    local exists = false
    if type(weaponActiveComponent[weaponName]) == "table" then
        for i, hash in ipairs(weaponActiveComponent[weaponName]) do
            if hash == componentHash then
                exists = true
                break
            end
        end
    else
        -- Si ce n'est pas une table, réinitialiser à une table vide
        weaponActiveComponent[weaponName] = {}
    end
    
    -- Ajoute le composant s'il n'existe pas déjà
    if not exists then
        table.insert(weaponActiveComponent[weaponName], componentHash)
        GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(weaponName), componentHash)
    end
    GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(weaponName), componentHash)
    
    SetResourceKvp("weapon_active_component", json.encode(weaponActiveComponent))
    print("SetWeaponActiveComponent", weaponName, componentHash, json.encode(weaponActiveComponent))
end 

function RemoveWeaponActiveComponent(weaponName, componentHash)
    if not weaponName or not componentHash then
        return
    end
    
    local weaponActiveComponent = GetAllWeaponActiveComponent()
    if not weaponActiveComponent then
        return
    end
    
    if weaponActiveComponent[weaponName] and type(weaponActiveComponent[weaponName]) == "table" then
        for i, hash in ipairs(weaponActiveComponent[weaponName]) do
            if hash == componentHash then
                table.remove(weaponActiveComponent[weaponName], i)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetHashKey(weaponName), componentHash)
                SetResourceKvp("weapon_active_component", json.encode(weaponActiveComponent))
                print("RemoveWeaponActiveComponent", weaponName, componentHash, json.encode(weaponActiveComponent))
                break
            end
        end
    end
end

function GetWeaponActiveComponent(weaponName, jsonString)
    if not weaponName then
        return {}
    end
    
    local weaponActiveComponent = GetAllWeaponActiveComponent(jsonString)
    if not weaponActiveComponent then
        return {}
    end
    
    if weaponActiveComponent[weaponName] and type(weaponActiveComponent[weaponName]) == "table" then
        return weaponActiveComponent[weaponName]
    else
        return {}
    end
end

function ResetWeaponActiveComponents()
    DeleteResourceKvp("weapon_active_component")
end

RegisterCommand('resetweaponcomponents', function()
    ResetWeaponActiveComponents()
end, false)