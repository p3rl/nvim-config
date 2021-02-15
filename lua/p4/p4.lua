local p4_cmd = 'p4.exe'

local function edit(filename)
 print 'hello perforce'
end

local P4 = p4 or {}
P4.edit = edit

return P4
