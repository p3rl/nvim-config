local notes_repo = "c:/git/docs"

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
  print(vim.fn.system('git ' .. string.format("-C %s pull", notes_repo)))
end

return Notes
