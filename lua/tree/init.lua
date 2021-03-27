local utils = require'utils'
local nvim_tree = require'nvim-tree'
local nvim_lib = require'nvim-tree.lib'
local map, set_var = utils.map, utils.set_var

local function is_file_readable(fname)
  local stat = luv.fs_stat(fname)
  if not stat or not stat.type == 'file' or not luv.fs_access(fname, 'R') then return false end
  return true
end

local Tree = {}

function Tree.setup(opts)
	-- Settings
	set_var('nvim_tree_width', 40)
	set_var('nvim_tree_ignore', {'.git', 'node_modules', '.cache'})
	set_var('nvim_tree_auto_open', false) 
	set_var('nvim_tree_auto_close', false)
	set_var('nvim_tree_quit_on_open', true)
	set_var('nvim_tree_follow', true)
	set_var('nvim_tree_indent_markers', true)
	set_var('nvim_tree_hide_dotfiles', false)
	set_var('nvim_tree_width_allow_resize', true)
	set_var('nvim_tree_disable_netrw', false)
	set_var('nvim_tree_hijack_netrw', false)
	set_var('nvim_tree_add_trailing', true)
	set_var('nvim_tree_show_icons', { git = true, folders = false, files = false})

	-- Mappings
	map('n', 'E', '<cmd>NvimTreeToggle<CR>')
	map('n', '<leader>ff', [[<cmd>lua require'tree'.find_current_directory()<CR>')]])
end

function Tree.find_current_directory()
	local buf_dir = vim.fn.expand('%:h')
	if buf_dir then
		local path = buf_dir:gsub('\\', '/')
		require('nvim-tree.lib').change_dir(path)
	end
end

function Tree.find_file(with_open)
	local bufname = vim.fn.bufname()
	if bufname then
		local bufdir = string.gsub(vim.fn.fnamemodify(bufname, ':p:h'), '\\', '/')
		nvim_lib.change_dir(bufdir)
		nvim_tree.find_file(true)
	end
end

return Tree
