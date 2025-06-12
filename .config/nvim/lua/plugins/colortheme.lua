return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000, -- Ensure it's loaded early
	config = function()
		require("catppuccin").setup({
			transparent_background = true,
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				treesitter = true,
				mini = {
					enabled = true,
					indentscope_color = "",
				},
			},
		})
		vim.cmd("colorscheme catppuccin")
	end,
}
