local P4 = { _info = nil }

local function p4_cmd(cmd)
    return vim.fn.system('p4 ' .. cmd)
end

local function split_line(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function file_or_buffer(filename)
    if filename == nil or filename == '' then
        return vim.fn.expand('%:p')
    end
    return P4.get_depot_path(filename)
end

local function ltrim(s)
    return s:match'^%s*(.*)'
end

function P4.info(reload)
    if reload then
        P4._info = nil
    end
    if P4_info then
        return P4._info
    else
        local p4_info = {}
        local info_string = p4_cmd('info')
        if info_string then
            for line in string.gmatch(info_string, '(.-)\n') do
                if line then
                    for k,v in string.gmatch(line, '(.-):(.*)') do
                        local property = string.lower(string.gsub(k, ' ', '_'))
                        local value = ltrim(v)
                        p4_info[property] = value
                    end
                end
            end
        end
        if p4_info.client_name then
            P4._info = p4_info
        end
        return P4._info
    end
end

function P4.setup(opts)
end

function P4.init(reload)
    if not P4._info or reload then
        local p4_info = P4.info(reload)
        --vim.cmd('doautocommand User PerforceWorkspaceChanged')
        print("[P4]: Workspace '" .. p4_info.client_name .. "'" .. " stream '" .. p4_info.client_stream .. "'")
    else
        print('[P4]: no workspace')
    end
end

function P4.has_active_workspace()
    return P4._info ~= nil
end

function P4.get_client_name()
    if P4._info then
        return P4._info.client_name
    else
        return ''
    end
end

function P4.get_depot_path(filename)
    if filename == nil or filename == '' then
        return ''
    end

    local result = p4_cmd('where ' .. filename)
    if result ~= nil then
        local tokens = split_line(result, " ")
        return tokens[1]
    end

    return ''
end

function P4.copy_depot_path(filename)
    local depot_path = P4.get_depot_path(file_or_buffer(filename))
    print(depot_path)
    vim.fn.setreg('+', depot_path)
end

function P4.edit(filename)
    print(p4_cmd('edit ' .. file_or_buffer(filename)))
end

function P4.revert(filename)
    print(p4_cmd('revert ' .. file_or_buffer(filename)))
end

function P4.revision_graph(filename)
    local file = file_or_buffer(filename)
    print("[P4]: Launching Revision Graph for '" .. file .. "'")
    return vim.fn.system('p4vc revgraph ' .. file)
end

function P4.timelapse_view(filename)
    local file = file_or_buffer(filename)
    print("[P4]: Launching Timelapse View for '" .. file .. "'")
    return vim.fn.system('p4vc timelapse ' .. file)
end

function P4.history_view(filename)
    local file = file_or_buffer(filename)
    print("[P4]: Launching History View for '" .. file .. "'")
    return vim.fn.system('p4vc history ' .. file)
end

-- Run p4 from the file's directory so its P4CONFIG picks the right workspace. Returns the result of vim.system.
local function p4_run(file, args)
    return vim.system(vim.list_extend({ 'p4' }, args), { text = true, cwd = vim.fn.fnamemodify(file, ':h') }):wait()
end

-- Error text of a failed p4_run result, or nil if it succeeded.
local function p4_error(result)
    if result.code ~= 0 or (result.stderr or '') ~= '' then
        return vim.trim(result.stderr ~= '' and result.stderr or result.stdout)
    end
end

-- Contents of `file` at revision `rev` (e.g. "#have", "#12", "@12345") as a list of lines, or nil and an error.
local function print_revision(file, rev)
    local result = p4_run(file, { 'print', '-q', file .. rev })
    local err = p4_error(result)
    if err then
        return nil, err
    end
    local lines = vim.split(result.stdout:gsub('\r', ''), '\n', { plain = true })
    if lines[#lines] == '' then
        table.remove(lines)
    end
    return lines
end

-- Diff the current buffer against a depot revision in a vertical split. `rev` is a P4 revision specifier
-- such as "#head", "#12" or "@12345"; it defaults to "#have", the revision synced to the workspace.
function P4.diff(rev)
    local file = vim.fn.expand('%:p')
    if file == '' or file:match('^p4://') then
        vim.notify('[P4]: Buffer is not a workspace file', vim.log.levels.ERROR)
        return
    end
    if rev == nil or rev == '' then
        rev = '#have'
    end

    local lines, err = print_revision(file, rev)
    if not lines then
        vim.notify('[P4]: ' .. err, vim.log.levels.ERROR)
        return
    end

    local filetype = vim.bo.filetype
    local source_win = vim.api.nvim_get_current_win()
    vim.cmd('diffthis')

    vim.cmd('vertical leftabove new')
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].buflisted = false -- keep it out of :ls and the buffer picker
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = filetype
    vim.b[buf].p4_diff = true
    pcall(vim.api.nvim_buf_set_name, buf, 'p4://' .. vim.fn.fnamemodify(file, ':t') .. rev)
    vim.cmd('diffthis')

    -- Closing the depot side turns diff mode off in the working file again.
    vim.api.nvim_create_autocmd('BufWipeout', {
        buffer = buf,
        once = true,
        callback = function()
            if vim.api.nvim_win_is_valid(source_win) then
                vim.api.nvim_win_call(source_win, function() vim.cmd('diffoff') end)
            end
        end,
    })

    vim.api.nvim_set_current_win(source_win)
end

-- Windows of the current P4.diff_prev view; the revision buffers themselves are kept for the quickfix list.
local prev_diff = { main = nil, prev = nil }

local function close_prev_diff()
    if prev_diff.prev and vim.api.nvim_win_is_valid(prev_diff.prev) then
        vim.api.nvim_win_close(prev_diff.prev, true)
    end
    if prev_diff.main and vim.api.nvim_win_is_valid(prev_diff.main) then
        vim.api.nvim_win_call(prev_diff.main, function() vim.cmd('diffoff') end)
    end
    prev_diff.main, prev_diff.prev = nil, nil
end

-- Diff a revision against the one before it. In the quickfix window this uses the entry under the cursor (from
-- :P4Log) and keeps the cursor there, so you can move down the list diffing each change; in a revision buffer
-- ("p4://<file>#<rev>") it uses that revision.
function P4.diff_prev()
    local in_qf = vim.bo.buftype == 'quickfix'
    local buf = vim.api.nvim_get_current_buf()
    if in_qf then
        local entry = vim.fn.getqflist({ idx = vim.fn.line('.'), items = 0 }).items[1]
        buf = entry and entry.bufnr or 0
    end
    local name = buf > 0 and vim.api.nvim_buf_get_name(buf) or ''
    local file, rev = name:match('^p4://(.*)#(%d+)$')
    if not file then
        vim.notify('[P4]: Not a P4 revision; use :P4Log to list the history', vim.log.levels.ERROR)
        return
    end
    rev = tonumber(rev)
    if rev <= 1 then
        vim.notify('[P4]: #1 is the first revision', vim.log.levels.WARN)
        return
    end

    close_prev_diff()

    -- Show the revision in the window quickfix would jump to, or in the current window.
    local qf_win = vim.api.nvim_get_current_win()
    local main = qf_win
    if in_qf then
        main = vim.fn.win_getid(vim.fn.winnr('#'))
        if main == 0 or main == qf_win or vim.bo[vim.api.nvim_win_get_buf(main)].buftype == 'quickfix' then
            main = nil
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= 'quickfix' then
                    main = win
                    break
                end
            end
        end
        if not main then
            vim.cmd('aboveleft split')
            main = vim.api.nvim_get_current_win()
        end
    end

    local prev_buf = vim.fn.bufadd('p4://' .. file .. '#' .. (rev - 1))
    vim.bo[prev_buf].buflisted = false

    vim.api.nvim_win_set_buf(main, buf)
    vim.api.nvim_win_call(main, function() vim.cmd('diffthis') end)
    local prev = vim.api.nvim_open_win(prev_buf, false, { split = 'left', win = main })
    vim.api.nvim_win_call(prev, function() vim.cmd('diffthis') end)
    prev_diff.main, prev_diff.prev = main, prev

    vim.api.nvim_set_current_win(in_qf and qf_win or main)
end

-- Delete every depot buffer opened by P4.diff; their BufWipeout autocmds turn diff mode off again.
function P4.diff_close()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.b[buf].p4_diff then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
    close_prev_diff()
end

-- Buffers named "p4://<local path>#<rev>" are filled with that revision when loaded, so the history quickfix
-- list only fetches the revisions you actually open.
vim.api.nvim_create_autocmd('BufReadCmd', {
    pattern = 'p4://*',
    callback = function(args)
        local buf = args.buf
        local file, rev = vim.api.nvim_buf_get_name(buf):match('^p4://(.*)(#%d+)$')
        if not file then
            return
        end
        local lines, err = print_revision(file, rev)
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines or { '[P4]: ' .. err })
        vim.bo[buf].buftype = 'nofile'
        vim.bo[buf].bufhidden = 'hide'
        vim.bo[buf].buflisted = false
        vim.bo[buf].swapfile = false
        vim.bo[buf].modified = false
        vim.bo[buf].modifiable = false
        vim.bo[buf].filetype = vim.filetype.match({ filename = file }) or ''
    end,
})

-- List every revision of the current file in the quickfix list, newest first. Each entry opens that revision.
function P4.log()
    local file = vim.fn.expand('%:p')
    if file == '' or file:match('^p4://') then
        vim.notify('[P4]: Buffer is not a workspace file', vim.log.levels.ERROR)
        return
    end

    local result = p4_run(file, { '-ztag', 'filelog', '-l', file })
    local err = p4_error(result)
    if err then
        vim.notify('[P4]: ' .. err, vim.log.levels.ERROR)
        return
    end

    -- Tagged output is "... key value" lines; a multi-line description continues on untagged lines.
    local fields, last_key = {}, nil
    for line in (result.stdout:gsub('\r', '') .. '\n'):gmatch('(.-)\n') do
        local key, value = line:match('^%.%.%. (%S+) ?(.*)$')
        if key then
            fields[key], last_key = value, key
        elseif last_key and vim.trim(fields[last_key]) == '' then
            fields[last_key] = vim.trim(line) -- keep the first non-empty description line
        end
    end

    local items, i = {}, 0
    while fields['rev' .. i] do
        local rev = '#' .. fields['rev' .. i]
        local buf = vim.fn.bufadd('p4://' .. file .. rev)
        vim.bo[buf].buflisted = false
        table.insert(items, {
            bufnr = buf,
            lnum = 1,
            module = rev,
            text = string.format('%s  %-9s %-12s %-12s %s',
                os.date('%Y-%m-%d %H:%M', tonumber(fields['time' .. i]) or 0),
                fields['change' .. i] or '', fields['action' .. i] or '',
                fields['user' .. i] or '', vim.trim(fields['desc' .. i] or '')),
        })
        i = i + 1
    end

    if #items == 0 then
        vim.notify('[P4]: No history for ' .. file, vim.log.levels.WARN)
        return
    end
    vim.fn.setqflist({}, ' ', { title = 'P4 history: ' .. vim.fn.fnamemodify(file, ':t'), items = items })
    vim.cmd('copen')
    -- d in the history list diffs the entry under the cursor against its previous revision.
    vim.keymap.set('n', 'd', P4.diff_prev, { buffer = true, desc = 'P4: diff against previous revision' })
end

return P4
