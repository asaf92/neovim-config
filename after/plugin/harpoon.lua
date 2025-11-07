local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
require("harpoon").setup({
    menu = {
        width = vim.api.nvim_win_get_width(0) - 40,
    }
})

vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Add File to Harpoon" })
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Toggle Harpoon Menu" })

vim.keymap.set("n", "<C-t>", function() ui.nav_file(1) end, { desc = "Navigate to Harpoon File 1" })
vim.keymap.set("n", "<C-n>", function() ui.nav_file(2) end, { desc = "Navigate to Harpoon File 2" })
vim.keymap.set("n", "<C-s>", function() ui.nav_file(3) end, { desc = "Navigate to Harpoon File 3" })
