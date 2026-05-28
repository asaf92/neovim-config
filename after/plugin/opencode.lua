vim.o.autoread = true

local snacks = require("snacks")
snacks.setup({
  input = {},
  picker = {},
  terminal = {},
})

local opencode_cmd = "opencode --port"
local opencode_terminal_opts = {
  auto_insert = true,
  start_insert = true,
  win = {
    position = "right",
    width = math.floor(vim.o.columns * 0.35),
    on_win = function(win)
      require("opencode.terminal").setup(win.win)
    end,
  },
}

local function terminal_opts(enter, opts)
  return vim.tbl_deep_extend("force", opencode_terminal_opts, {
    win = {
      enter = enter,
    },
  }, opts or {})
end

vim.g.opencode_opts = {
  server = {
    start = function()
      require("snacks.terminal").open(opencode_cmd, terminal_opts(false))
    end,
    stop = function()
      local terminal = require("snacks.terminal").get(opencode_cmd, terminal_opts(false, {
        create = false,
      }))
      if terminal then
        terminal:close()
      end
    end,
    toggle = function()
      require("snacks.terminal").focus(opencode_cmd, terminal_opts(true))
    end,
  },
  events = {
    reload = true,
  },
}

local opencode = require("opencode")
vim.keymap.set("n", "<leader>oo", opencode.toggle, { desc = "Toggle opencode" })
vim.keymap.set({ "n", "x" }, "<leader>os", opencode.select, { desc = "Select opencode action" })
vim.keymap.set("n", "<leader>od", function()
  opencode.prompt("Explain @diagnostics")
end, { desc = "Explain diagnostics" })
