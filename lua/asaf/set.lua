-- Hybrid line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs/Spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search highlighting
vim.api.nvim_set_keymap('n', '<Esc>', ':nohlsearch<CR>', {noremap = true, silent = true })
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Boundary
vim.opt.wrap = false
vim.opt.colorcolumn = "100"

-- Clipboard
vim.opt.clipboard:append("unnamedplus")

