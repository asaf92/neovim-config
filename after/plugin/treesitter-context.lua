require('treesitter-context').setup({
  max_lines = 3,
  multiline_threshold = 10,
  trim_scope = 'outer',
  mode = 'cursor',
  separator = '-',
})

vim.api.nvim_set_hl(0, 'TreesitterContext', { link = 'NormalFloat' })
vim.api.nvim_set_hl(0, 'TreesitterContextSeparator', { link = 'FloatBorder' })
