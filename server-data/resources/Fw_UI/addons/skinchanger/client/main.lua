local skinCam = nil

-- ==========================================
-- OUVERTURE DU SKINCHANGER
-- ==========================================
_Fw.onReceive('skinchanger:init', function(gender)
    local ped = PlayerPedId()
    
    -- Application du ped de base selon le sexe choisi dans l'identité
    local model = gender == "m" and `mp_m_freemode_01` or `mp_f_freemode_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    ped = PlayerPedId() -- Maj du ped après changement de model
    
    -- Positionnement pour la création
    SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
    SetEntityHeading(ped, 330.0)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, true, false)

    -- Création de la caméra Face
    local coords = GetEntityCoords(ped)
    skinCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(skinCam, coords.x - 0.5, coords.y + 1.5, coords.z + 0.6)
    PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + 0.6)
    SetCamActive(skinCam, true)
    RenderScriptCams(true, false, 0, true, true)

    Wait(500)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openSkinChanger",
        gender = gender == "m" and "male" or "female"
    })
end)

-- ==========================================
-- CALLBACKS NUI (Prévisualisation & Caméra)
-- ==========================================
RegisterNUICallback('updateSkinPreview', function(data, cb)
    local ped = PlayerPedId()
    -- Component : 0 = Tête, 2 = Cheveux, 3 = Bras, 4 = Pantalon, 6 = Chaussures, 11 = Torse
    SetPedComponentVariation(ped, data.component, data.drawable, data.texture, 2)
    cb('ok')
end)

RegisterNUICallback('changeSkinCam', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    if data.camType == 'head' then
        SetCamCoord(skinCam, coords.x - 0.5, coords.y + 1.5, coords.z + 0.6)
        PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + 0.6)
    elseif data.camType == 'body' then
        SetCamCoord(skinCam, coords.x - 0.8, coords.y + 2.0, coords.z + 0.2)
        PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + 0.2)
    elseif data.camType == 'legs' then
        SetCamCoord(skinCam, coords.x - 0.8, coords.y + 2.0, coords.z - 0.5)
        PointCamAtCoord(skinCam, coords.x, coords.y, coords.z - 0.5)
    end
    cb('ok')
end)

-- ==========================================
-- FIN DE CRÉATION ET SAUVEGARDE
-- ==========================================
RegisterNUICallback('saveSkinFinal', function(data, cb)
    SetNuiFocus(false, false)
    
    -- Destruction de la caméra
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(skinCam, false)
    skinCam = nil

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)

    -- Envoi au serveur pour sauvegarde SQL
    _Fw.toServer('skinchanger:saveFinalSkin', data.skin)
    cb('ok')
end)