-- Inline function in normal mode
vim.keymap.set('n', '<leader>ri', function()
  return require('refactoring').inline_func()
end, { expr = true, desc = 'Refactor: Inline function' })

-- Inline variable (visual)
vim.keymap.set('x', '<leader>ri', function()
  return require('refactoring').inline_var()
end, { expr = true, desc = 'Refactor: Inline variable' })

-- Extract variable from selection
vim.keymap.set('x', '<leader>rv', function()
  return require('refactoring').extract_var()
end, { expr = true, desc = 'Refactor: Extract variable' })

-- Extract function from selection
vim.keymap.set('x', '<leader>rf', function()
  return require('refactoring').extract_func()
end, { expr = true, desc = 'Refactor: Extract function' })
