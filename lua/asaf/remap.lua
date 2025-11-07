vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "File Explorer" })

-- Center screen after scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down and Center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up and Center" })

vim.keymap.set("n", "<leader>Y", "ggVGy", {noremap = true, silent = true, desc = "Yank Entire Buffer" })

-- LSP Restart
vim.api.nvim_set_keymap('n', '<leader>lsr', ':LspRestart<CR>', { noremap = true })

-- Pane switching
local pane_opts = { silent = true }

-- Normal mode pane moves
vim.keymap.set('n', '<C-h>', '<C-w>h', pane_opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', pane_opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', pane_opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', pane_opts)

-- Terminal mode: first leave terminal-input, then move
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], pane_opts)
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], pane_opts)
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], pane_opts)
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], pane_opts)
