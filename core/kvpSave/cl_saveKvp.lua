function SaveKVPInt(name, value) 
    local kvp = GetResourceKvpInt(name)
    if kvp ~= 0 then 
        return SetResourceKvpInt(name, value)
    else
        return false
    end
end

function SaveKVPString(name, value) 
    local kvp = GetResourceKvpString(name)
    if kvp ~= 0 then 
        return SetResourceKvpString(name, value)
    else
        return false
    end
end

function GetKVPInt(name) 
    local kvp = GetResourceKvpInt(name)
    if kvp ~= 0 then 
        return kvp
    else
        return false
    end
end

function GetKVPString(name) 
    local kvp = GetResourceKvpString(name)
    if kvp ~= 0 then 
        return kvp
    else
        return false
    end
end