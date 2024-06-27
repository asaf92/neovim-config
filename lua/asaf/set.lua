-- Hybrid line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs/Spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.shiftwidth = 2
  end
})

-- Search highlighting
vim.api.nvim_set_keymap('n', '<Esc>', ':nohlsearch<CR>', {noremap = true, silent = true })
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Search casing
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Boundary
vim.opt.wrap = false
vim.opt.colorcolumn = "100"

-- Clipboard
vim.opt.clipboard:append("unnamedplus")

-- Cursor update time 
vim.opt.updatetime = 100

-- Razor support
vim.api.nvim_create_autocmd("FileType", {
    pattern = "razor",
    callback = function()
        vim.cmd("runtime syntax/razor.vim") -- Ensure the syntax is loaded for Razor files
    end,
})

