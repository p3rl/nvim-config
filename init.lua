local cmd, fn, g = vim.cmd, vim.fn, vim.g

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
end

local function set_var(name, value)
    vim.api.nvim_set_var(name, value)
end

-- Plugins
-------------------------------------------------------------------------------
vim.cmd 'packadd paq-nvim'
local paq = require('paq-nvim').paq

paq {'savq/paq-nvim', opt = true}    -- paq-nvim manages itself
paq {'lifepillar/vim-gruvbox8'}
paq {'junegunn/fzf', hook = fn['fzf#install']}
paq {'junegunn/fzf.vim'}

_G.p4 = require('p4/p4')
_G.psue = require('psue/psue')

-- Settings
-------------------------------------------------------------------------------
cmd 'language en'
cmd 'syntax enable'
cmd 'filetype on'
cmd 'set clipboard+=unnamedplus'
cmd 'colorscheme gruvbox8_hard'
cmd 'set background=light'
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

opt('w', 'list', true)                                  -- Show some invisible characters (tabs...)
opt('w', 'number', true)                                -- Print line number
opt('w', 'relativenumber', false)                       -- Relative line numbers
opt('w', 'wrap', false)                                 -- Disable wrapping
opt('o', 'completeopt', 'menuone,noinsert,noselect')    -- Completion options (for deoplete)
opt('o', 'shiftround', true)                            -- Round indent
opt('o', 'scrolloff', 4 )                               -- Lines of context
opt('o', 'sidescrolloff', 8)                            -- Columns of context
opt('o', 'smartcase', true)                             -- Don't ignore case with capitals
opt('o', 'splitbelow', true)                            -- Put new windows below current
opt('o', 'splitright', true)                            -- Put new windows right of current
opt('o', 'termguicolors', true)                         -- True color support
opt('o', 'wildmode', 'list:longest')                    -- Command-line completion mode
opt('o', 'ttyfast', true)                               -- Should make scrolling faster
opt('o', 'lazyredraw', true)                            -- Same as above
opt('o', 'ignorecase', true)                            -- 
opt('o', 'smartcase', true)                             -- 
opt('w', 'foldmethod', 'syntax')                        -- Fold method
opt('o', 'foldcolumn', '2')                             -- Fold columns

-- Commands
-------------------------------------------------------------------------------
cmd 'command! CopyPath :let @+= expand("%:p") | echo expand("%:p")'
cmd "command! EditVimConfig :exec printf(':e %s/init.vim', stdpath('config'))"
cmd "command! EditConfig :exec printf(':e %s/init.lua', stdpath('config'))"
cmd [[ command! P4edit :lua p4.edit()]]
cmd [[ command! P4revert :lua p4.revert()]]
cmd [[ command! UEquickfix :lua psue.read_quickfix()]]
cmd [[ command! Notes :e c:/git/docs/ue/ue.md]]

-- Mappings
-------------------------------------------------------------------------------
map('n', '<F12>', '<cmd>execute printf(":tag %s", expand("<cword>"))<CR>')
map('n', '-', '<cmd>Vexplore<CR>')
map('n', '<C-F12>', '<cmd>EditConfig<CR>')
map('n', '<C-s>', '<cmd>w<CR>')
map('n', '<S-l>', '$')
map('n', '<S-h>', '0')
map('n', '<Esc>', '<cmd>noh<CR>')
map('n', '<C-p>', '<cmd>Files<CR>')
map('n', '<C-;>', '<cmd>Buffers<CR>')
map('i', 'jj', '<ESC>')
map('i', 'jk', '<ESC>')
map('i', '{', '{}<Left>')
map('i', '[', '[]<Left>')

-- File operations
map('n', '<leader>fc', '<cmd>CopyPath<CR>')
map('n', '<leader>fr', '<cmd>:e %<CR>')
map('n', '<leader>ffr', '<cmd>:e! %<CR>')

-- Perforce operations
map('n', '<leader>pe', '<cmd>P4edit<CR>')
map('n', '<leader>pr', '<cmd>P4rever<CR>')

-- PSUE
map('n', '<leader>qf', '<cmd>UEquickfix<CR>')

-- Quickfix
map('n', '<A-h>', '<cmd>cfirst<CR>')
map('n', '<A-j>', '<cmd>cn<CR>')
map('n', '<A-k>', '<cmd>cp<CR>')

set_var('fzf_preview_window', '')
