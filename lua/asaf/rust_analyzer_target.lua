local M = {}

local WINDOWS_TARGET = "x86_64-pc-windows-msvc"

local function settings(target)
  local cargo = {
    allFeatures = true,
  }

  if target then
    cargo.target = target
  end

  if target == WINDOWS_TARGET then
    cargo.cfgs = { 'target_os="windows"' }
  end

  return {
    ["rust-analyzer"] = {
      cargo = cargo,
      check = {
        command = "clippy",
      },
    },
  }
end

local function start_rust_analyzer_for_open_rust_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "rust" then
      local file = vim.api.nvim_buf_get_name(bufnr)
      local root = vim.fs.root(file, { "Cargo.toml", "rust-project.json", ".git" }) or vim.fn.getcwd()
      local config = vim.deepcopy(vim.lsp.config.rust_analyzer)
      config.root_dir = root

      vim.lsp.start(config, { bufnr = bufnr })
    end
  end
end

function M.config()
  return {
    settings = settings(vim.g.rust_analyzer_target),
  }
end

function M.set_windows()
  M.set_target(WINDOWS_TARGET, "Windows")
end

function M.set_mac()
  M.set_target(nil, "macOS/default")
end

function M.set_target(target, label)
  vim.g.rust_analyzer_target = target

  local existing = vim.lsp.config.rust_analyzer or {}
  local config = vim.tbl_deep_extend("force", existing, M.config())

  if not target then
    config.settings["rust-analyzer"].cargo.target = nil
    config.settings["rust-analyzer"].cargo.cfgs = nil
  end

  vim.diagnostic.reset()

  vim.lsp.enable("rust_analyzer", false)
  vim.lsp.config.rust_analyzer = config
  vim.lsp.enable("rust_analyzer", true)
  start_rust_analyzer_for_open_rust_buffers()

  vim.notify("rust-analyzer target: " .. label)
end

return M
