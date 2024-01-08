local window = require("panel.window")
local util = require("panel.util")

local M = {
	currentView = "",
	bufs = {},
	win = nil,
}

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

---@param winid winid
local renderWinbar = function(self, winid)
	local wb = ""

	for i, v in ipairs(PanelOrder) do
		if v == self.currentView then
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

---@param panelName string
---@param view view
local function handleOpen(self, panelName, view)
	vim.api.nvim_set_current_win(self.win)

	self.ignoreFTAutocmd = true
	self.bufs[panelName] = view.open()
	self.ignoreFTAutocmd = false

	if self.bufs[panelName] == nil then
		self.bufs[panelName] = nil
	else
		vim.bo[self.bufs[panelName]].bufhidden = "hide"
		vim.bo[self.bufs[panelName]].buflisted = false
	end
end

---@param name string
---@return view|nil
local function getView(self, name)
	for _, v in ipairs(self.config.views) do
		if v.name == name then
			return v
		end
	end

	return nil
end

---@return boolean
local function hasBufs(self)
	if self.bufs == nil then
		return false
	end

	for k, v in pairs(self.bufs) do
		if vim.api.nvim_buf_is_valid(v) then
			return true
		end

		self.bufs[k] = nil
	end

	return false
end

-- Manually trigger a size reset of the panel
M.resize = function(self)
	vim.o.eventignore = "WinResized"
	vim.api.nvim_win_set_height(self.win, self.config.size)
	vim.o.eventignore = ""
end

-- Check if the panel is open
---@return boolean
M.isOpen = function(self)
	if self.win == nil or not vim.api.nvim_win_is_valid(self.win) then
		self.win = nil
		return false
	end

	return true
end

-- Close the panel
M.close = function(self)
	if vim.api.nvim_win_is_valid(self.win) then
		self.winClosing = true
		vim.api.nvim_win_hide(self.win)
		self.winClosing = false
	end

	self.win = nil
end

-- Set panel's current view to `name`
---@param name string view name
M.setView = function(self, name)
	local view = getView(self, name)
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

	if self.win == nil or not vim.api.nvim_win_is_valid(self.win) then
		self.win = window.createWindow(self.config.size)
	end

	util.restoreWinOpts(self.win)

	if
		self.bufs[name] == nil or not vim.api.nvim_buf_is_valid(self.bufs[name])
	then
		handleOpen(self, name, view)
	end

	util.debounceResize = true
	vim.api.nvim_win_set_height(self.win, self.config.size)
	util.debounceResize = false

	if self.currentView ~= name then
		self.currentView = name
	end

	vim.api.nvim_win_set_buf(self.win, self.bufs[name])

	util.setWinOpts(self.win, view.wo)

	renderWinbar(self, self.win)

	cleanBufs()
end

-- Winbar tab click handler
M.handleClickTab = function(self, minwid, _, _, _)
	self.currentView = PanelOrder[minwid]

	self.setView(self, self.currentView)
end

-- Get the name of the next panel
---@return string
M.getNext = function(self)
	local current = 0
	for i, v in ipairs(PanelOrder) do
		if v == self.currentView then
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

-- Get the name of the previous panel
---@return string
M.getPrevious = function(self)
	local current = 0
	for i, v in ipairs(PanelOrder) do
		if v == self.currentView then
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

-- Focus the next panel
M.next = function(self)
	self.currentView = self:getNext()

	self.ignoreFTAutocmd = true
	self:setView(self.currentView)
	self.ignoreFTAutocmd = false
end

-- Focus the previous panel
M.previous = function(self)
	self.currentView = self:getPrevious()

	self.ignoreFTAutocmd = true
	self:setView(self.currentView)
	self.ignoreFTAutocmd = false
end

-- Open the panel
---@param opts openOpts
M.open = function(self, opts)
	if opts.name then
		local optView = getView(self, opts.name)
		if optView == nil then
			vim.error(
				string.format(
					"panel.nvim: open: requested view does not exist: %s",
					opts.name
				)
			)
			return
		end

		self.currentView = opts.name
	end

	local curWin = 0
	if opts.focus ~= nil and not opts.focus then
		curWin = vim.api.nvim_get_current_win()
	end

	if self.win == nil or not vim.api.nvim_win_is_valid(self.win) then
		self.win = window.createWindow(self.config.size)
	end

	self:setView(self.currentView)

	if opts.focus ~= nil and not opts.focus then
		vim.api.nvim_set_current_win(curWin)
	elseif opts.focus then
		vim.api.nvim_set_current_win(self.win)
	end
end

-- Check if panel is open in the current tab page
local openInTab = function(self)
	for _, v in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if self.win == v then
			return true
		end
	end

	return false
end

-- Toggle the panel
---@param focus? boolean
M.toggle = function(self, focus)
	if self:isOpen() then
		-- if the panel is open, but not on the current tab page, open it
		-- on this tabpage
		if not openInTab(self) then
			self:close()
			goto open
		end

		self:close()

		return
	end

	::open::
	if not hasBufs(self) then
		-- set the panelCurrent to the first entry
		self.currentView = PanelOrder[1]
	end

	self:open({ focus = focus })
end

return M
