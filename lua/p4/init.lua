local P4 = { _info = nil }

local function p4_cmd(cmd)
    return vim.fn.system('p4 ' .. cmd)
end

local function file_or_buffer(filename)
    return filename or vim.fn.expand('%:p')
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

function P4.init(reload)
  if not P4._info or reload then
    local p4_info = P4.info(reload)
    --vim.cmd('doautocommand User PerforceWorkspaceChanged')
    print("[Perforce]: Workspace is '" .. p4_info.client_name .. "'")
  else
    print('[Perforce]: no workspace')
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

function P4.edit(filename)
  print(p4_cmd('edit ' .. file_or_buffer(filname)))
end

function P4.revert(filename)
  print(p4_cmd('revert ' .. file_or_buffer(filname)))
end

function P4.revision_graph(filename)
  local file = file_or_buffer(filname)
  print("[Perforce]: Launching Revision Graph for '" .. file .. "'")
  return vim.fn.system('p4vc revgraph ' .. file)
end

function P4.timelapse_view(filename)
  local file = file_or_buffer(filname)
  print("[Perforce]: Launching Timelapse View for '" .. file .. "'")
  return vim.fn.system('p4vc timelapse ' .. file)
end

return P4
