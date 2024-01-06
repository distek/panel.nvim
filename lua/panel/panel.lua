local window = require("panel.window")
local util = require("panel.util")

---@type package
local M = {
	currentView = nil,

	winResized = false,
	winClosing = false,
	ignoreFTAutocmd = false,

	bufs = {},

	win = nil,

	defaultWinOpts = {},

	config = {
		size = 15,
		extPanels = {},
		views = {},
	},
}

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

	for i, v in ipairs(PanelOrder) do
		if v == M.currentView then
			wb = wb .. "%#TabLineSel#▎ "
		else
			wb = wb .. "%#TabLine#▎%#TabLine# "
		end

		wb = wb .. "%" .. i .. "@v:lua.require'panel'.handleClickTab@ "

		wb = wb .. v .. " %X"

		wb = wb .. " %#TabLineFill#"

		wb = wb .. "%#Normal#"
	end

	wb = wb .. "%#TabLineFill#"

	vim.wo[winid].winbar = wb

	vim.cmd("redraw")
end

---@param name string
---@return view|nil
local function getView(name)
	for _, v in ipairs(M.config.views) do
		if v.name == name then
			return v
		end
	end

	return nil
end

M.resize = function()
	vim.o.eventignore = "WinResized"
	vim.api.nvim_win_set_height(M.win, M.config.size)
	vim.o.eventignore = ""
end

---@return boolean
M.isOpen = function()
	if M.win == nil or not vim.api.nvim_win_is_valid(M.win) then
		M.win = nil
		return false
	end

	return true
end

M.close = function()
	if vim.api.nvim_win_is_valid(M.win) then
		M.winClosing = true
		vim.api.nvim_win_hide(M.win)
		M.winClosing = false
	end

	M.win = nil
end

---@param name string
M.setView = function(name)
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
		M.win = window.createWindow(M.config.size)
	end

	util.restoreWinOpts(M.win)

	if M.bufs[name] == nil or not vim.api.nvim_buf_is_valid(M.bufs[name]) then
		handleOpen(name, view)
	end

	util.debounceResize = true
	vim.api.nvim_win_set_height(M.win, M.config.size)
	util.debounceResize = false

	if M.currentView ~= name then
		M.currentView = name
	end

	vim.api.nvim_win_set_buf(M.win, M.bufs[name])

	util.setWinOpts(M.win, view.wo)

	renderWinbar(M.win)

	cleanBufs()
end

M.handleClickTab = function(minwid, _, _, _)
	M.currentView = PanelOrder[minwid]

	M.setView(M.currentView)
end

---@param opts openOpts
M.open = function(opts)
	if opts.name then
		local optView = getView(opts.name)
		if optView == nil then
			vim.error(
				string.format(
					"panel.nvim: open: requested view does not exist: %s",
					opts.name
				)
			)
			return
		end

		M.currentView = opts.name
	end

	local curWin = 0
	if opts.focus ~= nil and not opts.focus then
		curWin = vim.api.nvim_get_current_win()
	end

	if M.win == nil or not vim.api.nvim_win_is_valid(M.win) then
		M.win = window.createWindow(M.config.size)
	end

	M.setView(M.currentView)

	if opts.focus ~= nil and not opts.focus then
		vim.api.nvim_set_current_win(curWin)
	elseif opts.focus then
		vim.api.nvim_set_current_win(M.win)
	end
end

M.getNext = function()
	local current = 0
	for i, v in ipairs(PanelOrder) do
		if v == M.currentView then
			current = i
			break
		end
	end

	if current == #PanelOrder then
		current = 1
	else
		current = current + 1
	end

	return PanelOrder[current]
end

M.getPrevious = function()
	local current = 0
	for i, v in ipairs(PanelOrder) do
		if v == M.currentView then
			current = i
			break
		end
	end

	current = current - 1

	if current <= 0 then
		current = #PanelOrder
	end

	return PanelOrder[current]
end

M.next = function()
	M.currentView = M.getNext()

	M.ignoreFTAutocmd = true
	M.setView(M.currentView)
	M.ignoreFTAutocmd = false
end

M.previous = function()
	M.currentView = M.getPrevious()

	M.ignoreFTAutocmd = true
	M.setView(M.currentView)
	M.ignoreFTAutocmd = false
end

-- Toggle the panel
---@param focus? boolean
M.toggle = function(focus)
	if M.isOpen() then
		M.close()

		return
	end

	if not hasBufs() then
		-- set the panelCurrent to the first entry
		M.currentView = PanelOrder[1]
	end

	M.open({ focus = focus })
end

return M
