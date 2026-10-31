-- Picks tabs or spaces per buffer. Spaces are the global default (init.lua); these rules
-- only switch buffers to tabs. A project's .editorconfig indent_style always wins.
local TabSettings = {}

-- Filetypes whose own style uses tabs.
local tab_filetypes = { odin = true }

local function is_unreal_marker(name)
    return name == 'GenerateProjectFiles.bat' or name:match('%.uproject$') ~= nil
end

local function wants_tabs(buf)
    if tab_filetypes[vim.bo[buf].filetype] then
        return true
    end
    return vim.fs.root(buf, is_unreal_marker) ~= nil
end

function TabSettings.update(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype ~= '' or vim.b[buf].tabsettings_applied then
        return
    end
    vim.b[buf].tabsettings_applied = true

    local editorconfig = vim.b[buf].editorconfig
    if editorconfig and editorconfig.indent_style then
        return
    end
    if wants_tabs(buf) then
        vim.bo[buf].expandtab = false
    end
end

return TabSettings
