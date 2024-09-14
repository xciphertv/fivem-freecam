-- Utility function to copy a table
function table.copy(x)
  if type(x) ~= 'table' then return x end -- Early exit if not a table
  local copy = {}
  for k, v in pairs(x) do
      copy[k] = type(v) == 'table' and table.copy(v) or v -- Recursive copy for tables
  end
  return copy
end

-- Protects a table by throwing errors on unsupported keys
function protect(t)
  local fn = function(_, k)
      error('Key `' .. tostring(k) .. '` is not supported.')
  end
  return setmetatable(t, { __index = fn, __newindex = fn })
end

-- Create a metatable that switches between keyboard and gamepad controls
function CreateGamepadMetatable(keyboard, gamepad)
  return setmetatable({}, {
      __index = function(_, k)
          local src = IsGamepadControl() and gamepad or keyboard
          return src[k]
      end
  })
end

-- Clamps a value between a minimum and maximum
function Clamp(x, min, max)
  return math.min(math.max(x, min), max)
end

-- Clamps camera rotation to specified limits
function ClampCameraRotation(rotX, rotY, rotZ)
  return Clamp(rotX, -90.0, 90.0), rotY % 360, rotZ % 360
end

-- Checks if the game is using a gamepad
function IsGamepadControl()
  return not IsInputDisabled(2)
end

-- Get normalized control input for both bound and unbound controls
local function GetControlNormal(isUnbound, control)
  if type(control) == 'table' then
      local normal1 = isUnbound and GetDisabledControlUnboundNormal(0, control[1]) or GetDisabledControlNormal(0, control[1])
      local normal2 = isUnbound and GetDisabledControlUnboundNormal(0, control[2]) or GetDisabledControlNormal(0, control[2])
      return normal1 - normal2
  end
  return isUnbound and GetDisabledControlUnboundNormal(0, control) or GetDisabledControlNormal(0, control)
end

function GetNormalizedControlNormal(control)
  return GetControlNormal(false, control)
end

function GetNormalizedControlUnboundNormal(control)
  return GetControlNormal(true, control)
end

-- Converts Euler angles to a rotation matrix
function EulerToMatrix(rotX, rotY, rotZ)
  local radX, radY, radZ = math.rad(rotX), math.rad(rotY), math.rad(rotZ)

  local sinX, cosX = math.sin(radX), math.cos(radX)
  local sinY, cosY = math.sin(radY), math.cos(radY)
  local sinZ, cosZ = math.sin(radZ), math.cos(radZ)

  -- Precompute the vectors
  local vecX = vector3(cosY * cosZ, cosY * sinZ, -sinY)
  local vecY = vector3(cosZ * sinX * sinY - cosX * sinZ, cosX * cosZ - sinX * sinY * sinZ, cosY * sinX)
  local vecZ = vector3(-cosX * cosZ * sinY + sinX * sinZ, -cosZ * sinX + cosX * sinY * sinZ, cosX * cosY)

  return vecX, vecY, vecZ
end
