local ok_autopairs, autopairs = pcall(require, "nvim-autopairs")
if ok_autopairs then
  autopairs.setup({
    check_ts = true,
  })

  local ok_cmp, cmp = pcall(require, "cmp")
  if ok_cmp then
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
end

local ok_autotag, autotag = pcall(require, "nvim-ts-autotag")
if ok_autotag then
  autotag.setup({
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },
  })
end

local function smart_tag_slash()
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local left_char = col > 0 and line:sub(col, col) or ""

  vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, { "/" })

  if left_char == "<" then
    local ok_internal, internal = pcall(require, "nvim-ts-autotag.internal")
    if ok_internal then
      internal.close_slash_tag()
    end
    local new_row, new_col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_win_set_cursor(0, { new_row, new_col + 1 })
    return
  end

  local updated_line = vim.api.nvim_get_current_line()
  local prefix = updated_line:sub(1, col + 1)
  local suffix = updated_line:sub(col + 2)
  local in_open_tag = prefix:match("<[^/!][^>]*%/$") ~= nil
  local has_closing_bracket_ahead = suffix:find(">", 1, true) ~= nil

  local next_col = col + 1
  if in_open_tag and not has_closing_bracket_ahead then
    vim.api.nvim_buf_set_text(bufnr, row - 1, col + 1, row - 1, col + 1, { ">" })
    next_col = col + 2
  end

  vim.api.nvim_win_set_cursor(0, { row, next_col })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "javascriptreact", "typescriptreact" },
  callback = function(args)
    vim.keymap.set("i", "/", smart_tag_slash, {
      buffer = args.buf,
      noremap = true,
      silent = true,
      desc = "Smart tag slash",
    })
  end,
})
