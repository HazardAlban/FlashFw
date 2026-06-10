local isCreatorOpen = false
local identityCam = nil

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

    -- 1. Chargement instantané du Ped Homme de base
    local model = `mp_m_freemode_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
    SetEntityHeading(ped, 330.0)
    FreezeEntityPosition(ped, true)
    
    -- 2. FORCE LE JOUEUR TORSE NU / EN CALEÇON DIRECTEMENT
    SetPedComponentVariation(ped, 3, 15, 0, 2)   -- Bras nus
    SetPedComponentVariation(ped, 4, 61, 0, 2)   -- Caleçon / Slip de bain
    SetPedComponentVariation(ped, 6, 34, 0, 2)   -- Pieds nus / Tongs simples
    SetPedComponentVariation(ped, 8, 15, 0, 2)   -- Pas de sous-pull
    SetPedComponentVariation(ped, 11, 15, 0, 2)  -- Torse nu (Pas de veste)

    -- Le Ped apparaît INSTANTANÉMENT devant l'écran
    SetEntityVisible(ped, true, false)
    DoScreenFadeIn(500)

    -- Caméra studio fixe face au joueur pendant qu'il écrit son identité
    local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
    identityCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(identityCam, coords.x + (forward.x * 1.4), coords.y + (forward.y * 1.4), coords.z + 0.6)
    PointCamAtCoord(identityCam, coords.x, coords.y, coords.z + 0.6)
    SetCamActive(identityCam, true)
    RenderScriptCams(true, false, 0, true, true)

    Wait(500)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openCreatorIdentity" })
end)

RegisterNUICallback('submitCharacterIdentity', function(data, cb)
    SetNuiFocus(false, false)
    
    if identityCam then
        DestroyCam(identityCam, false)
        identityCam = nil
    end

    TriggerServerEvent('creator:registerIdentity', data)
    cb('ok')
end)

RegisterNetEvent('creator:finishSpawn')
AddEventHandler('creator:finishSpawn', function()
    local ped = PlayerPedId()
    RenderScriptCams(false, true, 500, true, true)
    FreezeEntityPosition(ped, false)
    isCreatorOpen = false 
    _Fw.log("Création validée, le joueur spawn en ville.")
end)