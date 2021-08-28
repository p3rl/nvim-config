local utils = require'utils'
local map, opt, set_var, nvim_create_augroups = utils.map, utils.opt, utils.set_var, utils.create_augroups
local cmd, fn, g, api = vim.cmd, vim.fn, vim.g, vim.api

-- Plugins
-------------------------------------------------------------------------------
vim.cmd 'packadd paq-nvim'
local paq = require('paq-nvim').paq

paq {'savq/paq-nvim', opt = true}    -- paq-nvim manages itself
--paq {'nvim-lua/popup.nvim'}
paq {'nvim-lua/plenary.nvim'}
paq {'neovim/nvim-lspconfig'}
paq {'junegunn/fzf', hook = fn['fzf#install']}
paq {'junegunn/fzf.vim'}
paq {'hoob3rt/lualine.nvim'}
paq {'folke/tokyonight.nvim'}
paq {'RishabhRD/popfix'}
paq {'hrsh7th/nvim-compe'}
--paq {'nvim-telescope/telescope.nvim'}
paq {'kyazdani42/nvim-web-devicons'}
paq {'kyazdani42/nvim-tree.lua'}

-- Local plugins
package.loaded['p4'] = nil
package.loaded['psue'] = nil
package.loaded['grep'] = nil
package.loaded['fastbuf'] = nil
package.loaded['statusline'] = nil
package.loaded['lsp'] = nil

-- Theme
-------------------------------------------------------------------------------
local theme = { colorscheme = 'tokyonight', background = 'dark'}
vim.g.tokyonight_style = "night" -- storm|night|day

cmd('colorscheme ' .. theme.colorscheme)
cmd('set background=' .. theme.background)
set_var('fzf_layout', { down = '20%' })

-- Settings
-------------------------------------------------------------------------------
cmd 'language en'
cmd 'syntax enable'
cmd 'filetype on'
cmd 'set clipboard+=unnamedplus'
cmd 'set noswapfile'
--cmd 'set listchars=space:_'
set_var('mapleader', ',')

-- Tabs
local indent = 4
local spaces_instead_of_tabs = false
opt('b', 'shiftwidth', indent)                          -- Size of indent
opt('b', 'tabstop', indent)                             -- Number of spaces tabs count for
opt('b', 'softtabstop', indent)                         -- Number of spaces that a <Tab> counts for while performing editingoperations, like inserting a <Tab> or using <BS>
opt('o', 'expandtab', spaces_instead_of_tabs)           -- Spaces instead of tabs
opt('b', 'autoindent', true)                            -- Copy indent from current line when starting a new line
opt('b', 'smartindent', true)                           -- Do smart autoindenting when starting a new line
opt('o', 'smarttab', true)                              -- When on, a <Tab> in front of a line inserts blanks according to
opt('b', 'cindent', true)
cmd 'set listchars=tab::.'                              -- Show tabs

opt('o', 'ignorecase', true)                            --
opt('o', 'incsearch', true)                             --
opt('o', 'laststatus', 2)                               --
opt('o', 'backup', false)                               --
opt('o', 'swapfile', false)                             --
opt('o', 'hidden', true)                                --
opt('w', 'cursorline', true)                            -- Highlight current line
opt('w', 'list', false)                                 -- Show some invisible characters (tabs...)
opt('w', 'number', true)                                -- Print line number
opt('w', 'relativenumber', false)                       -- Relative line numbers
opt('w', 'wrap', false)                                 -- Disable wrapping
opt('o', 'completeopt', 'menuone,noselect')             -- Completion options (for deoplete)
opt('o', 'shiftround', true)                            -- Round indent
opt('o', 'scrolloff', 4 )                               -- Lines of context
opt('o', 'sidescrolloff', 8)                            -- Columns of context
opt('o', 'smartcase', true)                             -- Don't ignore case with capitals
opt('o', 'splitbelow', true)                            -- Put new windows below current
opt('o', 'splitright', true)                            -- Put new windows right of current
opt('o', 'termguicolors', true)                         -- True color support
opt('o', 'wildmode', 'full')                            -- Command-line completion mode
opt('o', 'ttyfast', true)                               -- Should make scrolling faster
opt('o', 'lazyredraw', false)                            -- Same as above
opt('o', 'ignorecase', true)                            -- 
opt('o', 'smartcase', true)                             -- 
opt('w', 'foldmethod', 'syntax')                        -- Fold method
opt('o', 'foldcolumn', '0')                             -- Fold columns
opt('o', 'foldlevelstart', 99)                          -- Default fold level

-- Commands
-------------------------------------------------------------------------------
cmd 'command! CopyPath :let @+= expand("%:p") | echo expand("%:p")'
cmd 'command! CopyDir :let @+= expand("%:p:h") | echo expand("%:p:h")'
cmd "command! EditConfig :exec printf(':e %s/init.lua', stdpath('config'))"
cmd "command! EditGConfig :exec printf(':e %s/ginit.vim', stdpath('config'))"
cmd [[command! UEquickfix :lua require'psue'.read_quickfix()]]
cmd [[command! Notes :e c:/git/docs/ue/ue.md]]
cmd [[command! -nargs=+ -complete=dir -bar Grep lua require'grep'.async_grep(<q-args>)]]
-- FastBuf
cmd [[command! -nargs=0 FbPin lua require'fastbuf'.pin_buffer()]]
cmd [[command! -nargs=0 FbUnpin lua require'fastbuf'.unpin_buffer()]]
cmd [[command! -nargs=0 FbUnpinAll lua require'fastbuf'.unpin_all()]]
cmd [[command! -nargs=0 FbSelectPinned lua require'fastbuf'.select_pinned_buffer()]]
cmd [[command! -nargs=0 FbTogglePinned lua require'fastbuf'.toggle_pinned()]]
-- Perforce
cmd [[command! -nargs=* P4init :lua require'p4'.init(<q-args>)]]
cmd [[command! P4edit :lua require'p4'.edit()]]
cmd [[command! P4revert :lua require'p4'.revert()]]
cmd [[command! -nargs=? P4revgraph :lua require'p4'.revision_graph(<q-args>)]]
cmd [[command! -nargs=? P4timelapse :lua require'p4'.timelapse_view(<q-args>)]]
-- Perforce
cmd [[command! -nargs=0 ClangFormat :silent execute printf('!clang-format.exe -i %s', expand("%:p"))]]

-- Mappings
-------------------------------------------------------------------------------
map('n', '<F12>', '<cmd>execute printf(":tag %s", expand("<cword>"))<CR>')
map('n', '<A-F11>', [[<cmd>luafile %<CR><cmd>echo '"' . expand("%:p") . '"' . " reloaded"<CR>]])
map('n', '<C-F12>', '<cmd>EditConfig<CR>')
map('n', '<C-s>', '<cmd>w<CR>')
map('n', '<S-l>', '$')
map('n', '<S-h>', '0')
map('n', '<Esc>', '<cmd>noh<CR>')
map('n', '<C-n>', '<cmd>b#<CR>')
map('n', 'Y', 'y$')
map('i', 'jj', '<ESC>')
map('i', 'jk', '<ESC>')
map('i', '{', '{}<Left>')
map('i', '[', '[]<Left>')

-- File operations
map('n', '<leader>fc', '<cmd>CopyPath<CR>')
map('n', '<leader>fcd', '<cmd>CopyDir<CR>')
map('n', '<leader>fr', [[<cmd>:e %<CR><cmd>echo printf('"%s" reloaded', expand('%:p'))<CR>]])
map('n', '<leader>ffr', [[<cmd>:e! %<CR><cmd>echo printf('"%s" force reloaded', expand('%:p'))<CR>]])
map('n', '<C-Tab>', '<cmd>FbSelectPinned<CR>')
map('n', '<A-CR>', '<cmd>FbTogglePinned<CR>')

-- Perforce operations
map('n', '<leader>pe', '<cmd>P4edit<CR>')
map('n', '<leader>pr', '<cmd>P4rever<CR>')

-- PSUE
map('n', '<leader>qf', '<cmd>UEquickfix<CR>')

-- Quickfix
map('n', '<A-h>', '<cmd>cfirst<CR>')
map('n', '<A-j>', '<cmd>cn<CR>')
map('n', '<A-k>', '<cmd>cp<CR>')
map('n', '<leader>eo', '<cmd>copen 20<CR>')
map('n', '<leader>ec', '<cmd>cclose<CR>')

-- FZF
map('n', '<C-p>', '<cmd>Files<CR>')
map('n', '<C-;>', '<cmd>Buffers<CR>')
set_var('fzf_preview_window', '')

-- Folding
map('n', '<space>', 'za')
map('n', '<C-space>', 'zR')
map('n', '<S-space>', 'zM')

-- Search & Replace
map('n', 'gw', '<cmd>vim <cword> %<CR>:copen<CR>')
map('n', 'Gw', '<cmd>Grep <cword><CR>')
map('n', 'S', [[:%s/<C-R>=expand('<cword>')<CR>/<C-R>=expand('<cword>')<CR>/gc<Left><Left><Left>]])

-- Snippets
map('i', '<F5>', "<C-R>=strftime('%c')<CR>")
map('i', '<F9>', "PRAGMA_DISABLE_OPTIMIZATION")
map('i', '<S-F9>', "PRAGMA_ENABLE_OPTIMIZATION")

-- Window
map('n', '<A-Up>', '<cmd>resize +2<CR>')
map('n', '<A-Down>', '<cmd>resize -2<CR>')
map('n', '<A-Right>', '<cmd>vertical resize +2<CR>')
map('n', '<A-Left>', '<cmd>vertical resize -2<CR>')

-- Statusline
-------------------------------------------------------------------------------
require('lualine').setup {
  options = { 
    theme = theme.colorscheme,
    section_separators = {' ', ' '},
    component_separators = {' ', ' '}
  },
  sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = { 'encoding', 'fileformat', 'filetype' },
    lualine_z = { 'location'  },
  },
  inactive_sections = {
    lualine_a = {  },
    lualine_b = {  },
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {  },
    lualine_z = {   }
  },
  extensions = { 'fzf' }
}

-- NvimTree
-------------------------------------------------------------------------------
set_var('nvim_tree_side', 'left')
set_var('nvim_tree_width', 60)
set_var('nvim_tree_ignore', {'.git', 'node_modules', '.cache'})
set_var('nvim_tree_auto_open', 0) 
set_var('nvim_tree_auto_close', 0)
set_var('nvim_tree_quit_on_open', 0)
set_var('nvim_tree_follow', 1)
set_var('nvim_tree_indent_markers', 0)
set_var('nvim_tree_hide_dotfiles', 1)
set_var('nvim_tree_width_allow_resize', 1)
set_var('nvim_tree_disable_netrw', 0)
set_var('nvim_tree_hijack_netrw', 0)
set_var('nvim_tree_add_trailing', 1)
set_var('nvim_tree_show_icons', { git = 0, folders = 0, files = 0})
map('n', '<F1>', '<cmd>NvimTreeToggle<CR>')

-- LSP
require'lsp'.setup()
set_var('completion_matching_strategy_list', {'exact', 'substring', 'fuzzy', 'all'})
map('n', 'gd', '<cmd>:lua vim.lsp.buf.definition()<CR>')
map('n', 'gD', '<cmd>:lua vim.lsp.buf.declaration()<CR>')
cmd [[command! -nargs=0 LspLog :lua vim.cmd('e '..vim.lsp.get_log_path())]]
cmd [[command! -nargs=0 LspStop :lua require'lsp'.stop_all_clients()]]

-- Filetype hooks
g_filetype_hooks = {
  lua = function()
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
  pwsh = function()
    vim.bo.expandtab = true
  end
}

nvim_create_augroups {
  filetype_hooks = {
    { 'FileType', 'lua', [[lua g_filetype_hooks.lua()]] },
    { 'FileType', 'psm1', [[lua g_filetype_hooks.pwsh()]] },
    { 'FileType', 'ps1', [[lua g_filetype_hooks.pwsh()]] }
  }
}

--Terminal
map('t', '<Esc>', [[<C-\><C-n>]])

local autocmds = {
  terminal = {
    { 'TermOpen', '*', 'startinsert' }
  }
}
nvim_create_augroups(autocmds)
