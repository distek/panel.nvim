local util = require("panel.util")

M = {}

---@type winid[]
local winStack = {}

---@param size number
---@return winid
function M.createWindow(size)
	local panel = require("panel.panel")

	vim.o.lazyredraw = true

	local panelWin = 0

	local group = vim.api.nvim_create_augroup("PanelWin", { clear = true })

	vim.cmd("noautocmd horizontal botright split")
	panelWin = vim.api.nvim_get_current_win()

	util.saveDefaultWinOpts(panelWin)

	vim.api.nvim_win_set_height(panelWin, size or 15)

	-- Resize window only if user set panel.winResized to true and we're not in a
	-- debounce
	vim.api.nvim_create_autocmd({ "WinResized" }, {
		group = group,
		callback = function()
			vim.o.eventignore = "WinResized"
			if not util.debounceResize and not util.debounceNewClosed then
				if panel.winResized then
					panel.size = vim.api.nvim_win_get_height(panel.win)

					panel.winResized = false
					util.setDebounceResize()
				end
			end
			vim.o.eventignore = ""
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
					for _, v in pairs(panel.bufs) do
						if ev.buf == v then
							return
						end
					end

					local buf = vim.api.nvim_win_get_buf(panel.win)

					vim.api.nvim_win_set_buf(
						panel.win,
						panel.bufs[panel.currentView]
					)

					local mainWins
					-- get all non edgy or floating windows
					local ok, edgyWins = pcall(require("edgy.editor").list_wins)
					if ok then
						mainWins = edgyWins.main
					else
						for _, v in ipairs(vim.api.nvim_list_wins()) do
							if v ~= panel.win then
								mainWins[v] = v
							end
						end
					end

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
					local revWins = util.reverseTable(winStack)

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

	-- Create a new win if whatever command we had running closed it
	vim.api.nvim_create_autocmd({ "WinClosed" }, {
		pattern = tostring(panelWin),
		group = group,
		callback = function(ev)
			vim.o.eventignore = "WinClosed"
			if not util.debounceNewClosed then
				util.defer(function()
					if tonumber(ev.match) == panel.win then
						if panel.winClosing then
							return
						end

						panel.open({ focus = true })
						vim.o.eventignore = ""
					end
				end, 10)
			else
				vim.o.eventignore = ""
			end
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

	util.setDebounceNewClosed()

	vim.o.lazyredraw = false
	return panelWin
end

return M
