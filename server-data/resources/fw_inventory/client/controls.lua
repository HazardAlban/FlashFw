-- ============================================================
--  fw_inventory | client/controls.lua
--  Gestion des touches et contrôles in-game
-- ============================================================

-- ─────────────────────────────────────────────
--  DÉSACTIVER LES CONTRÔLES QUAND L'INV EST OUVERT
-- ─────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(0)
        if InventoryOpen then
            -- Bloquer tous les mouvements
            DisableAllControlActions(0)
            -- Permettre les clics souris pour l'UI
            EnableControlAction(0, 1, true)   -- LookLeftRight
            EnableControlAction(0, 2, true)   -- LookUpDown
            EnableControlAction(0, 142, true) -- MeleeAttackAlternate (pour NUI)
            EnableControlAction(0, 18, true)  -- Enter (pour NUI)
            EnableControlAction(0, 322, true) -- ESC
        end
    end
end)

-- ─────────────────────────────────────────────
--  TOUCHE F2 POUR OUVRIR/FERMER L'INVENTAIRE
-- ─────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, Config.OpenKey) and not InventoryOpen then
            print('fw_inventory:openRequest')
            TriggerEvent('fw_inventory:openRequest')
        end
    end
end)

-- ─────────────────────────────────────────────
--  HOTBAR — TOUCHES 1-5
-- ─────────────────────────────────────────────
local hotbarKeys = {
    [0] = 157, -- 1
    [1] = 158, -- 2
    [2] = 160, -- 3
    [3] = 164, -- 4
    [4] = 165, -- 5
}

CreateThread(function()
    while true do
        Wait(0)
        if not InventoryOpen then
            for hotbarIndex, control in pairs(hotbarKeys) do
                if IsControlJustReleased(0, control) then
                    TriggerEvent('fw_inventory:hotbarUse', hotbarIndex)
                end
            end
        end
    end
end)
