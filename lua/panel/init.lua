---@param f function some function
---@param delay number delay in ms
local function defer(f, delay)
	vim.schedule(function()
		vim.defer_fn(f, delay)
	end)
end

---@type string[]
local order = {}

---@type winid[]
local winStack = {}

---@type boolean
local debounceNewClosed = false

---@type boolean
local debounceResize = false

local function setDebounceNewClosed()
	debounceNewClosed = true

	defer(function()
		debounceNewClosed = false
	end, 100)
end

local function setDebounceResize()
	debounceResize = true

	defer(function()
		debounceResize = false
	end, 100)
end

---@param t table
---@return table
local function reverseTable(t)
	if t == nil or next(t) ~= nil and #t == 0 then
		return {}
	end

	local ret = {}

	for i = #t, 1, -1 do
		table.insert(ret, t[i])
	end

	return ret
end

---@alias bufid number
---@alias winid number

---@class config
---@field panel panel

---@class panel
---@field size number
---@field views view[]

---@class view
---@field name string
---@field ft string
---@field open function: bufid | nil
---@field close function|nil
---@field wo table<string, any>

---@class package
---@field currentView string|nil
---@field winResized boolean
---@field winClosing boolean
---@field ignoreFTAutocmd boolean
---@field bufs table<string,number|nil>
---@field win winid|nil
---@field defaultWinOpts table<string, any>
---@field config config
local M = {
	currentView = nil,

	winResized = false,
	winClosing = false,
	ignoreFTAutocmd = false,

	bufs = {},

	win = nil,

	defaultWinOpts = {},

	config = {
		panel = {
			size = 15,
			views = {},
		},
	},
}

local function saveDefaultWinOpts(winid)
	for _, v in pairs(M.config.panel.views) do
		for k, _ in pairs(v.wo) do
			M.defaultWinOpts[k] = vim.api.nvim_get_option_value(
				k,
				{ scope = "local", win = winid }
			)
		end
	end
end

local function restoreWinOpts(winid)
	for k, v in pairs(M.defaultWinOpts) do
		vim.wo[winid][k] = v
	end
end

local function setWinOpts(winid, opts)
	for k, v in pairs(opts) do
		vim.wo[winid][k] = v
	end
end

---@param size number
---@return winid
local function createWindow(size)
	vim.o.lazyredraw = true
	local panelWin = 0

	local group = vim.api.nvim_create_augroup("PanelWin", { clear = true })

	vim.cmd("noautocmd horizontal botright split")
	panelWin = vim.api.nvim_get_current_win()

	saveDefaultWinOpts(panelWin)

	vim.api.nvim_win_set_height(panelWin, size or 15)

	-- Resize window only if user set M.winResized to true and we're not in a
	-- debounce
	vim.api.nvim_create_autocmd({ "WinResized" }, {
		group = group,
		callback = function()
			vim.o.eventignore = "WinResized"
			if not debounceResize and not debounceNewClosed then
				if M.winResized then
					M.config.panel.size = vim.api.nvim_win_get_height(M.win)

					M.winResized = false
					setDebounceResize()
				end
			end
			vim.o.eventignore = ""
		end,
	})

	-- trigger resize if we _aren't_ resizing manually
	vim.api.nvim_create_autocmd({ "WinResized", "WinNew", "WinClosed" }, {
		group = group,
		callback = function()
			if not M.winResized then
				if M.isOpen() then
					M.resize()
				end
			end
		end,
	})

	-- prevent other buffers from opening in our panel
	-- opens whatever the new buffer is in a "main" window, as determined by edgy.nvim
	vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
		group = group,
		callback = function(ev)
			defer(function()
				if vim.api.nvim_get_current_win() == M.win then
					for _, v in pairs(M.bufs) do
						if ev.buf == v then
							return
						end
					end

					local buf = vim.api.nvim_win_get_buf(M.win)

					vim.api.nvim_win_set_buf(M.win, M.bufs[M.currentView])

					-- get all non edgy or floating windows
					local mainWins = require("edgy.editor").list_wins().main

					-- set main to _something_
					local main = 0

					for _, v in pairs(mainWins) do
						main = v
						break
					end

					-- No main window, scary things are afoot
					if main == 0 then
						vim.notify(
							"panel.nvim: could not find a main window for the new buffer!",
							vim.log.levels.ERROR
						)
						return
					end

					-- check our global winstack and if one of them is
					-- in mainWins, use it
					local revWins = reverseTable(winStack)

					if revWins == nil then
						vim.api.nvim_win_set_buf(main, buf)
						return
					end

					for _, v in ipairs(revWins) do
						if mainWins[v] ~= nil then
							vim.api.nvim_win_set_buf(main, buf)

							return
						end
					end
				end
			end, 10)
		end,
	})

	setDebounceNewClosed()

	vim.o.lazyredraw = false
	return panelWin
end

---@param panelName string
---@param view view
local function handleOpen(panelName, view)
	vim.api.nvim_set_current_win(M.win)

	M.ignoreFTAutocmd = true
	M.bufs[panelName] = view.open()
	M.ignoreFTAutocmd = false

	if M.bufs[panelName] == nil then
		M.bufs[panelName] = nil
	else
		vim.bo[M.bufs[panelName]].bufhidden = "hide"
		vim.bo[M.bufs[panelName]].buflisted = false
	end
end

local function setupAutocmds()
	for i, v in ipairs(M.config.panel.views) do
		local group = vim.api.nvim_create_augroup(
			"PanelAuGroup_" .. v.ft,
			{ clear = true }
		)

		vim.api.nvim_create_autocmd({ "FileType" }, {
			group = group,
			pattern = v.ft,
			callback = function(ev)
				if not M.ignoreFTAutocmd then
					defer(function()
						local temp = vim.o.eventignore
						vim.o.eventignore = "FileType"

						M.currentView = order[i]
						M.bufs[M.currentView] = ev.buf

						M.setView(M.currentView)

						for _, win in ipairs(vim.api.nvim_list_wins()) do
							if vim.api.nvim_win_get_buf(win) == ev.buf then
								if v ~= M.win then
									vim.api.nvim_win_close(win, true)
								end
							end
						end

						M.open(true)

						vim.o.eventignore = temp or ""
					end, 1)
				end
			end,
		})
	end

	vim.api.nvim_create_autocmd({ "WinLeave" }, {
		pattern = "*",
		callback = function(ev)
			local winid = tonumber(ev.id)
			for i, v in ipairs(winStack) do
				if winid == v then
					table.remove(winStack, i)
					break
				end
			end

			table.insert(winStack, winid)
			if #winStack > 10 then
				table.remove(winStack, 1)
			end
		end,
	})

	-- Create a new win if whatever command we had running closed it
	vim.api.nvim_create_autocmd({ "WinClosed" }, {
		callback = function(ev)
			vim.o.eventignore = "WinClosed"
			if not debounceNewClosed then
				defer(function()
					if tonumber(ev.match) == M.win then
						if M.winClosing then
							return
						end

						M.open(true)
						vim.o.eventignore = ""
					end
				end, 10)
			end
		end,
	})
end

---@return boolean
local function hasBufs()
	if M.bufs == nil then
		return false
	end

	for k, v in pairs(M.bufs) do
		if vim.api.nvim_buf_is_valid(v) then
			return true
		end

		M.bufs[k] = nil
	end

	return false
end

M.resize = function()
	vim.o.eventignore = "WinResized"
	vim.api.nvim_win_set_height(M.win, M.config.panel.size)
	vim.o.eventignore = ""
end

---@return boolean
M.isOpen = function()
	if M.win == nil then
		return false
	end

	if vim.api.nvim_win_is_valid(M.win) then
		return true
	end

	M.win = nil
	return false
end

M.close = function()
	if vim.api.nvim_win_is_valid(M.win) then
		M.winClosing = true
		vim.api.nvim_win_close(M.win, true)
		M.winClosing = false
	end

	M.win = nil
end

local function cleanBufs()
	for _, v in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(v) == "" then
			if #vim.fn.getbufinfo(v)[1].windows == 0 then
				vim.bo[v].bufhidden = "hide"
				vim.bo[v].buflisted = false
			end
		end
	end
end

local renderWinbar = function(winid)
	local wb = ""

	for i, v in ipairs(order) do
		if v == M.currentView then
			wb = wb .. "%#TabLineSel#▎"
			wb = wb .. "%#TabLineSel# "
		else
			wb = wb .. "%#TabLine#▎%#TabLine# "
		end

		wb = wb .. "%" .. i .. "@v:lua.Panel.handleClickTab@ "

		wb = wb .. v .. " %X"

		wb = wb .. " %#TabLineFill# "

		wb = wb .. "%#Normal#"
	end

	wb = wb .. "%#TabLineFill#"

	vim.wo[winid].winbar = wb

	vim.cmd("redraw")
end

---@param name string
---@return view|nil
local function getView(name)
	for _, v in ipairs(M.config.panel.views) do
		if v.name == name then
			return v
		end
	end

	return nil
end

---@param name string
M.setView = function(name)
	vim.o.lazyredraw = true

	local view = getView(name)
	if view == nil then
		vim.notify(
			string.format(
				"panel.nvim: setView: view with name %s not found in config",
				name
			),
			vim.log.levels.ERROR
		)

		return
	end

	if M.win == nil or not vim.api.nvim_win_is_valid(M.win) then
		M.win = createWindow(M.config.panel.size)
	end

	if M.bufs[name] == nil or not vim.api.nvim_buf_is_valid(M.bufs[name]) then
		handleOpen(name, view)
	end

	debounceResize = true
	debounceNewClosed = true
	vim.api.nvim_win_set_height(M.win, M.config.panel.size)
	debounceResize = false
	debounceNewClosed = false

	restoreWinOpts(M.win)

	if M.currentView ~= name then
		M.currentView = name
	end

	vim.api.nvim_win_set_buf(M.win, M.bufs[name])

	renderWinbar(M.win)

	setWinOpts(M.win, view.wo)

	cleanBufs()

	vim.o.lazyredraw = false
end

M.handleClickTab = function(minwid, _, _, _)
	M.currentView = order[minwid]

	M.setView(M.currentView)
end

---@param focus? boolean
M.open = function(focus)
	local curWin = 0
	if focus ~= nil and not focus then
		curWin = vim.api.nvim_get_current_win()
	end

	M.win = createWindow(M.config.panel.size)

	if
		M.bufs[M.currentView] == nil
		or not vim.api.nvim_buf_is_valid(M.bufs[M.currentView])
	then
		for _, v in ipairs(order) do
			if M.bufs[v] ~= nil and vim.api.nvim_buf_is_valid(M.bufs[v]) then
				M.currentView = v
			end
		end
	end

	M.setView(M.currentView)

	if focus ~= nil and not focus then
		vim.api.nvim_set_current_win(curWin)
	end
end

M.next = function()
	local current = 0
	for i, v in ipairs(order) do
		if v == M.currentView then
			current = i
			break
		end
	end

	local view = getView(M.currentView)
	if view == nil then
		vim.notify(
			string.format(
				"panel.nvim: next: view with name %s not found in config",
				M.currentView
			),
			vim.log.levels.ERROR
		)

		return
	end

	if view.close then
		view.close()
	end

	if current == #order then
		current = 1
	else
		current = current + 1
	end

	M.currentView = order[current]

	M.setView(M.currentView)
end

M.previous = function()
	local current = 0
	for i, v in ipairs(order) do
		if v == M.currentView then
			current = i
			break
		end
	end

	local view = getView(M.currentView)
	if view == nil then
		vim.notify(
			string.format(
				"panel.nvim: previous: view with name %s not found in config",
				M.currentView
			),
			vim.log.levels.ERROR
		)

		return
	end

	-- close the current panel window if
	if view.close then
		view.close()
	end

	current = current - 1

	if current <= 0 then
		current = #order
	end

	M.currentView = order[current]

	M.setView(M.currentView)
end

-- Toggle the panel
---@param focus? boolean
M.toggle = function(focus)
	vim.o.lazyredraw = true
	if M.isOpen() then
		M.close()

		vim.o.lazyredraw = false

		return
	end

	if not hasBufs() then
		-- set the panelCurrent to the first entry
		M.currentView = order[1]
	end

	M.open(focus)

	vim.api.nvim_set_current_win(M.win)
	vim.o.lazyredraw = false
end

---@param config config
M.setup = function(config)
	if
		config == nil
		or config == {}
		or config.panel == nil
		or config.panel.views == nil
		or #config.panel.views == 0
	then
		vim.notify(
			"panel.nvim: you need to set at least one panel in your config",
			vim.log.levels.ERROR
		)

		return
	end

	M.config = vim.deepcopy(config)

	for i, v in ipairs(M.config.panel.views) do
		order[i] = v.name
	end

	setupAutocmds()
end

return M
