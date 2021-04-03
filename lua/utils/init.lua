local cmd, fn, g, api = vim.cmd, vim.fn, vim.g, vim.api
local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

function _G.rerequire(module_name)
  package.loaded[module_name] = nil
  return require(module_name)
end

local Utils = {}

function Utils.map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function Utils.set_var(name, value)
    vim.api.nvim_set_var(name, value)
end

function Utils.opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
end

function Utils.create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    api.nvim_command('augroup '..group_name)
    api.nvim_command('autocmd!')
    for _, def in ipairs(definition) do
      -- if type(def) == 'table' and type(def[#def]) == 'function' then
      --  def[#def] = lua_callback(def[#def])
      -- end
      local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
      api.nvim_command(command)
    end
    api.nvim_command('augroup END')
  end
end

return Utils
