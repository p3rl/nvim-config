local Settings = {
}

function Settings.setup_tabs(opts)
    vim.opt.tabstop = opts.width
    vim.opt.softtabstop = opts.width
    vim.opt.shiftwidth = opts.width
    vim.opt.expandtab = opts.expand
    vim.opt.smartindent = true
end

function Settings.setup(opts)
    vim.g.mapleader = ","
    vim.opt.number = true
    vim.opt.relativenumber = false
    vim.opt.wrap = false
    vim.opt.hlsearch = false
    vim.opt.incsearch = true
    vim.opt.scrolloff = 8
    vim.opt.signcolumn = "no"
    vim.opt.updatetime = 50
    vim.opt.colorcolumn = "140"

    Settings.setup_tabs(opts.tabs or { width = 4, expand = true })

    vim.cmd('set termguicolors')
    vim.cmd('syntax enable')
    vim.cmd('filetype on')
    vim.cmd('colorscheme ' .. opts.colorscheme.name)
    vim.cmd('set background=' .. opts.colorscheme.background)
end

return Settings
