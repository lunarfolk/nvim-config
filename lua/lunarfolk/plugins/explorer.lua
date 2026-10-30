return {
    {
        "nvim-telescope/telescope.nvim", branch = "master",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = function(_, opts)
            opts.pickers = opts.pickers or {}
            opts.pickers.live_grep = opts.pickers.live_grep or {}

            opts.pickers.live_grep.additional_args = function()
                return { "--hidden", "--no-ignore", "--glob", "!.git/**", "--glob", "!**/.pytest_cache/**" }
            end
        end,
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
            },
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    never_show = { ".git" },
                },
            }
        }
    }
}
