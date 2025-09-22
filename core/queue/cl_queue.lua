Queue = {}
Queue.InFile = false
Queue.Type = ""

function Queue:Join(type)
    Queue.InFile = true
    Queue.Type = type

    Tse("queue:joinQueue", type)

    ShowAboveRadarMessage("You join the Queue.~s~\n/leave to leave")
    Citizen.CreateThread(function()
        while Queue.InFile do

            print(Queue.Type)
            local isFinish = CallbackServer("queue:searchPlayer", Queue.Type)
        
            if isFinish then
                Queue.InFile = false
            end

            Citizen.Wait(4*1000)
        end 
    end)

    ShowLoadingPrompt("Looking for match", 2)
end

function Queue:Quit(type)
    Tse("queue:quitQueue", type)
    RemoveLoadingPrompt()
    ShowAboveRadarMessage("~r~You quit the Queue")
end


_RegisterNetEvent("queue:resetFile")
_AddEventHandler("queue:resetFile", function()
    Queue.InFile = false
end)

_RegisterNetEvent("zoliax:queueStart")
_AddEventHandler("zoliax:queueStart", function(place, data) 
    if data ~= nil then
        if data.gamemode == "" then return end
        if data.gamemode == "1vs1tricks" then 

        end
    end
end)

RegisterNUICallback("selectGamemode", function(data)
    return ShowAboveRadarMessage("~r~This option is not available yet.")
    -- if data.gamemodeItem == "1v1 Tricks" then
    --     Queue:Join("1vs1tricks")
    -- end
end)