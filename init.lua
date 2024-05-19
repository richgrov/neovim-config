vim.cmd.source(vim.fn.stdpath("config") .. "/vimrc.vim")

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

	use 'nvim-telescope/telescope.nvim'
	use 'nvim-lua/plenary.nvim'
	use 'windwp/nvim-autopairs'
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'L3MON4D3/LuaSnip'
	use 'saadparwaiz1/cmp_luasnip'
	use 'mg979/vim-visual-multi'
	use 'tpope/vim-sleuth'
	use 'prettier/vim-prettier'

	use 'neovim/nvim-lspconfig'
	use 'nvim-treesitter/nvim-treesitter'

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

require('telescope').setup({
	pickers = {
		find_files = {
			find_command = {'rg', '--files', '--hidden', '-g', '!.git'}
		},
	},
})
local telescope = require('telescope.builtin')
vim.keymap.set('n', '-', telescope.find_files, { noremap = true, silent = true })
vim.keymap.set('n', '+', telescope.lsp_dynamic_workspace_symbols, { noremap = true, silent = true })

require('nvim-autopairs').setup({})

vim.lsp.set_log_level("warn")
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local formatGroup = vim.api.nvim_create_augroup('LspFormatting', {})

function lsp_allowed(name)
	return name ~= "html" and name ~= "cssls" and name ~= "tsserver" and name ~= "tailwindcss"
end

function lsp_attach(client, bufnr)
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

local servers = { 'rust_analyzer', 'tailwindcss', 'gopls', 'pyright', 'html', 'cssls', 'tsserver', 'clangd', 'dartls' }
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
