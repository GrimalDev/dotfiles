local font_settings = {
	family = "Jetbrainsmono Nerd Font",
	size = 14.0,
	style_map = {
		["Regular"] = "Regular",
		["Semibold"] = "Medium",
		["Bold"] = "Bold",
		["Heavy"] = "Bold",
		["Black"] = "ExtraBold",
	},
}

return {
	display = 1,
	paddings = 2,
	group_paddings = 10,
	aerospace_padding = 3,
	corner_radius = 0,
	bar = {
		height = 50,
	},
	y_offset = 0,

	-- Apple Menu Config
	app = {
		offset = {
			y = 60,
			x = 5,
		},
		corner_radius = 2,
		font = {
			text = {
				family = font_settings.family,
				size = font_settings.size,
			},
			numbers = {
				family = font_settings.family,
				size = font_settings.size,
			},
			icons = font_settings.family,
			style_map = font_settings.style_map,
			overrides = {
				TimeView = {
					family = font_settings.family,
					size = 2.0,
				},
			},
		},
	},
	icons = font_settings.family,
	animated_icons = false, -- Set to true if you want to use animated icons

	font = {
		text = font_settings.family,
		numbers = font_settings.family,
		icons = font_settings.family,
		style_map = font_settings.style_map,
	},
}
