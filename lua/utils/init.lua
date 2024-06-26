local Utils = {
    psue_dir = nil
}

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

function Utils.get_psue_dir()
    if Utils.psue_dir ~= nil then
        return Utils.psue_dir
    else
        local working_dir = vim.fn.getcwd()
        local current_dir = working_dir
        local search = true
        while search do
            local psue = current_dir .. '/.psue'
            if vim.fn.isdirectory(psue) ~= 0 then
                Utils.psue_dir = psue
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
        return Utils.psue_dir
    end
end

function Utils.read_quickfix()
    local root_dir = Utils.get_psue_dir()
    if root_dir then
        vim.fn.setqflist({})
        vim.cmd('cfile ' .. root_dir .. '/quickfix.txt')
        vim.cmd('botright copen 20')
    end
end

return Utils
