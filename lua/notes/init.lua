local notes_repo = "c:/git/docs"

local Notes = {}

function Notes.open()
  vim.cmd [[:e c:/git/docs/ue/ue.md]]
end

function Notes.save()
  print(vim.fn.system('git ' .. string.format("-C %s commit -a -m %s", notes_repo, "Update")))
  print(vim.fn.system('git ' .. string.format("-C %s push", notes_repo)))
end

return Notes
