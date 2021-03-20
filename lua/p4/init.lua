local P4 = { _info = nil }

local function p4_cmd(cmd)
    return vim.fn.system('p4 ' .. cmd)
end

local function file_or_buffer(filename)
    return filename or vim.fn.expand('%:p')
end

local function ltrim(s)
	return s:match'^%s*(.*)'
end

function P4.info()
	if P4_info then
		return P4._info
	else
		P4._info = {}
		local info_string = p4_cmd('info')
		if info_string then
			for line in string.gmatch(info_string, '(.-)\n') do
				if line then
					for k,v in string.gmatch(line, '(.-):(.*)') do
						P4._info[k] = ltrim(v)
					end
				end
			end
		end
		return P4._info
	end
end

function P4.edit(filename)
    print(p4_cmd('edit ' .. file_or_buffer(filname)))
end

function P4.revert(filename)
    print(p4_cmd('revert ' .. file_or_buffer(filname)))
end

function P4.revision_graph(filename)
    return vim.fn.system('p4vc revgraph ' .. file_or_buffer(filname))
end

function P4.timelapse_view(filename)
    return vim.fn.system('p4vc timelapse ' .. file_or_buffer(filname))
end

return P4
