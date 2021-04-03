local cmd, fn, g, api = vim.cmd, vim.fn, vim.g, vim.api

local M = {}

local function buf_get_var(buf, name)
  local status, value = pcall(vim.api.nvim_buf_get_var, buf, name)
  if status then return value else return nil end
end

function M.is_buffer_pinned()
  return buf_get_var(buffer, 'pinned')
end

function M.pin_buffer()
  api.nvim_buf_set_var(0, 'pinned', true)
  print(string.format('"%s" pinned', fn.expand('%:p')))
end

function M.unpin_buffer()
  api.nvim_buf_set_var(0, 'pinned', false)
  print(string.format('"%s" unpinned', fn.expand('%:p')))
end

function M.toggle_pinned()
  if buf_get_var(0, 'pinned') then
    M.unpin_buffer()
  else
    M.pin_buffer()
  end
end

function M.select_pinned_buffer()
  local pinned_buffers = {} 
  local popup_data = {} 
  local buffers = api.nvim_list_bufs()

  for i = 1, #buffers do
    local buffer = buffers[i] 
    local is_pinned = buf_get_var(buffer, 'pinned')
    if is_pinned then
      local buf_name = api.nvim_buf_get_name(buffer)
      local filename = vim.fn.fnamemodify(buf_name, ':t')
      local directory = vim.fn.fnamemodify(buf_name, ':h')
      pinned_buffers[#pinned_buffers + 1] = { handle = buffer, name = buf_name }
      popup_data[#popup_data + 1] = string.format('%-80s %s', filename, directory)
    end
  end

  if #pinned_buffers > 0 then
    local function on_select(index, line)
      vim.cmd(string.format('b%d', pinned_buffers[index].handle))
    end

    local opts = {
      height = 20,
      width = 160,
      mode = 'editor',
      close_on_bufleave = true,
      data = popup_data,
      keymaps = {
        i = {
        },
        n = {
          ['<CR>'] = function(popup)
            popup:close(on_select)
          end,
          ['q'] = function(popup)
            popup:close(on_close)
          end
        }
      },
      list = {
        border = true,
        title = 'Pinned buffers'
      }
    }

    local popup = require'popfix':new(opts)
  end
end

return M
