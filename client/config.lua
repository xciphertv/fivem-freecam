-- Input Mappings
local INPUT_LOOK_LR = 1
local INPUT_LOOK_UD = 2
local INPUT_CHARACTER_WHEEL = 19
local INPUT_SPRINT = 21
local INPUT_MOVE_UD = 31
local INPUT_MOVE_LR = 30
local INPUT_VEH_ACCELERATE = 71
local INPUT_VEH_BRAKE = 72
local INPUT_PARACHUTE_BRAKE_LEFT = 152
local INPUT_PARACHUTE_BRAKE_RIGHT = 153

--------------------------------------------------------------------------------

-- Base Control Mapping (Keyboard)
local BASE_CONTROL_MAPPING = protect({
    -- Rotation
    LOOK_X = INPUT_LOOK_LR,
    LOOK_Y = INPUT_LOOK_UD,

    -- Position
    MOVE_X = INPUT_MOVE_LR,
    MOVE_Y = INPUT_MOVE_UD,
    MOVE_Z = { INPUT_PARACHUTE_BRAKE_LEFT, INPUT_PARACHUTE_BRAKE_RIGHT },

    -- Speed Multipliers
    MOVE_FAST = INPUT_SPRINT,
    MOVE_SLOW = INPUT_CHARACTER_WHEEL
})

--------------------------------------------------------------------------------

-- Base Control Settings
local BASE_CONTROL_SETTINGS = protect({
    -- Rotation sensitivity
    LOOK_SENSITIVITY_X = 5,
    LOOK_SENSITIVITY_Y = 5,

    -- Movement speed multipliers
    BASE_MOVE_MULTIPLIER = 1,
    FAST_MOVE_MULTIPLIER = 10,
    SLOW_MOVE_MULTIPLIER = 10
})

--------------------------------------------------------------------------------

-- Base Camera Settings
local BASE_CAMERA_SETTINGS = protect({
    -- Camera field of view
    FOV = 45.0,

    -- Easing settings when enabling/disabling freecam
    ENABLE_EASING = true,
    EASING_DURATION = 1000,

    -- Keep position/rotation when toggling freecam
    KEEP_POSITION = false,
    KEEP_ROTATION = false
})

--------------------------------------------------------------------------------

-- Keyboard Control Mappings (Copy of Base)
_G.KEYBOARD_CONTROL_MAPPING = table.copy(BASE_CONTROL_MAPPING)

-- Gamepad Control Mappings (Copy of Base with Customization)
_G.GAMEPAD_CONTROL_MAPPING = table.copy(BASE_CONTROL_MAPPING)

-- Customize gamepad up/down movement and speed
_G.GAMEPAD_CONTROL_MAPPING.MOVE_Z = { INPUT_PARACHUTE_BRAKE_LEFT, INPUT_PARACHUTE_BRAKE_RIGHT } -- Up/Down
_G.GAMEPAD_CONTROL_MAPPING.MOVE_FAST = INPUT_VEH_ACCELERATE -- Speed up (RT)
_G.GAMEPAD_CONTROL_MAPPING.MOVE_SLOW = INPUT_VEH_BRAKE -- Slow down (LT)

-- Protect the mappings
protect(_G.KEYBOARD_CONTROL_MAPPING)
protect(_G.GAMEPAD_CONTROL_MAPPING)

--------------------------------------------------------------------------------

-- Keyboard Control Settings (Copy of Base)
_G.KEYBOARD_CONTROL_SETTINGS = table.copy(BASE_CONTROL_SETTINGS)

-- Gamepad Control Settings (Copy of Base with Customization)
_G.GAMEPAD_CONTROL_SETTINGS = table.copy(BASE_CONTROL_SETTINGS)

-- Gamepad has lower look sensitivity
_G.GAMEPAD_CONTROL_SETTINGS.LOOK_SENSITIVITY_X = 2
_G.GAMEPAD_CONTROL_SETTINGS.LOOK_SENSITIVITY_Y = 2

-- Protect the settings
protect(_G.KEYBOARD_CONTROL_SETTINGS)
protect(_G.GAMEPAD_CONTROL_SETTINGS)

--------------------------------------------------------------------------------

-- Camera Settings (Copy of Base)
_G.CAMERA_SETTINGS = table.copy(BASE_CAMERA_SETTINGS)

-- Protect camera settings
protect(_G.CAMERA_SETTINGS)

--------------------------------------------------------------------------------

-- Create convenient metatables to automatically switch between keyboard and gamepad controls and settings
_G.CONTROL_MAPPING = CreateGamepadMetatable(_G.KEYBOARD_CONTROL_MAPPING, _G.GAMEPAD_CONTROL_MAPPING)
_G.CONTROL_SETTINGS = CreateGamepadMetatable(_G.KEYBOARD_CONTROL_SETTINGS, _G.GAMEPAD_CONTROL_SETTINGS)
