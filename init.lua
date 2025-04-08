vim.cmd.source(vim.fn.stdpath("config") .. "/vimrc.vim")

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
	spec = {
		{
			"ibhagwan/fzf-lua",
			config = function()
				-- calling `setup` is optional for customization
				require("fzf-lua").setup({})
			end,
		},
		{ "tpope/vim-sleuth" },
		{ "https://github.com/hrsh7th/nvim-cmp" },
		{ "https://github.com/neovim/nvim-lspconfig" },
		{ "https://github.com/hrsh7th/cmp-nvim-lsp" },
		{ "https://github.com/prettier/vim-prettier" },
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
		},
		{
			"TabbyML/vim-tabby",
			lazy = false,
			dependencies = {
				"neovim/nvim-lspconfig",
			},
			init = function()
				vim.g.tabby_agent_start_command = { "bunx", "tabby-agent", "--stdio" }
				vim.g.tabby_inline_completion_trigger = "auto"
				vim.g.tabby_inline_completion_keybinding_accept = "<C-/>"
			end,
		},
		{
			"greggh/claude-code.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			config = function()
				require("claude-code").setup()
			end,
		},
	},
	checker = {
		enabled = true,
		notify = false,
	},
})

local fzf = require("fzf-lua");

vim.keymap.set("n", "=", fzf.files, { desc = "Fzf Files" })

vim.lsp.set_log_level("warn")
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

local formatGroup = vim.api.nvim_create_augroup("LspFormatting", {})

local function lsp_allowed(name)
	return name ~= "html" and name ~= "cssls" and name ~= "ts_ls"
end

local function lsp_attach(client, bufnr)
	client.server_capabilities.semanticTokensProvider = nil
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "gr", fzf.lsp_references, bufopts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "rn", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<C-p>", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<C-q>", vim.lsp.buf.code_action, bufopts)

	if lsp_allowed(client.name) and client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = formatGroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = formatGroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end
end

local servers = {
	"rust_analyzer", "tailwindcss", "gopls", "pyright", "html", "cssls", "ts_ls", "clangd",
	"dartls", "lua_ls", "jdtls", "astro",
}

for _, server in ipairs(servers) do
	local filetypes = nil
	if server == "clangd" then
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "mm" }
	end

	lspconfig[server].setup({
		settings = {
			["rust-analyzer"] = {
				procMacro = { enable = true },
				assist = { importMergeBeavior = "last" },
				imports = {
					granularity = {
						group = "module",
					},
				},
			},
			["Lua"] = {
				format = {
					defaultConfig = {
						quote_style = "double",
						trailing_table_separator = "smart",
					},
				},
			},
			["python"] = {
				analysis = {
					typeCheckingMode = "off",
				},
			},
			["jdtls"] = {
				format = {
					enabled = true,
				},
			},
		},
		capabilities = capabilities,
		on_attach = lsp_attach,
		filetypes = filetypes,
	})
end

local cmp = require("cmp")
cmp.setup({
	mapping = cmp.mapping.preset.insert({
		["<C-x>"] = cmp.mapping.complete(),
		["<tab>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp", keyword_length = 2 },
	}, { name = "buffer " }),
})

vim.api.nvim_create_user_command("AutoTheme", function()
	local brightness = vim.fn.system("brightness -l | grep brightness | awk '{print $NF}'")
	if tonumber(brightness) >= 0.9 then
		vim.cmd("colorscheme delek")
	else
		vim.cmd("colorscheme habamax")
	end
end, { desc = "Auto-adjusts the theme based on the system's brightness level" })
