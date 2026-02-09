--[[
Neovim Configuration File
A comprehensive configuration with plugins and basic settings
--]]

-- PLUGIN MANAGER BOOTSTRAP
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

-- PLUGINS CONFIGURATION
require('packer').startup(function(use)
-- Packer can manage itself
use 'wbthomason/packer.nvim'

-- LSP Support
use 'neovim/nvim-lspconfig'

-- Autocompletion
use 'hrsh7th/nvim-cmp'
use 'hrsh7th/cmp-nvim-lsp'
use 'hrsh7th/cmp-buffer'
use 'hrsh7th/cmp-path'

-- Fuzzy Finder
use {
    'nvim-telescope/telescope.nvim',
    requires = {'nvim-lua/plenary.nvim'}
}

-- File Explorer
use {
    'nvim-tree/nvim-tree.lua',
    requires = {'nvim-tree/nvim-web-devicons'}
}

-- Status Line
use {
    'nvim-lualine/lualine.nvim',
    requires = {'nvim-tree/nvim-web-devicons'}
}

-- Treesitter
use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
}

-- aider
use {
    'joshuavial/aider.nvim'
}

-- amp.nvim
use 'sourcegraph/amp.nvim'

if packer_bootstrap then
    require('packer').sync()
end
end)

-- PLUGIN CONFIGURATIONS
-- LSP Configuration
local lspconfig = require('lspconfig')
-- Add your language servers here, for example:
-- lspconfig.pyright.setup{}
-- lspconfig.tsserver.setup{}

-- Completion Configuration
local cmp = require('cmp')
cmp.setup({
mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
}),
sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' }
})
})

-- Telescope Configuration
local telescope = require('telescope')
telescope.setup()

-- NvimTree Configuration
require('nvim-tree').setup()

-- Lualine Configuration
require('lualine').setup()

-- Treesitter Configuration
require('nvim-treesitter.configs').setup({
ensure_installed = { "lua", "vim", "vimdoc" },
highlight = { enable = true },
})

-- KEYMAPPINGS FOR PLUGINS
local map = vim.keymap.set
-- Telescope
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })

-- NvimTree
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle file explorer' })

-- LSP
map('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
map('n', 'K', vim.lsp.buf.hover, { desc = 'Show hover information' })
map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })

-- BASIC EDITOR SETTINGS
-- Enable line numbers
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers

-- INDENTATION SETTINGS
-- Configure tab behavior
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.tabstop = 4        -- Number of spaces for a tab
vim.opt.shiftwidth = 4     -- Number of spaces for each indentation level
vim.opt.smartindent = true -- Enable smart indenting

-- VISUAL SETTINGS
-- Enable syntax highlighting and UI elements
vim.opt.syntax = 'on'      -- Enable syntax highlighting
vim.opt.termguicolors = true -- Enable true color support
vim.opt.ruler = true       -- Show cursor position
vim.opt.showmatch = true   -- Highlight matching brackets
vim.opt.signcolumn = 'yes' -- Always show the signcolumn
vim.opt.cursorline = true  -- Highlight the current line

-- INTERACTION SETTINGS
-- Configure mouse and system interaction
vim.opt.mouse = 'a'        -- Enable mouse support in all modes
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard

-- SEARCH SETTINGS
-- Configure search behavior
vim.opt.ignorecase = true  -- Ignore case in search patterns
vim.opt.smartcase = true   -- Override ignorecase when search pattern contains uppercase
vim.opt.hlsearch = true    -- Highlight all search matches
vim.opt.incsearch = true   -- Show search matches as you type

