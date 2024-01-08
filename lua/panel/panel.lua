local util = require("panel.util")

---@type package
local M = {
	winResized = false,
	winClosing = false,
	ignoreFTAutocmd = false,

	defaultWinOpts = {},

	tabScopes = {},

	config = {
		size = 15,
		tabScoped = false,
		extPanels = {},
		views = {},
	},
}

-- Check if the current tab has an associated panel
-- Always check tab 1 if config.tabScoped == false
local tabCheck = function()
	if M.tabScopes[util.getCurTab()] == nil then
		M.tabScopes[util.getCurTab()] = M.newPanel()
	end
end

-- Manually trigger a size reset of the panel
M.resize = function()
	tabCheck()
	return M.tabScopes[util.getCurTab()]:resize()
end

-- Check if the panel is open
---@return boolean
M.isOpen = function()
	tabCheck()
	return M.tabScopes[util.getCurTab()]:isOpen()
end

-- Close the panel
M.close = function()
	tabCheck()
	M.tabScopes[util.getCurTab()]:close()
end

-- Set panel's current view to `name`
---@param name string view name
M.setView = function(name)
	tabCheck()
	M.tabScopes[util.getCurTab()]:setView(name)
end

-- Winbar tab click handler
M.handleClickTab = function(minwid, _, _, _)
	tabCheck()
	M.tabScopes[util.getCurTab()]:handleClickTab(minwid, _, _, _)
end

-- Get the name of the next panel
---@return string
M.getNext = function()
	tabCheck()
	return M.tabScopes[util.getCurTab()]:getNext()
end

-- Get the name of the previous panel
---@return string
M.getPrevious = function()
	tabCheck()
	return M.tabScopes[util.getCurTab()]:getPrevious()
end

-- Focus the next panel
M.next = function()
	tabCheck()
	M.tabScopes[util.getCurTab()]:next()
end

-- Focus the previous panel
M.previous = function()
	tabCheck()
	M.tabScopes[util.getCurTab()]:previous()
end

-- Open the panel
---@param opts openOpts
M.open = function(opts)
	tabCheck()
	M.tabScopes[util.getCurTab()]:open(opts)
end

-- Toggle the panel
---@param focus? boolean
M.toggle = function(focus)
	tabCheck()
	M.tabScopes[util.getCurTab()]:toggle(focus)
end

-- Get the winid of the panel in this tabpage
---@return winid|nil
M.getWin = function()
	return M.tabScopes[util.getCurTab()].win
end

-- Create a new panel
-- User shouldn't have to run this, done automatically on TabNewEntered
M.newPanel = function()
	local new = vim.deepcopy(require("panel.tab"))

	new.config = M.config

	return new
end

return M
