-- Fw_UI/addons/skinchanger/client/receiver.lua
local isSkinChangerOpen = false
local skinCam = nil

-- Commande Dev Admin pour le futur (S'ouvre sur place, sans TP)
RegisterCommand('devskin', function()
    -- Paramètres: Sexe 'm', isNewCharacter = false
    _Fw.toInternal('skinchanger:init', 'm', false) 
end, false)

_Fw.onReceive('skinchanger:init', function(sex, isNewCharacter)
    if isSkinChangerOpen then return end
    isSkinChangerOpen = true

    local ped = PlayerPedId()

    -- Si c'est une création, on force le ped de base
    if isNewCharacter then
        local model = (sex == "m" or sex == "M") and `mp_m_freemode_01` or `mp_f_freemode_01`
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        
        ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
        SetEntityHeading(ped, 330.0)
    end

    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, true, false)

    -- Caméra dynamique (s'adapte à la position actuelle du joueur)
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    
    skinCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    -- Place la caméra devant le joueur
    SetCamCoord(skinCam, coords.x + (forward.x * 1.5), coords.y + (forward.y * 1.5), coords.z + 0.6)
    PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + 0.6)
    SetCamActive(skinCam, true)
    RenderScriptCams(true, false, 0, true, true)

    Wait(400)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openSkinChanger",
        gender = (sex == "m" or sex == "M") and "male" or "female",
        isNewCharacter = isNewCharacter -- On passe la variable au NUI
    })
end)

RegisterNUICallback('updateSkinPreview', function(data, cb)
    SetPedComponentVariation(PlayerPedId(), data.component, data.drawable, data.texture, 2)
    cb('ok')
end)

RegisterNUICallback('changeSkinCam', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local camX = coords.x + (forward.x * 1.5)
    local camY = coords.y + (forward.y * 1.5)

    if data.camType == 'head' then
        SetCamCoord(skinCam, camX, camY, coords.z + 0.6)
        PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + 0.6)
    elseif data.camType == 'body' then
        SetCamCoord(skinCam, camX, camY, coords.z + 0.2)
        PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + 0.2)
    elseif data.camType == 'legs' then
        SetCamCoord(skinCam, camX, camY, coords.z - 0.4)
        PointCamAtCoord(skinCam, coords.x, coords.y, coords.z - 0.4)
    end
    cb('ok')
end)

RegisterNUICallback('saveSkinFinal', function(data, cb)
    SetNuiFocus(false, false)
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(skinCam, false)
    skinCam = nil

    local ped = PlayerPedId()
    
    -- Si c'est un admin, on le défreeze de suite. 
    -- Si création, le spawn final le fera.
    if not data.isNewCharacter then
        FreezeEntityPosition(ped, false)
    end

    isSkinChangerOpen = false
    -- On transmet isNewCharacter au serveur pour qu'il sache quoi faire ensuite
    _Fw.toServer('skinchanger:saveFinalSkin', data.skin, data.isNewCharacter)
    cb('ok')
end)