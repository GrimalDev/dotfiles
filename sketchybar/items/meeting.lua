local colors = require("colors")
local settings = require("settings")
local orientation = require("helpers.bar-orientation")

-- Launch agents may have a smaller PATH than an interactive shell.
local calendar_command = "ical-guy"
for _, path in ipairs({ "/opt/homebrew/bin/ical-guy", "/usr/local/bin/ical-guy", os.getenv("HOME") .. "/.local/bin/ical-guy" }) do
    local file = io.open(path, "r")
    if file then
        file:close()
        calendar_command = "'" .. path:gsub("'", "'\\''") .. "'"
        break
    end
end

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

local meeting_spacer = sbar.add("item", "meeting.centering", {
    position = "e", width = 0, drawing = false,
    icon = { drawing = false }, label = { drawing = false },
    background = { drawing = false }, padding_left = 0, padding_right = 0,
})
local spacer_width = 0

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

local function has_notch()
    for _, display in ipairs(orientation.displays) do
        if display.notch_height > 0 then return true end
    end
    return false
end

local function center_meeting()
    if not orientation.horizontal or not has_notch() then return end
    sbar.delay(0.05, function()
        if not orientation.horizontal then return end
        local screen
        for _, display in ipairs(orientation.displays) do
            if not screen or display.main == true or display.main == 1 then screen = display end
            if (display.builtin == true or display.builtin == 1) and display.notch_height > 0 then
                screen = display
                break
            end
        end
        if not screen then return end
        local query = meeting_card:query()
        local bounds = query.bounding_rects and query.bounding_rects["display-" .. tostring(screen.index or 1)]
        if not bounds then return end
        local notch = screen.notch_width or 0
        local target = (screen.x or 0) + (notch > 0
            and (screen.width + (screen.width + notch) / 2) / 2
            or screen.width / 2)
        local current = bounds.origin[1] + bounds.size[1] / 2
        local next_width = math.max(0, math.floor(spacer_width + target - current + 0.5))
        if next_width ~= spacer_width then
            spacer_width = next_width
            meeting_spacer:set({ width = spacer_width })
        end
    end)
end

local function apply_orientation(horizontal)
    spacer_width = 0
    meeting_spacer:set({ drawing = horizontal and has_notch(), width = 0 })
    local position = horizontal and (has_notch() and "e" or "center") or "right"
    for _, item in ipairs({ meeting_icon, meeting_next, meeting_label, meeting_time }) do
        item:set({
            position = position,
            width = horizontal and "dynamic" or 16,
            padding_left = horizontal and 3 or 0,
            padding_right = horizontal and 3 or 0,
            label = { padding_left = 3, padding_right = 3 },
        })
    end
    meeting_icon:set({ label = { font = { size = horizontal and 16.0 or 22.0 } } })
    meeting_card:set({ background = { height = horizontal and 24 or 0, corner_radius = horizontal and 5 or 7 } })
    if horizontal then
        sbar.exec("sketchybar --reorder meeting.centering meeting.icon meeting.next meeting.label meeting.time", center_meeting)
    else
        sbar.exec("sketchybar --reorder meeting.time meeting.label meeting.next meeting.icon")
    end
end
orientation.subscribe(apply_orientation)

meeting_time:set({
	popup = {
		align = "right",
        height = 44,
        y_offset = 4,
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
	label = { string = "TODAY’S EVENTS", align = "left", color = colors.green, width = 236, font = { size = 10.0 } },
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
			callback(tonumber(result))
		end
	)
end

local function show_no_meetings()
	meeting_card:set({ background = { drawing = true, border_color = colors.grey } })
	meeting_icon:set({ label = { drawing = true, string = "󰃭", color = colors.grey }, click_script = "" })
	meeting_next:set({ label = { drawing = true, string = "NO", color = colors.grey }, click_script = "" })
	meeting_label:set({ label = { drawing = true, string = "MEETINGS", color = colors.grey }, click_script = "" })
	meeting_time:set({ label = { drawing = false }, click_script = "" })
    center_meeting()
end

local function show_calendar_error()
    meeting_card:set({ background = { drawing = true, border_color = colors.orange } })
    meeting_icon:set({ label = { drawing = true, string = "󰃭", color = colors.orange }, click_script = "" })
    meeting_next:set({ label = { drawing = true, string = "CALENDAR", color = colors.orange }, click_script = "" })
    meeting_label:set({ label = { drawing = true, string = "ERROR", color = colors.orange }, click_script = "" })
    meeting_time:set({ label = { drawing = false }, click_script = "" })
    center_meeting()
end

local function hide_popup_event(row)
	row:set({ drawing = false, background = { drawing = false }, icon = { drawing = false }, label = { drawing = false }, click_script = "" })
end

local function calendar_color(event)
	local calendar = type(event) == "table" and event.calendar or nil
	local hex = json_string(calendar, "color")
	if hex:match("^#%x%x%x%x%x%x$") then
		return tonumber("0xff" .. hex:sub(2))
	end
	return colors.teal
end

local function popup_title(title)
    local count = utf8.len(title)
    if count and count > 24 then
        return title:sub(1, utf8.offset(title, 24) - 1) .. "…"
    end
    return title
end

local function update_popup_event(row, entry, now)
    if not entry then
        hide_popup_event(row)
        return
    end
    local event = entry.event
    local active = entry.start <= now and now < entry.finish
    local link = json_string(event, "meetingUrl")
    row:set({
        drawing = true,
        icon = {
            drawing = true,
            string = os.date("%H:%M", entry.start),
            color = active and colors.orange or (link == "" and calendar_color(event) or colors.teal),
        },
        label = {
            drawing = true,
            string = popup_title(json_string(event, "title")),
            color = active and colors.yellow or white,
        },
        background = {
            drawing = true,
            color = active and colors.bg1 or colors.bg2,
            border_color = active and colors.orange or colors.bar.border,
        },
        click_script = link == "" and "" or "open " .. shell_quote(link),
    })
end

local function set_popup_visible(visible)
    meeting_time:set({ popup = { drawing = visible } })
end

local function update_meeting(entry, now)
    if not entry then
        show_no_meetings()
        return
    end
    local link = json_string(entry.event, "meetingUrl")
    local active = entry.start <= now and now < entry.finish
    local click_script = link == "" and "" or "open " .. shell_quote(link)
    for _, item in ipairs({ meeting_icon, meeting_next, meeting_label, meeting_time }) do
        item:set({ click_script = click_script })
    end
    meeting_card:set({ background = { drawing = true, border_color = active and colors.red or colors.teal } })
    meeting_icon:set({ label = { drawing = true, string = "󰃭", color = active and colors.orange or colors.yellow } })
    meeting_next:set({ label = { drawing = true, string = active and "IN" or "NEXT", color = active and colors.red or colors.green } })
    meeting_label:set({ label = { drawing = true, string = "MEETING", color = active and colors.red or colors.green } })
    meeting_time:set({ label = {
        drawing = true,
        string = os.date("%H:%M", entry.start),
        color = active and white or colors.yellow,
    } })
    center_meeting()
end

-- Fetch the whole day so meetings remain present after their start time.
-- Filter and sort before applying the popup's five-row limit.
local refreshing = false
local function refresh_meeting()
    if refreshing then return end
    refreshing = true
    sbar.exec(calendar_command .. " events --from today --to tomorrow --exclude-all-day --group-by none --format json", function(result, code)
        if code ~= 0 or type(result) ~= "table" then
            refreshing = false
            show_calendar_error()
            for _, row in ipairs(popup_events) do hide_popup_event(row) end
            return
        end
        local entries = {}
        local pending = #result
        local function render()
            refreshing = false
            local now = os.time()
            local today = os.date("%Y-%m-%d", now)
            local remaining = {}
            for _, entry in ipairs(entries) do
                if entry.finish > now and os.date("%Y-%m-%d", entry.start) == today then
                    table.insert(remaining, entry)
                end
            end
            table.sort(remaining, function(a, b) return a.start < b.start end)
            local meeting
            for _, entry in ipairs(remaining) do
                if json_string(entry.event, "meetingUrl") ~= "" then
                    meeting = entry
                    break
                end
            end
            update_meeting(meeting, now)
            for index, row in ipairs(popup_events) do
                update_popup_event(row, remaining[index], now)
            end
        end
        if pending == 0 then render(); return end
        for _, event in ipairs(result) do
            event_epoch(json_string(event, "startDate"), function(start_epoch)
                event_epoch(json_string(event, "endDate"), function(finish_epoch)
                    if start_epoch and finish_epoch and json_string(event, "title") ~= "" then
                        table.insert(entries, { event = event, start = start_epoch, finish = finish_epoch })
                    end
                    pending = pending - 1
                    if pending == 0 then render() end
                end)
            end)
        end
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

meeting_icon:subscribe({ "forced", "routine", "system_woke" }, refresh_meeting)
meeting_spacer:set({ updates = true, update_freq = 2 })
meeting_spacer:subscribe("routine", center_meeting)
refresh_meeting()
