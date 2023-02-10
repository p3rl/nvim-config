require("p3rl.packer")

require("p3rl.settings").setup{
    tabs = {
        width = 4,
        expand = true
    },
    colorscheme = {
        name = 'rose-pine',
        theme = 'moon',
        background = 'light'
    }
}

require("p3rl.utils").setup{}
require("p3rl.p4").setup{}
require("p3rl.statusline").setup{}
require("p3rl.notes").setup{
    root_path = "c:/git/docs",
    path = "c:/git/docs/ue/2023.md"
}
require("p3rl.commands").setup{}
require("p3rl.mappings")
