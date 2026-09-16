local colors = require("colors")
local orientation = require("helpers.bar-orientation")
local config_dir = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")
local helper = config_dir .. "/helpers/wifi-status.sh"
local command = "/bin/sh '" .. helper:gsub("'", "'\\''") .. "'"

local wifi = sbar.add("item", "wifi", {
    position = "right",
    width = 32,
    padding_left = 3,
    padding_right = 3,
    icon = {
        string = "󰖪", width = 32, align = "center", color = colors.grey,
        font = { family = "JetBrainsMono Nerd Font", size = 17.0 },
        padding_left = 0, padding_right = 0,
    },
    label = { drawing = false },
    background = { color = colors.bg1, height = 24, corner_radius = 5 },
    update_freq = 30,
    popup = { align = "right", height = 32, y_offset = 4 },
})

local function row(name, title, value)
    return sbar.add("item", name, {
        position = "popup.wifi",
        icon = { string = title, width = 76, align = "left", padding_left = 8 },
        label = { string = value, width = 148, align = "right", padding_right = 8, font = { size = 12.0 } },
        background = { drawing = false },
    })
end
local status_row = row("wifi.status", "Wi-Fi", "Checking…")
local ssid_row = row("wifi.ssid", "Network", "—")
ssid_row:set({ label = { max_chars = 20 } })
local ip_row = row("wifi.ip", "IP address", "—")
local settings_row = sbar.add("item", "wifi.settings", {
    position = "popup.wifi",
    icon = { drawing = false },
    label = { string = "Open Wi-Fi Settings…", width = 240, align = "center", color = colors.teal, font = { size = 12.0 } },
    background = { drawing = false },
})

local busy = false
local function refresh()
    if busy then return end
    busy = true
    sbar.exec(command, function(result, code)
        busy = false
        local status, ip, ssid
        if code == 0 and type(result) == "string" then
            status, ip, ssid = result:match("([^\n]+)\n([^\n]+)\n([^\n]+)")
        end
        status, ip = status or "Unavailable", ip or "—"
        local connected = status == "Connected"
        wifi:set({ icon = { string = connected and "󰖩" or "󰖪", color = connected and colors.teal or colors.grey } })
        status_row:set({ label = { string = status } })
        ip_row:set({ label = { string = ip } })
        ssid_row:set({ label = { string = ssid or "—" } })
    end)
end

wifi:subscribe({ "routine", "forced", "wifi_change", "system_woke" }, refresh)
-- Track one current target: a missed exit must not leave an older row hovered.
local hover_target
local hover_generation = 0
local function close_popup()
    hover_target = nil
    hover_generation = hover_generation + 1
    wifi:set({ popup = { drawing = false } })
end
for _, item in ipairs({ wifi, status_row, ssid_row, ip_row, settings_row }) do
    item:subscribe("mouse.entered", function()
        hover_generation = hover_generation + 1
        hover_target = item.name
        if item == wifi then
            refresh()
            wifi:set({ popup = { drawing = true } })
        end
    end)
    item:subscribe("mouse.exited", function()
        -- An old item's exit can arrive after the next item's enter.
        if hover_target ~= item.name then return end
        hover_target = nil
        hover_generation = hover_generation + 1
        local generation = hover_generation
        sbar.delay(0.2, function()
            if generation == hover_generation and not hover_target then
                close_popup()
            end
        end)
    end)
end
wifi:subscribe("mouse.exited.global", close_popup)
settings_row:subscribe("mouse.clicked", function()
    close_popup()
    sbar.exec("/usr/bin/open 'x-apple.systempreferences:com.apple.wifi-settings-extension'")
end)
orientation.subscribe(function(horizontal)
    wifi:set({ background = { height = horizontal and 24 or 25 } })
end)
refresh()
