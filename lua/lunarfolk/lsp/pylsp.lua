local function find_python_venv(root)
    if not root then
        return
    end

    -- Look for a shared uv workspace env, but don't pick up one outside the repo.
    local repo = vim.fs.root(root, ".git")
    local candidates = vim.fs.find(".venv", {
        path = root,
        upward = true,
        stop = repo and vim.fs.dirname(repo),
        type = "directory",
        limit = math.huge,
    })
    for _, venv in ipairs(candidates) do
        if vim.fn.executable(venv .. "/bin/python") == 1 then
            return venv
        end
    end
end

local function start_pylsp(dispatchers, config)
    local venv = find_python_venv(config.root_dir)
    local env = config.cmd_env
    if venv then
        -- Prefer project tools for both pylsp and the mypy subprocess it launches.
        local bin = venv .. "/bin"
        env = vim.tbl_extend("force", {}, env or {})
        local path = env.PATH or vim.env.PATH or ""
        env.PATH = path == "" and bin or bin .. ":" .. path
    end

    return vim.lsp.rpc.start({ "pylsp" }, dispatchers, {
        -- A shared .venv means mypy should resolve relative paths from the workspace root.
        cwd = venv and vim.fs.dirname(venv) or config.root_dir,
        env = env,
        detached = config.detached,
    })
end

return {
    cmd = start_pylsp,
    settings = {
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
    },
    before_init = function(_, config)
        local venv = find_python_venv(config.root_dir)
        if not venv then
            return
        end

        -- Update the settings table Neovim will send just after initialization.
        local plugins = config.settings.pylsp.plugins
        plugins.jedi = plugins.jedi or {}
        plugins.jedi.environment = venv
        plugins.pylsp_mypy.overrides = { "--python-executable", venv .. "/bin/python", true }
    end,
}
