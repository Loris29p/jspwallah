EventManagerActual = {
    Data = nil,
}

function UpdateEventManager(data)
    EventManagerActual.Data = data
    _TriggerClientEvent('EventManager:UpdateEvent', -1, EventManagerActual.Data)
end

function GetEventManagerData()
    return EventManagerActual.Data
end 

function CheckEventManagerActive()
    return EventManagerActual.Data and true or false
end

function DeleteEventManagerData()
    EventManagerActual.Data = nil
    _TriggerClientEvent('EventManager:UpdateEvent', -1, EventManagerActual.Data)
end

_RegisterServerEvent('EventManager:GetEventData', function(source)
    if not EventManagerActual.Data then return end
    if EventManagerActual.Data.id == "thanks" then  
        _TriggerClientEvent('chat:addMessage', source, { 
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 255, 34, 0.51);"><i class="fas fa-user-crown"></i> {0} </div>',
            args = { "Thanks Event is now active! /thanks to take tokens (10 minutes)" }, color = { 0, 255, 128 } 
        })
    end
    _TriggerClientEvent('EventManager:UpdateEvent', source, EventManagerActual.Data)
end)


