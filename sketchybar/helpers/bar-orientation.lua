local M = { horizontal = false, displays = {} }
local listeners = {}
local signature
function M.subscribe(callback)
  listeners[#listeners + 1] = callback
  callback(M.horizontal)
end
function M.set(horizontal, displays)
  displays = displays or {}
  local parts = { tostring(horizontal) }
  for _, display in ipairs(displays) do
    parts[#parts + 1] = tostring(display.id) .. ":" .. display.width .. ":" .. display.notch_width .. ":" .. tostring(display.rotation) .. ":" .. tostring(display.index) .. ":" .. tostring(display.x)
  end
  local next_signature = table.concat(parts, ";")
  if signature == next_signature then return end
  signature = next_signature
  M.horizontal, M.displays = horizontal, displays
  for _, callback in ipairs(listeners) do callback(horizontal) end
end
return M
