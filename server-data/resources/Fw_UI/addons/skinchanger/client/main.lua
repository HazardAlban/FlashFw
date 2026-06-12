local isSkinChangerOpen = false
local skinCam = nil
local camOffsetZ = 0.6
local camDist = 1.2
local fixedForward = nil 

RegisterCommand('devskin', function()
    TriggerEvent('skinchanger:init', 'm', false) 
end, false)

RegisterNetEvent('skinchanger:init')
AddEventHandler('skinchanger:init', function(sex, isNewCharacter)
    if isSkinChangerOpen then return end
    isSkinChangerOpen = true

    local ped = PlayerPedId()

    if isNewCharacter then
        local model = (sex == "m" or sex == "M") and `mp_m_freemode_01` or `mp_f_freemode_01`
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        
        ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
        SetEntityHeading(ped, 330.0)
        
        -- SÉCURITÉ ABSOLUE : INITIALISE LA TÊTE POUR QUE LE MAQUILLAGE S'AFFICHE
        SetPedHeadBlendData(ped, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.0, false)
    end

    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, true, false)

    fixedForward = GetEntityForwardVector(ped)
    camOffsetZ = 0.6
    camDist = 1.2

    local coords = GetEntityCoords(ped)
    skinCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(skinCam, coords.x + (fixedForward.x * camDist), coords.y + (fixedForward.y * camDist), coords.z + camOffsetZ)
    PointCamAtCoord(skinCam, coords.x, coords.y, coords.z + camOffsetZ)
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

local function UpdateCameraPosition()
    if not skinCam then return end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    if not fixedForward then fixedForward = GetEntityForwardVector(ped) end
    local camX = coords.x + (fixedForward.x * camDist)
    local camY = coords.y + (fixedForward.y * camDist)
    local camZ = coords.z + camOffsetZ
    SetCamCoord(skinCam, camX, camY, camZ)
    PointCamAtCoord(skinCam, coords.x, coords.y, camZ)
end

RegisterNUICallback('changeSkinCam', function(data, cb)
    if data.camType == 'head' then camOffsetZ = 0.6; camDist = 1.0
    elseif data.camType == 'eyes' then camOffsetZ = 0.65; camDist = 0.35
    elseif data.camType == 'torso' then camOffsetZ = 0.2; camDist = 1.4
    elseif data.camType == 'legs' then camOffsetZ = -0.3; camDist = 1.4
    elseif data.camType == 'feet' then camOffsetZ = -0.7; camDist = 1.0
    end
    UpdateCameraPosition()
    cb('ok')
end)

RegisterNUICallback('zoomCam', function(data, cb)
    if data.dir == 'in' then
        camDist = camDist - 0.15
        if camDist < 0.25 then camDist = 0.25 end
    else
        camDist = camDist + 0.15
        if camDist > 2.5 then camDist = 2.5 end
    end
    UpdateCameraPosition()
    cb('ok')
end)

RegisterNUICallback('rotateCam', function(data, cb)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    if data.dir == 'left' then
        SetEntityHeading(ped, heading + 15.0)
    else
        SetEntityHeading(ped, heading - 15.0)
    end
    cb('ok')
end)

RegisterNUICallback('updateSkinParents', function(data, cb)
    SetPedHeadBlendData(PlayerPedId(), tonumber(data.shapeMother), tonumber(data.shapeFather), 0, tonumber(data.skinMother), tonumber(data.skinFather), 0, tonumber(data.shapeMix) + 0.0, tonumber(data.skinMix) + 0.0, 0, false)
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
        SetPedHairColor(ped, p, s)
    elseif not data.isComponent then
        if id == 1 then SetPedHeadOverlayColor(ped, 1, 1, p, s)
        elseif id == 22 then SetPedHeadOverlayColor(ped, 2, 1, p, s)
        elseif id == 4 then SetPedHeadOverlayColor(ped, 4, 0, p, s)
        elseif id == 5 then SetPedHeadOverlayColor(ped, 5, 2, p, s)
        elseif id == 8 then SetPedHeadOverlayColor(ped, 8, 2, p, s)
        elseif id == 10 then SetPedHeadOverlayColor(ped, 10, 1, p, s)
        end
    end
    cb('ok')
end)

RegisterNUICallback('updateEyeColor', function(data, cb)
    SetPedEyeColor(PlayerPedId(), tonumber(data.value))
    cb('ok')
end)

RegisterNUICallback('applyPresetOutfit', function(data, cb)
    local ped = PlayerPedId()
    local isMale = (data.gender == "male")
    if data.style == 'basique' then
        if isMale then
            SetPedComponentVariation(ped, 3, 0, 0, 2) SetPedComponentVariation(ped, 4, 4, 0, 2)
            SetPedComponentVariation(ped, 6, 1, 0, 2) SetPedComponentVariation(ped, 11, 1, 0, 2)
        else
            SetPedComponentVariation(ped, 3, 15, 0, 2) SetPedComponentVariation(ped, 4, 4, 0, 2)
            SetPedComponentVariation(ped, 6, 1, 0, 2) SetPedComponentVariation(ped, 11, 2, 0, 2)
        end
    elseif data.style == 'classe' then
        if isMale then
            SetPedComponentVariation(ped, 3, 4, 0, 2) SetPedComponentVariation(ped, 4, 10, 0, 2)
            SetPedComponentVariation(ped, 6, 10, 0, 2) SetPedComponentVariation(ped, 11, 10, 0, 2)
        else
            SetPedComponentVariation(ped, 3, 15, 0, 2) SetPedComponentVariation(ped, 4, 6, 0, 2)
            SetPedComponentVariation(ped, 6, 6, 0, 2) SetPedComponentVariation(ped, 11, 6, 0, 2)
        end
    elseif data.style == 'rue' then
        if isMale then
            SetPedComponentVariation(ped, 3, 1, 0, 2) SetPedComponentVariation(ped, 4, 5, 2, 2)
            SetPedComponentVariation(ped, 6, 5, 0, 2) SetPedComponentVariation(ped, 11, 5, 0, 2)
        else
            SetPedComponentVariation(ped, 3, 15, 0, 2) SetPedComponentVariation(ped, 4, 5, 0, 2)
            SetPedComponentVariation(ped, 6, 5, 0, 2) SetPedComponentVariation(ped, 11, 5, 0, 2)
        end
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
