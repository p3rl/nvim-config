-- Plugin Manager
-------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
    { "williamboman/mason.nvim" },
    { "neovim/nvim-lspconfig" },
    {
        "theprimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {
            {"nvim-lua/plenary.nvim"}
        }
    },
    { "folke/tokyonight.nvim", lazy = false },
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = true,
        opts = {
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
            contrast = "", -- can be "hard", "soft" or empty string
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = false,
        }
    },
    { "vijaymarupudi/nvim-fzf", lazy = false },
    {
        "saghen/blink.cmp",
        lazy = false,
        version = "1.*",
        opts = {
            -- Tab and Enter accept the selected (or first) item; Tab also jumps through
            -- snippet placeholders. Ctrl-n/Ctrl-p move the selection. With the menu
            -- closed, Enter inserts a newline as usual.
            keymap = {
                preset = "super-tab",
                ["<CR>"] = { "select_and_accept", "fallback" },
            },
            sources = { default = { "lsp", "path", "snippets", "buffer" } },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        opts = {
            options = { theme = "auto", icons_enabled = false },
            sections = {
                lualine_x = {
                    -- Language servers attached to the current buffer, e.g. "lsp: clangd".
                    function()
                        local names = vim.tbl_map(function(client) return client.name end,
                            vim.lsp.get_clients({ bufnr = 0 }))
                        return #names > 0 and "lsp: " .. table.concat(names, ",") or "lsp: none"
                    end,
                    -- Indentation of the current buffer, e.g. "spaces:4" or "tabs:4".
                    function()
                        return string.format("%s:%d", vim.bo.expandtab and "spaces" or "tabs", vim.bo.shiftwidth)
                    end,
                    "encoding",
                    "fileformat",
                    "filetype",
                },
            },
        },
    }
})
-------------------------------------------------------------------------------

-- Lsp
-------------------------------------------------------------------------------
require("mason").setup()

vim.lsp.config['lua_ls'] = {
      -- Command and arguments to start the server.
    cmd = { 'lua-language-server' },
    -- Filetypes to automatically attach to.
    filetypes = { 'lua' },
    -- Sets the "workspace" to the directory where any of these files is found.
    -- Files that share a root directory will reuse the LSP server connection.
    -- Nested lists indicate equal priority, see |vim.lsp.Config|.
    root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
    -- Specific settings to send to the server. The schema is server-defined.
    -- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            }
        }
    }
}

-- Advertise blink.cmp's completion capabilities to every server.
vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
})

local clangd_args = {
    '--background-index',
    '--background-index-priority=low',
    '--clang-tidy=false',
    '--completion-style=detailed',
    '--header-insertion=never',
    '--pch-storage=memory',
    '--limit-results=200',
    '-j=8',
}

vim.lsp.config['clangd'] = {
    -- Unreal ships a clangd that matches the compiler compile_commands.json was generated with. The system
    -- clangd rejects the MSVC STL headers (STL1000: expected Clang 19 or newer), so use the bundled one when
    -- the workspace root has it and fall back to the clangd on PATH for any other project.
    cmd = function(dispatchers, config)
        local exe = 'clangd'
        local epic = config.root_dir and (config.root_dir .. '/Engine/Binaries/Win64/EpicClang/20/bin/x64/EpicClangd.exe')
        if epic and vim.uv.fs_stat(epic) then
            exe = epic
        end
        return vim.lsp.rpc.start(vim.list_extend({ exe }, clangd_args), dispatchers,
            { cwd = config.cmd_cwd, env = config.cmd_env })
    end,
    filetypes = { 'c', 'cpp' },
    -- compile_commands.json / .clangd first so the index follows the compile database.
    root_markers = { { 'compile_commands.json', '.clangd' }, { '.p4config' }, '.git' },
}

vim.lsp.config['csharp-ls'] = {
    cmd = { 'csharp-ls' },
    filetypes = { 'cs' },
    root_markers = { { '.p4config' }, '.git' }
}

vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls')

-- gd goes to the declaration and gD to the definition of the symbol under the cursor. Only bound in buffers with a
-- server that supports them, so other buffers keep the built-in gd and gD.
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
            return
        end
        if client:supports_method('textDocument/declaration') then
            vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, { buffer = args.buf, desc = 'LSP: go to declaration' })
        end
        if client:supports_method('textDocument/definition') then
            vim.keymap.set('n', 'gD', vim.lsp.buf.definition, { buffer = args.buf, desc = 'LSP: go to definition' })
        end
    end,
})

-- Keep diagnostics out of the buffer; view them on demand instead.
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = false,
    underline = false,
    signs = false,
    update_in_insert = false,
})
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)  -- diagnostics on the cursor line
vim.keymap.set('n', '<leader>D', vim.diagnostic.setqflist)   -- all diagnostics in the quickfix list

--require('lspconfig').clangd.setup({})
--require('lspconfig').lua_ls.setup({})
--require('lspconfig').rust_analyzer.setup({})
--require('lspconfig').pylsp.setup({})

-------------------------------------------------------------------------------

-- Theme
-------------------------------------------------------------------------------
require("tokyonight").setup({
    -- your configuration comes here
    -- or leave it empty to use the default settings
    style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
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
    path = "c:\\git\\docs\\ue\\2026.md",
})

-- Settings
-------------------------------------------------------------------------------

-- Unreal Verse (syntax/verse.vim, ftplugin/verse.lua)
vim.filetype.add({ extension = { verse = "verse" } })

--local colorscheme = "tokyonight"
local colorscheme = "gruvbox"

vim.o.background = "light"
vim.cmd('colorscheme ' .. colorscheme)

-- Cycle colorschemes: gruvbox dark -> gruvbox light -> tokyonight -> default.
local colorschemes = {
    { name = "gruvbox", background = "dark" },
    { name = "gruvbox", background = "light" },
    { name = "tokyonight", background = "dark" },
    { name = "default", background = "dark" },
}
vim.api.nvim_create_user_command('CycleColorscheme', function()
    local current = 0
    for i, scheme in ipairs(colorschemes) do
        -- tokyonight reports its style in the name, e.g. "tokyonight-moon".
        if vim.startswith(vim.g.colors_name or "", scheme.name) and scheme.background == vim.o.background then
            current = i
        end
    end
    local next = colorschemes[current % #colorschemes + 1]
    vim.o.background = next.background
    vim.cmd.colorscheme(next.name)
    print(string.format("%s (%s)", next.name, next.background))
end, {})

vim.g.mapleader = ","
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "auto"
--vim.opt.updatetime = 50
--vim.opt.colorcolumn = "140"
vim.cmd('set ignorecase')
vim.cmd('set noswapfile')
vim.cmd('set clipboard+=unnamedplus')
vim.cmd('set splitright')
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
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

-- Build (CMake preset, errors to quickfix)
vim.api.nvim_create_user_command('Build', function(opts) require'build'.run(opts.args) end,
    { nargs = '?', complete = function() return require'build'.presets() end })
vim.keymap.set('n', '<F7>', '<cmd>Build<CR>')

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
-- :P4Diff diffs the buffer against the synced revision; :P4Diff #head, :P4Diff #12, :P4Diff @12345 pick another.
-- :P4DiffClose deletes the depot buffers and turns diff mode off.
vim.api.nvim_create_user_command('P4Diff', function(opts) require'p4'.diff(opts.args) end, { nargs = '?' })
vim.api.nvim_create_user_command('P4DiffClose', function() require'p4'.diff_close() end, {})
-- :P4Log lists the current file's revisions in the quickfix list; <CR> on an entry opens that revision.
vim.api.nvim_create_user_command('P4Log', function() require'p4'.log() end, {})
-- :P4DiffPrev (or d in the :P4Log list) diffs a revision against the one before it.
vim.api.nvim_create_user_command('P4DiffPrev', function() require'p4'.diff_prev() end, {})

-- Shell: run commands in another terminal tab running scripts/nvim-listener.ps1.
-- :Shell <cmd> sends a command, :ShellRepeat sends the last one again.
vim.api.nvim_create_user_command('Shell', function(opts) require'shell'.send(opts.args) end,
    { nargs = '+', complete = 'shellcmd' })
vim.api.nvim_create_user_command('ShellRepeat', function() require'shell'.repeat_last() end, {})

-- UE
vim.api.nvim_create_user_command('UEctags',
function(opts)
    require'ctags'.generate(opts.fargs)
end,
{ nargs = '*', complete = 'dir' })

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
        require'tabsettings'.update(opts.buf)
    end
})

-- Mappings
-------------------------------------------------------------------------------
vim.keymap.set('n', '<S-l>', '$')
vim.keymap.set('n', '<S-h>', '0')
vim.keymap.set("n", "<F1>", vim.cmd.Ex)
vim.keymap.set("n", "<S-F1>", "<cmd>CycleColorscheme<CR>")
vim.keymap.set("n", "<F13>", "<cmd>CycleColorscheme<CR>") -- what some terminals send for Shift-F1
vim.keymap.set("n", "<leader>s", ":w<CR>")

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "jj", "<Esc>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "[[", "[[zz")
vim.keymap.set("n", "]]", "]]zz")

vim.keymap.set('i', '{', '{}<Left>')
vim.keymap.set('i', '[', '[]<Left>')
vim.keymap.set('n', '<Esc>', '<cmd>noh<CR>')
vim.keymap.set('n', '<C-n>', '<cmd>b#<CR>')
vim.keymap.set('n', 'Y', 'y$')

-- Quickfix
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
--vim.keymap.set('n', 'n', 'nzz')
--vim.keymap.set('n', 'N', 'Nzz')

-- Snippets
vim.keymap.set('i', '<F3>', "<C-R>=strftime('%Y-%m-%d %H:%M')<CR>")
vim.keymap.set('i', '<S-F3>', "<C-R>=strftime('%a %d/%m')<CR>")
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
vim.keymap.set('n', '<C-F9>', '<cmd>P4revgraph<CR>')
vim.keymap.set('n', '<C-F10>', '<cmd>P4timelapse<CR>')

-- Format with the attached language server (clangd uses the project's .clang-format), then save.
vim.keymap.set('n', '<leader>w', function()
    vim.lsp.buf.format()
    vim.cmd.write()
end)

-- Tags
vim.keymap.set('n', '<F12>', [[<cmd>execute printf(":tag %s", expand("<cword>"))<CR>]])

-------------------------------------------------------------------------------

-- Harpoon
-------------------------------------------------------------------------------
local harpoon = require("harpoon")
harpoon:setup({
    settings = {
        save_on_toggle = true,
        save_on_ui_close = true
    }
})
vim.keymap.set("n", "<leader>af", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
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
