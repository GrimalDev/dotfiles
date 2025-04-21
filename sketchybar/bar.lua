local colors = require("colors")

-- Equivalent to the --bar domain
return function(sbar)
	sbar.bar({
		height = 40,
		color = colors.bar.bg,
		shadow = true,
		position = "top",
		sticky = true,
		padding_right = 10,
		padding_left = 10,
		blur_radius = 20,
		topmost = "window",
		-- padding_right = 2,
		-- padding_left = 2,
		-- padding_top = 2,
		-- padding_bottom = 2,
		-- corner_radius = 9,
		-- y_offset = 6,
		-- margin = 5,
		-- blur_radius = 20,
		-- notch_width = 0,
	})
end
