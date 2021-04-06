local utils = require'utils'
local nvim_tree = require'nvim-tree'
local nvim_tree_lib = require'nvim-tree.lib'
local map, set_var = utils.map, utils.set_var
local luv = vim.loop

local function is_file_readable(fname)
  local stat = luv.fs_stat(fname)
  if not stat or not stat.type == 'file' or not luv.fs_access(fname, 'R') then return false end
  return true
end

local Tree = { project_dir = null }

function Tree.setup(opts)
  Tree.project_dir = luv.cwd()

  -- Settings
  set_var('nvim_tree_side', 'left')
  set_var('nvim_tree_width', 500)
  set_var('nvim_tree_ignore', {'.git', 'node_modules', '.cache'})
  set_var('nvim_tree_auto_open', 0) 
  set_var('nvim_tree_auto_close', 0)
  set_var('nvim_tree_quit_on_open', 0)
  set_var('nvim_tree_follow', 1)
  set_var('nvim_tree_indent_markers', 0)
  set_var('nvim_tree_hide_dotfiles', 1)
  set_var('nvim_tree_width_allow_resize', 1)
  set_var('nvim_tree_disable_netrw', 0)
  set_var('nvim_tree_hijack_netrw', 0)
  set_var('nvim_tree_add_trailing', 1)
  set_var('nvim_tree_show_icons', { git = 0, folders = 0, files = 0})

  -- Mappings
  --map('n', '<F1>', [[<cmd>lua require'tree'.toggle()<CR>')]])
  --map('n', '<S-F1>', [[<cmd>lua require'tree'.find_file()<CR>')]])
  --map('n', '<F2>', [[<cmd>lua require'tree'.go_to_project_dir()<CR>')]])
end

function Tree.go_to_project_dir()
  if Tree.project_dir then
    local path = string.gsub(Tree.project_dir, '\\', '/')
    nvim_tree_lib.change_dir(path)
  end
end

return Tree
