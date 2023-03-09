local Settings = {
    tabs = {
        general = {
            width = 4,
            expand = true
        },
        c = {
            width = 4,
            expand = false
        },
        cpp = {
            width = 4,
            expand = false
        },
        cs = {
            width = 4,
            expand = false
        },
        lua = {
            width = 4,
            expand = true
        },
        rs = {
            width = 4,
            expand = true
        }
    }
}

function Settings.setup_tabs(opts)
    vim.opt.tabstop = opts.width
    vim.opt.softtabstop = opts.width
    vim.opt.shiftwidth = opts.width
    vim.opt.expandtab = opts.expand
    vim.opt.smartindent = true
    vim.opt.autoindent = true
    vim.opt.cindent = true
end

function Settings.setup(opts)
    vim.g.mapleader = ","
    vim.opt.number = true
    vim.opt.relativenumber = false
    vim.opt.wrap = false
    vim.opt.hlsearch = true
    vim.opt.incsearch = true
    vim.opt.scrolloff = 8
    vim.opt.signcolumn = "no"
    vim.opt.updatetime = 50
    --vim.opt.colorcolumn = "140"

    vim.cmd('set termguicolors')
    vim.cmd('syntax enable')
    vim.cmd('filetype on')
    vim.cmd('set ignorecase')
    vim.cmd('set noswapfile')
    vim.cmd('set clipboard+=unnamedplus')
    vim.cmd('set splitright')

    Settings.setup_tabs(Settings.tabs.general)
end

function Settings.update_tabsettings(filetype)
    local settings = Settings.tabs[filetype] or nil
    if settings then
        vim.bo.tabstop = settings.width
        vim.bo.softtabstop = settings.width
        vim.bo.shiftwidth = settings.width
        vim.bo.expandtab = settings.expand
    end
end

return Settings
