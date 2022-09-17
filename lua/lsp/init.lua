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
  cmp.setup {
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'cmp_ctags' },
      }, {
        { name = 'buffer' },
      })
  }
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

  lspconfig.clangd.setup {
    root_dir = lspconfig.util.root_pattern('compile_commands.json', '.zenroot', '.p4config', '.gitignore'),
    cmd = { 'clangd', '--background-index' },
    capabilities = capabilities
  }
end

--function Lsp.setup(opts)
--  
--  cmp.setup {
--    sources = cmp.config.sources({
--      { name = 'nvim_lsp' },
--      { name = 'nvim_lua' },
--      { name = 'buffer' }
--    }),
--    completion = {
--		  keyword_length = 2
--	  },
--    enabled = function()
--      if vim.bo.filetype == 'markdown' then
--        return false
--      else
--        return true
--      end
--    end
--  }
--
--  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
--
--  local lsp_attach = function(client, buf)
--    -- Example maps, set your own with vim.api.nvim_buf_set_keymap(buf, "n", <lhs>, <rhs>, { desc = <desc> })
--    -- or a plugin like which-key.nvim
--    -- <lhs>        <rhs>                        <desc>
--    -- "K"          vim.lsp.buf.hover            "Hover Info"
--    -- "<leader>qf" vim.diagnostic.setqflist     "Quickfix Diagnostics"
--    -- "[d"         vim.diagnostic.goto_prev     "Previous Diagnostic"
--    -- "]d"         vim.diagnostic.goto_next     "Next Diagnostic"
--    -- "<leader>e"  vim.diagnostic.open_float    "Explain Diagnostic"
--    -- "<leader>ca" vim.lsp.buf.code_action      "Code Action"
--    -- "<leader>cr" vim.lsp.buf.rename           "Rename Symbol"
--    -- "<leader>fs" vim.lsp.buf.document_symbol  "Document Symbols"
--    -- "<leader>fS" vim.lsp.buf.workspace_symbol "Workspace Symbols"
--    -- "<leader>gq" vim.lsp.buf.formatting_sync  "Format File"
--
--    vim.api.nvim_buf_set_option(buf, "formatexpr", "v:lua.vim.lsp.formatexpr()")
--    vim.api.nvim_buf_set_option(buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
--    vim.api.nvim_buf_set_option(buf, "tagfunc", "v:lua.vim.lsp.tagfunc")
--  end
--  
--  lspconfig.clangd.setup {
--    root_dir = lspconfig.util.root_pattern('compile_commands.json', '.zenroot', '.p4config', '.gitignore'),
--    cmd = { 'clangd', '--background-index' },
--    capabilities = capabilities,
--    on_attach = lsp_attach
--  }
--
--  lspconfig.rls.setup {
--    root_dir = lspconfig.util.root_pattern('Cargo.toml'),
--    cmd = { 'rls' }
--  }
--
--  vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
--
--end

return Lsp
