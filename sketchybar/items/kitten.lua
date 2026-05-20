local kitten = sbar.add("item", "kitten", {
	position = "right",
	label = { drawing = false },
	background = {
		-- color = "0xffff0000",
		image = {
			string = "~/.config/kitty/images/kitten.png",
			scale = 0.2,
			border_width = 0,
		},
		drawing = true,
		height = 67,
	},
})

-- Track menu visibility
local menu_visible = false
local menu_process = nil

-- Functions to handle menu visibility
local function show_menu()
	if not menu_visible then
		-- Kill any existing menu process
		if menu_process then
			sbar.exec("pkill -f apple_menu")
			menu_process = nil
		end

		-- Start new menu process
		sbar.exec("~/.config/sketchybar/helpers/event_providers/apple_menu/bin/apple_menu app=menu &")
		menu_visible = true
	end
end

local function hide_menu()
	if menu_visible then
		sbar.exec("pkill -f apple_menu")
		menu_visible = false
		menu_process = nil
	end
end

-- Toggle menu on click only
kitten:subscribe("mouse.clicked", function(_)
	if menu_visible then
		hide_menu()
	else
		show_menu()
	end
end)

-- Add this to prevent window from closing when clicking inside it
kitten:subscribe("mouse.clicked.inside", function(_)
	return 1
end)

return kitten
