local SETTINGS = _G.CONTROL_SETTINGS
local CONTROLS = _G.CONTROL_MAPPING

-------------------------------------------------------------------------------

-- Calculates the speed multiplier for camera movement
local function GetSpeedMultiplier()
    local fastNormal = GetNormalizedControlNormal(CONTROLS.MOVE_FAST)
    local slowNormal = GetNormalizedControlNormal(CONTROLS.MOVE_SLOW)

    local baseSpeed = SETTINGS.BASE_MOVE_MULTIPLIER
    local fastSpeed = 1 + (SETTINGS.FAST_MOVE_MULTIPLIER - 1) * fastNormal
    local slowSpeed = 1 + (SETTINGS.SLOW_MOVE_MULTIPLIER - 1) * slowNormal

    local frameMultiplier = GetFrameTime() * 60
    return baseSpeed * fastSpeed / slowSpeed * frameMultiplier
end

-- Updates the camera position and rotation
local function UpdateCamera()
    if not IsFreecamActive() or IsPauseMenuActive() then
        return
    end

    if not IsFreecamFrozen() then
        local vecX, vecY = GetFreecamMatrix()
        local vecZ = vector3(0, 0, 1)

        local pos = GetFreecamPosition()
        local rot = GetFreecamRotation()

        -- Get speed multiplier for movement
        local speedMultiplier = GetSpeedMultiplier()

        -- Get rotation input (look around)
        local lookX = GetNormalizedControlUnboundNormal(CONTROLS.LOOK_X)
        local lookY = GetNormalizedControlUnboundNormal(CONTROLS.LOOK_Y)

        -- Get movement input
        local moveX = GetNormalizedControlNormal(CONTROLS.MOVE_X)
        local moveY = GetNormalizedControlNormal(CONTROLS.MOVE_Y)
        local moveZ = GetNormalizedControlNormal(CONTROLS.MOVE_Z)

        -- Calculate new rotation
        local rotX = rot.x - lookY * SETTINGS.LOOK_SENSITIVITY_X
        local rotZ = rot.z - lookX * SETTINGS.LOOK_SENSITIVITY_Y
        local rotY = rot.y

        -- Adjust position relative to the camera's rotation and input
        pos = pos + (vecX * moveX * speedMultiplier)
        pos = pos + (vecY * -moveY * speedMultiplier)
        pos = pos + (vecZ * moveZ * speedMultiplier)

        -- Update camera position and rotation
        SetFreecamPosition(pos.x, pos.y, pos.z)
        SetFreecamRotation(rotX, rotY, rotZ)
    end

    -- Trigger a tick event for any resources relying on freecam position updates
    TriggerEvent('freecam:onTick')
end

-------------------------------------------------------------------------------

-- Main update thread that continuously updates the camera
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- No delay for real-time updates
        UpdateCamera()
    end
end)

-------------------------------------------------------------------------------

-- When the resource is stopped, disable the freecam
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetFreecamActive(false)
    end
end)
