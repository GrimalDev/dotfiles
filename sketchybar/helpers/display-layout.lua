local M = {}

-- Geometry is reported in points, so Retina scaling does not require conversion.
function M.profile(displays, side_height)
  local notch_height, notch_width = 0, 0
  for _, display in ipairs(displays) do
    if (display.builtin == true or display.builtin == 1) and display.notch_height > 0 then
      notch_height = math.max(notch_height, display.notch_height)
      notch_width = math.max(notch_width, display.notch_width)
    end
  end
  local top = notch_height > 0
  return {
    position = top and "top" or "left",
    height = top and notch_height or side_height,
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

function M.gaps(displays, profile)
  if profile.position == "left" then
    return 'outer.left = [{ monitor.main = 55 }, 5]\nouter.top = 5'
  end
  local rules = {}
  for _, display in ipairs(displays) do
    -- macOS already excludes the notch/menu strip from the usable frame.
    local gap = 5 + math.max(0, math.ceil(profile.height - display.reserved_top))
    rules[#rules + 1] = '{ monitor.' .. monitor_pattern(display.name) .. ' = ' .. gap .. ' }'
  end
  rules[#rules + 1] = '5'
  return 'outer.left = 5\nouter.top = [' .. table.concat(rules, ', ') .. ']'
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
