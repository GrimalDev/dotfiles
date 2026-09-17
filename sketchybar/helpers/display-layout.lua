local M = {}

function M.is_portrait(display)
  local angle = (display.rotation or 0) % 180
  return math.abs(angle - 90) < 1
end

function M.select(displays, portrait)
  local selected, indices = {}, {}
  for _, display in ipairs(displays) do
    if M.is_portrait(display) == portrait then
      selected[#selected + 1] = display
      indices[#indices + 1] = tostring(display.index)
    end
  end
  return selected, table.concat(indices, ",")
end

-- Geometry is reported in points, so Retina scaling does not require conversion.
function M.profile(displays, side_height)
  local notch_height, notch_width = 0, 0
  for _, display in ipairs(displays) do
    if (display.builtin == true or display.builtin == 1) and display.notch_height > 0 then
      notch_height = math.max(notch_height, display.notch_height)
      notch_width = math.max(notch_width, display.notch_width)
    end
  end
  local top = notch_height > 0 or (#displays > 0 and M.is_portrait(displays[1]))
  local top_height = notch_height > 0 and notch_height or 32
  return {
    position = top and "top" or "left",
    height = top and top_height or side_height,
    notch_display_height = top and notch_height or 0,
    notch_width = top and math.ceil(notch_width + 16) or 200,
    notch_offset = 0,
    y_offset = 0,
    -- Stay above app windows while allowing the native menu to open above us.
    topmost = top and "window" or false,
  }
end

local function monitor_pattern(name)
  local escaped = name:gsub('([\\%.%^%$%|%?%*%+%(%)%{%}%[%]])', '\\%1')
  return string.format('%q', '^' .. escaped .. '$')
end

function M.gaps(displays, side_height)
  local landscape = M.select(displays, false)
  local landscape_profile = M.profile(landscape, side_height)
  local left, top = {}, {}
  for _, display in ipairs(displays) do
    local profile = M.is_portrait(display) and M.profile({ display }, side_height) or landscape_profile
    local left_gap = profile.position == "left" and side_height + 5 or 5
    local top_gap = profile.position == "top" and 5 + math.max(0, math.ceil(profile.height - display.reserved_top)) or 5
    local key = '{ monitor.' .. monitor_pattern(display.name) .. ' = '
    left[#left + 1] = key .. left_gap .. ' }'
    top[#top + 1] = key .. top_gap .. ' }'
  end
  left[#left + 1], top[#top + 1] = '5', '5'
  return 'outer.left = [' .. table.concat(left, ', ') .. ']\nouter.top = [' .. table.concat(top, ', ') .. ']'
end

-- Only rewrite the explicitly managed gap block; retain every other config byte.
function M.replace_gaps(config, gaps)
  local begin_marker = '# BEGIN SKETCHYBAR DISPLAY GAPS'
  local end_marker = '# END SKETCHYBAR DISPLAY GAPS'
  local first, first_end = config:find(begin_marker, 1, true)
  local last = first_end and config:find(end_marker, first_end + 1, true)
  if not first or not last then return nil end
  return config:sub(1, first_end) .. '\n' .. gaps .. '\n' .. config:sub(last)
end

return M
