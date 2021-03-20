local utils = require'utils'
local map, opt, set_var, nvim_create_augroups = utils.map, utils.opt, utils.set_var, utils.create_augroups
local cmd, fn, g, api = vim.cmd, vim.fn, vim.g, vim.api

-- Plugins
-------------------------------------------------------------------------------
vim.cmd 'packadd paq-nvim'
local paq = require('paq-nvim').paq

paq {'savq/paq-nvim', opt = true}    -- paq-nvim manages itself
paq {'arcticicestudio/nord-vim'}
paq {'lifepillar/vim-gruvbox8'}
paq {'ghifarit53/tokyonight-vim'}
paq {'junegunn/fzf', hook = fn['fzf#install']}
paq {'junegunn/fzf.vim'}
paq {'itchyny/lightline.vim'}
paq {'RishabhRD/popfix'}
paq {'neovim/nvim-lspconfig'}
paq {'nvim-lua/completion-nvim'}
paq {'hrsh7th/nvim-compe'}

-- Loal plugins
package.loaded['p4'] = nil
package.loaded['psue'] = nil
package.loaded['grep'] = nil
package.loaded['fastbuf'] = nil

_G.p4 = require('p4')
_G.psue = require('psue')
_G.grep = require('grep')
_G.fastbuf = require('fastbuf')

-- Theme
-------------------------------------------------------------------------------
local colorscheme = 'nord'
set_var('nord_bold', 1)
set_var('nord_italic', 1)
set_var('nord_italic_comments', 1)
set_var('nord_cursor_line_number_background', 1)
set_var('tokyonight_style', 'storm') -- night, storm
set_var('tokyonight_enable_italic', 1)
--cmd 'set background=light'

cmd('colorscheme ' .. colorscheme)
set_var('fzf_layout', { down = '20%' })

-- Lightline
-------------------------------------------------------------------------------
api.nvim_exec([[
function! Lightline_filedir()
    return expand('%:h')
endfunction
]], true)

local lightline_config = {
	colorscheme = colorscheme,
	active = {
		left = {
			{ 'readonly', 'filename', 'modified', 'filedir' }
		}
	},
	component_function = {
		filedir = 'Lightline_filedir'
	}
}
set_var('lightline', lightline_config)

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
opt('o', 'lazyredraw', true)                            -- Same as above
opt('o', 'ignorecase', true)                            -- 
opt('o', 'smartcase', true)                             -- 
opt('w', 'foldmethod', 'syntax')                        -- Fold method
opt('o', 'foldcolumn', '2')                             -- Fold columns
--opt('o', 'foldlevel', 0)                                -- Default fold level
opt('o', 'foldlevelstart', 99)                          -- Default fold level

-- Netrw
set_var('netrw_banner', 0)
set_var('netrw_browse_split', 4)
set_var('netrw_liststyle', 3)
set_var('netrw_winsize', 20)

-- Commands
-------------------------------------------------------------------------------
cmd 'command! CopyPath :let @+= expand("%:p") | echo expand("%:p")'
cmd 'command! CopyDir :let @+= expand("%:h") | echo expand("%:h")'
cmd "command! EditVimConfig :exec printf(':e %s/init.vim', stdpath('config'))"
cmd "command! EditConfig :exec printf(':e %s/init.lua', stdpath('config'))"
cmd [[command! UEquickfix :lua psue.read_quickfix()]]
cmd [[command! Notes :e c:/git/docs/ue/ue.md]]
cmd [[command! -nargs=+ -complete=dir -bar Grep lua grep.async_grep(<q-args>)]]
-- FastBuf
cmd [[command! -nargs=0 FbPin lua fastbuf.pin_buffer()]]
cmd [[command! -nargs=0 FbUnpin  lua fastbuf.unpin_buffer()]]
cmd [[command! -nargs=0 FbSelectPinned lua fastbuf.select_pinned_buffer()]]
cmd [[command! -nargs=0 FbTogglePinned lua fastbuf.toggle_pinned()]]
-- Perforce
cmd [[command! P4edit :lua p4.edit()]]
cmd [[command! P4revert :lua p4.revert()]]
cmd [[command! -nargs=? P4revgraph :lua p4.revision_graph(<q-args>)]]
cmd [[command! -nargs=? P4timelapse :lua p4.timelapse_view(<q-args>)]]

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
map('n', '<space>', 'zA')
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

-- LSP
package.loaded['lsp'] = nil
require'lsp'.setup()
set_var('completion_matching_strategy_list', {'exact', 'substring', 'fuzzy', 'all'})
map('n', 'gd', '<cmd>:lua vim.lsp.buf.definition()<CR>')
map('n', 'gD', '<cmd>:lua vim.lsp.buf.declaration()<CR>')
cmd [[command! -nargs=0 LspLog :lua vim.cmd('e '..vim.lsp.get_log_path())]]
cmd [[command! -nargs=0 LspStop :lua require'Lsp'.stop_all_clients()]]

---- Terminal
--map('t', '<Esc>', [[<C-\><C-n>]])

local autocmds = {
	terminal = {
		{ 'TermOpen', '*', 'startinsert' }
	}
}

nvim_create_augroups(autocmds)
