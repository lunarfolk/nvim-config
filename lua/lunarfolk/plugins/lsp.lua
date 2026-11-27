return {
    {
        "mason-org/mason.nvim",
        lazy = false,
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        version = "v2.12.0",
        config = function()
            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        -- Fast, imports-based vulnerability diagnostics in go.mod.
                        vulncheck = "Imports",

                        -- Show a code lens on go.mod for the slower, precise govulncheck run.
                        codelenses = {
                            run_govulncheck = true,
                        },
                    },
                },
            })

            local puppet_gems = vim.fn.stdpath("data")
                .. "/mason/packages/puppet-editor-services/libexec/vendor/bundle/ruby/2.7.0"
            if vim.fn.isdirectory(puppet_gems) == 1 then
                -- Mason's launcher does not add its bundled gems to Ruby's search path.
                vim.lsp.config("puppet", {
                    cmd_env = {
                        -- An empty GEM_PATH suffix tells RubyGems to keep its defaults.
                        GEM_PATH = puppet_gems .. ":" .. (vim.env.GEM_PATH or ""),
                    },
                })
            end
            vim.lsp.config("pylsp", require("lunarfolk.lsp.pylsp"))

            vim.lsp.enable("pylsp")
            vim.lsp.enable("ruff")
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("rust_analyzer")
            vim.lsp.enable("gopls")
            vim.lsp.enable("bashls")
            vim.lsp.enable("vtsls")
            vim.lsp.enable("cue")
            vim.lsp.enable("puppet")
        end,
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },
}
