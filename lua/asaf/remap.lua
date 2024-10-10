vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Center screen after scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<leader>Y", "ggVGy", {noremap = true, silent = true })

-- LSP Restart
vim.api.nvim_set_keymap('n', '<leader>lsr', ':LspRestart<CR>', { noremap = true })
