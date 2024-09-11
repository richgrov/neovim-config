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

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"ibhagwan/fzf-lua",
			-- optional for icon support
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				-- calling `setup` is optional for customization
				require("fzf-lua").setup({})
			end
		},
		{
			"tpope/vim-sleuth"
		},
		{ "https://github.com/hrsh7th/nvim-cmp" },
		{
			"https://github.com/neovim/nvim-lspconfig"
		},
		{
			"https://github.com/hrsh7th/cmp-nvim-lsp"
		},
		{
			"https://github.com/L3MON4D3/LuaSnip"
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	-- automatically check for plugin updates
	checker = { enabled = true },
})

--[[Packer
local packer_bootstrap = ensure_packer()
require('packer').startup(function()
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'L3MON4D3/LuaSnip'
	use 'saadparwaiz1/cmp_luasnip'
	use 'tpope/vim-sleuth'
	use 'prettier/vim-prettier'

	use 'neovim/nvim-lspconfig'
	use 'nvim-treesitter/nvim-treesitter'

	if packer_bootstrap then
		require('packer').sync()
	end
end)]]

-- Theme

require 'nvim-treesitter.configs'.setup{
	highlight = {
		enable = true,
	}
}
vim.keymap.set("n", "=", require('fzf-lua').files, { desc = "Fzf Files" })

local function setHighlight(color, groups)
	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(0, group, { ctermfg = color })
	end
end

vim.api.nvim_set_hl(0, 'StatusLine', { ctermfg = 0, ctermbg = 7 })
vim.api.nvim_set_hl(0, 'StatusLineNC', { ctermfg = 7, ctermbg = 'DarkGray' })
vim.api.nvim_set_hl(0, 'NormalFloat', { ctermbg = 'DarkGray' })

setHighlight(11, {
	'@string',
	'@string.special.url.html',
	'@constant.builtin',
	'@variable.constant',
})

setHighlight('DarkGray', {
	'@comment',
	'Comment',
	'LineNr',
	'EndOfBuffer',
	'NvimTreeWinSeparator',
	'@keyword.jsdoc',
})
setHighlight('Magenta', {
	'@keyword',
	'@tag',
	'@include',
	'@conditional',
	'@repeat',
	'@boolean',
	'@storageclass',
	'@exception',
	'@type.qualifier',
	'@number',
	'@float',
	'@function.macro',
	'@function.builtin',
	'@variable.builtin',
	'@constant.builtin',
	'@type.builtin.cpp',
	'PreProc',
})
setHighlight('NONE', {
	'@operator',
	'@tag.delimiter',
	'@tag.attribute',
	'@namespace',
	'@variable',
	'Identifier',
	'@constant',
	'@parameter',
	'@field',
	'@property',
	'@punctuation.bracket',
	'@punctuation.delimiter',
	'@punctuation.special',
	'@definition.parameter',
	'@function.builtin',
	'@constructor.lua',
	'@type',
	'Type',
	'@constructor',
})

--require('nvim-autopairs').setup({})

vim.lsp.set_log_level("warn")
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local formatGroup = vim.api.nvim_create_augroup('LspFormatting', {})

local function lsp_allowed(name)
	return name ~= "html" and name ~= "cssls" and name ~= "tsserver" and name ~= "tailwindcss"
end

local function lsp_attach(client, bufnr)
	client.server_capabilities.semanticTokensProvider = nil
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'rn', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<C-p>', vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set('n', '<C-q>', vim.lsp.buf.code_action, bufopts)

	if lsp_allowed(client.name) and client.supports_method('textDocument/formatting') then
		vim.api.nvim_clear_autocmds({ group = formatGroup, buffer = bufnr })
		vim.api.nvim_create_autocmd('BufWritePre', {
			group = formatGroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end
end

local servers = {
	'rust_analyzer', 'tailwindcss', 'gopls', 'pyright', 'html', 'cssls', 'tsserver', 'clangd',
	'dartls', 'lua_ls'
}

for _, server in ipairs(servers) do
	lspconfig[server].setup({
		settings = {
			["rust-analyzer"] = {
				procMacro = { enable = true },
				assist = { importMergeBeavior = 'last' },
				imports = {
					granularity = {
						group = "module",
					},
				},
			},
		},
		capabilities = capabilities,
		on_attach = lsp_attach,
	})
end

local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end
	},
	mapping = cmp.mapping.preset.insert({
		['<C-Space>'] = cmp.mapping.complete(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}, { name = 'buffer '}),
})

vim.g['prettier#autoformat'] = 1
vim.g['prettier#autoformat_require_pragma'] = 0
