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

function MoveOrTmux(direction, tmux_flag)
  local cur = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. direction)

  -- If we didn't change window, we're at the edge
  if vim.api.nvim_get_current_win() == cur and vim.env.TMUX then
    vim.fn.jobstart({ 'tmux', 'select-pane', '-' .. tmux_flag }, { detach = true })
  end
end

-- Normal mode pane moves
vim.keymap.set('n', '<C-h>', function() MoveOrTmux('h', 'L') end, pane_opts)
vim.keymap.set('n', '<C-j>', function() MoveOrTmux('j', 'D') end, pane_opts)
vim.keymap.set('n', '<C-k>', function() MoveOrTmux('k', 'U') end, pane_opts)
vim.keymap.set('n', '<C-l>', function() MoveOrTmux('l', 'R') end, pane_opts)

-- Terminal mode: first leave terminal-input, then move
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], pane_opts)
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], pane_opts)
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], pane_opts)
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], pane_opts)
