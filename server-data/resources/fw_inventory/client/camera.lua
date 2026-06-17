-- ============================================================
--  fw_inventory | client/camera.lua
--  Caméra lors de l'ouverture de l'inventaire
-- ============================================================

InvCamera = {}

local cam         = nil
local defaultFov  = 45.0

-- ─────────────────────────────────────────────
--  CRÉER LA CAMÉRA (vue légèrement en face du joueur)
-- ─────────────────────────────────────────────
function InvCamera.Create()
    if cam then InvCamera.Destroy() end

    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local heading   = GetEntityHeading(playerPed)

    -- Position en face du joueur (légèrement surélevée)
    local rad   = math.rad(heading)
    local camX  = coords.x + math.sin(rad) * 2.0
    local camY  = coords.y - math.cos(rad) * 2.0
    local camZ  = coords.z + 0.3

    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, camX, camY, camZ)
    SetCamRot(cam, -5.0, 0.0, heading + 180.0)
    SetCamFov(cam, defaultFov)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, false)
end

-- ─────────────────────────────────────────────
--  DÉTRUIRE LA CAMÉRA
-- ─────────────────────────────────────────────
function InvCamera.Destroy()
    if cam then
        RenderScriptCams(false, true, 500, true, false)
        SetCamActive(cam, false)
        DestroyCam(cam, false)
        cam = nil
    end
end

-- ─────────────────────────────────────────────
--  ZOOM IN (focus visage)
-- ─────────────────────────────────────────────
function InvCamera.ZoomFace()
    if not cam then return end
    SetCamFov(cam, 25.0)
    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local heading   = GetEntityHeading(playerPed)
    local rad       = math.rad(heading)
    SetCamCoord(cam, coords.x + math.sin(rad) * 1.2, coords.y - math.cos(rad) * 1.2, coords.z + 0.6)
end

-- ─────────────────────────────────────────────
--  ZOOM OUT (corps entier)
-- ─────────────────────────────────────────────
function InvCamera.ZoomFull()
    if not cam then return end
    SetCamFov(cam, defaultFov)
    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local heading   = GetEntityHeading(playerPed)
    local rad       = math.rad(heading)
    SetCamCoord(cam, coords.x + math.sin(rad) * 2.0, coords.y - math.cos(rad) * 2.0, coords.z + 0.3)
end
