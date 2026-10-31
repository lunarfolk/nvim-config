--- lualine's `auto` + `base16-*` colors uses `lualine/themes/base16.lua`, which expects
--- either `g:tinted_*` (tinted-vim) or `nvim-base16`. tinted-nvim sets neither, so we build
--- the same layout from `tinted-nvim.get_palette()` (see lualine/themes/base16.lua `setup()`).
local function lualine_tinted_theme()
    local ok, tinted = pcall(require, "tinted-nvim")
    if not ok then
        return require("lualine.utils.loader").load_theme("gruvbox")
    end
    local p = tinted.get_palette()
    if not p then
        return require("lualine.utils.loader").load_theme("gruvbox")
    end
    local c = {
        bg = p.base01,
        alt_bg = p.base02,
        dark_fg = p.base03,
        fg = p.base04,
        light_fg = p.base05,
        normal = p.base0D,
        insert = p.base0B,
        visual = p.base0E,
        replace = p.base09,
    }
    local theme = {
        normal = {
            a = { fg = c.bg, bg = c.normal },
            b = { fg = c.light_fg, bg = c.alt_bg },
            c = { fg = c.fg, bg = c.bg },
        },
        replace = {
            a = { fg = c.bg, bg = c.replace },
            b = { fg = c.light_fg, bg = c.alt_bg },
        },
        insert = {
            a = { fg = c.bg, bg = c.insert },
            b = { fg = c.light_fg, bg = c.alt_bg },
        },
        visual = {
            a = { fg = c.bg, bg = c.visual },
            b = { fg = c.light_fg, bg = c.alt_bg },
        },
        inactive = {
            a = { fg = c.dark_fg, bg = c.bg },
            b = { fg = c.dark_fg, bg = c.bg },
            c = { fg = c.dark_fg, bg = c.bg },
        },
    }
    theme.command = theme.normal
    theme.terminal = theme.insert
    return theme
end

-- Keep Kitty's terminal colours aligned with the active Neovim colourscheme.
-- Chameleon.nvim only synchronized `Normal.bg` to Kitty's `background`, so a
-- theme switch left Kitty's cursor at its previous colour.
local function setup_kitty_theme_sync()
    local function hex(color)
        return color and string.format("#%06x", color)
    end

    local function read_kitty_colors()
        local result = vim.system({ "kitty", "@", "get-colors" }, { text = true }):wait()
        if result.code ~= 0 then
            return {}
        end

        local colors = {}
        for name, color in result.stdout:gmatch("([%w_]+)%s+([#%x]+)") do
            if name == "background" or name == "cursor" then
                colors[name] = color
            end
        end
        return colors
    end

    local original_colors = read_kitty_colors()
    local warned = false

    local function set_kitty_colors(colors)
        local command = { "kitty", "@", "set-colors" }
        for name, color in pairs(colors) do
            table.insert(command, name .. "=" .. color)
        end

        vim.system(command, { text = true }, function(result)
            if result.code ~= 0 and not warned then
                warned = true
                vim.schedule(function()
                    vim.notify("Kitty theme sync failed: " .. vim.trim(result.stderr), vim.log.levels.WARN)
                end)
            end
        end)
    end

    local function sync_kitty_colors()
        local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
        local cursor = vim.api.nvim_get_hl(0, { name = "Cursor", link = false })
        local background = hex(normal.bg)
        -- Cursor.bg is the block cursor's colour.  Some schemes leave it
        -- unset, in which case the normal foreground remains a visible default.
        local cursor_color = hex(cursor.bg or normal.fg)

        if background and cursor_color then
            set_kitty_colors({ background = background, cursor = cursor_color })
        end
    end

    local group = vim.api.nvim_create_augroup("lunarfolk_kitty_theme_sync", { clear = true })
    vim.api.nvim_create_autocmd({ "ColorScheme", "VimResume" }, {
        group = group,
        callback = sync_kitty_colors,
    })
    vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
        group = group,
        callback = function()
            if next(original_colors) then
                set_kitty_colors(original_colors)
            end
        end,
    })
end

return {
    {
        "tinted-theming/tinted-nvim",
        priority = 1000,
        lazy = false,
        config = function(_, opts)
            -- Register first so tinted-nvim's initial ColorScheme event is
            -- synchronized as well as subsequent Telescope selections.
            setup_kitty_theme_sync()
            require("tinted-nvim").setup(opts)
        end,
        opts = {
            default_scheme = "base16-default-dark",
            highlights = {
                -- Prefer red (base08) for keywords, matching old vim/helix feel vs default purple, plus
                -- some personal preferences for macros, type aliases, modules, etc.
                overrides = function(palette)
                    local red = palette.base08
                    return {
                        Keyword = { fg = red },
                        StorageClass = { fg = red },
                        Conditional = { fg = red },
                        Repeat = { fg = red },
                        Exception = { fg = red },
                        Statement = { fg = red },
                        ["@keyword"] = { fg = red },
                        ["@keyword.storage"] = { fg = red },
                        ["@storageclass"] = { fg = red },
                        ["@keyword.function"] = { fg = red },
                        ["@keyword.return"] = { fg = red },
                        ["@conditional"] = { fg = red },
                        ["@repeat"] = { fg = red },
                        ["@function.macro"] = { link = "Function" },
                        TSFuncMacro = { link = "Function" },
                        rustSigil = { link = "Type" },
                        ["@lsp.type.type.rust"] = { link = "Type" },
                        ["@lsp.type.typeAlias.rust"] = { link = "Type" },
                        ["@lsp.type.typeParameter.rust"] = { link = "Type" },
                        ["@lsp.type.namespace.rust"] = { link = "Type" },
                        ["@lsp.type.builtinType.rust"] = { link = "Type" },
                    }
                end,
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", "tinted-theming/tinted-nvim" },
        config = function()
            require("lualine").setup({ options = { theme = lualine_tinted_theme } })
        end,
    },
}
