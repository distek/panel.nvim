local util = require("panel.util")

M = {}

---@type winid[]
local winStack = {}

---@param size number
---@return winid
function M.createWindow(size)
	local panel = require("panel.panel")

	local panelWin = 0

	local group = vim.api.nvim_create_augroup("PanelWin", { clear = true })

	vim.cmd("noautocmd horizontal botright " .. panel.config.size .. " split")
	panelWin = vim.api.nvim_get_current_win()

	util.saveDefaultWinOpts(panelWin)

	vim.api.nvim_win_set_height(panelWin, size or 15)

	-- Resize window only if user set panel.winResized to true and we're not in a
	-- debounce
	vim.api.nvim_create_autocmd({ "WinResized" }, {
		group = group,
		callback = function()
			if not util.debounceResize then
				if panel.winResized then
					if vim.api.nvim_win_is_valid(panelWin) then
						panel.config.size =
							vim.api.nvim_win_get_height(panelWin)

						panel.winResized = false
						util.setDebounceResize()
					end
				end
			end
		end,
	})

	-- trigger resize if we _aren't_ resizing manually
	vim.api.nvim_create_autocmd({ "WinResized", "WinNew", "WinClosed" }, {
		group = group,
		callback = function()
			if not panel.winResized then
				if panel.isOpen() then
					panel.resize()
				end
			end
		end,
	})

	-- prevent other buffers from opening in our panel
	-- opens whatever the new buffer is in a "main" window
	vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
		group = group,
		callback = function(ev)
			util.defer(function()
				if vim.api.nvim_get_current_win() == panel.win then
					-- filetype check
					for _, v in pairs(panel.config.views) do
						if ev.buf == v.ft then
							-- Buf is fine
							return
						end
					end

					-- get this new buffer
					local buf = vim.api.nvim_win_get_buf(panel.win)

					-- set our panel back to currentView or the first panel
					vim.api.nvim_win_set_buf(
						panel.win,
						panel.bufs[panel.currentView]
					)

					local previousWin = vim.fn.winnr("#")

					-- if the previous window isn't in the ignored ft's, send buf there
					if vim.api.nvim_win_is_valid(previousWin) then
						if
							not util.ignoreFt(
								vim.api.nvim_win_get_buf(previousWin),
								panel.config.extPanels
							)
						then
							vim.api.nvim_win_set_buf(previousWin, buf)
							return
						end
					end

					local mainWins = {}

					-- get all non special or floating windows
					for _, v in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_get_config(v).relative == "" then
							if
								not util.ignoreFt(
									vim.api.nvim_win_get_buf(v),
									panel.config.extPanels
								)
							then
								table.insert(mainWins, v)
							end
						end
					end

					local main = 0

					if #mainWins ~= 0 then
						main = mainWins[0]
					end

					-- we lost the last main window, create a new one
					if main == 0 then
						local switchTo = 0
						-- find the first non-ignored buffer
						for _, v in vim.api.nvim_list_bufs() do
							if not util.ignoreFt(v, panel.config.extPanels) then
								switchTo = v
								break
							end
						end

						-- create a split above
						vim.cmd("horizontal aboveleft split")

						-- we couldn't find a normal buffer, create an empty one
						if switchTo == 0 then
							vim.cmd("enew")
						end
					end
				end
			end, 10)
		end,
	})

	-- Create a new win if whatever command we had running closed it
	vim.api.nvim_create_autocmd({ "WinClosed" }, {
		pattern = tostring(panelWin),
		group = group,
		callback = function(ev)
			util.defer(function()
				if tonumber(ev.match) == panel.win then
					if panel.winClosing then
						return
					end

					panel.open({ focus = true })
					vim.o.eventignore = ""
				end
			end, 10)
		end,
	})

	vim.api.nvim_create_autocmd({ "WinLeave" }, {
		pattern = "*",
		group = group,
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

	return panelWin
end

return M
