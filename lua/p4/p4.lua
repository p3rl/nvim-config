local function p4_cmd(cmd)
    return vim.fn.system('p4 ' .. cmd)
end

local function file_or_buffer(filename)
    return filename or vim.fn.expand('%:p')
end

local function edit(filename)
    print(p4_cmd('edit ' .. file_or_buffer(filname)))
end

local function revert(filename)
    print(p4_cmd('revert ' .. file_or_buffer(filname)))
end

return {
    edit = edit,
    revert = revert
}
