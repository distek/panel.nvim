---@alias bufid number
---@alias winid number

---@class config
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
---@field resize? function
---@field isOpen? function
---@field close? function
---@field setView? function
---@field handleClickTab? function
---@field open? function
---@field next? function
---@field previous? function
---@field toggle? function
---@field setup? function

---@class openOpts
---@field name? string
---@field focus? boolean
