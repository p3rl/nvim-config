local Commands = {}

function Commands.setup(opts)
    vim.cmd('command! CopyPath :let @+= expand("%:p") | echo expand("%:p")')
    vim.cmd('command! CopyDir :let @+= expand("%:p:h") | echo expand("%:p:h")')
    vim.cmd("command! EditConfig :exec printf(':e %s/init.lua', stdpath('config'))")
    vim.cmd("command! EditGConfig :exec printf(':e %s/ginit.vim', stdpath('config'))")
    vim.cmd([[command! EditBuildConfig :exec printf(':e %s', 'C:\Users\per.larsson\AppData\Roaming\Unreal Engine\UnrealBuildTool\BuildConfiguration.xml')]])

    -- Notes
    vim.cmd([[command! Notes lua require'p3rl.notes'.open()]])
    vim.cmd([[command! SaveNotes lua require'p3rl.notes'.save()]])
    vim.cmd([[command! UpdateNotes lua require'p3rl.notes'.update()]])

    vim.cmd([[command! -nargs=+ -complete=dir -bar Grep lua require('p3rl.grep').async_grep(<q-args>)]])
    vim.cmd([[command! ReloadBuffer :e! %]])

    -- Perforce
    vim.cmd([[command! -nargs=* P4init :lua require'p3rl.p4'.init(<q-args>)]])
    vim.cmd([[command! P4edit :lua require'p3rl.p4'.edit()]])
    vim.cmd([[command! P4revert :lua require'p3rl.p4'.revert()]])
    vim.cmd([[command! -nargs=? P4revgraph :lua require'p3rl.p4'.revision_graph(<q-args>)]])
    vim.cmd([[command! -nargs=? P4timelapse :lua require'p3rl.p4'.timelapse_view(<q-args>)]])
    vim.cmd([[command! -nargs=? P4history :lua require'p3rl.p4'.history_view(<q-args>)]])
    vim.cmd([[command! -nargs=? P4depotpath :lua require'p3rl.p4'.copy_depot_path(<q-args>)]])

    --Fzf
    vim.cmd([[command! FzfFiles :lua require'p3rl.fzf-cmds'.files()]])
    vim.cmd([[command! FzfBuffers :lua require'p3rl.fzf-cmds'.buffers()]])
    vim.cmd([[command! FzfTags :lua require'p3rl.fzf-cmds'.tags()]])

    -- UE
    vim.api.nvim_create_user_command('UEquickfix',
        function()
            require'p3rl.utils'.read_quickfix()
        end,
        {})

    vim.api.nvim_create_user_command('SetTabs',
        function(opts)
            if not opts.fargs or #opts.fargs == 0 then
                print("SetTabs <with:int> <expand:boolean>")
                return
            end

            local expand = false
            if #opts.fargs > 1 and opts.fargs[2] == 'true' then
                expand = true
            end
            local tabs = {
                width = tonumber(opts.fargs[1]),
                expand = expand
            }
            require'p3rl.settings'.setup_tabs(tabs)
            print(string.format("Set tabs, with=%d, spaces='%s'", tabs.width, tostring(tabs.expand)))
        end,
        {
            nargs = "*"
        })
    
    vim.api.nvim_create_user_command('TabSettings',
        function(opts)
            print(string.format("<tabstop=%d>, <expandtab='%s'>", vim.bo.tabstop, tostring(vim.bo.expandtab)))
        end,
        {})

    vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
        pattern = '*',
        callback = function(opts)
            require'p3rl.settings'.update_tabsettings(vim.bo.filetype)
        end
    })
end

return Commands
