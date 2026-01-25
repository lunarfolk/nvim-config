return {
    {
        "shaun-mathew/Chameleon.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("chameleon").setup()
        end,
    },
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 999,
        config = function()
            vim.cmd([[colorscheme terafox]])
        end,
    },
    {
        "sainnhe/everforest",
        config = function()
            vim.g.everforest_background = "hard"
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({ options = { theme = "terafox" } })
        end
    },
}
