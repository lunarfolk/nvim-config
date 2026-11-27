local function find_python_venv(root)
    -- A workspace member can have its own LSP root but share an ancestor's virtualenv.
    return root and vim.fs.find(".venv", { path = root, upward = true, type = "directory" })[1]
end

local function start_pylsp(dispatchers, config)
    -- Resolve pylsp before changing its child process's PATH.
    local pylsp = vim.fn.exepath("pylsp")
    local venv = find_python_venv(config.root_dir)
    local bin = venv and (venv .. "/bin")
    if pylsp ~= "" and bin and vim.fn.executable(bin .. "/mypy") == 1 then
        -- pylsp-mypy finds mypy on PATH. Running the project's mypy lets it load
        -- project plugins, which --python-executable alone does not do.
        local env = vim.tbl_extend("force", {}, config.cmd_env or {})
        local path = env.PATH or vim.env.PATH or ""
        if path ~= bin and not vim.startswith(path, bin .. ":") then
            path = path == "" and bin or bin .. ":" .. path
        end
        env.PATH = path
        config.cmd_env = env
    end

    return vim.lsp.rpc.start({ pylsp ~= "" and pylsp or "pylsp" }, dispatchers, {
        cwd = config.cmd_cwd,
        env = config.cmd_env,
        detached = config.detached,
    })
end

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
                cmd = start_pylsp,
                on_init = function(client)
                    local config = client.config
                    local venv = find_python_venv(config.root_dir)

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

                                pylsp_mypy = {
                                    live_mode = false,
                                },
                            },
                        },
                    }

                    -- Use the nearest project/workspace virtualenv when present.
                    if venv then
                        settings.pylsp.plugins.jedi = {
                            environment = venv,
                        }

                        local python = venv .. "/bin/python"
                        if vim.fn.executable(python) == 1 then
                            -- Resolve packages and stubs from the project environment.
                            settings.pylsp.plugins.pylsp_mypy.overrides = { "--python-executable", python, true }
                        end
                    end

                    client.settings = vim.tbl_deep_extend("force", client.settings or {}, settings)
                    config.settings = client.settings
                    client:notify("workspace/didChangeConfiguration", { settings = client.settings })
                end,
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
