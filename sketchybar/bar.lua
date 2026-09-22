local colors = require("colors")
local settings = require("settings")
local layout = require("helpers.display-layout")
local orientation = require("helpers.bar-orientation")

sbar.bar({
  sticky = true,
  hidden = true, -- Do not draw on a fallback screen before the first probe.
  position = "left",
  height = settings.bar.height,
  margin = 0,
  color = colors.bar.bg,
  border_color = colors.bar.border,
  border_width = 0,
  padding_right = settings.paddings,
  padding_left = settings.paddings,
  corner_radius = 0,
  blur_radius = 0,
  y_offset = settings.y_offset,
})

local function quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end
local config_dir = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")
local command = "/bin/bash " .. quote(config_dir .. "/helpers/display-info.sh")
local busy = false
local refresh_pending = false
local previous_profile
local portrait = os.getenv("SKETCHYBAR_ROLE") == "portrait"

local function sync_gaps(displays, profile)
  sbar.exec("aerospace config --config-path", function(path, code)
    if code ~= 0 or type(path) ~= "string" then return end
    path = path:gsub("%s+$", "")
    local file = io.open(path, "r")
    if not file then return end
    local original = file:read("*a")
    file:close()
    local updated = layout.replace_gaps(original, layout.gaps(displays, settings.bar.height))
    if not updated or updated == original then return end
    -- Stage in the same directory for an atomic replacement.
    local temporary = path .. ".sketchybar.tmp"
    file = io.open(temporary, "w")
    if not file then return end
    local written = file:write(updated)
    local closed = file:close()
    if written and closed and os.rename(temporary, path) then
      sbar.exec("aerospace reload-config --no-gui")
    else
      os.remove(temporary)
    end
  end)
end

local refresh
refresh = function()
  if busy then refresh_pending = true; return end
  busy = true
  sbar.exec(command, function(displays, code)
    busy = false
    if refresh_pending then
      refresh_pending = false
      refresh()
      return -- This result may describe the display that was just removed.
    end
    -- A failed probe must not revert a working layout or rewrite window gaps.
    if code ~= 0 or type(displays) ~= "table" or #displays == 0 then return end
    local selected, indices = layout.select(displays, portrait)
    if portrait and #selected == 0 then
      sbar.bar({ hidden = true })
      sbar.exec("sketchybar --quit")
      return
    end
    local profile = layout.profile(selected, settings.bar.height)
    profile.display = indices ~= "" and indices or "main"
    profile.hidden = #selected == 0
    local signature = profile.position .. ':' .. profile.height .. ':' .. profile.notch_width .. ':' .. indices
    if signature ~= previous_profile then
      profile.padding_left = profile.position == "top" and 10 or settings.paddings
      -- Leave room for macOS privacy/recording indicators at the screen edge.
      profile.padding_right = profile.position == "top" and 32 or settings.paddings
      sbar.bar(profile)
      previous_profile = signature
    end
    orientation.set(profile.position == "top" or profile.position == "bottom", selected)
    if not portrait then
      sync_gaps(displays, profile)
      local rotated = layout.select(displays, true)
      sbar.exec("/bin/bash " .. quote(config_dir .. "/helpers/portrait-bar.sh") .. (#rotated > 0 and " start" or " stop"))
    end
  end)
end

-- The interval also catches lid closing, resolution changes and monitor removal.
local watcher = sbar.add("item", "display.layout", {
  drawing = false,
  updates = true,
  update_freq = 2,
})
watcher:subscribe({ "routine", "forced" }, refresh)
watcher:subscribe({ "display_change", "system_woke" }, function()
  -- Display indices can be reassigned on disconnect. Hide stale placement first.
  sbar.bar({ hidden = true })
  previous_profile = nil
  refresh()
end)
refresh()

if not portrait then
  watcher:subscribe("aerospace_workspace_change", function()
    sbar.exec("/bin/bash " .. quote(config_dir .. "/helpers/portrait-bar.sh") .. " trigger")
  end)
end
