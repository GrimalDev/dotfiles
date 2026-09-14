--- @since 25.5.31
--- @sync entry

local function setup(self, opts) self.open_multi = opts.open_multi end

local function shquote(s) return "'" .. s:gsub("'", "'\\''") .. "'" end

local function entry(self)
	local h = cx.active.current.hovered
	if h and h.cha.is_dir then
		return ya.emit("enter", { hovered = not self.open_multi })
	end

	-- yazi.nvim sets NVIM_CWD and launches yazi with --chooser-file, where
	-- `open` hands the hovered file back to Neovim. Keep that native behavior.
	if os.getenv("NVIM_CWD") then
		return ya.emit("open", { hovered = not self.open_multi })
	end

	local paths = {}
	if self.open_multi then
		for _, u in pairs(cx.active.selected) do
			paths[#paths + 1] = tostring(u)
		end
	end
	if #paths == 0 and h then
		paths[1] = tostring(h.url)
	end
	if #paths == 0 then
		return
	end

	local command = { "open" }
	for _, p in ipairs(paths) do
		command[#command + 1] = shquote(p)
	end
	os.execute(table.concat(command, " "))

	ya.emit("quit", {})
end

return { entry = entry, setup = setup }
