local Colors = {}

function Colors.setup(opts)

	if opts.colorscheme == 'rose-pine' then
		require("rose-pine").setup({
			dark_variant = opts.flavour,
			disable_italics = true,
			bold_vert_split = false,
			dim_nc_background = false,
			disable_background = false,
			disable_float_background = false,
		})
	end
	
	vim.cmd('set background=' .. opts.background or 'dark')
	vim.cmd('colorscheme ' .. opts.colorscheme)
end

return Colors
