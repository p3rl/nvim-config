local lspconfig = require'lspconfig'
local cmp = require'cmp'

local Lsp = {}

function Lsp.get_active_clients()
  local clients = {}  
  for _,client in ipairs(vim.lsp.get_active_clients()) do
    clients[#clients + 1] = { name = client.name, id = client.id }
  end
  return clients
end

function Lsp.get_buf_clients()
  local clients = {}  
  for _,client in ipairs(vim.lsp.buf_get_clients()) do
    clients[#clients + 1] = { name = client.name, id = client.id }
  end
  return clients
end

function Lsp.get_buf_client_name()
  local name = 'none'
  local clients = Lsp.get_buf_clients()
  if #clients > 0 then
    name = clients[1].name
  end
  return 'lsp: '..name
end

function Lsp.stop_all_clients()
  local clients = Lsp.get_active_clients()
  for _, client in ipairs(clients) do
    print(string.format("Stopping Lsp client '%s (%d)'", client.name, client.id))
    vim.lsp.stop_client(id)
  end
end

function Lsp.setup(opts)
  
  lspconfig.clangd.setup {
    root_dir = lspconfig.util.root_pattern('compile_commands.json', '.zenroot', '.p4config', '.gitignore'),
    cmd = { 'clangd', '--enable-config', '--pch-storage=memory', '--log=verbose', '--background-index' }
  }

  lspconfig.rls.setup {
    root_dir = lspconfig.util.root_pattern('Cargo.toml'),
    cmd = { 'rls' }
  }

  cmp.setup {
    sources = {
      { name = 'buffer' },
      { name = 'nvim_lsp' },
      { name = 'nvm_lua' },
    }
  }

end

return Lsp
