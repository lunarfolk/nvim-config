return {
    {
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({
                ignore_filetypes = { markdown = true },
                condition = function()
                    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
                    return filename == ".env" or filename:match("^%.env%.") ~= nil
                end,
            })
        end,
    },
}
