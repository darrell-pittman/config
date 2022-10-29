local utils = require('wgc.utils')

local gmap = utils.make_mapper {silent = true} 

-- LSP
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
gmap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
gmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
gmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
gmap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local map = utils.make_mapper {buffer = bufnr, silent = true} 
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
  map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
  map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
  map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
  map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
  map('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
  map('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
  map('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
  map('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
  map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
  map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
  map('n', '<leader>t', '<cmd>lua vim.lsp.buf.format{ async = true }<CR>')
end

-- Use a loop to conveniently call 'setup' on multiple servers and

-- map buffer local keybindings when the language server attaches
local servers = { 'rust_analyzer','ccls', }
local capabilities = require('cmp_nvim_lsp').default_capabilities()
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    },
    capabilities = capabilities,
  }
end
