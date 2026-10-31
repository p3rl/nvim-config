local Ctags = {}

-- UE reflection/export macros that confuse the C++ parser. The trailing '+'
-- tells ctags to also skip the macro's parenthesised arguments.
local IGNORE = {
    'UCLASS+', 'USTRUCT+', 'UENUM+', 'UINTERFACE+', 'UPROPERTY+', 'UFUNCTION+',
    'UDELEGATE+', 'UMETA+', 'UPARAM+', 'DECLARE_CLASS+',
    'GENERATED_BODY+', 'GENERATED_UCLASS_BODY+', 'GENERATED_USTRUCT_BODY+',
    'GENERATED_IINTERFACE_BODY+', 'GENERATED_UINTERFACE_BODY+',
    'FORCEINLINE', 'FORCENOINLINE', 'FORCEINLINE_DEBUGGABLE',
    'UE_DEPRECATED+', 'PRAGMA_DISABLE_OPTIMIZATION', 'PRAGMA_ENABLE_OPTIMIZATION',
    'ABSTRACT', 'CONSTEXPR', 'PURE_VIRTUAL+',
}

local EXCLUDE = {
    'Intermediate', 'Binaries', 'Saved', 'DerivedDataCache', 'Build',
    'ThirdParty', '.git', '.vs', '.idea', '*.gen.cpp', '*.generated.h',
}

local running = false

--- Generate a 'tags' file in the current directory.
--- @param paths string[]|nil directories to scan, relative to cwd (default: cwd)
function Ctags.generate(paths)
    if running then
        vim.notify('[ctags]: already running', vim.log.levels.WARN)
        return
    end

    if vim.fn.executable('ctags') == 0 then
        vim.notify('[ctags]: ctags not found in PATH', vim.log.levels.ERROR)
        return
    end

    paths = (paths and #paths > 0) and paths or { '.' }

    local cmd = {
        'ctags', '-R',
        '-f', 'tags',
        '--languages=C++',
        '--langmap=C++:+.inl.h.hpp',
        '--c++-kinds=+p',
        '--fields=+iaS',
        '--extras=+q',  -- also emit qualified tags: AActor::BeginPlay
        '-I', table.concat(IGNORE, ','),
    }
    for _, pattern in ipairs(EXCLUDE) do
        cmd[#cmd + 1] = '--exclude=' .. pattern
    end
    vim.list_extend(cmd, paths)

    running = true
    local start = vim.uv.hrtime()
    vim.notify(string.format("[ctags]: indexing %s ...", table.concat(paths, ', ')))

    vim.system(cmd, { cwd = vim.fn.getcwd(), text = true }, vim.schedule_wrap(function(result)
        running = false
        if result.code ~= 0 then
            vim.notify('[ctags]: failed\n' .. (result.stderr or ''), vim.log.levels.ERROR)
            return
        end
        local seconds = (vim.uv.hrtime() - start) / 1e9
        vim.notify(string.format('[ctags]: done in %.1fs', seconds))
    end))
end

return Ctags
