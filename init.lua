local utils = require'utils'
local map, opt, set_var, nvim_create_augroups = utils.map, utils.opt, utils.set_var, utils.create_augroups
local cmd, fn, g, api = vim.cmd, vim.fn, vim.g, vim.api

-- Plugins
-------------------------------------------------------------------------------
require "paq" {
  'savq/paq-nvim';
  'nvim-lua/popup.nvim';
  'nvim-lua/plenary.nvim';
  'neovim/nvim-lspconfig';
  'vijaymarupudi/nvim-fzf';
  'hoob3rt/lualine.nvim';
  'RishabhRD/popfix';
  {'folke/tokyonight.nvim', branch = 'main'};
  'ellisonleao/gruvbox.nvim'; 
  'hrsh7th/nvim-cmp';
  'hrsh7th/cmp-buffer';
  'hrsh7th/cmp-nvim-lua';
  'hrsh7th/cmp-nvim-lsp';
  'delphinus/cmp-ctags';
  'tpope/vim-fugitive';
  'kyazdani42/nvim-tree.lua';
  'rust-lang/rust.vim';
}

-- Local plugins
package.loaded['fzf-cmds'] = nil
package.loaded['p4'] = nil
package.loaded['psue'] = nil
package.loaded['grep'] = nil
package.loaded['fastbuf'] = nil
package.loaded['lsp'] = nil
package.loaded['notes'] = nil

-- Theme(s)
-------------------------------------------------------------------------------
require("gruvbox").setup({
  undercurl = true,
  underline = true,
  bold = true,
  italic = false,
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = true,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "hard", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})

local theme = { colorscheme = 'gruvbox', background = 'light', lualine_theme = 'gruvbox'}
--local theme = { colorscheme = 'tokyonight-night', background = 'dark', lualine_theme = 'tokyonight-night'}

cmd('set termguicolors')
cmd('set background=' .. theme.background)
cmd('colorscheme ' .. theme.colorscheme)

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
-------------------------------------------------------------------------------
local tabs = {
  general = {
    indent = 4,
    spaces = false
  },
  lua = {
    indent = 2,
    spaces = true
  },
  ps1 = {
    indent = 4,
    spaces = true
  },
  psm1 = {
    indent = 4,
    spaces = true
  },
  psd1 = {
    indent = 4,
    spaces = true
  },
  rs = {
    indent = 4,
    spaces = true
  },
  js = {
    indent = 4,
    spaces = true
  }
}

function set_filetype_tabs()
  local settings = tabs[vim.bo.filetype]
  if settings then
    vim.bo.expandtab = settings.spaces
    vim.bo.shiftwidth = settings.indent
    vim.bo.tabstop = settings.indent
    vim.bo.softtabstop = settings.indent
  end
end

-- Settings
-------------------------------------------------------------------------------
opt('b', 'shiftwidth', tabs.general.indent)             -- Size of indent
opt('b', 'tabstop', tabs.general.indent)                -- Number of spaces tabs count for
opt('b', 'softtabstop', tabs.general.indent)            -- Number of spaces that a <Tab> counts for while performing editingoperations, like inserting a <Tab> or using <BS>
opt('o', 'expandtab', tabs.general.spaces)              -- Spaces instead of tabs
opt('b', 'autoindent', true)                            -- Copy indent from current line when starting a new line
opt('b', 'smartindent', true)                           -- Do smart autoindenting when starting a new line
opt('o', 'smarttab', true)                              -- When on, a <Tab> in front of a line inserts blanks according to
opt('b', 'cindent', true)
cmd 'set listchars=tab::.'                              -- Show tabs

opt('o', 'ignorecase', true)                            --
opt('o', 'incsearch', true)                             --
opt('o', 'laststatus', 3)                               --
opt('o', 'backup', false)                               --
opt('o', 'swapfile', false)                             --
opt('o', 'hidden', true)                                --
opt('w', 'cursorline', true)                            -- Highlight current line
opt('w', 'list', false)                                 -- Show some invisible characters (tabs...)
opt('w', 'number', true)                                -- Print line number
opt('w', 'relativenumber', false)                       -- Relative line numbers
opt('w', 'wrap', false)                                 -- Disable wrapping
opt('o', 'completeopt', 'menu,menuone,noselect')        -- Completion options
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
cmd [[command! Notes lua require'notes'.open()]]
cmd [[command! SaveNotes lua require'notes'.save()]]
cmd [[command! UpdateNotes lua require'notes'.update()]]
cmd [[command! -nargs=+ -complete=dir -bar Grep lua require'grep'.async_grep(<q-args>)]]
cmd [[command! ReloadBuffer :e! %]]
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
cmd [[command! -nargs=? P4history :lua require'p4'.history_view(<q-args>)]]
cmd [[command! -nargs=? P4depotpath :lua require'p4'.copy_depot_path(<q-args>)]]
-- FZF
cmd [[command! FzfFiles :lua require'fzf-cmds'.files()]]
cmd [[command! FzfBuffers :lua require'fzf-cmds'.buffers()]]
cmd [[command! FzfTags :lua require'fzf-cmds'.tags()]]
-- Lsp
cmd [[command! -nargs=0 LspLog :lua vim.cmd('e '..vim.lsp.get_log_path())]]
cmd [[command! -nargs=0 LspStop :lua require'lsp'.stop_all_clients()]]
--NvimTree
map('n', '<F1>', '<cmd>NvimTreeToggle<CR>')

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
map('n', '<leader>f', '<cmd>FzfFiles<CR>')
map('n', '<leader>b', '<cmd>FzfBuffers<CR>')
map('n', '<leader>t', '<cmd>FzfTags<CR>')
map('n', '<leader>pe', '<cmd>P4edit<CR>')
map('n', '<leader>pr', '<cmd>P4revert<CR>')
map('n', '<leader>cp', '<cmd>CopyPath<CR>')
map('n', '<leader>cd', '<cmd>CopyDir<CR>')
map('n', '<leader>w', [[<cmd>write<CR><cmd>silent execute printf('!clang-format.exe -i %s', expand("%:p"))<CR><cmd>:e! %<CR>]])

-- PSUE
map('n', '<leader>qf', '<cmd>UEquickfix<CR>')

-- Quickfix
map('n', '<A-h>', '<cmd>cfirst<CR>')
map('n', '<A-j>', '<cmd>cn<CR>')
map('n', '<A-k>', '<cmd>cp<CR>')
map('n', '<leader>eo', '<cmd>copen 20<CR>')
map('n', '<leader>ec', '<cmd>cclose<CR>')

-- Folding
map('n', '<space>', 'za')
map('n', '<C-space>', 'zR')
map('n', '<S-space>', 'zM')

-- Search & Replace
map('n', 'gw', '<cmd>vim <cword> %<CR>:copen<CR>')
map('n', 'Gw', '<cmd>Grep <cword><CR>')
map('n', 'S', [[:%s/<C-R>=expand('<cword>')<CR>/<C-R>=expand('<cword>')<CR>/gc<Left><Left><Left>]])
map('n', 'R', [[:,$s/<C-R>=expand('<cword>')<CR>/<C-R>=expand('<cword>')<CR>/gc<Left><Left><Left>]])

-- Snippets
map('i', '<F5>', "<C-R>=strftime('%c')<CR>")
map('i', '<F9>', "PRAGMA_DISABLE_OPTIMIZATION")
map('i', '<S-F9>', "PRAGMA_ENABLE_OPTIMIZATION")

-- Window
map('n', '<A-Up>', '<cmd>resize +2<CR>')
map('n', '<A-Down>', '<cmd>resize -2<CR>')
map('n', '<A-Right>', '<cmd>vertical resize +2<CR>')
map('n', '<A-Left>', '<cmd>vertical resize -2<CR>')

-- Lsp
map('n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>')

-- Statusline
-------------------------------------------------------------------------------
local function lualine_tab_info()
  local indent = 'tabs'
	if vim.bo.expandtab then
	  indent = 'spaces'
	end
	return string.format('%s:%d', indent, vim.bo.shiftwidth)
end

require('lualine').setup {
  options = { 
    icons_enabled = false,
    theme = theme.lualine_theme,
    section_separators = {' ', ' '},
    component_separators = {' ', ' '}
  },
  sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = { require'lsp'.get_buf_client_name, 'encoding', 'fileformat', 'filetype', lualine_tab_info },
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
  extensions = { 'fzf', 'quickfix', 'nvim-tree' }
}

-- NvimTree
-------------------------------------------------------------------------------
require'nvim-tree'.setup {
  disable_netrw       = true,
  hijack_netrw        = false,
  open_on_setup       = false,
  ignore_ft_on_setup  = {},
  open_on_tab         = false,
  hijack_cursor       = false,
  update_cwd          = false,
  update_focused_file = {
    enable      = true,
    update_cwd  = false,
    ignore_list = {}
  },
  view = {
    width = 50,
    side = 'left',
    mappings = {
      custom_only = false,
      list = {}
    }
  }
}

-- LSP
-------------------------------------------------------------------------------
require'lsp'.setup()

--Terminal
-------------------------------------------------------------------------------
map('t', '<Esc>', [[<C-\><C-n>]])

local autocmds = {
  terminal = {
    { 'TermOpen', '*', 'startinsert' }
  },
  set_tabs = {
    { 'FileType', '*', [[lua set_filetype_tabs()]] }
  }
}
nvim_create_augroups(autocmds)
