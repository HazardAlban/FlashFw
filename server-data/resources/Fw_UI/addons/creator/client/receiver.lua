

_Fw.onReceiveWithoutNet("creator:init", function(_src)
    print("1")
end)
_Fw.onReceive("creator:init", function(_src)
    print("3")
end)
_Fw.onReceiveWithoutNetExposed("creator:init", function(_src)
    print("2")
end)

-- Fw_UI/src/client/creator.lua

RegisterCommand('testcreator', function()
    -- On utilise ton toInternal !
    _Fw.toInternal('Fw_UI:client:openIdentityMenu')
end, false)

-- On utilise ton onReceive personnalisé !
_Fw.onReceive('Fw_UI:client:openIdentityMenu', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openCreatorIdentity"
    })
end)

RegisterNUICallback('submitCharacterIdentity', function(data, cb)
    SetNuiFocus(false, false)
    
    -- J'imagine que tu as codé un _Fw.toServer dans ton client/main.lua
    -- Sinon, remplace par TriggerServerEvent
    _Fw.toServer('Fw_UI:server:registerNewCharacter', data)
    
    cb('ok')
end)