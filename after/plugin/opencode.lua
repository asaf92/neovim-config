vim.g.opencode_opts = {
  events = {
    reload = false,
  },
}

local snacks_ok, snacks = pcall(require, "snacks")
if snacks_ok then
  snacks.setup({
    input = {},
    picker = {},
  })
else
  vim.notify("opencode: snacks.nvim not available", vim.log.levels.WARN)
end

local opencode = require("opencode")
vim.keymap.set("n", "<leader>o", opencode.toggle, { desc = "Toggle opencode" })

vim.api.nvim_create_autocmd("User", {
  pattern = "OpencodeEvent:file.edited",
  callback = function(args)
    vim.schedule(function()
      local event = args.data and args.data.event or nil
      local file = event and event.properties and event.properties.file or nil
      if not file then
        return
      end

      local target = vim.fs.normalize(file)
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if vim.api.nvim_buf_is_loaded(buf) and name ~= "" and vim.fs.normalize(name) == target then
          if vim.bo[buf].modified then
            vim.notify("opencode edited file on disk, but buffer has unsaved changes: " .. target, vim.log.levels.WARN)
            return
          end

          vim.api.nvim_buf_call(buf, function()
            vim.cmd("edit!")
          end)
          return
        end
      end
    end)
  end,
})
