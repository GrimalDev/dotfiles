return {
	-- Basic colors
	black = 0xff181926,
	white = 0xffcad3f5,
	red = 0xffed8796,
	green = 0xffa6da95,
	blue = 0xff8aadf4,
	yellow = 0xffeed49f,
	orange = 0xfff5a97f,
	magenta = 0xffc6a0f6,
	grey = 0xff939ab7,
	transparent = 0x00000000,

	-- Bar specific colors
	bar = {
		bg = 0xb72b3339,
		border = 0xff2b3339,
	},
	popup = {
		bg = 0x2d353b3a,
		border = 0xffcad3f5,
	},
	bg1 = 0x903c3e4f,
	bg2 = 0x85928964,

	-- shadow = 0xff181926,
	-- icon = 0xffcad3f5,
	-- label = 0xffcad3f5,

	-- Helper function to apply alpha to colors
	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		-- Extract the RGB components (last 6 hex digits)
		local rgb = color % 0x1000000
		-- Calculate the alpha value (0-255)
		local a = math.floor(alpha * 255.0)
		-- Combine alpha and RGB
		return rgb + (a * 0x1000000)
	end,
}
