CreateThread(function()
    -- On attend que le client ait fini de charger la map et les entités
    while not NetworkIsPlayerActive(PlayerId()) do 
        Wait(50) 
    end
    TriggerServerEvent("creator:checkIdentity")
end)

