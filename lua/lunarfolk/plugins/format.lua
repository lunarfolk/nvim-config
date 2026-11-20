return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        opts = {
            formatters_by_ft = {
                nix = { "nixfmt" },
                python = { "ruff_organize_imports", "ruff_format" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "never",
            },
        },
    },
}
