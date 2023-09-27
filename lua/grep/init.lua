local Grep = {}

function Grep.setup()
end

function Grep.async_grep(args)
    print(string.format("Searching for '%s'...", args))

    vim.fn.setqflist({}, 'r', { title = 'Searching for: ' .. args, lines = {} })

    local result = {}
    local process_handle = nil
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    local function on_read(err, data)
        if err then
        end
        if data then
            local lines = vim.split(data, '\n')
            for _, line in pairs(lines) do
                if line and line ~= '' then
                    result[#result + 1] = line
                end
            end
        end
    end

    local function on_completed()
        print(string.format("Found '%d' matches for '%s'", #result, args))
        stdout:read_stop()
        stdout:close()
        stderr:read_stop()
        stderr:close()
        process_handle:close()

        vim.fn.setqflist({}, 'r', { title = 'Search result for: ' .. args, lines = result })
        vim.api.nvim_command('cwindow')
    end

    process_handle = vim.loop.spawn('rg', {
        args = { args, '--vimgrep', '--smart-case', '--block-buffered', './' },
        stdio = { stdout, stderr }
    }, vim.schedule_wrap(on_completed));

    if process_handle then
        vim.loop.read_start(stdout, on_read)
        vim.loop.read_start(stderr, on_read)
    else
        print('Error')
    end
end

return Grep
