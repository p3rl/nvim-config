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
    vim.opt.hlsearch = true
    vim.opt.incsearch = true
    vim.opt.scrolloff = 8
    vim.opt.signcolumn = "no"
    --vim.opt.updatetime = 50
    --vim.opt.colorcolumn = "140"

    vim.cmd('set termguicolors')
    vim.cmd('syntax enable')
    vim.cmd('filetype on')
    vim.cmd('set ignorecase')
    vim.cmd('set noswapfile')
    vim.cmd('set clipboard+=unnamedplus')
    vim.cmd('set splitright')
    
	Settings.setup_tabs(opts.tabs or { width = 4, expand = true })
end

return Settings
