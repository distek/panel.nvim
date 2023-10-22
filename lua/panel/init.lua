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

					if view.close then
						view.close()
					end

					M.currentView = PanelOrder[orderIdx]
					M.bufs[M.currentView] = ev.buf

					M.setView(M.currentView)

					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_get_buf(win) == ev.buf then
							if win ~= M.win then
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

	M.config = vim.deepcopy(config)

	for i, v in ipairs(M.config.views) do
		PanelOrder[i] = v.name
		setupFTAutocmds(i, v)
	end
end

return M
