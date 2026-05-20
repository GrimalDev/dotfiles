local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
	sticky = true,
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
