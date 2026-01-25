local default_group = vim.api.nvim_create_augroup("lunarfolk_default_group", { clear = true })

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
