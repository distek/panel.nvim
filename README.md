# panel.nvim

A ~~VSCode~~-ish bottom panel for Neovim

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

I like VS Code's panel, but I _don't_ like VS Code's pain-in-the-ass customization.

## Configuration

Configuration of panel is a bit weird!

The way panel works is:

- Determine the (now) current panel
- Close the view for the current panel (if panel is already open)
- Get the new buffer from the view's `open()` function
- set the panel window to that buffer
- update the winbar of the panel, 'cause we fancy

Here's a simple example that just has a terminal:

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

                        -- finally return the new buffer ID
                        return bufid
                    end,

                    -- close is for a specific scenario in which the filetype relies on a specific window
                    -- Trouble is a good example of this
                    close = nil,

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
2. Store the buffer ID of the created window
3. Hide whatever the original window was (if not set in the command's args, see the Trouble example for a special case)
4. Return the buffer ID

Here's some more examples:

<details>
    <summary>trouble.nvim</summary>

https://github.com/folke/trouble.nvim

Note: as mentioned above, Trouble is a special case where we _don't_ want to close the window.

```lua
    {
        name = "Problems",
        ft = "Trouble",
        open = function()
            -- We set the window to the panel window on open, as trouble relies on the window ID in it's code
            -- If we _don't_ provide a window, then trouble will create it's own and this all falls apart
            require("trouble").open({
                win = require("panel").win,
            })

            local bufid = vim.api.nvim_get_current_buf()

            vim.bo[bufid].buflisted = false

            -- since we close the window each time, cursor
            -- position gets lost
            -- save it to a global so we can recall it later
            vim.api.nvim_win_set_cursor(
                require("panel").win,
                -- TroublePos will be officially defined once you close the navigate away from this view
                TroublePos or { 0, 0 }
            )

            return bufid
        end,
        close = function()
            -- We close the trouble window, saving our current cursor position to a global: TroublePos
            if
                vim.api.nvim_get_current_buf()
                == require("panel").bufs["Problems"]
            then
                TroublePos = vim.api.nvim_win_get_cursor(
                    require("panel").win
                )
            end

            -- since we're closing the window, we tell the "WinClosed" autocmds setup by panel.nvim to knock it off for a moment
            require("panel").winClosing = true
            require("trouble").close()
            require("panel").winClosing = false
        end,
        wo = {
            winhighlight = "Normal:ToggleTermNormal",
        },
    },

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
            local bufid = 0
            -- if we have a help buf already, use that
            for _, v in ipairs(vim.api.nvim_list_bufs()) do
                if vim.bo[v].filetype == "help" then
                    bufid = v
                end
            end

            if bufid == 0 then
                -- otherwise make sure we have a buf to show
                vim.cmd("help help")
                bufid = vim.api.nvim_get_current_buf()
            end

            return bufid
        end,
        close = false,
        wo = {
            number = false,
            winhighlight = "Normal:ToggleTermNormal",
            relativenumber = false,
            list = false,
            signcolumn = "no",
            statuscolumn = "",
        },
    },
```

</details>

Please feel free to submit others (that you've tested thoroughly)!

## API?

You can change pretty much whatever you like at any time you like. Just... be careful?

### Overview

```lua
package {
    -- Variables --

    -- table of panel name ("Terminal") keys to buffer associations
    bufs: table<string, number|nil>

    -- the config
    config: {
        -- height of the panel
        size: number
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

    -- name of the current view
    currentView: string|nil

    -- winid of the panel (can change frequently)
    win: nil

    -- stores the default window opts applied to new windows before applying specific window opts
    -- setup in the local createWindow function
    winOpts: table

    -- Event blockers --

    -- used to indicate to panel that _you_ resized, otherwise it will force the size back to config.panel.size
    winResized: boolean

    -- can be set to prevent panel from forcing a current panel view's FT from being absorbed.
    -- set it back to false once your specific file is open completely
    ignoreFTAutocmd: boolean

    -- prevent panel's WinClosed autocmds from running on true
    winClosing: boolean


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

    -- focus the next panel
    next: function()

    -- focus the previous panel
    previous: function()

    -- open the panel, optionally focusing it if focus == true
    open: function(focus?: boolean)

    -- set's the panel's view to name
    setView: function(name: string)

    -- setup function
    setup: function(config: config)
}
```

### Resizing

If you have a mapping for resizing, include a:

```lua
	require("panel").winResized = true
```

at the beginning of the map function, and a

```lua
	require("panel").winResized = false
```

at the end, to prevent panel from forcing it's size back to the configured size.

This will also save the new size so it can be recalled later when panel needs to resize itself

## Known issues

- Flickering when you switch a panel
  - Not sure what to do about this, tried using `vim.o.lazyredraw` to no avail
  - If you know how to fix it, please let me know

## Contributing

Should you feel inclined to do so:

- Use stylua to format code (or format manually)
  - Tabs, not spaces, for indents
  - Wrap code longer than 80 chars as best you can
    - Comments are excluded
    - Long strings can also be excluded
- Include lua_ls type annotations where applicable
  - Functions that have no parameters and return nil not included
