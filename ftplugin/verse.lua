-- Verse is indentation-sensitive and uses spaces; C-style indenting gets it wrong.
vim.bo.cindent = false
vim.bo.smartindent = false
vim.bo.autoindent = true
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.commentstring = "# %s"
vim.bo.comments = "s:<#,e:#>,:#"
