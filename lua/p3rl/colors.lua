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

	elseif opts.colorscheme == 'catppuccin' then
		require('catppuccin').setup({
			flavour = opts.flavour, -- latte, frappe, macchiato, mocha
			background = { -- :h background
				light = "latte",
				dark = "mocha",
			}
		})
	end
	
	vim.cmd('colorscheme ' .. opts.colorscheme)
	vim.cmd('set background=' .. opts.background or 'dark')
end

return Colors
