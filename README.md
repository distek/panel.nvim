# panel.nvim

**Note**: I would consider this beta-ish at this point. I think I've been able to cover a lot of cases, and tested some ways of using it (see [Configuration](##Configuration))

A V̴̢̧̧̢̢̧̨̛̛̺͇͚̜͎̣̳̙̰̳͉̙̺͔̠̰̠̦͕̤̳̱͉͈͎͔̬̩̞̺̘̫͎̩͚̪͔̩͓͍̼̝̫̗͖̩͙͉̮̙̝̯̝͚͍̳͕͉͓̰̮̜̪͚̮̝̝̬͓͇̠̘̯̤̗͇͉̫̘͂̄̉͆̾̇̈́̈̽̊͌̅̃̏̆͗̅͗̀̍͗͌̒͒̎͆̄̀̓̑̋̓̅̇̋͑̉̎̋̊̽̊̉̈́̐̀̀̀̓̈́̒̓̓͌̍̅̉̇̄͂͐̑̌͆̽̔̃̑͐͊́̄̃̇̅̑̾̚̚̕̕͘͜͜͠͝͠͝͠͝S̷̡̧̧̛͍̣̫̦̲̲̳͎̤͔͉̣̲̗͓̥̙̳̘̗̳̮͔̣̰̤̱̙͓̝̪̻̤͚͇͍̩͚̻͈̗̮͉̭̞̠̹̱̣͇̼͍̳͕͆̈́̈̃͗̓̉̈͛̌̅̎̔̈́͌̂̏̍́̐̇͊̆̓͛̍͑́͒͋̀̈́̔̂̓̾́̍̉̐̅̅͐̃̈̂͋̈̈͑̾̅̏͛̀͗͒̇͛͗͊̽̋̒͗̎̑̀̾̀̒̀̍̓̈́́͗̾̾̀̓͗̄̋̂̇͒͂̇̈́͂̀̅̓̚͘͜͜͝͝͠͝͝͝͝C̴̢̧̧̨̧̢̨̧̧̢̢̧̛̛̛̛̛̛͖̰̭̙͙̗͚̝̼͖̹̦̫̩̠̞͇̣̞̮̪̙̯͉̯̞̼̘̰̼̠̠̙͓̜̫̩̺̘̘͍̟͇͇̫͚̯̭͔̘͉̣͍̯̰̘͈̻̻͙̦̘̘̳̼̟̖̟̪̰̞͍͙̘̪̭̻̱͙͍̟͖̹̞͍͍͉̩̝̬̣̭̟̙̰̘͔͔̲̤̻̲̞̗͙̦̣̿̓̓͐͋͗̈̃̇̈͑̇͋̔̌̈̽̀̌̈͐͛̄̓̂͑́͛͆̓̌̅̈̈́͐͆͊̉͛͗̌́͋̄̀̂̆̈́͌̋̑̎͗͊̌̽̾͆́͛̈́͂͒͒͑́̀̌̂̑́̽̈́̽̄̓̋̈́̃̾̿͊̓̐̉̽̆̓̓̑̍͊̚̚̕̚̚͘̚̕͜͠͝͝͝͝ͅͅơ̸̧̨̡̢̧̢̡̛͍̦̟͔̳̭̖͓͔̬̟̲͈̯͉̥͇͈̟͈͚̣͈̻̼̟̞͕̤̲̲̳̗͉̬̙͙̲̖̳͓̣̬̩͓̪̳̮̥̖̣͕̫̭̝͔͎̤͎̮͖̦̼̯̹͇͉̲̗̣̳̺̟̻̲͈̲͚̬̭͓̠̜̰̙̖̳̣͓͕̳̳̓́̎̍̋̔͑͑̄̆͌̿̑̊̀͛̾̾̐̏̀̿̋̈͐̾̋̀͆͂̐́̾̓̋͒̓̏̍͗͛̽̆͆̀̿̓͊͛͒̀̓͂̽̓̏̐̏̐̈́̈́̋͂͌̒̋̇͗̉̇̀̓̈́͑͋̐̎̿̆͊̒̊̆͛͘̚̕̕̕͘̕͘͝͝͠͝͝ď̸̡̨̧̢̧̧̼͚̣̥̯̞̪̖͍̠̙͚̗͈̬̖͓̮̳̤͍̦̤̠̝͎͍͔̺̘̘̻̜͙͍̱͔̥̠̣̦͔̮̜̫̮͎̱̪̬͙̱͉̻͓̥̦̙̪̤̟̻͈̹͊̽̒̔̌̚͜͝ͅę̵̧̧̢̧̧͔̫̺͙͇̖̟̹̫̦͍͎̱̮̭̭̰͇͈̙̘͙̖̦̣͖̳̰͇̪͖̹͕͎̦̞̻̯͇̙̝̙̗̥̗̻̱̖̟͍̺͉̻̦͓̟̗͈̲̟͔̫̩͚̠͇̼̹̞͓̻̈́̈́͜͜ͅ-ish bottom panel for Neovim

![screenshot](screenshot.png)

## Installation

Lazy:

```lua
{
	"distek/panel.nvim",
	config = function()
        require("panel").setup({
            -- config goes here, see the "Configuration" section
        })
    end,
}
```

## Why?

I like VS Code's panel concept, but I _don't_ like VS Code's pain-in-the-ass customization.

You shouldn't have to write a damn extension just to fullscreen the damn panel.

## Configuration

The way panel works is:

- use the view's `open()` function (set by the user) to return the view's buffer ID
- set the panel window to that buffer
- update the winbar of the panel, 'cause we fancy

Here's an example that just has a terminal:

```lua
{
	"distek/panel.nvim",
	config = function()
        require("panel").setup({
            size = 15,
            views = {
                {
                    -- the name of the panel view (will also be shown in the winbar)
                    name = "Terminal",

                    -- the filetype to lock to the panel
                    ft = "toggleterm",

                    -- The open function should return the buffer ID of whatever we want in the panel
                    open = function()
                        -- open a new terminal in a split (we *want* to create a new window)
                        vim.cmd("split +term")

                        -- Grab the buffer's ID
                        local bufid = vim.api.nvim_get_current_buf()

                        -- hide the window (closing could delete the buffer, we don't want that)
                        vim.api.nvim_win_hide(vim.api.nvim_get_current_win())

                        -- Plugins would do this for you typically
                        vim.bo[bufid].filetype = "toggleterm"

                        -- finally return the new buffer ID
                        return bufid
                    end,

                    -- close is for a specific scenario in which the filetype relies on a specific window
                    -- Trouble is a good example of this
                    close = false,

                    -- Additional window options to apply to the panel when this buffer is focused
                    wo = {
                        winhighlight = "Normal:ToggleTermNormal",
                        number = false,
                        relativenumber = false,
                        wrap = false,
                        list = false,
                        signcolumn = "no",
                        statuscolumn = "",
                    },
                },
                -- ... more panels go here
            }
        })
    end
}
```

Three main things we need to focus on here in the `open` function:

1. Create a new window (if the command doesn't already do this)
   - if the command has a `toggle` and an `open` command, using the `open` is usually the way to go (we are the toggler now)
   - if the command _does_ have a `close`, you can use that as the `close` function (i.e. `close = require('plugin').close` - note the lack of parens)
     - though, you probably don't have to actually close it
2. Store the buffer ID of the created window
3. Hide `vim.api.nvim_win_hide(winid)` whatever the original window was (if not set in the command's args, see the Trouble example for a special case)
4. Return the buffer ID

Here's some more examples:

<details>
    <summary>trouble.nvim</summary>

If you have a panel object that uses a filetype with an LSP server attached (Like a markdown note panel), you need to ignore autocmds when switching panels. Like:

- `noautocmd lua require("panel").next()` or `.previous()`

Trouble freaks out if it thinks it is still open as it starts trying to check diagnostics for this filetype. Using `noautocmd` will prevent it from seeing the buffer change, effectively skipping it.
Example of skipping autocmds:

```lua

vim.keymap.set({ "t", "n" }, "<A-[>", function()
	-- Ignore autos unless we're going into Terminal ("so the auto-insert auto still works")
	-- This mitigates issues with trouble.nvim
	if require("panel").getPrevious() == "Terminal" then
		require("panel").previous()
	else
		vim.cmd("noautocmd lua require('panel').previous()")
	end
end)

vim.keymap.set({ "t", "n" }, "<A-]>", function()
	if require("panel").getNext() == "Terminal" then
		require("panel").next()
	else
		vim.cmd("noautocmd lua require('panel').next()")
	end
end)
```

```lua
    {
        name = "Problems",
        ft = "Trouble",
        open = function()
            require("trouble").open({
                win = require("panel").getWin(),
            })

            local bufid = vim.api.nvim_get_current_buf()

            vim.bo[bufid].buflisted = false

            -- As mentioned earlier in the readme, we don't want to hide trouble's window

            return bufid
        end,
        close = function()
            require("trouble").close()
        end,
        wo = {
            winhighlight = "Normal:PanelNormal",
        },
    }
```

</details>

<details>
    <summary>quickfix list</summary>

```lua
    {
        name = "Quickfix",
        ft = "qf",
        open = function()
            vim.cmd(":copen")
            local bufid = vim.api.nvim_get_current_buf()

            vim.api.nvim_win_hide(vim.api.nvim_get_current_win())

            return bufid
        end,
        close = false,
        wo = {
            winhighlight = "Normal:ToggleTermNormal",
        },
    },
```

</details>

<details>
    <summary>nvim help docs</summary>

```lua
    {
        name = "Help",
        ft = "help",
        open = function()
            -- just open `:help help` by default
            vim.cmd("help help")
            local bufid = vim.api.nvim_get_current_buf()
            vim.api.nvim_win_hide(vim.api.nvim_get_current_win())

            return bufid
        end,
        close = false,
        wo = {
            number = false,
            relativenumber = false,
            list = false,
            signcolumn = "no",
            statuscolumn = "",
            winhighlight = "Normal:PanelNormal",
        },
    },
```

</details>

Please feel free to submit others (that you've tested thoroughly) via issue or PR!

## API? Kinda?

You can change pretty much whatever you like at any time you like. Just... be careful?

Also, if there's a portion of the code that you'd like exposed, please do fork it, fix it, test it, and PR it.

### Overview

The internal stuffs. Not needed unless you want to hack on it a bit more.

```lua
package {
    -- Variables --

    -- the config
    config: {
        -- height of the panel
        size: number
        -- filetype's that should not be used when moving a rouge buffer out of the panel
        extPanels: string[]
        -- Each tabpage has it's own panel (disabled by default)
        tabScoped: boolean
        -- the panel views
        views: {
            {
                -- the view name
                name: string
                -- the view filetype
                ft: string
                -- how to open the view; return the buffer's ID
                open: function() -> number
                -- how to close the view when navigating away (if applicable)
                close: function() | nil
                -- window options to apply to view
                wo: table<string, any>
            }
        }
    }

    -- table of panel name ("Terminal") keys to buffer associations
    bufs: table<string, number|nil>

    -- name of the current view
    currentView: string|nil

    -- winid of the panel (can change frequently)
    win: nil

    -- stores the default window opts applied to new windows before applying specific window opts
    -- setup in the local createWindow function
    defaultWinOpts: table

    -----------------------------------------------------------------------------------------------------------

    -- Event blockers --

    -- used to indicate to panel that _you_ resized, otherwise it will force the size back to config.panel.size
    winResized: boolean

    -- can be set to prevent panel from forcing a current panel view's FT from being absorbed.
    -- set it back to false once your specific file is open completely
    ignoreFTAutocmd: boolean

    -- prevent panel's WinClosed autocmds from running on true
    winClosing: boolean

    -----------------------------------------------------------------------------------------------------------

    -- Functions --

    -- wouldn't recommend modifying any of these, but you do you

    -- what happens when you click a winbar tab
    handleClickTab: function()

    -- trigger a resize of the panel (prevents WinResized event)
    resize: function()

    -- check if panel is open
    -- returns boolean
    isOpen: function() -> boolean

    -- toggle the panel open/closed, optionally focusing it if focus == true
    toggle: function(focus?: boolean)

    -- close the panel
    close: function()

    -- get what the next view _would_ be if we switched to it
    getNext: function() -> string

    -- same as getNext, just in the opposite direction
    getPrevious: function() -> string

    -- focus the next panel
    next: function()

    -- focus the previous panel
    previous: function()

    -- open the panel, optionally focusing it if focus == true
    open: function(focus?: boolean)

    -- set's the panel's view to name
    setView: function(name: string)

    -- get the panel's window (tabScoped or not)
    getWin: function() -> winid|nil

    -- Create a new panel, shouldn't ever have to be ran by the user
    getWin: function() -> tabScope (panel, basically)

    -- setup function
    setup: function(config: config)
}
```

### Resizing

If you have a mapping for resizing, include a:

```lua
	require("panel").winResized = true
```

at the beginning of the map function. Setting back to `false` is handled by the plugin.

This will save the new size so it can be recalled later when panel detects a window size change elsewhere.

## Known issues

- Plugins that depend on the original window they were opened with can be problematic and will require special attention
  - i.e. [trouble.nvim](https://github.com/folke/trouble.nvim)
- If you use tmux as the command for your panel terminal, you can't click the tabs of the panel itself. You can work around it with something like:

```lua
    vim.keymap.set("i", "<MouseMove>", function()
        buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].filetype == "toggleterm" then
            vim.cmd("stopinsert")
        end
    end, { silent = true })
```

## Contributing

Should you feel inclined to do so:

- Use stylua to format code (or format manually)
  - Tabs, not spaces, for indents
  - Wrap code longer than 80 chars as best you can
    - Comments are excluded
    - Long strings can also be excluded
- Include lua_ls type annotations where applicable
  - Functions that have no parameters and return nil not included, unless they are a method of an object
