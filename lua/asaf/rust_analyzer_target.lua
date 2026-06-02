local M = {}

local WINDOWS_TARGET = "x86_64-pc-windows-msvc"

local function settings(target)
  local cargo = {
    allFeatures = true,
  }

  if target then
    cargo.target = target
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
  vim.lsp.config("rust_analyzer", config)

  if vim.fn.exists(":LspRestart") == 2 then
    vim.cmd("LspRestart rust_analyzer")
  else
    for _, client in ipairs(vim.lsp.get_clients({ name = "rust_analyzer" })) do
      client.stop(true)
    end
    vim.defer_fn(function()
      vim.lsp.enable("rust_analyzer")
    end, 100)
  end

  vim.notify("rust-analyzer target: " .. label)
end

return M
