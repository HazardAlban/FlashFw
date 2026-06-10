local isSkinChangerOpen = false
local skinCam = nil

RegisterNetEvent('skinchanger:init')
AddEventHandler('skinchanger:init', function(sex, isNewCharacter)
    if isSkinChangerOpen then return end
    isSkinChangerOpen = true

    local ped = PlayerPedId()

    -- Ajustement du sexe si le joueur a choisi "Femme" (f) dans l'identité
    if isNewCharacter and (sex == "f" or sex == "F") then
        local model = `mp_f_freemode_01`
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        
        ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
        SetEntityHeading(ped, 330.0)
        -- Sous-vêtements Femme de base
        SetPedComponentVariation(ped, 3, 15, 0, 2)
        SetPedComponentVariation(ped, 4, 15, 0, 2)
        SetPedComponentVariation(ped, 11, 15, 0, 2)
    end

    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, true, false)

    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    
    skinCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(skinCam, coords.x + (forward.x * 1.4), coords.y + (forward.y * 1.4), coords.z + 0.6)
    PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + 0.6)
    SetCamActive(skinCam, true)
    RenderScriptCams(true, false, 0, true, true)

    Wait(400)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openSkinChanger",
        gender = (sex == "m" or sex == "M") and "male" or "female",
        isNewCharacter = isNewCharacter
    })
end)

-- ==========================================
-- CALLBACKS NUI (Mise à jour en temps réel)
-- ==========================================

-- ==========================================
-- CALLBACKS NUI (Mise à jour en direct)
-- ==========================================

RegisterNUICallback('updateSkinParents', function(data, cb)
    -- + 0.0 convertit le nombre entier reçu du JS en Float pour la native Lua
    SetPedHeadBlendData(PlayerPedId(), data.shapeMother, data.shapeFather, 0, data.skinMother, data.skinFather, 0, tonumber(data.shapeMix) + 0.0, tonumber(data.skinMix) + 0.0, 0, false)
    cb('ok')
end)

RegisterNUICallback('updateFaceFeature', function(data, cb)
    SetPedFaceFeature(PlayerPedId(), tonumber(data.index), tonumber(data.value) + 0.0)
    cb('ok')
end)

RegisterNUICallback('updateHeadOverlay', function(data, cb)
    local ped = PlayerPedId()
    if data.isComponent then
        SetPedComponentVariation(ped, tonumber(data.id), tonumber(data.value), 0, 2)
    else
        SetPedHeadOverlay(ped, tonumber(data.id), tonumber(data.value), tonumber(data.opacity) + 0.0)
    end
    cb('ok')
end)

RegisterNUICallback('updateSkinColor', function(data, cb)
    local ped = PlayerPedId()
    local id = tonumber(data.id)
    local p = tonumber(data.primary)
    local s = tonumber(data.secondary)

    if data.isComponent and id == 2 then 
        SetPedHairColor(ped, p, s) -- Cheveux
    elseif not data.isComponent then
        if id == 1 then SetPedHeadOverlayColor(ped, 1, 1, p, s)
        elseif id == 22 then SetPedHeadOverlayColor(ped, 2, 1, p, s)
        elseif id == 4 then SetPedHeadOverlayColor(ped, 4, 0, p, s)
        elseif id == 5 then SetPedHeadOverlayColor(ped, 5, 2, p, s)
        elseif id == 8 then SetPedHeadOverlayColor(ped, 8, 2, p, s)
        elseif id == 10 then SetPedHeadOverlayColor(ped, 10, 1, p, s) -- Pilosité Torse
        end
    end
    cb('ok')
end)


-- CALLBACK 5 : Application des 3 Tenues de départ pré-définies (Sans personnalisation)
RegisterNUICallback('applyPresetOutfit', function(data, cb)
    local ped = PlayerPedId()
    local isMale = (data.gender == "male")

    if data.style == 'basique' then
        if isMale then
            SetPedComponentVariation(ped, 3, 0, 0, 2)   -- Bras
            SetPedComponentVariation(ped, 4, 4, 0, 2)   -- Jean
            SetPedComponentVariation(ped, 6, 1, 0, 2)   -- Baskets
            SetPedComponentVariation(ped, 11, 1, 0, 2)  -- T-shirt Blanc
        else
            SetPedComponentVariation(ped, 3, 15, 0, 2)
            SetPedComponentVariation(ped, 4, 4, 0, 2)
            SetPedComponentVariation(ped, 6, 1, 0, 2)
            SetPedComponentVariation(ped, 11, 2, 0, 2)
        end
    elseif data.style == 'classe' then
        if isMale then
            SetPedComponentVariation(ped, 3, 4, 0, 2)
            SetPedComponentVariation(ped, 4, 10, 0, 2)  -- Pantalon de costume
            SetPedComponentVariation(ped, 6, 10, 0, 2)  -- Souliers noirs
            SetPedComponentVariation(ped, 11, 10, 0, 2) -- Veste + Chemise
        else
            SetPedComponentVariation(ped, 3, 15, 0, 2)
            SetPedComponentVariation(ped, 4, 6, 0, 2)
            SetPedComponentVariation(ped, 6, 6, 0, 2)
            SetPedComponentVariation(ped, 11, 6, 0, 2)
        end
    elseif data.style == 'rue' then
        if isMale then
            SetPedComponentVariation(ped, 3, 1, 0, 2)
            SetPedComponentVariation(ped, 4, 5, 2, 2)   -- Jogging
            SetPedComponentVariation(ped, 6, 5, 0, 2)   -- Sneakers montantes
            SetPedComponentVariation(ped, 11, 5, 0, 2)  -- Hoodie / Sweat à capuche
        else
            SetPedComponentVariation(ped, 3, 15, 0, 2)
            SetPedComponentVariation(ped, 4, 5, 0, 2)
            SetPedComponentVariation(ped, 6, 5, 0, 2)
            SetPedComponentVariation(ped, 11, 5, 0, 2)
        end
    end
    cb('ok')
end)

RegisterNUICallback('changeSkinCam', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local camX = coords.x + (forward.x * 1.4)
    local camY = coords.y + (forward.y * 1.4)

    if data.camType == 'head' then
        SetCamCoord(skinCam, camX, camY, coords.z + 0.6)
        PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + 0.6)
    elseif data.camType == 'body' then
        SetCamCoord(skinCam, camX, camY, coords.z + 0.1)
        PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + 0.1)
    end
    cb('ok')
end)

RegisterNUICallback('saveSkinFinal', function(data, cb)
    SetNuiFocus(false, false)
    if skinCam then DestroyCam(skinCam, false) skinCam = nil end
    isSkinChangerOpen = false
    TriggerServerEvent('skinchanger:saveFinalSkin', data.skin, data.isNewCharacter)
    cb('ok')
end)


RegisterNUICallback('updateEyeColor', function(data, cb)
    SetPedEyeColor(PlayerPedId(), tonumber(data.value))
    cb('ok')
end)

RegisterNUICallback('rotateCam', function(data, cb)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    
    -- Tourne le personnage de 20 degrés vers la gauche ou la droite
    if data.dir == 'left' then
        SetEntityHeading(ped, heading + 20.0)
    else
        SetEntityHeading(ped, heading - 20.0)
    end
    cb('ok')
end)