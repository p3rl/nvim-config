local fzf = require 'fzf'.fzf

local FzfCmds = {}

function FzfCmds.files()
  local command = 'fd'
	local opts = '--ansi'

	coroutine.wrap(function()
		local results = fzf(command, opts)
		if not results then return end
    local file = vim.fn.fnameescape(results[1])
		vim.cmd('e ' .. file)
	end)()
end

function FzfCmds.buffers()
	local buf_names = {}
	for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_option(buf_id, 'buflisted') then
			local buf_name = vim.api.nvim_buf_get_name(buf_id)
			local filename = vim.fn.fnamemodify(buf_name, ':p:.')
			buf_names[#buf_names + 1] = string.format('%2d %s', buf_id, filename)
		end
	end

	coroutine.wrap(function()
		local results = fzf(buf_names)
		if not results then return end
		local buf_id = tonumber(string.match(results[1], '%d+'))
		vim.cmd('b ' .. buf_id)
	end)()
end

return FzfCmds
