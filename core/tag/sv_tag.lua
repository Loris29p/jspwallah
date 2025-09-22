function ReturnUsername(src)
    if not src or not GetPlayerId(tonumber(src)) then
        return "Unknown Player"
    end
    
    local username = GetPlayerId(tonumber(src)).username
    return username
end

exports("ReturnUsername", ReturnUsername)