return {
    {
        "nvim-telescope/telescope.nvim", branch = "master",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = false, -- neo-tree will lazily load itself
        ---@module 'neo-tree'
        ---@type neotree.Config
        opts = {
            popup_border_style = "",
            window = {
                position = "float"
            }
        }
    }
}
