
local controlsEnabled = true

local function createControlsDisabler()
    controlsEnabled = false
    CreateThread(function()
        while (not (controlsEnabled)) do
            Wait(1)
            DisableAllControlActions(0)
            DisableAllControlActions(1)
        end
    end)
end

_Fw.Client_Utils.controls_disable = function()
    if (not (controlsEnabled)) then
        return
    end
    createControlsDisabler()
end

_Fw.Client_Utils.controls_getCamDirection = function()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
    local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

    if len ~= 0 then
        coords = coords / len
    end

    return coords
end