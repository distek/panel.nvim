local util = require("panel.util")

local M = require("panel.panel")

---@type string[]
PanelOrder = {}

---@param orderIdx number
---@param view view
local function setupFTAutocmds(orderIdx, view)
	local group = vim.api.nvim_create_augroup(
		"PanelAuGroup_" .. view.ft,
		{ clear = true }
	)

	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = view.ft,
		callback = function(ev)
			if not M.ignoreFTAutocmd then
				util.defer(function()
					local temp = vim.o.eventignore
					vim.o.eventignore = "FileType"

					M.tabScopes[util.getCurTab()].currentView =
						PanelOrder[orderIdx]
					M.tabScopes[util.getCurTab()].bufs[M.tabScopes[util.getCurTab()].currentView] =
						ev.buf

					M.setView(M.tabScopes[util.getCurTab()].currentView)

					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_get_buf(win) == ev.buf then
							if win ~= M.tabScopes[util.getCurTab()].win then
								vim.api.nvim_win_hide(win)
							end
						end
					end

					M.open({ focus = true })

					vim.o.eventignore = temp or ""
				end, 1)
			end
		end,
	})
end

vim.api.nvim_create_autocmd("TabNewEntered", {
	callback = function()
		if M.tabScopes[util.getCurTab()] == nil then
			M.tabScopes[util.getCurTab()] = M.newPanel()
		end
	end,
})

---@param config config
M.setup = function(config)
	if
		config == nil
		or config == {}
		or config.views == nil
		or #config.views == 0
	then
		vim.notify(
			"panel.nvim: you need to set at least one panel in your config",
			vim.log.levels.ERROR
		)

		return
	end

	for _, v in ipairs(config.views) do
		table.insert(M.config.extPanels, v.ft)
	end

	M.config = vim.tbl_deep_extend("force", {}, M.config, config)

	for i, v in ipairs(M.config.views) do
		PanelOrder[i] = v.name
		setupFTAutocmds(i, v)
	end

	for _, v in ipairs(vim.api.nvim_list_tabpages()) do
		M.tabScopes[v] = M.newPanel()
	end
end

return M
