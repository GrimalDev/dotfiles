return {
	black = 0xff272E33,
	white = 0xffD3C6AA,
	red = 0xffE67E80,
	green = 0xffA7C080,
	blue = 0xff7FBBB3,
	yellow = 0xffDBBC7F,
	orange = 0xffE69875,
	magenta = 0xffD699B6,
	grey = 0xff859289,
	teal = 0xff83C092,
	transparent = 0x00000000,

	bar = {
		bg = 0xff272E33,
		border = 0xff374145,
	},
	popup = {
		bg = 0xF22E383C,
		border = 0xff859289,
		card = 0xff2E383C,
	},
	spaces = {
		active = 0xff414B50,
		inactive = 0xff374145,
	},
	bg1 = 0xff2E383C,
	bg2 = 0xff414B50,

	battery = {
		_100 = 0xffA7C080, -- #A7C080
		_75 = 0xff8BA06B, -- #8BA06B
		_50 = 0xffE6BB73, -- #E6BB73
		_25 = 0xffE69875, -- #E69875
		_10 = 0xffE67E80, -- #E67E80
	},
	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) * 16777216)
	end,
}
