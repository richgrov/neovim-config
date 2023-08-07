-- Generic settings
vim.wo.number = true
vim.o.tabstop = 3
vim.o.shiftwidth = 3

-- https://vimtricks.com/p/vimtrick-moving-lines/
vim.keymap.set('n', '<C-j>', ':m .+1<CR>==', {noremap = true})
vim.keymap.set('n', '<C-k>', ':m .-2<CR>==', {noremap = true})

vim.keymap.set('i', '<C-j>', '<Esc>:m .+1<CR>==gi', {noremap = true})
vim.keymap.set('i', '<C-k>', '<Esc>:m .-2<CR>==gi', {noremap = true})

vim.keymap.set('v', '<C-j>', "'>+1<CR>gv=gv", {noremap = true})
vim.keymap.set('v', '<C-k>', "'>-2<CR>gv=gv", {noremap = true})

-- Packer
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()
require('packer').startup(function()
	use 'wbthomason/packer.nvim'

	use 'nvim-tree/nvim-tree.lua'
	use 'windwp/nvim-autopairs'
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'L3MON4D3/LuaSnip'
	use 'saadparwaiz1/cmp_luasnip'
	use 'mg979/vim-visual-multi'
	use 'tpope/vim-sleuth'
	use 'prettier/vim-prettier'

	use 'williamboman/mason.nvim'
	use 'williamboman/mason-lspconfig.nvim'
	use 'neovim/nvim-lspconfig'
	use 'nvim-treesitter/nvim-treesitter'
	use 'mfussenegger/nvim-dap'

	use 'ray-x/go.nvim'
	use 'leoluz/nvim-dap-go'

	if packer_bootstrap then
		require('packer').sync()
	end
end)

-- Theme
require 'nvim-treesitter.configs'.setup{
	highlight = {
		enable = true,
	}
}

vim.api.nvim_set_hl(0, 'StatusLine', { ctermfg = 0, ctermbg = 7 })
vim.api.nvim_set_hl(0, 'StatusLineNC', { ctermfg = 7, ctermbg = 0 })

vim.api.nvim_set_hl(0, '@function.macro', { ctermfg = 6 })
vim.api.nvim_set_hl(0, '@function.builtin', { ctermfg = 6 })
vim.api.nvim_set_hl(0, '@constant.builtin', { ctermfg = 6 })
vim.api.nvim_set_hl(0, '@variable.builtin', { ctermfg = 6 })

vim.api.nvim_set_hl(0, '@comment', { ctermfg = 7 })
vim.api.nvim_set_hl(0, 'Comment', { ctermfg = 7 })
vim.api.nvim_set_hl(0, 'LineNr', { ctermfg = 7 })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { ctermfg = 7 })
vim.api.nvim_set_hl(0, 'NvimTreeWinSeparator', { ctermfg = 7 })

vim.api.nvim_set_hl(0, '@type', { ctermfg = 9 })
vim.api.nvim_set_hl(0, '@type.definition', { ctermfg = 9 })

vim.api.nvim_set_hl(0, '@function', { ctermfg = 10 })
vim.api.nvim_set_hl(0, '@method', { ctermfg = 10 })

vim.api.nvim_set_hl(0, '@keyword', { ctermfg = 12 })
vim.api.nvim_set_hl(0, '@include', { ctermfg = 12 })
vim.api.nvim_set_hl(0, '@conditional', { ctermfg = 12 })
vim.api.nvim_set_hl(0, '@repeat', { ctermfg = 12 })
vim.api.nvim_set_hl(0, '@boolean', { ctermfg = 12 })
vim.api.nvim_set_hl(0, '@storageclass', { ctermfg = 12 })
vim.api.nvim_set_hl(0, '@exception', { ctermfg = 12 })
vim.api.nvim_set_hl(0, '@type.qualifier', { ctermfg = 12 })

vim.api.nvim_set_hl(0, '@string', { ctermfg = 14 })

vim.api.nvim_set_hl(0, '@operator', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@namespace', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@variable', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@constant', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@parameter', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@field', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@property', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@label', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@constructor', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@punctuation.bracket', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@punctuation.delimiter', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@punctuation.special', { ctermfg = 15 })
vim.api.nvim_set_hl(0, '@definition.parameter', { ctermfg = 15 })

-- Tree
require('nvim-tree').setup({
	on_attach = function(bufnr)
		local api = require('nvim-tree')
		vim.keymap.set('n', '+', api.focus, { noremap = true, silent = true })
	end,
	renderer = {
		icons = {
			show = {
				file = false,
				folder = false,
				folder_arrow = false,
				git = false,
				modified = false,
			},
		},
	},
	git = {
		ignore = false,
	},
})

vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = function()
	require('nvim-tree.api').tree.open()
end })

require('nvim-autopairs').setup({})

-- Languages
require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = { 'gopls', 'rust_analyzer', 'tsserver', 'html', 'clangd', 'tailwindcss' }
})

local lspconfig = require('lspconfig')
local lsp_on_attach = function(client, bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'rn', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<C-p>', vim.lsp.buf.signature_help, bufopts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
require('mason-lspconfig').setup_handlers({
	function(id)
		lspconfig[id].setup({
			on_attach = lsp_on_attach,
			capabilities = capabilities,
			settings = {
				['rust-analyzer'] = {
					procMacro = { enable = true },
					assist = { importMergeBehaviour = 'last' },
				}
			}
		})
	end
})

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

require('go').setup()
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
   require('go.format').goimport()
  end,
  group = vim.api.nvim_create_augroup("GoFormat", {}),
})

vim.keymap.set('n', '<C-Q>', require 'dap.ui.widgets'.hover, {noremap = true})
vim.keymap.set('n', '<C-b>', require 'dap'.toggle_breakpoint, {noremap = true})

require('dap-go').setup()

vim.g['prettier#autoformat'] = 1
vim.g['prettier#autoformat_require_pragma'] = 0
