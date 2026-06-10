local isSkinChangerOpen = false
local skinCam = nil

RegisterCommand('devskin', function()
    TriggerEvent('Flash:skinchanger:init', 'm', false) 
end, false)

RegisterNetEvent('Flash:skinchanger:init')
AddEventHandler('Flash:skinchanger:init', function(sex, isNewCharacter)
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
    end

    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, true, false)

    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    
    skinCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(skinCam, coords.x + (forward.x * 1.5), coords.y + (forward.y * 1.5), coords.z + 0.6)
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
    
    if not data.isNewCharacter then
        FreezeEntityPosition(ped, false)
    end

    isSkinChangerOpen = false
    -- Envoi natif
    TriggerServerEvent('Flash:skinchanger:saveFinalSkin', data.skin, data.isNewCharacter)
    cb('ok')
end)