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

            vim.lsp.config("pylsp", {
                on_init = function(client)
                    local config = client.config
                    local venv = config.root_dir and vim.fs.joinpath(config.root_dir, ".venv")

                    local settings = {
                        pylsp = {
                            plugins = {
                                jedi_definition = {
                                    enabled = true,
                                    follow_imports = true,
                                    follow_builtin_imports = true,
                                },

                                pycodestyle = {
                                    maxLineLength = 100,
                                },
                            },
                        },
                    }

                    -- Only use the project's virtualenv when it exists
                    if venv and vim.fn.isdirectory(venv) == 1 then
                        settings.pylsp.plugins.jedi = {
                            environment = venv,
                        }
                    end

                    client.settings = vim.tbl_deep_extend("force", client.settings or {}, settings)
                    config.settings = client.settings
                    client:notify("workspace/didChangeConfiguration", { settings = client.settings })
                end,
            })

            vim.lsp.enable("pylsp")
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("rust_analyzer")
            vim.lsp.enable("gopls")
            vim.lsp.enable("bashls")
            vim.lsp.enable("vtsls")
            vim.lsp.enable("cue")
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
