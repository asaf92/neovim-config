-- Pick the ruff binary at attach time based on the buffer's location:
-- inside a uv project → use that project's pinned ruff via `uv run ruff
-- server` (so we match CI / pre-commit). Outside any uv project → fall back
-- to the ruff binary on PATH (Mason's).
local function find_uv_root(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local search_from = fname ~= "" and vim.fs.dirname(fname) or vim.uv.cwd()
  local match = vim.fs.find({ "uv.lock" }, { upward = true, path = search_from, type = "file" })[1]
  return match and vim.fs.dirname(match) or nil
end

return {
  cmd = function(dispatchers)
    local bufnr = vim.api.nvim_get_current_buf()
    local uv_root = find_uv_root(bufnr)
    if uv_root then
      return vim.lsp.rpc.start({ "uv", "run", "ruff", "server" }, dispatchers, { cwd = uv_root })
    end
    return vim.lsp.rpc.start({ "ruff", "server" }, dispatchers)
  end,
  init_options = {
    settings = {
      args = {},
    },
  },
}
