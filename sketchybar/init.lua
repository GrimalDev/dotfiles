-- Require the sketchybar module
sbar = require("sketchybar")

local portrait = os.getenv("SKETCHYBAR_ROLE") == "portrait"
if portrait then
  sbar.set_bar_name("sketchybar_portrait")
  local exec = sbar.exec
  local binary = (os.getenv("HOME") .. "/.cache/sketchybar/sketchybar_portrait")
  sbar.exec = function(command, ...)
    command = command:gsub("^sketchybar ", "'" .. binary .. "' ")
    return exec(command, ...)
  end
end

-- Bundle the entire initial configuration into a single message to sketchybar
sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()
