-- ==========================================
-- RECEPTION DE L'EVENT DU CORE (Nouveau Joueur)
-- ==========================================
_Fw.onReceive('creator:init', function()
    -- Sécurité : On attend que le jeu ait chargé le joueur local
    while not NetworkIsPlayerActive(PlayerId()) do Wait(50) end

    -- ON TUE L'ÉCRAN DE CHARGEMENT INFINI ("Awaiting scripts")
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    -- On place le joueur (Invisible et bloqué) à l'aéroport en attendant
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    DoScreenFadeIn(500)

    -- On ouvre ton menu
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openCreatorIdentity"
    })
    _Fw.log("Menu identité ouvert pour le nouveau joueur.")
end)

-- ==========================================
-- VALIDATION DU NUI ET ENVOI AU SERVEUR
-- ==========================================
RegisterNUICallback('submitCharacterIdentity', function(data, cb)
    SetNuiFocus(false, false)
    -- On envoie les infos au serveur Fw_UI pour l'insertion SQL
    _Fw.toServer('creator:registerIdentity', data)
    cb('ok')
end)

-- ==========================================
-- FIN DE LA CRÉATION -> SPAWN
-- ==========================================
_Fw.onReceive('creator:finishSpawn', function()
    -- On met un ped de base pour l'instant
    local model = `mp_m_freemode_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    -- On le rend visible et on le débloque
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)

    _Fw.log("Création terminée, le joueur a spawn.")
end)