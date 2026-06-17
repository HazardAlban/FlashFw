-- ============================================================
--  fw_inventory | client/ped_preview.lua
--  Gestion du ped de prévisualisation dans le menu pause
--  Adapté du ped_preview.lua fourni
-- ============================================================

PedPreview = {
    ped          = nil,
    enabled      = true,
    updateQueued = false,
}

-- ─────────────────────────────────────────────
--  HEAD BLEND DATA
-- ─────────────────────────────────────────────
function PedPreview.getHeadBlendData(ped)
    local data = {
        Citizen.InvokeNative(
            0x2746BD9D88C5C5D0,
            ped,
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueFloatInitialized(0),
            Citizen.PointerValueFloatInitialized(0),
            Citizen.PointerValueFloatInitialized(0)
        )
    }
    return {
        shapeFirst  = data[1], shapeSecond = data[2], shapeThird  = data[3],
        skinFirst   = data[4], skinSecond  = data[5], skinThird   = data[6],
        shapeMix    = data[7], skinMix     = data[8], thirdMix    = data[9],
    }
end

-- ─────────────────────────────────────────────
--  MISE À JOUR DU PED (sync avec le joueur réel)
-- ─────────────────────────────────────────────
function PedPreview.update()
    if not PedPreview.ped or not DoesEntityExist(PedPreview.ped) then return end

    local playerPed     = PlayerPedId()
    local headBlendData = PedPreview.getHeadBlendData(playerPed)

    SetPedHeadBlendData(
        PedPreview.ped,
        headBlendData.shapeFirst,  headBlendData.shapeSecond, headBlendData.shapeThird,
        headBlendData.skinFirst,   headBlendData.skinSecond,  headBlendData.skinThird,
        headBlendData.shapeMix,    headBlendData.skinMix,     headBlendData.thirdMix,
        false
    )

    for i = 0, 19 do
        SetPedFaceFeature(PedPreview.ped, i, GetPedFaceFeature(playerPed, i))
    end

    for componentId = 0, 11 do
        SetPedComponentVariation(
            PedPreview.ped, componentId,
            GetPedDrawableVariation(playerPed, componentId),
            GetPedTextureVariation(playerPed, componentId),
            GetPedPaletteVariation(playerPed, componentId)
        )
    end

    for propId = 0, 7 do
        local propIndex = GetPedPropIndex(playerPed, propId)
        if propIndex ~= -1 then
            SetPedPropIndex(PedPreview.ped, propId, propIndex, GetPedPropTextureIndex(playerPed, propId), true)
        else
            ClearPedProp(PedPreview.ped, propId)
        end
    end
end

-- ─────────────────────────────────────────────
--  MISE À JOUR DIFFÉRÉE (évite les doubles appels)
-- ─────────────────────────────────────────────
function PedPreview.queueUpdate()
    if PedPreview.updateQueued then return end
    PedPreview.updateQueued = true
    CreateThread(function()
        Wait(100)
        PedPreview.update()
        PedPreview.updateQueued = false
    end)
end

-- ─────────────────────────────────────────────
--  TOGGLE : show/hide le ped dans le menu pause
-- ─────────────────────────────────────────────
function PedPreview.toggle(show)
    if not PedPreview.enabled then return end
    if show and PedPreview.ped then return end

    local menuName = "FE_MENU_VERSION_EMPTY_NO_BACKGROUND"

    if show then
        SetFrontendActive(true)

        local currentMenu = GetCurrentFrontendMenuVersion()
        if currentMenu ~= joaat(menuName) then
            ActivateFrontendMenu(GetHashKey(menuName), false, -1)
            Wait(100)
        end

        SetMouseCursorVisible(false)

        local playerPed = PlayerPedId()
        PedPreview.ped  = ClonePed(playerPed, false, false, false)

        local coords = GetEntityCoords(playerPed)
        SetEntityCoords(PedPreview.ped, coords.x, coords.y, coords.z - 1.0)
        SetEntityCollision(PedPreview.ped, false, false)
        SetEntityAsMissionEntity(PedPreview.ped, true, true)
        SetBlockingOfNonTemporaryEvents(PedPreview.ped, true)
        SetEntityInvincible(PedPreview.ped, true)
        ReplaceHudColourWithRgba(117, 0, 0, 0, 0)
        FreezeEntityPosition(PedPreview.ped, true)
        SetPedCombatAbility(PedPreview.ped, 0)
        N_0x4668d80430d6c299(PedPreview.ped)

        GivePedToPauseMenu(PedPreview.ped, 1)
        SetPauseMenuPedLighting(true)
        SetPauseMenuPedSleepState(1)
        SetMouseCursorVisible(false)

        -- Thread pour maintenir le curseur invisible
        CreateThread(function()
            while PedPreview.ped do
                Wait(1)
                SetMouseCursorVisible(false)
            end
        end)

        Wait(200)
        PedPreview.update()

    else
        if PedPreview.ped then
            SetPauseMenuPedLighting(false)
            SetFrontendActive(false)
            SetPauseMenuPedSleepState(false)
            GivePedToPauseMenu(PedPreview.ped, 0)

            if DoesEntityExist(PedPreview.ped) then
                DeletePed(PedPreview.ped)
            end
            PedPreview.ped = nil

            local currentMenu = GetCurrentFrontendMenuVersion()
            if currentMenu == joaat(menuName) then
                ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_EMPTY_NO_BACKGROUND"), true, -1)
            end

            ReplaceHudColourWithRgba(117, 0, 0, 0, 200)
        end
    end
end
