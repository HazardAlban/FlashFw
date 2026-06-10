local isCreatorOpen = false

RegisterCommand('devcreator', function()
    TriggerEvent('creator:init')
end, false)

RegisterNetEvent('creator:init')
AddEventHandler('creator:init', function()
    if isCreatorOpen then return end
    isCreatorOpen = true

    while not NetworkIsPlayerActive(PlayerId()) do Wait(50) end

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    DoScreenFadeIn(500)

    Wait(100)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openCreatorIdentity" })
end)

RegisterNUICallback('submitCharacterIdentity', function(data, cb)
    SetNuiFocus(false, false)
    -- Envoi natif au serveur
    TriggerServerEvent('creator:registerIdentity', data)
    cb('ok')
end)

RegisterNetEvent('creator:finishSpawn')
AddEventHandler('creator:finishSpawn', function()
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    
    isCreatorOpen = false 
    _Fw.log("Création à 100%. Le joueur est en ville !")
end)