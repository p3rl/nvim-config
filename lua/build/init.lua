-- Runs `cmake --build --preset <preset>` asynchronously and puts compiler errors and
-- warnings in the quickfix list.
local Build = {
    job = nil,
    default_preset = 'ninja-debug',
}

local function project_root()
    return vim.fs.root(0, { 'CMakePresets.json', '.git' }) or vim.fn.getcwd()
end

-- Build preset names from CMakePresets.json, for command completion.
function Build.presets()
    local file = project_root() .. '/CMakePresets.json'
    if vim.fn.filereadable(file) == 0 then
        return {}
    end
    local ok, json = pcall(vim.json.decode, table.concat(vim.fn.readfile(file), '\n'))
    if not ok or not json.buildPresets then
        return {}
    end
    return vim.tbl_map(function(preset) return preset.name end, json.buildPresets)
end

local function build_command(root, preset)
    local cmake = string.format('cmake --build --preset %s', preset)
    -- Ninja builds need the MSVC environment; load it through env.ps1 when Neovim was not
    -- started from a developer shell.
    if vim.fn.executable('cl') == 0 and vim.fn.filereadable(root .. '/env.ps1') == 1 then
        return {
            'powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command',
            string.format('. ./env.ps1 *> $null; %s', cmake),
        }
    end
    return vim.split(cmake, ' ')
end

local function on_exit(result, preset)
    Build.job = nil
    local output = (result.stdout or '') .. (result.stderr or '')
    local lines = vim.split(output:gsub('\r', ''), '\n', { trimempty = true })

    -- Keep only lines that match 'errorformat' (errors, warnings, notes).
    local items = vim.tbl_filter(function(item) return item.valid == 1 end,
        vim.fn.getqflist({ lines = lines, efm = vim.o.errorformat }).items)
    vim.fn.setqflist({}, ' ', { title = 'Build ' .. preset, items = items })

    if #items > 0 then
        vim.cmd('botright copen')
    elseif result.code == 0 then
        vim.cmd('cclose')
    end

    if result.code == 0 then
        vim.notify(string.format('Build %s succeeded (%d warnings)', preset, #items))
    else
        vim.notify(string.format('Build %s failed', preset), vim.log.levels.ERROR)
        if #items == 0 then
            -- Nothing parsable (configure or link error); show the raw output instead.
            vim.fn.setqflist({}, ' ', { title = 'Build ' .. preset, lines = lines, efm = '%m' })
            vim.cmd('botright copen')
        end
    end
end

function Build.run(preset)
    if Build.job then
        vim.notify('A build is already running', vim.log.levels.WARN)
        return
    end
    preset = (preset and preset ~= '') and preset or Build.default_preset

    local root = project_root()
    vim.cmd('silent! wall')
    vim.notify(string.format('Building %s...', preset))
    Build.job = vim.system(build_command(root, preset), { cwd = root, text = true }, function(result)
        vim.schedule(function() on_exit(result, preset) end)
    end)
end

return Build
