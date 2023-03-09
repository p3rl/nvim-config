local Colors = {}

function Colors.setup(opts)
    vim.cmd('set background=' .. opts.background or 'dark')
	vim.cmd('colorscheme ' .. opts.colorscheme)
end

return Colors
