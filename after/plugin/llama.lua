vim.fn['llama#enable']()

vim.keymap.set('i', '<C-f>', 'llama#fim_inline(v:false, v:false)', {
  expr = true,
  silent = true,
})
