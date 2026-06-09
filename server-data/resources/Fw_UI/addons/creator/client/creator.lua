-- Fw_UI/addons/creator/client/receiver.lua
local isCreatorOpen = false

RegisterCommand('devcreator', function()
    _Fw.toInternal('creator:init')
end, false)

_Fw.onReceive('creator:init', function()
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

    Wait(500)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openCreatorIdentity" })
end)

RegisterNUICallback('submitCharacterIdentity', function(data, cb)
    SetNuiFocus(false, false)
    _Fw.toServer('creator:registerIdentity', data)
    cb('ok')
end)

-- L'Event de libération finale après le SkinChanger
_Fw.onReceive('creator:finishSpawn', function()
    local ped = PlayerPedId()
    
    -- Le joueur devient visible et libre en ville
    SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    
    isCreatorOpen = false 
    _Fw.log("Création à 100%. Le joueur est en ville !")
end)