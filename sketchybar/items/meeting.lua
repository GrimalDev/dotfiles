local colors = require("colors")
local settings = require("settings")

local function add_meeting_row(name, font_size, update_freq)
	return sbar.add("item", name, {
		position = "right",
		width = 16,
		update_freq = update_freq or 0,
		label = {
			drawing = false,
			align = "center",
			color = 0xffffffff,
			font = { family = settings.font.text, size = font_size },
			padding_left = 3,
			padding_right = 3,
		},
		icon = { drawing = false },
		background = { drawing = false },
		padding_left = 0,
		padding_right = 0,
	})
end

local meeting_time = add_meeting_row("meeting.time", 12.0)
local meeting_label = add_meeting_row("meeting.label", 11.0)
local meeting_next = add_meeting_row("meeting.next", 11.0)
local meeting_icon = add_meeting_row("meeting.icon", 22.0, 30)
local meeting_card = sbar.add("bracket", "meeting.card", {
	meeting_icon.name,
	meeting_next.name,
	meeting_label.name,
	meeting_time.name,
}, {
	background = {
		color = colors.bg1,
		border_color = colors.teal,
		border_width = 1,
		corner_radius = 7,
	},
	padding_left = 3,
	padding_right = 3,
})

meeting_time:set({
	popup = {
		align = "right",
		background = {
			color = colors.popup.bg,
			border_color = colors.popup.border,
			border_width = 1,
			corner_radius = 8,
			shadow = { drawing = true },
		},
	},
})

local popup_heading = sbar.add("item", "meeting.popup.heading", {
	position = "popup.meeting.time",
	icon = { string = "󰃭", color = colors.yellow, width = 24, align = "center" },
	label = { string = "UPCOMING EVENTS", align = "left", color = colors.green, width = 236, font = { size = 10.0 } },
})

local popup_events = {}
for index = 1, 5 do
	local row = sbar.add("item", "meeting.popup.event." .. index, {
		position = "popup.meeting.time",
		icon = {
			drawing = false,
			width = 54,
			align = "center",
			font = { family = settings.font.numbers, size = 11.0 },
		},
		label = {
			drawing = false,
			align = "left",
			color = 0xffffffff,
			width = 206,
			font = { family = settings.font.text, style = settings.font.style_map["Semibold"], size = 13.0 },
		},
		background = { drawing = false, color = colors.bg2, border_color = colors.bar.border, border_width = 1, height = 38, corner_radius = 6 },
	})
	table.insert(popup_events, row)
end

local white = 0xffffffff

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\\"'\\\"'") .. "'"
end

local function json_string(json, key)
	if type(json) == "table" then
		return tostring(json[key] or "")
	end
	if type(json) ~= "string" then
		return ""
	end

	local quoted_key = '"' .. key .. '"%s*:%s*"'
	local _, value_start = json:find(quoted_key)
	if not value_start then
		return ""
	end

	local value = {}
	local escaped = false
	for index = value_start + 1, #json do
		local character = json:sub(index, index)
		if escaped then
			local escapes = { n = "\n", r = "\r", t = "\t", ['"'] = '"', ["\\"] = "\\" }
			table.insert(value, escapes[character] or character)
			escaped = false
		elseif character == "\\" then
			escaped = true
		elseif character == '"' then
			return table.concat(value)
		else
			table.insert(value, character)
		end
	end

	return ""
end

local function event_epoch(timestamp, callback)
	if timestamp == "" then
		callback(nil)
		return
	end

	local normalized = timestamp:gsub("%.%d+([Z+-])", "%1"):gsub("Z$", "+0000"):gsub("([+-]%d%d):(%d%d)$", "%1%2")
	sbar.exec(
		"date -j -f " .. shell_quote("%Y-%m-%dT%H:%M:%S%z") .. " " .. shell_quote(normalized) .. " +%s",
		function(result)
			callback(tonumber(result:match("%d+")))
		end
	)
end

local function hide_meeting()
	meeting_card:set({ background = { drawing = false } })
	meeting_icon:set({ label = { drawing = false } })
	meeting_next:set({ label = { drawing = false } })
	meeting_label:set({ label = { drawing = false } })
	meeting_time:set({ label = { drawing = false } })
end

local function hide_popup_event(row)
	row:set({ icon = { drawing = false }, label = { drawing = false }, click_script = "" })
end

local function calendar_color(event)
	local calendar = type(event) == "table" and event.calendar or nil
	local hex = json_string(calendar, "color")
	if hex:match("^#%x%x%x%x%x%x$") then
		return tonumber("0xff" .. hex:sub(2))
	end
	return colors.teal
end

local function update_popup_event(row, event)
	local title = json_string(event, "title")
	if title == "" then
		hide_popup_event(row)
		return
	end

	local start = json_string(event, "startDate")
	local link = json_string(event, "meetingUrl")
	local click_script = link == "" and "" or "open " .. shell_quote(link)
	event_epoch(start, function(start_epoch)
		if not start_epoch then
			hide_popup_event(row)
			return
		end

		row:set({
			icon = {
				drawing = true,
				string = os.date("%H:%M", start_epoch),
				color = link == "" and calendar_color(event) or colors.teal,
			},
			label = { drawing = true, string = #title > 26 and title:sub(1, 25) .. "…" or title },
			background = { drawing = true },
			click_script = click_script,
		})
	end)
end

local function update_popup_events()
	sbar.exec("ical-guy events --from now --to today+2 --exclude-all-day --group-by none --limit 5 --format json", function(result)
		local events = type(result) == "table" and result or {}
		for index, row in ipairs(popup_events) do
			update_popup_event(row, events[index])
		end
	end)
end

local function set_popup_visible(visible)
	meeting_time:set({ popup = { drawing = visible } })
end

local function update_meeting()
	sbar.exec("ical-guy meeting next --format json", function(result)
		local event = type(result) == "table" and result[1] or result
		local title = json_string(event, "title")
		if title == "" then
			hide_meeting()
			return
		end

		local start = json_string(event, "startDate")
		local finish = json_string(event, "endDate")
		local link = json_string(event, "meetingUrl")
		event_epoch(start, function(start_epoch)
			if not start_epoch then
				hide_meeting()
				return
			end

			local click_script = link == "" and "" or "open " .. shell_quote(link)
			meeting_icon:set({ click_script = click_script })
			meeting_next:set({ click_script = click_script })
			meeting_label:set({ click_script = click_script })
			meeting_time:set({ click_script = click_script })
			event_epoch(finish, function(finish_epoch)
				if os.time() < start_epoch then
				meeting_card:set({ background = { drawing = true, border_color = colors.teal } })
				meeting_icon:set({ label = { drawing = true, string = "󰃭", color = colors.yellow } })
				meeting_next:set({ label = { drawing = true, string = "NEXT", color = colors.green } })
				meeting_label:set({ label = { drawing = true, string = "MEETING", color = colors.green } })
				meeting_time:set({
					label = {
						drawing = true,
						string = os.date("%H:%M", start_epoch),
						color = colors.yellow,
						},
				})
			else
				meeting_card:set({ background = { drawing = true, border_color = colors.red } })
				meeting_icon:set({ label = { drawing = true, string = "󰃭", color = colors.orange } })
				meeting_next:set({ label = { drawing = true, string = "IN", color = colors.red } })
				meeting_label:set({ label = { drawing = true, string = "MEETING", color = colors.red } })
					meeting_time:set({ label = { drawing = true, string = "NOW", color = white } })
				end
			end)
		end)
	end)
end

local hover_targets = {}
local hover_items = { meeting_icon, meeting_next, meeting_label, meeting_time, popup_heading }
for _, row in ipairs(popup_events) do
	table.insert(hover_items, row)
end

local function has_hover_target()
	for _, is_hovered in pairs(hover_targets) do
		if is_hovered then
			return true
		end
	end
	return false
end

for _, item in ipairs(hover_items) do
	item:subscribe("mouse.entered", function()
		hover_targets[item.name] = true
		set_popup_visible(true)
	end)
	item:subscribe("mouse.exited", function()
		hover_targets[item.name] = false
		sbar.delay(0.15, function()
			if not has_hover_target() then
				set_popup_visible(false)
			end
		end)
	end)
end

local function refresh_meeting()
	update_meeting()
	update_popup_events()
end

meeting_icon:subscribe({ "forced", "routine", "system_woke" }, refresh_meeting)
refresh_meeting()
