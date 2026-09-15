-- Add the sketchybar module to the package cpath
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

local helpers = (os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")) .. "/helpers"

local helper_binaries = {
  "event_providers/cpu_load/bin/cpu_load",
  "event_providers/memory_load/bin/memory_load",
  "event_providers/hdd_load/bin/hdd_load",
  "event_providers/network_load/bin/network_load",
  "menus/bin/menus",
}

local function helpers_are_built()
  for _, relative in ipairs(helper_binaries) do
    local handle = io.open(helpers .. "/" .. relative, "r")
    if not handle then
      return false
    end
    handle:close()
  end
  return true
end

if not helpers_are_built() then
  os.execute("(cd '" .. helpers .. "' && make)")
end
