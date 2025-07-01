vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "File Explorer" })

-- Center screen after scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down and Center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up and Center" })

vim.keymap.set("n", "<leader>Y", "ggVGy", {noremap = true, silent = true, desc = "Yank Entire Buffer" })

-- LSP Restart
vim.api.nvim_set_keymap('n', '<leader>lsr', ':LspRestart<CR>', { noremap = true })
