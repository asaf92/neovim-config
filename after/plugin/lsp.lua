local lsp = require("lsp-zero")
local lspconfig = require('lspconfig')

lsp.preset("recommended")

lsp.ensure_installed({
  'ts_ls',
  'eslint',
  'pyright',
  'tailwindcss',
  'csharp_ls',
  'gopls'
})

lsp.nvim_workspace()

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})


lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.on_attach(function(client, bufnr)

  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "<leader>f", function()
    -- use eslint for formatting instead of ts_ls
    vim.lsp.buf.format({
      filter = function(client)
        return client.name ~= "ts_ls"
      end,
      bufnr = bufnr,
    })
  end, {buffer = bufnr})
 
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  
  -- diagnostics
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set('n', '<Leader>d', function() vim.diagnostic.open_float() end, opts)
  
  -- LSP actions
  vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

lspconfig.eslint.setup({
  format = true,
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true
  end
})

vim.diagnostic.config({
	virtual_text = true
})
