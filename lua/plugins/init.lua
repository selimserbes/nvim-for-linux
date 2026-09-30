return {
	-- KRL
	{
		"KnoP-01/krl-for-vim",
		ft = { "krl", "src", "dat" },
	},
	-- Claude Code Neovim IDE integration
	-- Requires the `claude` CLI to be available in PATH. Your Foundry/Azure
	-- environment variables should stay in ~/.zshrc; do not put API keys here.
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = true,
		cmd = {
			"ClaudeCode",
			"ClaudeCodeFocus",
			"ClaudeCodeSelectModel",
			"ClaudeCodeAdd",
			"ClaudeCodeSend",
			"ClaudeCodeTreeAdd",
			"ClaudeCodeStatus",
			"ClaudeCodeStart",
			"ClaudeCodeStop",
			"ClaudeCodeOpen",
			"ClaudeCodeClose",
			"ClaudeCodeDiffAccept",
			"ClaudeCodeDiffDeny",
			"ClaudeCodeCloseAllDiffs",
		},
		opts = {
			terminal_cmd = "claude",
			focus_after_send = true,
			terminal = {
				provider = "auto",
				split_side = "right",
				split_width_percentage = 0.35,
			},
			diff_opts = {
				layout = "vertical",
				open_in_new_tab = false,
			},
		},
		keys = {
			{ "<leader>a", nil, desc = "AI/Claude Code" },
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: focus" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: resume" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Claude: add file from tree",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
			},
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: deny diff" },
		},
	},

	-- Dressing.nvim (vim.ui.select / vim.ui.input için)
	{
		"stevearc/dressing.nvim",
		lazy = false, -- hemen yükle
		config = function()
			require("dressing").setup({
				input = { enabled = true },
				select = { enabled = true },
			})
		end,
	},

	-- Mini Icons
	{
		"echasnovski/mini.icons",
		config = function()
			require("mini.icons").setup()
		end,
		lazy = false,
	},

	-- nvim-spectre
	{
		"nvim-pack/nvim-spectre",
		config = function()
			require("spectre").setup()
			require("mappings").load_plugin("spectre")
		end,
		lazy = false,
	},

	-- DAP Python
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
		config = function()
			require("dap-python").setup("debugpy-adapter")
			require("mappings").load_plugin("dap")
		end,
	},

	-- Go plugin
	{
		"olexsmir/gopher.nvim",
		ft = "go",
		config = function(_, opts)
			require("gopher").setup(opts)
			require("mappings").load_plugin("gopher")
		end,
		build = function()
			vim.cmd([[silent! GoInstallDeps]])
		end,
	},

	-- DAP UI
	{
		"rcarriga/nvim-dap-ui",
		event = "VeryLazy",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},

	-- nvim-dap
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		config = function()
			require("configs.dap")
			require("mappings").load_plugin("dap")
		end,
	},

	-- Conform formatter
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = require("configs.conform"),
	},

	-- nvim-lint
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("configs.lint")
		end,
	},

	-- Java LSP / DAP / Test integration
	-- JDTLS is started from lua/configs/lspconfig.lua to keep the original structure.
	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		dependencies = { "mfussenegger/nvim-dap" },
	},

	-- Crystal filetype
	{
		"vim-crystal/vim-crystal",
		ft = "crystal",
		config = function()
			vim.g.crystal_auto_format = 1
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("configs.lspconfig")
		end,
	},

	-- Mason
	{
		"mason-org/mason.nvim",
		lazy = false,
		opts = function(_, opts)
			-- NvChad defaults to PATH="skip". Prepending Mason's bin directory makes
			-- LSP/formatter/DAP executables available consistently on clean machines.
			opts.PATH = "prepend"
			return opts
		end,
		config = function(_, opts)
			require("mason").setup(opts)
		end,
	},

	-- nvim-ts-autotag
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	-- nvim-treesitter (rewritten `main` API, requires Neovim >= 0.12)
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			-- Keep this as a plain table: NvChad's :TSInstallAll command reads
			-- `spec.opts.ensure_installed` and calls the new install() API.
			ensure_installed = {
				"lua",
				"luadoc",
				"vim",
				"vimdoc",
				"printf",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"go",
				"rust",
				"python",
				"markdown",
				"markdown_inline",
				"slint",
				"java",
				"json",
				"yaml",
				"toml",
				"bash",
			},
		},
		config = function(_, opts)
			require("configs.treesitter").setup(opts)
		end,
	},

}
