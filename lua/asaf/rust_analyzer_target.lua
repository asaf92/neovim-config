local M = {}

local WINDOWS_TARGET = "x86_64-pc-windows-msvc"

local function settings(target)
  local cargo = {}

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
  vim.defer_fn(function()
    vim.lsp.enable("rust_analyzer", true)
    vim.cmd.doautoall("nvim.lsp.enable FileType")
  end, 500)

  vim.notify("rust-analyzer target: " .. label)
end

return M
