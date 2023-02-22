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
end

return Commands
