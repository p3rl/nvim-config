-- PowerShell Unreal helper functions

local M = {}
local psue_directory = nil

local function get_psue_dir()
  if psue_directory ~= nil then
    return psue_directory
  else
    local working_dir = vim.fn.getcwd()
    local current_dir = working_dir
    local search = true
    while search do
      local psue = current_dir .. '/.psue'
      if vim.fn.isdirectory(psue) ~= 0 then
        psue_directory = psue
        search = false
      else
        vim.cmd('cd ..')
        local parent_dir = vim.fn.getcwd()
        if parent_dir == nil or parent_dir == current_dir then
            search = false
        else
            current_dir = parent_dir
        end
      end
    end
    return psue_directory
  end
end

function M.read_quickfix()
  local root_dir = get_psue_dir()
  if root_dir then
    vim.fn.setqflist({})
    vim.cmd('cfile ' .. root_dir .. '/quickfix.txt')
  vim.cmd('botright copen 20')
  end
end

return M
