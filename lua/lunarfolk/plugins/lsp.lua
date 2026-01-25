return {
    {
        "mason-org/mason.nvim",
        lazy = false,
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("rust_analyzer")
            vim.lsp.enable("bashls")
            vim.lsp.enable("pylsp")
            vim.lsp.enable("vtsls")
            vim.lsp.config('pylsp', {
                settings = {
                    pylsp = {
                        plugins = {
                            pycodestyle = {
                                maxLineLength = 100
                            }
                        }
                    }
                }
            })
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
         config = true
    }
}
