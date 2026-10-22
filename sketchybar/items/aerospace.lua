local colors = require("colors")
local settings = require("settings")
local spaces = {}
local busy = false

local function refresh()
  if busy then return end
  busy = true
  sbar.exec("aerospace list-monitors --format '%{monitor-id}|%{monitor-appkit-nsscreen-screens-id}'", function(output, code)
    if code ~= 0 or type(output) ~= "string" then busy = false; return end
    local displays = {}
    for monitor, display in output:gmatch("(%d+)|(%d+)") do
      displays[tonumber(monitor)] = tonumber(display)
    end
    if next(displays) == nil then busy = false; return end
    sbar.exec("aerospace list-workspaces --all --format '%{workspace}%{monitor-id}' --json", function(workspaces, status)
      if status ~= 0 or type(workspaces) ~= "table" or #workspaces == 0 then busy = false; return end
      sbar.exec("aerospace list-workspaces --monitor all --visible", function(output, status)
        busy = false
        if status ~= 0 or type(output) ~= "string" then return end
        local visible = {}
        for name in output:gmatch("[^\r\n]+") do visible[name] = true end
        local present, order = {}, {}
        table.sort(workspaces, function(a, b) return a.workspace < b.workspace end)
        for _, workspace in ipairs(workspaces) do
          local name = workspace.workspace
          local label = name:match("[^/]+$") or name
          local number = tonumber(label)
          local display = displays[workspace["monitor-id"]]
          if number and number >= 1 and number <= 10 and label:match("^%d+$") and display then
            present[name] = true
            local entry = spaces[name]
            if not entry then
              local item = sbar.add("item", "space." .. name, {
                icon = { drawing = false },
                label = {
                  drawing = true, string = label,
                  font = { style = settings.font.style_map["SemiBold"], size = 12.0 },
                  padding_right = 10, padding_left = 10,
                },
                padding_right = 0, padding_left = 0,
                background = { border_width = 0, height = 26 },
              })
              local padding = sbar.add("item", "space.padding." .. name, {
                icon = { drawing = false }, label = { drawing = false },
                background = { drawing = false }, width = settings.aerospace_padding,
              })
              item:subscribe("mouse.clicked", function()
                sbar.exec("aerospace workspace '" .. name:gsub("'", "'\\''") .. "'")
              end)
              entry = { item = item, padding = padding }
              spaces[name] = entry
            end
            entry.item:set({
              drawing = true, associated_display = display,
              label = { color = visible[name] and colors.black or colors.white },
              background = { color = visible[name] and colors.spaces.active or colors.bg1 },
            })
            entry.padding:set({ drawing = true, associated_display = display })
            table.insert(order, { name = name, number = number })
          end
        end
        for name, entry in pairs(spaces) do
          if not present[name] then
            entry.item:set({ drawing = false })
            entry.padding:set({ drawing = false })
          end
        end
        table.sort(order, function(a, b)
          if a.number == b.number then return a.name < b.name end
          return a.number < b.number
        end)
        local names = {}
        for _, entry in ipairs(order) do
          table.insert(names, spaces[entry.name].item.name)
          table.insert(names, spaces[entry.name].padding.name)
        end
        if #names > 0 then sbar.exec("sketchybar --reorder " .. table.concat(names, " ")) end
      end)
    end)
  end)
end

-- Retry after startup failures, and refresh assignments after monitor changes.
local watcher = sbar.add("item", "aerospace.refresh", {
  drawing = false, updates = true, update_freq = 5,
})
watcher:subscribe({ "routine", "forced", "aerospace_workspace_change", "display_change", "system_woke" }, refresh)
refresh()
