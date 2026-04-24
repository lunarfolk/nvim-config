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

return {
    {
        "shaun-mathew/Chameleon.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("chameleon").setup()
        end,
    },
    {
        "tinted-theming/tinted-nvim",
        priority = 999,
        lazy = false,
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
        end
    },
}
