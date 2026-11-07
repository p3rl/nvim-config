-- Send commands to a PowerShell tab running scripts/nvim-listener.ps1. Each command opens a connection to the
-- listener's named pipe, sends {"cmd": ...} as a JSON line and reports the {"ok", "exit"} reply when it finishes.
local Shell = { last = nil }

local function address()
    return [[\\.\pipe\]] .. (vim.g.shell_pipe or 'nvim-shell')
end

function Shell.send(cmd)
    if cmd == nil or vim.trim(cmd) == '' then
        vim.notify('[Shell]: No command', vim.log.levels.ERROR)
        return
    end

    local received = ''
    local ok, chan = pcall(vim.fn.sockconnect, 'pipe', address(), {
        on_data = function(chan, data)
            -- data is a list of chunks split on newlines; the reply is complete once a newline has arrived.
            received = received .. table.concat(data, '\n')
            if not received:find('\n') then
                return
            end
            local reply = vim.trim(received)
            received = ''
            if reply == '' then
                return
            end

            local decoded, msg = pcall(vim.json.decode, reply)
            vim.schedule(function()
                pcall(vim.fn.chanclose, chan)
                if not decoded then
                    vim.notify('[Shell]: Bad reply: ' .. reply, vim.log.levels.ERROR)
                elseif msg.ok then
                    vim.notify('[Shell]: Done: ' .. cmd)
                elseif msg.exit ~= 0 then
                    vim.notify(string.format('[Shell]: Failed (exit %s): %s', msg.exit, cmd), vim.log.levels.WARN)
                else
                    vim.notify('[Shell]: Failed: ' .. cmd, vim.log.levels.WARN)
                end
            end)
        end,
    })
    if not ok or chan == 0 then
        vim.notify('[Shell]: No listener on ' .. address() .. '; run scripts/nvim-listener.ps1 in the other tab',
            vim.log.levels.ERROR)
        return
    end

    Shell.last = cmd
    vim.fn.chansend(chan, vim.json.encode({ cmd = cmd }) .. '\n')
end

function Shell.repeat_last()
    if not Shell.last then
        vim.notify('[Shell]: Nothing sent yet', vim.log.levels.ERROR)
        return
    end
    Shell.send(Shell.last)
end

return Shell
