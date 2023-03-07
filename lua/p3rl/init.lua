require("p3rl.packer")

require("p3rl.settings").setup{
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

local rose_pine = {
	colorscheme = 'rose-pine',
	flavour = 'main',
	background = 'dark'
}

local tokyo = {
	colorscheme = 'tokyonight-night',
	background = 'dark'
}

require('p3rl.colors').setup(tokyo)
require("p3rl.utils").setup{}
require("p3rl.p4").setup{}
require("p3rl.grep").setup{}
require("p3rl.fzf-cmds").setup{}
require("p3rl.statusline").setup{}

require("p3rl.notes").setup{
    root_path = "c:/git/docs",
    path = "c:/git/docs/ue/2023.md"
}

require("p3rl.commands").setup{}
require("p3rl.mappings")
