local default_group = vim.api.nvim_create_augroup("lunarfolk_default_group", { clear = true })

local function update_signcolumn(buf, detached_client_id)
    local has_lsp = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        if client.id ~= detached_client_id then
            has_lsp = true
            break
        end
    end

    -- signcolumn is window-local; update every window displaying this buffer.
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        vim.wo[win].signcolumn = has_lsp and "yes" or "auto"
    end
end

vim.api.nvim_create_autocmd({ "LspAttach", "BufWinEnter" }, {
    desc = "Reserve the sign column for buffers with an attached LSP",
    group = default_group,
    callback = function(e)
        update_signcolumn(e.buf)
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    desc = "Release the sign column when the last LSP detaches",
    group = default_group,
    callback = function(e)
        -- LspDetach fires before the client is removed from the buffer.
        update_signcolumn(e.buf, e.data.client_id)
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "Use tabs for indentation in CUE files",
    group = default_group,
    pattern = "cue",
    callback = function()
        vim.bo.expandtab = false
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "Use two-space indentation for HTML, CSS, and Nix",
    group = default_group,
    pattern = { "html", "css", "nix" },
    callback = function()
        vim.bo.expandtab = true
        vim.bo.tabstop = 2
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = default_group,
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Trim whitespaces before saving",
    group = default_group,
    command = [[%s/\s\+$//e]],
})

vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Refresh file when entering buffer if no pending changes",
    group = default_group,
    callback = function()
        if not vim.bo.modified then
            vim.cmd("checktime")
        end
    end,
})
