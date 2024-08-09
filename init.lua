-- Plugin Manager
-------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","
-------------------------------------------------------------------------------

-- Plugins
-------------------------------------------------------------------------------
require("lazy").setup({
    {"nvim-lua/plenary.nvim"},
    {"theprimeagen/harpoon"},
    {"folke/tokyonight.nvim", lazy = false},
    {"ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = {
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
            strings = false,
            emphasis = false,
            comments = false,
            operators = false,
            folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "hard", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
    }},
    {"vijaymarupudi/nvim-fzf", lazy = false},
    {"VonHeikemen/lsp-zero.nvim",
        branch = 'v4.x',
        dependencies = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {'williamboman/mason.nvim'},           -- Optional
            {'williamboman/mason-lspconfig.nvim'}, -- Optional

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},     -- Required
            {'hrsh7th/cmp-nvim-lsp'}, -- Required
            {'L3MON4D3/LuaSnip'},     -- Required
        }
    }
})
-------------------------------------------------------------------------------

-- Lsp
-------------------------------------------------------------------------------
require("mason").setup()

local lsp_zero = require("lsp-zero")

local lsp_attach = function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    lsp_attach = lsp_attach,
    float_border = "rounded",
    sign_text = true
})

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
cmp.setup({
    sources = {
        {name = 'nvim_lsp'},
    },
    mapping = {
        -- `Enter` key to confirm
        ['<CR>'] = cmp.mapping.confirm({select = false}),
        -- Ctrl+Space to trigger completion menu
        ['<C-Space>'] = cmp.mapping.complete(),
        -- Navigate between snippet placeholder
        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        ['<C-b>'] = cmp_action.luasnip_jump_backward(),
    }
})

require('lspconfig').clangd.setup({})
require('lspconfig').lua_ls.setup({})
require('lspconfig').rust_analyzer.setup({})
require('lspconfig').pylsp.setup({})

-------------------------------------------------------------------------------

-- Theme
-------------------------------------------------------------------------------
require("tokyonight").setup({
    -- your configuration comes here
    -- or leave it empty to use the default settings
    style = "moon", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
    light_style = "day", -- The theme is used when the background is set to light
    transparent = false, -- Enable this to disable setting the background color
    terminal_colors = true, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
    styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = false },
        keywords = { italic = false },
        functions = { italic = false},
        variables = { italic = false },
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "dark", -- style for sidebars, see below
        floats = "dark", -- style for floating windows
    },
    sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
    day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
    hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
    dim_inactive = false, -- dims inactive windows
    lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
})

-- Notes
-------------------------------------------------------------------------------
require('notes').setup({
    root_path = "c:\\git\\docs",
    path = "c:\\git\\docs\\ue\\2024.md",
})

-- Settings
-------------------------------------------------------------------------------

local colorscheme = "tokyonight"
--local colorscheme = "gruvbox"

vim.cmd('colorscheme ' .. colorscheme)
vim.g.mapleader = ","
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
--vim.opt.updatetime = 50
--vim.opt.colorcolumn = "140"
vim.cmd('set termguicolors')
vim.cmd('syntax enable')
vim.cmd('filetype on')
vim.cmd('set ignorecase')
vim.cmd('set noswapfile')
vim.cmd('set clipboard+=unnamedplus')
vim.cmd('set splitright')
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.cindent = true

-- Commands
-------------------------------------------------------------------------------
vim.cmd('command! CopyPath :let @+= expand("%:p") | echo expand("%:p")')
vim.cmd('command! CopyDir :let @+= expand("%:p:h") | echo expand("%:p:h")')
vim.cmd("command! EditConfig :exec printf(':e %s/init.lua', stdpath('config'))")
vim.cmd("command! EditGConfig :exec printf(':e %s/ginit.vim', stdpath('config'))")
vim.cmd([[command! EditBuildConfig :exec printf(':e %s', 'C:\Users\per.larsson\AppData\Roaming\Unreal Engine\UnrealBuildTool\BuildConfiguration.xml')]])

-- Grep
vim.cmd [[command! -nargs=+ -complete=dir -bar Grep lua require'grep'.async_grep(<q-args>)]]

-- Fzf
vim.cmd [[command! FzfFiles :lua require'fzf-cmds'.files()]]
vim.cmd [[command! FzfBuffers :lua require'fzf-cmds'.buffers()]]
vim.cmd [[command! FzfTags :lua require'fzf-cmds'.tags()]]

-- Notes
vim.cmd([[command! Notes lua require'notes'.open()]])
vim.cmd([[command! SaveNotes lua require'notes'.save()]])
vim.cmd([[command! UpdateNotes lua require'notes'.update()]])

vim.cmd([[command! ReloadBuffer :e! %]])

-- Perforce
vim.cmd([[command! -nargs=* P4init :lua require'p4'.init(<q-args>)]])
vim.cmd([[command! P4edit :lua require'p4'.edit()]])
vim.cmd([[command! P4revert :lua require'p4'.revert()]])
vim.cmd([[command! -nargs=? P4revgraph :lua require'p4'.revision_graph(<q-args>)]])
vim.cmd([[command! -nargs=? P4timelapse :lua require'p4'.timelapse_view(<q-args>)]])
vim.cmd([[command! -nargs=? P4history :lua require'p4'.history_view(<q-args>)]])
vim.cmd([[command! -nargs=? P4depotpath :lua require'p4'.copy_depot_path(<q-args>)]])

-- UE
vim.api.nvim_create_user_command('UEquickfix',
function()
    require'utils'.read_quickfix()
end,
{})

vim.api.nvim_create_user_command('TabSettings',
function(opts)
    print(string.format("<tabstop=%d>, <expandtab='%s'>", vim.bo.tabstop, tostring(vim.bo.expandtab)))
end,
{})

vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
    pattern = '*',
    callback = function(opts)
        --require'p3rl.settings'.update_tabsettings(vim.bo.filetype)
    end
})

-- Mappings
-------------------------------------------------------------------------------
vim.keymap.set('n', '<S-l>', '$')
vim.keymap.set('n', '<S-h>', '0')
vim.keymap.set("n", "<F1>", vim.cmd.Ex)
vim.keymap.set("n", "<leader>s", ":w<CR>")

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "jj", "<Esc>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

vim.keymap.set('i', '{', '{}<Left>')
vim.keymap.set('i', '[', '[]<Left>')
vim.keymap.set('n', '<Esc>', '<cmd>noh<CR>')
vim.keymap.set('n', '<C-n>', '<cmd>b#<CR>')
vim.keymap.set('n', 'Y', 'y$')

-- Quckfix
vim.keymap.set('n', '<A-h>', '<cmd>cfirst<CR>')
vim.keymap.set('n', '<A-j>', '<cmd>cn<CR>')
vim.keymap.set('n', '<A-k>', '<cmd>cp<CR>')

-- Search
vim.keymap.set('n', 'gw', '<cmd>vim <cword> %<CR>:copen<CR>')
vim.keymap.set('n', 'Gw', '<cmd>Grep <cword><CR>')
vim.keymap.set('n', 'S', [[:%s/<C-R>=expand('<cword>')<CR>/<C-R>=expand('<cword>')<CR>/gc<Left><Left><Left>]])
vim.keymap.set('n', 'R', [[:,$s/<C-R>=expand('<cword>')<CR>/<C-R>=expand('<cword>')<CR>/gc<Left><Left><Left>]])
vim.keymap.set('n', '<leader>ff', '<cmd>FzfFiles<CR>')
vim.keymap.set('n', '<leader>ft', '<cmd>FzfTags<CR>')
vim.keymap.set('n', ';', '<cmd>FzfBuffers<CR>')

-- General
vim.keymap.set('n', '<leader>cp', '<cmd>CopyPath><CR>')

-- Snippets
vim.keymap.set('i', '<F5>', "<C-R>=strftime('%c')<CR>")
vim.keymap.set('i', '<F9>', "UE_DISABLE_OPTIMIZATION")
vim.keymap.set('i', '<S-F9>', "UE_ENABLE_OPTIMIZATION")

-- Copy
vim.keymap.set('n', '<leader>cp', '<cmd>CopyPath<CR>')
vim.keymap.set('n', '<leader>cd', '<cmd>CopyDir<CR>')

-- UE Quckfix
vim.keymap.set('n', '<leader>qf', '<cmd>UEquickfix<CR>')

-- Perforce
vim.keymap.set('n', '<leader>ef', '<cmd>P4edit<CR>')
vim.keymap.set('n', '<leader>rf', '<cmd>P4revert<CR>')

-- Format
vim.keymap.set('n', '<leader>w', [[<cmd>write<CR><cmd>silent execute printf('!clang-format.exe -i %s', expand("%:p"))<CR><cmd>:e! %<CR>]])

-- Tags
vim.keymap.set('n', '<F12>', [[<cmd>execute printf(":tag %s", expand("<cword>"))<CR>]])

-------------------------------------------------------------------------------

-- Harpoon
-------------------------------------------------------------------------------
require("harpoon").setup({
    menu = {
        width = vim.api.nvim_win_get_width(0) - 10,
    }
})

local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

vim.keymap.set('n', '<leader>af', mark.add_file)
vim.keymap.set('n', '<leader>df', mark.rm_file)
vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)

-- Utils
-------------------------------------------------------------------------------
function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

function _G.rerequire(module_name)
  package.loaded[module_name] = nil
  return require(module_name)
end
-------------------------------------------------------------------------------
