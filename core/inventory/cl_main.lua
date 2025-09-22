
DisableOpeninvKey = false
RegisterKeyMapping(Config.OpenCommand, 'Open/Hide Inventory', 'keyboard', 'TAB')
RegisterCommand(Config.OpenCommand, function()

    if isOpened then inDropInventory = false end

    if not DisableOpeninvKey then 
        CommandFunction()
    else 
        return
    end
end)

Citizen.CreateThread(function()
    for i = 1, 7 do
        RegisterKeyMapping("useslot"..i, 'Use Slot #'..i, 'keyboard', i)
        RegisterCommand("useslot"..i, function()
            UseSlot(i)
        end)
    end
end)