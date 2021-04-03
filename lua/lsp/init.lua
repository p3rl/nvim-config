local lspconfig = require'lspconfig'
local completion = require'compe'

local Lsp = {}

function Lsp.get_active_clients()
  local clients = {}  
  for _,client in ipairs(vim.lsp.get_active_clients()) do
    clients[#clients + 1] = { name = client.name, id = client.id }
  end
  return clients
end

function Lsp.stop_all_clients()
  local clients = Lsp.get_active_clients()
  for _, client in ipairs(clients) do
    print(string.format("Stopping Lsp client '%s (%d)'", client.name, client.id))
    vim.lsp.stop_client(id)
  end
end

function Lsp.setup()
  lspconfig.clangd.setup {
    root_dir = lspconfig.util.root_pattern('compile_commands.json'),
    cmd = { 'clangd', '--enable-config', '--pch-storage=memory', '--log=verbose', '--background-index' }
  }

  completion.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
      path = true;
      buffer = true;
      calc = true;
      nvim_lsp = true;
      nvim_lua = true;
      vsnip = true;
    };
  }

  vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
end

return Lsp
