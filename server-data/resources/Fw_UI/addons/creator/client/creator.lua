-- Fw_UI/addons/creator/client/receiver.lua

-- ========================================================
-- BOUCLE DE LANCEMENT AUTOMATIQUE (Connexion & Restarts)
-- ========================================================
CreateThread(function()
    -- On attend que le joueur soit chargé par FiveM
    while not NetworkIsPlayerActive(PlayerId()) do 
        Wait(50) 
    end

    -- Petit temps d'attente pour laisser le NUI respirer au restart
    Wait(500)

    -- LA MAGIE EST ICI : Appel interne pour lancer la création immédiatement
    _Fw.toInternal('creator:init')
    _Fw.log("Auto-lancement de la création de personnage réussi (Restart/Initial).")
end)


-- ========================================================
-- RECEPTION DE L'EVENT (Déclenché par le serveur ou le thread ci-dessus)
-- ========================================================
_Fw.onReceive('creator:init', function()
    -- ON TUE L'ÉCRAN DE CHARGEMENT INFINI ("Awaiting scripts")
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    -- On place le joueur (Invisible et bloqué) à l'aéroport en attendant
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, -1042.48, -2745.57, 21.36, false, false, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    DoScreenFadeIn(500)

    -- On ouvre ton menu NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openCreatorIdentity"
    })
    _Fw.log("Menu identité ouvert avec succès.")
end)

-- ========================================================
-- VALIDATION DU FORMULAIRE NUI
-- ========================================================
RegisterNUICallback('submitCharacterIdentity', function(data, cb)
    SetNuiFocus(false, false)
    -- Envoi sécurisé au serveur de Fw_UI pour l'insertion OxMySQL
    _Fw.toServer('creator:registerIdentity', data)
    cb('ok')
end)

-- ========================================================
-- FIN DE LA CRÉATION -> SPAWN DEFINITIF
-- ========================================================
_Fw.onReceive('creator:finishSpawn', function()
    local ped = PlayerPedId()
    
    -- Le joueur redevient visible et libre de ses mouvements
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    
    -- On lui applique un ped de base pour l'instant
    local model = `mp_m_freemode_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    _Fw.log("Le joueur a spawn définitivement.")
end)