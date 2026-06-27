return {
    {
        "0mykull/nvim-fountain",
        ft = "fountain",
        config = function()
            require("nvim-fountain").setup({
                use_treesitter = true,
            })
        end,
    },
}
