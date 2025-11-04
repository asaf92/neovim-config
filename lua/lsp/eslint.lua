return {
  settings = {
    format = {
      enable = true,
    },
    -- Avoid re-linting unrelated files when switching buffers
    workingDirectory = {
      mode = "auto",
    },
  },
  on_attach = function(client)
    -- Ensure Neovim knows the ESLint server supports formatting so vim.lsp.buf.format works.
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true
  end,
}
