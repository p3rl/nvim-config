local Notes = {
    config = {
        root_path = "",
        path = ""
    }
}

function Notes.setup(config)
    Notes.config = config
end

function Notes.open()
    local path = Notes.config.path
    vim.cmd (string.format("e %s", path))
end

function Notes.save()
    local path = Notes.config.root_path
    print(vim.fn.system('git ' .. string.format("-C %s commit -a -m %s", path, "Update")))
    print(vim.fn.system('git ' .. string.format("-C %s push", path)))
end

function Notes.update()
    local path = Notes.config.root_path
    print(vim.fn.system('git ' .. string.format("-C %s pull", path)))
end

return Notes
