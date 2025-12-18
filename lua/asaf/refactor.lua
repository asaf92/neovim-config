local refactoring = require('refactoring')

refactoring.setup({})

-- Inline function in normal mode
vim.keymap.set('n', '<leader>ri', function()
  return refactoring.refactor('Inline Function')
end, { expr = true, desc = 'Refactor: Inline function' })

-- Inline variable (visual)
vim.keymap.set('v', '<leader>ri', function()
  return refactoring.refactor('Inline Variable')
end, { expr = true, desc = 'Refactor: Inline variable' })

-- Extract variable from selection
vim.keymap.set('v', '<leader>rv', function()
  return refactoring.refactor('Extract Variable')
end, { expr = true, desc = 'Refactor: Extract variable' })

-- Extract function from selection
vim.keymap.set('v', '<leader>rf', function()
  return refactoring.refactor('Extract Function')
end, { expr = true, desc = 'Refactor: Extract function' })
