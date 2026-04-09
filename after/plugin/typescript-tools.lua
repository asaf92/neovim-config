local ok, ts_tools = pcall(require, "typescript-tools")
if not ok then
  return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

ts_tools.setup({
  capabilities = capabilities,
  settings = {
    separate_diagnostic_server = true,
    publish_diagnostic_on = "insert_leave",
  },
})

-- Project-wide type errors via tsc --noEmit, parsed into the quickfix list.
vim.keymap.set("n", "<leader>pe", function()
  -- Find the nearest tsconfig.json to determine the project root.
  local tsconfig = vim.fs.find("tsconfig.json", {
    upward = true,
    path = vim.fn.expand("%:p:h"),
  })[1]
  local cwd = tsconfig and vim.fn.fnamemodify(tsconfig, ":h") or vim.fn.getcwd()

  vim.notify("[tsc] Checking project errors...", vim.log.levels.INFO)
  vim.fn.jobstart({ "npx", "tsc", "--noEmit", "--pretty", "false" }, {
    cwd = cwd,
    stdout_buffered = true,
    on_stdout = function(_, data)
      vim.schedule(function()
        local lines = vim.tbl_filter(function(line)
          return line ~= ""
        end, data or {})
        if #lines == 0 then
          vim.notify("[tsc] No errors found.", vim.log.levels.INFO)
          return
        end
        vim.fn.setqflist({}, " ", {
          title = "tsc --noEmit",
          lines = lines,
          efm = "%f(%l\\,%c): error TS%n: %m",
        })
        vim.cmd("botright copen")
        vim.notify(string.format("[tsc] Found %d error(s).", #vim.fn.getqflist()), vim.log.levels.WARN)
      end)
    end,
    on_stderr = function(_, data)
      vim.schedule(function()
        local msg = table.concat(data or {}, "\n")
        if msg ~= "" then
          vim.notify("[tsc] " .. msg, vim.log.levels.ERROR)
        end
      end)
    end,
  })
end, { desc = "Project Errors (tsc --noEmit)" })
