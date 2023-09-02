-- Misc
vim.keymap.set('n', '<S-l>', '$')
vim.keymap.set('n', '<S-h>', '0')
vim.keymap.set("n", "<F1>", vim.cmd.Ex)
vim.keymap.set("n", "<leader>s", ":w<CR>")

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "jj", "<Esc>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

vim.keymap.set('i', '{', '{}<Left>')
vim.keymap.set('i', '[', '[]<Left>')
vim.keymap.set('n', '<Esc>', '<cmd>noh<CR>')
vim.keymap.set('n', '<C-n>', '<cmd>b#<CR>')
vim.keymap.set('n', 'Y', 'y$')

-- Quckfix
vim.keymap.set('n', '<A-h>', '<cmd>cfirst<CR>')
vim.keymap.set('n', '<A-j>', '<cmd>cn<CR>')
vim.keymap.set('n', '<A-k>', '<cmd>cp<CR>')

-- Search
vim.keymap.set('n', 'gw', '<cmd>vim <cword> %<CR>:copen<CR>')
vim.keymap.set('n', 'Gw', '<cmd>Grep <cword><CR>')
vim.keymap.set('n', 'S', [[:%s/<C-R>=expand('<cword>')<CR>/<C-R>=expand('<cword>')<CR>/gc<Left><Left><Left>]])
vim.keymap.set('n', 'R', [[:,$s/<C-R>=expand('<cword>')<CR>/<C-R>=expand('<cword>')<CR>/gc<Left><Left><Left>]])
vim.keymap.set('n', '<leader>ff', '<cmd>FzfFiles<CR>')
vim.keymap.set('n', ';', '<cmd>FzfBuffers<CR>')

-- General
vim.keymap.set('n', '<leader>cp', '<cmd>CopyPath><CR>')

-- Snippets
vim.keymap.set('i', '<F5>', "<C-R>=strftime('%c')<CR>")
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

-- Format
vim.keymap.set('n', '<leader>w', [[<cmd>write<CR><cmd>silent execute printf('!clang-format.exe -i %s', expand("%:p"))<CR><cmd>:e! %<CR>]])
