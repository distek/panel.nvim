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

local tabCheck = function()
	if M.tabScopes[util.getCurTab()] == nil then
		M.tabScopes[util.getCurTab()] = M.newPanel()
	end
end

M.resize = function()
	tabCheck()
	return M.tabScopes[util.getCurTab()]:resize()
end

---@return boolean
M.isOpen = function()
	tabCheck()
	return M.tabScopes[util.getCurTab()]:isOpen()
end

M.close = function()
	tabCheck()
	M.tabScopes[util.getCurTab()]:close()
end

---@param name string
M.setView = function(name)
	tabCheck()
	M.tabScopes[util.getCurTab()]:setView(name)
end

M.handleClickTab = function(minwid, _, _, _)
	tabCheck()
	M.tabScopes[util.getCurTab()]:handleClickTab(minwid, _, _, _)
end

---@param opts openOpts
M.open = function(opts)
	tabCheck()
	M.tabScopes[util.getCurTab()]:open(opts)
end

M.getNext = function()
	tabCheck()
	M.tabScopes[util.getCurTab()]:getNext()
end

M.getPrevious = function()
	tabCheck()
	M.tabScopes[util.getCurTab()]:getPrevious()
end

M.next = function()
	tabCheck()
	M.tabScopes[util.getCurTab()]:next()
end

M.previous = function()
	tabCheck()
	M.tabScopes[util.getCurTab()]:previous()
end

-- Toggle the panel
---@param focus? boolean
M.toggle = function(focus)
	tabCheck()
	M.tabScopes[util.getCurTab()]:toggle(focus)
end

M.getWin = function()
	return M.tabScopes[util.getCurTab()].win
end

M.newPanel = function()
	local new = vim.deepcopy(require("panel.tab"))

	new.config = M.config

	return new
end

return M
