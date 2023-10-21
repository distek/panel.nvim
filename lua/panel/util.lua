M = {}

---@param f function some function
---@param delay number delay in ms
local function defer(f, delay)
	vim.schedule(function()
		vim.defer_fn(f, delay)
	end)
end

M.defer = defer

---@type boolean
M.debounceNewClosed = false

---@type boolean
M.debounceResize = false

function M.setDebounceNewClosed()
	M.debounceNewClosed = true

	defer(function()
		M.debounceNewClosed = false
	end, 100)
end

function M.setDebounceResize()
	M.debounceResize = true

	defer(function()
		M.debounceResize = false
	end, 100)
end

---@param t table
---@return table
function M.reverseTable(t)
	if t == nil or next(t) ~= nil and #t == 0 then
		return {}
	end

	local ret = {}

	for i = #t, 1, -1 do
		table.insert(ret, t[i])
	end

	return ret
end

function M.saveDefaultWinOpts(winid)
	local panel = require("panel.panel")

	for _, v in pairs(panel.config.views) do
		for k, _ in pairs(v.wo) do
			panel.defaultWinOpts[k] = vim.api.nvim_get_option_value(
				k,
				{ scope = "local", win = winid }
			)
		end
	end
end

function M.restoreWinOpts(winid)
	for k, v in pairs(require("panel.panel").defaultWinOpts) do
		vim.wo[winid][k] = v
	end
end

function M.setWinOpts(winid, opts)
	for k, v in pairs(opts) do
		vim.wo[winid][k] = v
	end
end

return M
