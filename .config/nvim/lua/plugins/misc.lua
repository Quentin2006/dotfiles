-- Standalone plugins with less than 10 lines of config go here
return {
	{
		"github/copilot.vim",
		event = "InsertEnter", -- lazy-load on first insert
		config = function()
			vim.g.copilot_enabled = true

			-- Toggle function
			function ToggleCopilot()
				if vim.g.copilot_enabled then
					vim.cmd("Copilot disable")
					vim.g.copilot_enabled = false
					vim.notify("Copilot disabled", vim.log.levels.INFO)
				else
					vim.cmd("Copilot enable")
					vim.g.copilot_enabled = true
					vim.notify("Copilot enabled", vim.log.levels.INFO)
				end
			end

			-- Keymap: <leader>ct (Copilot Toggle)
			vim.keymap.set("n", "<leader>tc", ToggleCopilot, {
				noremap = true,
				silent = true,
				desc = "[T]oggle [C]opiolit",
			})
		end,
	},
	{
		"numToStr/FTerm.nvim",
		config = function()
			local fterm = require("FTerm")

			-- Optional: Customize appearance
			fterm.setup({
				border = "rounded",
				dimensions = {
					height = 0.9,
					width = 0.9,
					x = 0.5,
					y = 0.5,
				},
			})

			-- Keymap to toggle terminal
			vim.keymap.set("n", "<leader>tt", fterm.toggle, { desc = "[T]oggle Floating [T]erminal" })
			vim.keymap.set("n", "<leader>tt", fterm.toggle, { desc = "[T]oggle Floating [T]erminal" })
			vim.keymap.set("t", "<leader>tt", fterm.toggle, { desc = "[T]oggle Floating [T]erminal" })
		end,
	},
	{
		"hrsh7th/cmp-cmdline",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			local cmp = require("cmp")
			cmp.setup.cmdline(":", {
				sources = {
					{ name = "cmdline" },
				},
			})
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},
	{
		-- Tmux & split window navigation
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
			"TmuxNavigatorProcessList",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
		},
	},
	{
		-- Detect tabstop and shiftwidth automatically
		"tpope/vim-sleuth",
	},
	{
		-- Powerful Git integration for Vim
		"tpope/vim-fugitive",
	},
	{
		-- GitHub integration for vim-fugitive
		"tpope/vim-rhubarb",
	},
	{
		-- Hints keybinds
		"folke/which-key.nvim",
	},
	{
		-- Autoclose parentheses, brackets, quotes, etc.
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = {},
	},
	{
		-- Highlight todo, notes, etc in comments
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		-- High-performance color highlighter
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
}
