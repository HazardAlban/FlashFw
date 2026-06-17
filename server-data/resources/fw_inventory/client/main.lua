-- ============================================================
--  fw_inventory | client/main.lua
--  Point d'entrée client — gestion UI, drops, véhicules
-- ============================================================

InventoryOpen    = false
CurrentInventory = nil
CurrentContext   = nil
CurrentDrops     = {}
HotbarData       = {}

-- ─────────────────────────────────────────────
--  OUVRIR L'INVENTAIRE
-- ─────────────────────────────────────────────
AddEventHandler('fw_inventory:openRequest', function()
    if InventoryOpen then return end

    -- Détecter contexte : en voiture ou à pied
    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, false)
    local contextData = nil

    if vehicle ~= 0 then
        -- Dans un véhicule → boîte à gants
        local vehPlate = GetVehicleNumberPlateText(vehicle)
        local vehId    = vehPlate:gsub('%s+', '')
        contextData    = { type = 'glovebox', vehicleId = vehId }
    else
        -- À pied → chercher un drop proche
        local closestDrop = GetClosestDrop()
        if closestDrop then
            contextData = { type = 'drop', dropId = closestDrop.id }
        end
    end

    TriggerServerEvent('fw_inventory:open', contextData)
end)

-- ─────────────────────────────────────────────
--  RÉCEPTION DES DONNÉES (ouverture UI)
-- ─────────────────────────────────────────────
RegisterNetEvent('fw_inventory:openUI', function(data)
    if InventoryOpen then return end
    InventoryOpen = true

    CurrentInventory = data.player
    CurrentContext   = data.context
    CurrentDrops     = data.allDrops or {}
    HotbarData       = data.hotbarData or {}

    -- Ped preview
    PedPreview.toggle(true)

    -- Envoyer données à l'UI NUI
    SendNUIMessage({
        action  = 'openInventory',
        player  = data.player,
        context = data.context,
        hotbarSlots = data.hotbarSlots or 5,
        items   = GetItemsData(),    -- catalogue complet des items
    })

    SetNuiFocus(true, true)
end)

-- ─────────────────────────────────────────────
--  FERMER L'INVENTAIRE
-- ─────────────────────────────────────────────
RegisterNUICallback('close', function(data, cb)
    CloseInventory()
    cb('ok')
end)

function CloseInventory()
    if not InventoryOpen then return end
    InventoryOpen    = false
    CurrentInventory = nil
    CurrentContext   = nil

    SetNuiFocus(false, false)
    PedPreview.toggle(false)

    SendNUIMessage({ action = 'closeInventory' })
    TriggerServerEvent('fw_inventory:close')
end

-- ─────────────────────────────────────────────
--  DRAG & DROP — DÉPLACER UN ITEM
-- ─────────────────────────────────────────────
RegisterNUICallback('moveItem', function(data, cb)
    TriggerServerEvent('fw_inventory:moveItem', data)
    cb('ok')
end)

-- ─────────────────────────────────────────────
--  JETER UN ITEM
-- ─────────────────────────────────────────────
RegisterNUICallback('dropItem', function(data, cb)
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('fw_inventory:dropItem', data.slot, data.amount, {
        x = coords.x, y = coords.y, z = coords.z
    })
    cb('ok')
end)

-- ─────────────────────────────────────────────
--  UTILISER UN ITEM
-- ─────────────────────────────────────────────
RegisterNUICallback('useItem', function(data, cb)
    TriggerServerEvent('fw_inventory:useItem', data.slot)
    cb('ok')
end)

-- ─────────────────────────────────────────────
--  DONNER UN ITEM
-- ─────────────────────────────────────────────
RegisterNUICallback('giveItem', function(data, cb)
    -- Chercher joueur le plus proche
    local targetId = GetClosestPlayer()
    if not targetId then
        cb({ error = 'Aucun joueur proche.' })
        return
    end
    TriggerServerEvent('fw_inventory:giveItem', data.slot, data.amount, targetId)
    cb('ok')
end)

-- ─────────────────────────────────────────────
--  RAMASSER UN ITEM DU SOL
-- ─────────────────────────────────────────────
RegisterNUICallback('pickupDrop', function(data, cb)
    TriggerServerEvent('fw_inventory:pickupDrop', data.dropId, data.slot, data.amount)
    cb('ok')
end)

-- ─────────────────────────────────────────────
--  SYNC INVENTAIRE JOUEUR (depuis serveur)
-- ─────────────────────────────────────────────
RegisterNetEvent('fw_inventory:syncPlayer', function(slots, weight)
    if CurrentInventory then
        CurrentInventory.slots  = slots
        CurrentInventory.weight = weight
    end
    if InventoryOpen then
        SendNUIMessage({ action = 'syncPlayer', slots = slots, weight = weight })
    end
end)

-- ─────────────────────────────────────────────
--  SYNC CONTEXTE (drop / glovebox)
-- ─────────────────────────────────────────────
RegisterNetEvent('fw_inventory:syncContext', function(slots)
    if InventoryOpen then
        SendNUIMessage({ action = 'syncContext', slots = slots })
    end
end)

-- ─────────────────────────────────────────────
--  REFRESH COMPLET
-- ─────────────────────────────────────────────
RegisterNetEvent('fw_inventory:refreshInventory', function()
    if InventoryOpen then
        TriggerEvent('fw_inventory:openRequest')
    end
end)

-- ─────────────────────────────────────────────
--  DROPS — SPAWN ET MISE À JOUR
-- ─────────────────────────────────────────────
RegisterNetEvent('fw_inventory:spawnDrop', function(dropId, items, coords)
    CurrentDrops[dropId] = { id = dropId, items = items, coords = coords }
    -- Afficher marqueur / blip si proche
end)

RegisterNetEvent('fw_inventory:updateDrop', function(dropId, items)
    if not items or next(items) == nil then
        CurrentDrops[dropId] = nil
    else
        if CurrentDrops[dropId] then
            CurrentDrops[dropId].items = items
        end
    end
    if InventoryOpen then
        SendNUIMessage({ action = 'syncContext', slots = items })
    end
end)

-- ─────────────────────────────────────────────
--  ARMES — ÉQUIPER
-- ─────────────────────────────────────────────
RegisterNetEvent('fw_inventory:equipWeapon', function(weaponName, weaponHash, ammo, metadata)
    local playerPed = PlayerPedId()
    GiveWeaponToPed(playerPed, weaponHash, ammo, false, true)
    SetCurrentPedWeapon(playerPed, weaponHash, true)

    -- Usure : si durabilité faible, dégrader visuellement
    if metadata and metadata.durability then
        -- Rien de natif pour l'usure visuelle, géré côté UI
    end

    -- Sync munitions à chaque tir
    CreateThread(function()
        local lastAmmo = ammo
        while InventoryOpen == false do -- Thread actif même hors inventaire
            Wait(500)
            local currentAmmo = GetAmmoInPedWeapon(PlayerPedId(), weaponHash)
            if currentAmmo ~= lastAmmo then
                -- Détection du tir
                if currentAmmo < lastAmmo then
                    TriggerServerEvent('fw_inventory:weaponShot')
                end
                TriggerServerEvent('fw_inventory:syncAmmo', metadata.slot or 0, currentAmmo)
                lastAmmo = currentAmmo
            end
        end
    end)
end)

RegisterNetEvent('fw_inventory:unequipWeapon', function()
    RemoveAllPedWeapons(PlayerPedId(), true)
end)

RegisterNetEvent('fw_inventory:weaponBroken', function(weaponName)
    local hash = joaat(weaponName)
    RemoveWeaponFromPed(PlayerPedId(), hash)
end)

-- ─────────────────────────────────────────────
--  SOINS (depuis item médical)
-- ─────────────────────────────────────────────
RegisterNetEvent('fw_inventory:heal', function(amount)
    local playerPed  = PlayerPedId()
    local currentHp  = GetEntityHealth(playerPed)
    local newHp      = math.min(200, currentHp + amount)
    SetEntityHealth(playerPed, newHp)
end)

-- ─────────────────────────────────────────────
--  NOTIFICATIONS
-- ─────────────────────────────────────────────
RegisterNetEvent('fw_inventory:notify', function(data)
    SendNUIMessage({ action = 'notify', data = data })
end)

-- ─────────────────────────────────────────────
--  HOTBAR — UTILISER UN ITEM DEPUIS LA TOUCHE
-- ─────────────────────────────────────────────
AddEventHandler('fw_inventory:hotbarUse', function(hotbarIndex)
    local slot = HotbarData[hotbarIndex + 1]
    if slot and slot.name then
        TriggerServerEvent('fw_inventory:useItem', slot.playerSlot)
    end
end)

-- ─────────────────────────────────────────────
--  HOTBAR — MISE À JOUR DEPUIS UI
-- ─────────────────────────────────────────────
RegisterNUICallback('setHotbar', function(data, cb)
    HotbarData = data.hotbar or {}
    cb('ok')
end)

-- ─────────────────────────────────────────────
--  UTILITAIRE : trouver le drop le plus proche
-- ─────────────────────────────────────────────
function GetClosestDrop()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closest      = nil
    local closestDist  = Config.PickupDistance

    for dropId, drop in pairs(CurrentDrops) do
        if drop.coords then
            local dropCoords = vector3(drop.coords.x, drop.coords.y, drop.coords.z)
            local dist       = #(playerCoords - dropCoords)
            if dist < closestDist then
                closestDist = dist
                closest     = drop
            end
        end
    end

    return closest
end

-- ─────────────────────────────────────────────
--  UTILITAIRE : trouver le joueur le plus proche
-- ─────────────────────────────────────────────
function GetClosestPlayer()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestId    = nil
    local closestDist  = 5.0

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local ped    = GetPlayerPed(playerId)
            local coords = GetEntityCoords(ped)
            local dist   = #(playerCoords - coords)
            if dist < closestDist then
                closestDist = dist
                closestId   = GetPlayerServerId(playerId)
            end
        end
    end

    return closestId
end

-- ─────────────────────────────────────────────
--  UTILITAIRE : catalogue items pour l'UI
-- ─────────────────────────────────────────────
function GetItemsData()
    local data = {}
    for name, item in pairs(Items) do
        data[name] = {
            label       = item.label,
            weight      = item.weight,
            stack       = item.stack,
            usable      = item.usable,
            type        = item.type,
            durability  = item.durability,
            description = item.description,
            image       = item.image,
        }
    end
    return data
end

-- ─────────────────────────────────────────────
--  MARKERS AU SOL POUR LES DROPS
-- ─────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for dropId, drop in pairs(CurrentDrops) do
            if drop.coords then
                local dropCoords = vector3(drop.coords.x, drop.coords.y, drop.coords.z)
                local dist       = #(playerCoords - dropCoords)

                if dist < 20.0 then
                    -- Marqueur petit cercle vert
                    DrawMarker(
                        1,
                        dropCoords.x, dropCoords.y, dropCoords.z - 0.1,
                        0, 0, 0,
                        0, 0, 0,
                        0.3, 0.3, 0.1,
                        27, 171, 113, 180,
                        false, true, 2, false, nil, nil, false
                    )

                    if dist < Config.PickupDistance then
                        -- Texte d'aide
                        DrawText3D(dropCoords.x, dropCoords.y, dropCoords.z + 0.3, '~g~[F2]~w~ Inventaire')
                    end
                end
            end
        end
    end
end)

-- ─────────────────────────────────────────────
--  HELPER DrawText3D
-- ─────────────────────────────────────────────
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry('STRING')
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
