local cmd, fn, g, api = vim.cmd, vim.fn, vim.g, vim.api

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

function nvim_create_augroups(definitions)
	for group_name, definition in pairs(definitions) do
		api.nvim_command('augroup '..group_name)
		api.nvim_command('autocmd!')
		for _, def in ipairs(definition) do
			-- if type(def) == 'table' and type(def[#def]) == 'function' then
			-- 	def[#def] = lua_callback(def[#def])
			-- end
			local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
			api.nvim_command(command)
		end
		api.nvim_command('augroup END')
	end
end

-- Plugins
-------------------------------------------------------------------------------
vim.cmd 'packadd paq-nvim'
local paq = require('paq-nvim').paq

paq {'savq/paq-nvim', opt = true}    -- paq-nvim manages itself
paq {'lifepillar/vim-gruvbox8'}
paq {'junegunn/fzf', hook = fn['fzf#install']}
paq {'junegunn/fzf.vim'}
paq {'arcticicestudio/nord-vim'}
paq {'itchyny/lightline.vim'}
--paq {'lukas-reineke/indent-blankline.nvim'}

_G.p4 = require('p4/p4')
_G.psue = require('psue/psue')
_G.grep = require('grep/grep')

-- Theme
-------------------------------------------------------------------------------
set_var('nord_bold', 1)
set_var('nord_italic', 1)
set_var('nord_italic_comments', 1)
set_var('nord_cursor_line_number_background', 1)
--cmd 'set background=light'

local colorscheme = 'nord'
set_var('lightline', { colorscheme = colorscheme  })
cmd('colorscheme ' .. colorscheme)

-- Settings
-------------------------------------------------------------------------------
cmd 'language en'
cmd 'syntax enable'
cmd 'filetype on'
cmd 'set clipboard+=unnamedplus'
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
opt('o', 'completeopt', 'menuone,noinsert,noselect')    -- Completion options (for deoplete)
opt('o', 'shiftround', true)                            -- Round indent
opt('o', 'scrolloff', 4 )                               -- Lines of context
opt('o', 'sidescrolloff', 8)                            -- Columns of context
opt('o', 'smartcase', true)                             -- Don't ignore case with capitals
opt('o', 'splitbelow', true)                            -- Put new windows below current
opt('o', 'splitright', true)                            -- Put new windows right of current
opt('o', 'termguicolors', true)                         -- True color support
opt('o', 'wildmode', 'full')                            -- Command-line completion mode
opt('o', 'ttyfast', true)                               -- Should make scrolling faster
opt('o', 'lazyredraw', true)                            -- Same as above
opt('o', 'ignorecase', true)                            -- 
opt('o', 'smartcase', true)                             -- 
opt('w', 'foldmethod', 'syntax')                        -- Fold method
opt('o', 'foldcolumn', '2')                             -- Fold columns
opt('o', 'foldlevel', 99)                              -- Default fold level

-- Commands
-------------------------------------------------------------------------------
cmd 'command! CopyPath :let @+= expand("%:p") | echo expand("%:p")'
cmd 'command! CopyDir :let @+= expand("%:h") | echo expand("%:h")'
cmd "command! EditVimConfig :exec printf(':e %s/init.vim', stdpath('config'))"
cmd "command! EditConfig :exec printf(':e %s/init.lua', stdpath('config'))"
cmd [[command! P4edit :lua p4.edit()]]
cmd [[command! P4revert :lua p4.revert()]]
cmd [[command! UEquickfix :lua psue.read_quickfix()]]
cmd [[command! Notes :e c:/git/docs/ue/ue.md]]
cmd [[command! -nargs=+ -complete=dir -bar Grep lua grep.async_grep(<q-args>)]]

-- Mappings
-------------------------------------------------------------------------------
map('n', '<F12>', '<cmd>execute printf(":tag %s", expand("<cword>"))<CR>')
map('n', '<A-F11>', [[<cmd>luafile %<CR><cmd>echo '"' . expand("%:p") . '"' . " reloaded"<CR>]])
map('n', '-', '<cmd>Vexplore<CR>')
map('n', '<C-F12>', '<cmd>EditConfig<CR>')
map('n', '<C-s>', '<cmd>w<CR>')
map('n', '<S-l>', '$')
map('n', '<S-h>', '0')
map('n', '<Esc>', '<cmd>noh<CR>')
map('n', '<C-n>', '<cmd>b#<CR>')
map('i', 'jj', '<ESC>')
map('i', 'jk', '<ESC>')
map('i', '{', '{}<Left>')
map('i', '[', '[]<Left>')

-- File operations
map('n', '<leader>fc', '<cmd>CopyPath<CR>')
map('n', '<leader>fcd', '<cmd>CopyDir<CR>')
map('n', '<leader>fr', [[<cmd>:e %<CR><cmd>echo printf('"%s" reloaded', expand('%:p'))<CR>]])
map('n', '<leader>ffr', [[<cmd>:e! %<CR><cmd>echo printf('"%s" force reloaded', expand('%:p'))<CR>]])

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
map('n', 'S', [[:%s/\<<C-R>=expand('<cword>')<CR>\>/<C-R>=expand('<cword>')<CR>/gc<Left><Left>')]])

-- Snippets
map('i', '<F5>', "<C-R>=strftime('%c')<CR>")
map('i', '<F9>', "PRAGMA_DISABLE_OPTIMIZATION")
map('i', '<S-F9>', "PRAGMA_ENABLE_OPTIMIZATION")

-- Snippets
map('t', '<Esc>', [[<C-\><C-n>]])

local autocmds = {
	terminal = {
		{ 'TermOpen', '*', 'startinsert' }
	}
}

nvim_create_augroups(autocmds)
