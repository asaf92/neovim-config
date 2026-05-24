local ok, conform = pcall(require, "conform")
if not ok then
  return
end

conform.setup({
  notify_on_error = true,
  formatters_by_ft = {
    -- Python is handled by the ruff LSP directly (see lua/asaf/lsp.lua),
    -- not by conform, so it uses the project-pinned ruff via `uv run`.
    javascript = { "prettierd", "prettier" },
    javascriptreact = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
  },
  format_on_save = false,
  default_format_opts = {
    timeout_ms = 5000,
  },
})
