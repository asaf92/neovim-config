local ok, conform = pcall(require, "conform")
if not ok then
  return
end

conform.setup({
  notify_on_error = true,
  formatters_by_ft = {
    python = { "ruff_fix", "ruff_format" },
  },
  format_on_save = false,
  default_format_opts = {
    timeout_ms = 5000,
  },
})
