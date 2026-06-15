local multicharCam = nil

RegisterNetEvent('multichar:open')
AddEventHandler('multichar:open', function(characters, maxSlots)
    -- 1. FORCE LA FERMETURE DE L'ÉCRAN DE CHARGEMENT FIVEM
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeOut(0)

    -- 2. CHARGEMENT DU PED PAR DÉFAUT
    local model = `mp_m_freemode_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
    SetEntityHeading(ped, 330.0)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, true, false)
    SetPedHeadBlendData(ped, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.0, false)

    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    
    multicharCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(multicharCam, coords.x + (forward.x * 1.4), coords.y + (forward.y * 1.4), coords.z + 0.6)
    PointCamAtCoord(multicharCam, coords.x, coords.y, coords.z + 0.2)
    SetCamActive(multicharCam, true)
    RenderScriptCams(true, false, 0, true, true)

    DoScreenFadeIn(500)
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "openMultichar",
        characters = characters,
        maxSlots = maxSlots or 4
    })
end)

RegisterNUICallback('previewCharacter', function(data, cb)
    -- Sécurisation du tostring pour empêcher le crash de concaténation de nil
    print("Preview du personnage ID : " .. tostring(data.id or "Inconnu"))
    
    local ped = PlayerPedId()
    local model = (data.sex == 'm' or data.sex == 'M') and `mp_m_freemode_01` or `mp_f_freemode_01`
    
    if GetEntityModel(ped) ~= model then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        ped = PlayerPedId()
        SetEntityHeading(ped, 330.0)
    end

    if data.skin and data.skin ~= "" and data.skin ~= "null" then
        local skin = json.decode(data.skin)
        if skin then
            if skin.genetic then
                SetPedHeadBlendData(ped, skin.genetic.shapeMother or 0, skin.genetic.shapeFather or 0, 0, skin.genetic.skinMother or 0, skin.genetic.skinFather or 0, 0, (skin.genetic.shapeMix or 0.5) + 0.0, (skin.genetic.skinMix or 0.5) + 0.0, 0, false)
            end
            if skin.features then
                for k, v in pairs(skin.features) do SetPedFaceFeature(ped, tonumber(k), tonumber(v) + 0.0) end
            end
            if skin.overlays then
                for k, v in pairs(skin.overlays) do
                    local id = tonumber(k)
                    if id == 2 then SetPedComponentVariation(ped, 2, tonumber(v.val), 0, 2)
                    else SetPedHeadOverlay(ped, id, tonumber(v.val), tonumber(v.op) + 0.0) end
                end
            end
            if skin.colors then
                for k, v in pairs(skin.colors) do
                    local id = tonumber(k)
                    if id == 'eye' then SetPedEyeColor(ped, tonumber(v))
                    elseif id == 2 then SetPedHairColor(ped, tonumber(v.primary), tonumber(v.secondary))
                    elseif id == 1 then SetPedHeadOverlayColor(ped, 1, 1, tonumber(v.primary), tonumber(v.secondary))
                    elseif id == 22 then SetPedHeadOverlayColor(ped, 2, 1, tonumber(v.primary), tonumber(v.secondary))
                    elseif id == 4 then SetPedHeadOverlayColor(ped, 4, 0, tonumber(v.primary), tonumber(v.secondary))
                    elseif id == 5 then SetPedHeadOverlayColor(ped, 5, 2, tonumber(v.primary), tonumber(v.secondary))
                    elseif id == 8 then SetPedHeadOverlayColor(ped, 8, 2, tonumber(v.primary), tonumber(v.secondary))
                    elseif id == 10 then SetPedHeadOverlayColor(ped, 10, 1, tonumber(v.primary), tonumber(v.secondary))
                    end
                end
            end
        end
    else
        SetPedComponentVariation(ped, 3, 15, 0, 2)
        SetPedComponentVariation(ped, 4, (data.sex == 'm' or data.sex == 'M') and 61 or 15, 0, 2)
        SetPedComponentVariation(ped, 6, 34, 0, 2)
        SetPedComponentVariation(ped, 8, 15, 0, 2)
        SetPedComponentVariation(ped, 11, 15, 0, 2)
    end

    cb('ok')
end)

RegisterNUICallback('createNewCharacter', function(data, cb)
    SendNUIMessage({ action = "closeMultichar" })
    TriggerEvent('creator:init') 
    cb('ok')
end)

RegisterNUICallback('playCharacter', function(data, cb)
    SetNuiFocus(false, false)
    RenderScriptCams(false, true, 500, true, true)
    if multicharCam then DestroyCam(multicharCam, false) end
    FreezeEntityPosition(PlayerPedId(), false)
    print("Spawn du personnage ID : " .. data.id)
    cb('ok')
end)