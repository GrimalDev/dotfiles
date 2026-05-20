local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "battery", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
		},
		padding_right = 0,
	},
	label = {
		font = {
			family = settings.font.numbers,
		},
	},
	background = {
		color = colors.transparent,
		border_width = 0,
		corner_radius = 5,
		height = 25,
	},
	update_freq = 180,
	popup = { align = "right" },
})

local remaining_time = sbar.add("item", {
	position = "popup." .. battery.name,
	icon = {
		string = "Time remaining:",
		width = 100,
		align = "left",
	},
	label = {
		string = "??:??h",
		width = 100,
		align = "right",
	},
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local label = "?"

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local color = colors.teal
		local charging, _, _ = batt_info:find("AC Power")

		if charging then
			icon = icons.lightning.charging
		else
			if found and charge > 80 then
				icon = icons.lightning.battery
				color = colors.battery._100
			elseif found and charge > 60 then
				icon = icons.lightning.battery
				color = colors.battery._75
			elseif found and charge > 40 then
				icon = icons.lightning.battery
				color = colors.battery._50
			elseif found and charge > 20 then
				icon = icons.lightning.battery
				color = colors.battery._25
			elseif found and charge < 10 then
				icon = icons.lightning.battery
				color = colors.battery._10
			else
				icon = icons.lightning.battery
				color = colors.battery._10
			end
		end

		battery:set({
			icon = {
				string = icon,
				color = color,
			},
			label = { string = label },
		})
	end)
end)

battery:subscribe("mouse.clicked", function(_)
	local drawing = battery:query().popup.drawing
	battery:set({ popup = { drawing = "toggle" } })

	if drawing == "off" then
		sbar.exec("pmset -g batt", function(batt_info)
			local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
			local label = found and remaining .. "h" or "No estimate"
			remaining_time:set({ label = label })
		end)
	end
end)

sbar.add("bracket", "battery.bracket", { battery.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "battery.padding", {
	position = "right",
	width = settings.group_paddings,
})
