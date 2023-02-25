local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

vim.keymap.set('n', '<leader>af', mark.add_file)
vim.keymap.set('n', '<leader>df', mark.rm_file)
vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)
