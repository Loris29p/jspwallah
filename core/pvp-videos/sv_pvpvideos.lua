ActualScaleform = {}

_RegisterServerEvent("pvpvideos:loadVideosEveryone", function(tblData)
    local intSource = source 
    local vidId = tblData.videoId
    local vidPos = tblData.pos
    if GetPlayerId(intSource).role ~= "vip" or GetPlayerId(intSource).role ~= "vip+" or GetPlayerId(intSource).role ~= "mvp" or GetPlayerId(intSource).role ~= "god" then return end
    _TriggerClientEvent("pvp-videos:loadVideosYoutube", -1, vidPos, vidId)
    ActualScaleform = {pos = vidPos, videoId = vidId, source = intSource}
end)

_RegisterServerEvent("pvpvideos:unloadVideosEveryone", function()
    _TriggerClientEvent("pvp-videos:unloadVideosYoutube", -1)
    ActualScaleform = {}
end)

_RegisterServerEvent("pvpvideos:GetActualScaleform", function()
    if ActualScaleform.pos == nil then return end
    _TriggerClientEvent("pvp-videos:loadVideosYoutube", source, ActualScaleform.pos, ActualScaleform.videoId)
end)

RegisterCommand("force_delete_yt", function(source, args)
    if GetPlayerId(source).role ~= "vip" or GetPlayerId(source).role ~= "vip+" or GetPlayerId(source).role ~= "mvp" or GetPlayerId(source).role ~= "god" then return end
    if PlayersIsOnline(ActualScaleform.author) then 
        return 
    else
        _TriggerClientEvent("pvp-videos:unloadVideosYoutube", -1)
        ActualScaleform = {}
    end
end)