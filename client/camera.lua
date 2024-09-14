local _internal_camera = nil
local _internal_isFrozen = false

local _internal_pos = nil
local _internal_rot = nil
local _internal_fov = nil
local _internal_vecX = nil
local _internal_vecY = nil
local _internal_vecZ = nil

--------------------------------------------------------------------------------

-- Retrieve initial camera position, keeping the existing one if required by settings
function GetInitialCameraPosition()
    if _G.CAMERA_SETTINGS.KEEP_POSITION and _internal_pos then
        return _internal_pos
    end
    return GetGameplayCamCoord()
end

-- Retrieve initial camera rotation, keeping the existing one if required by settings
function GetInitialCameraRotation()
    if _G.CAMERA_SETTINGS.KEEP_ROTATION and _internal_rot then
        return _internal_rot
    end
    local rot = GetGameplayCamRot()
    return vector3(rot.x, 0.0, rot.z)
end

--------------------------------------------------------------------------------

-- Check if the freecam is frozen
function IsFreecamFrozen()
    return _internal_isFrozen
end

-- Freeze or unfreeze the freecam
function SetFreecamFrozen(frozen)
    _internal_isFrozen = frozen == true -- Ensure boolean value
end

--------------------------------------------------------------------------------

-- Get the current position of the freecam
function GetFreecamPosition()
    return _internal_pos
end

-- Set a new position for the freecam and update necessary components
function SetFreecamPosition(x, y, z)
    local pos = vector3(x, y, z)
    LoadInterior(GetInteriorAtCoords(pos)) -- Load interior at the new position

    SetFocusArea(pos) -- Focus camera area
    LockMinimapPosition(x, y) -- Lock minimap
    SetCamCoord(_internal_camera, pos) -- Update the camera position

    _internal_pos = pos
end

--------------------------------------------------------------------------------

-- Get the current rotation of the freecam
function GetFreecamRotation()
    return _internal_rot
end

-- Set a new rotation for the freecam and update camera direction
function SetFreecamRotation(x, y, z)
    local rotX, rotY, rotZ = ClampCameraRotation(x, y, z)
    local vecX, vecY, vecZ = EulerToMatrix(rotX, rotY, rotZ)
    local rot = vector3(rotX, rotY, rotZ)

    LockMinimapAngle(math.floor(rotZ)) -- Lock minimap angle
    SetCamRot(_internal_camera, rot) -- Update camera rotation

    -- Store internal rotation and vectors
    _internal_rot  = rot
    _internal_vecX = vecX
    _internal_vecY = vecY
    _internal_vecZ = vecZ
end

--------------------------------------------------------------------------------

-- Get the current field of view (FOV) of the freecam
function GetFreecamFov()
    return _internal_fov
end

-- Set a new field of view (FOV) for the freecam
function SetFreecamFov(fov)
    _internal_fov = Clamp(fov, 0.0, 90.0)
    SetCamFov(_internal_camera, _internal_fov)
end

--------------------------------------------------------------------------------

-- Get the freecam's rotation matrix and position
function GetFreecamMatrix()
    return _internal_vecX, _internal_vecY, _internal_vecZ, _internal_pos
end

-- Get the target point in front of the freecam at a given distance
function GetFreecamTarget(distance)
    return _internal_pos + (_internal_vecY * distance)
end

--------------------------------------------------------------------------------

-- Check if the freecam is active
function IsFreecamActive()
    return IsCamActive(_internal_camera) == 1
end

-- Activate or deactivate the freecam
function SetFreecamActive(active)
    if active == IsFreecamActive() then
        return -- No change needed if already in desired state
    end

    local enableEasing = _G.CAMERA_SETTINGS.ENABLE_EASING
    local easingDuration = _G.CAMERA_SETTINGS.EASING_DURATION

    if active then
        -- Activate freecam
        _internal_camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

        -- Set initial position, rotation, and FOV
        SetFreecamFov(_G.CAMERA_SETTINGS.FOV)
        SetFreecamPosition(GetInitialCameraPosition().x, GetInitialCameraPosition().y, GetInitialCameraPosition().z)
        SetFreecamRotation(GetInitialCameraRotation().x, GetInitialCameraRotation().y, GetInitialCameraRotation().z)

        -- Trigger the event for entering freecam
        TriggerEvent('freecam:onEnter')
    else
        -- Deactivate freecam
        DestroyCam(_internal_camera)
        ClearFocus()
        UnlockMinimapPosition()
        UnlockMinimapAngle()

        -- Trigger the event for exiting freecam
        TriggerEvent('freecam:onExit')
    end

    -- Update player control and render the freecam
    SetPlayerControl(PlayerId(), not active)
    RenderScriptCams(active, enableEasing, easingDuration)
end
