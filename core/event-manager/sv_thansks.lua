ThanksEventActive = false 
ThanksEventTime = 1000*60*15 -- 15 minutes 

ThanksEventPlyRegistered = {}

function OnThanks(source)
    local PLAYER_DATA <const> = GetPlayerId(source)
    if not ThanksEventActive then return _TriggerClientEvent('chat:addMessage', source, { args = { "^2Thanks Event", "There is no thanks event active" }, color = 0, 255, 128 }) end
    if ThanksEventPlyRegistered[PLAYER_DATA.uuid] then return _TriggerClientEvent('chat:addMessage', source, { args = { "^2Thanks Event", "You have already registered for the thanks event" }, color = 248, 10, 255 }) end
    ThanksEventPlyRegistered[PLAYER_DATA.uuid] = true
    if PLAYER_DATA then 
        local randomNumber = math.random(2000, 4000)
        PLAYER_DATA.AddTokens(tonumber(randomNumber))
        _TriggerClientEvent('chat:addMessage', source, { args = { "^2Thanks Event", "You have received "..randomNumber.." tokens for the thanks event" }, color = 0, 255, 128 })
    end
end


RegisterCommand("thanks", function(source, args, raw)
    OnThanks(source)
end)

Citizen.CreateThread(function()
    _TriggerClientEvent('chat:addSuggestions', -1, {
        {
            name = "/thanks",
            help = "Take tokens for the thanks event"
        }
    })
end)




function StartThanksEvent()
    ThanksEventActive = true
    ThanksEventPlyRegistered = {}
    UpdateEventManager({
        Title = "Thanks Event",
        id = "thanks",
    })
    _TriggerClientEvent('chat:addMessage', -1, { 
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 255, 34, 0.51);"><i class="fas fa-user-crown"></i> {0} </div>',
        args = { "Thanks Event is now active! /thanks to take tokens (10 minutes)" }, color = { 0, 255, 128 } 
    })
    TriggerClientEvent("kAnnounce:client:openAnnounce", -1, true, "Thanks Event", "Thanks Event is now active! /thanks to take tokens (5 minutes)", 7000)
    SetTimeout(1000*60*5, function()
        ThanksEventActive = false
        _TriggerClientEvent('chat:addMessage', -1, { 
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 255, 34, 0.51);"><i class="fas fa-user-crown"></i> {0} </div>',
            args = { "Thanks Event is now over" }, color = { 0, 255, 128 } 
        })
        DeleteEventManagerData()
    end)
end

RegisterCommand('staff_startthanks', function(source, args, raw)
    local PLAYER_DATA <const> = GetPlayerId(source)
    if PLAYER_DATA.group ~= "owner" then return end
    StartThanksEvent()
end)

Citizen.CreateThread(function()
    while true do 
        Wait(ThanksEventTime)
        StartThanksEvent()
    end
end)