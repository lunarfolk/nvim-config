local builtin = require("telescope.builtin")
local utils = require("lunarfolk.utils")

-- Telescope
vim.keymap.set('n', "<leader>f", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set('n', "<leader>g", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set('n', "<leader>h", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set('n', "<leader>ut", function()
    builtin.colorscheme({ enable_preview = true })
end, { desc = "Telescope colorscheme picker" })

-- Neotree
vim.keymap.set('n', "<leader>e", "<Cmd>Neotree reveal<CR>", { desc = "Open file explorer" })

-- AI agent
vim.keymap.set('n', "<leader>o", "<Cmd>vsplit | terminal cursor-agent<CR>", { desc = "Open cursor-agent in vertical split" })
vim.keymap.set('t', "<C-Space>", "<C-\\><C-N>", { desc = "Unfocus terminal" })

-- CodeDiff
local codediff_group = vim.api.nvim_create_augroup("lunarfolk_codediff_group", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = codediff_group,
    callback = function()
        if utils.is_in_codediff_tab() then
            vim.keymap.set('n', "<space>i", "<Cmd>CodeDiff<CR>", {
                desc = "Close CodeDiff",
                buffer = 0,
                silent = true
            })
            --
            pcall(vim.keymap.del, 'n', "<leader>ii", { buffer = 0 })
            pcall(vim.keymap.del, 'n', "<leader>ib", { buffer = 0 })
        else
            vim.keymap.set('n', "<leader>ii", "<Cmd>CodeDiff<CR>", { desc = "Open git status diff", buffer = 0 })
            vim.keymap.set('n', "<leader>ib", function()
                local branch = vim.fn.input("Branch name: ")
                if branch ~= "" then
                    vim.cmd("CodeDiff " .. branch)
                end
            end, { desc = "Open git diff against branch", buffer = 0 })
            --
            pcall(vim.keymap.del, 'n', "<space>i", { buffer = 0 })
        end
    end
})

-- LSP
local lsp_group = vim.api.nvim_create_augroup("lunarfolk_lsp_group", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Set buffer-local key bindings when LSP gets attached",
    group = lsp_group,
    callback = function(e)
        local telescope = require("telescope.builtin")
        vim.keymap.set("n", "gd", telescope.lsp_definitions, { buffer = e.buf, desc = "Go-to defintion" })
        vim.keymap.set("n", "gr", telescope.lsp_references, { buffer = e.buf, desc = "Go-to references" })
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { buffer = e.buf, desc = "Hover" })
        vim.keymap.set("n", "<leader>s", telescope.lsp_document_symbols, { buffer = e.buf, desc = "Find symbol in buffer" })
        vim.keymap.set("n", "<leader>S", telescope.lsp_workspace_symbols, { buffer = e.buf, desc = "Find symbol in workspace" })
        vim.keymap.set("n", "<leader>a", function() vim.lsp.buf.code_action() end, { buffer = e.buf, desc = "Code action" })
        vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.rename() end, { buffer = e.buf, desc = "Rename symbol" })
        vim.keymap.set("n", "<leader>D", telescope.diagnostics, { buffer = e.buf, desc = "List diagnostics" })
        --vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, { buffer = e.buf, desc = "Display signature help" })
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { buffer = e.buf, desc = "Display float diagnostic" })
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = 1 }) end, { buffer = e.buf, desc = "Jump to next diagnostic" })
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = -1 }) end, { buffer = e.buf, desc = "Jump to previous diagnostic" })
    end
})
