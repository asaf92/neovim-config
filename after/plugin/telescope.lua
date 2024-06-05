local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

-- Setup for telescope-ui-select extension
require('telescope').setup{
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown { }
      -- Additional configuration for the dropdown theme as needed
    },
  },
}

-- Load the ui-select extension
require('telescope').load_extension('ui-select')

-- Harpoon
require('telescope').load_extension('harpoon')
local function launch_harpoon_marks()
  local opts = {
    attach_mappings = function(_, map)
      map("i", "<c-n>", "move_selection_next")
      map("i", "<c-p>", "move_selection_previous")
      return true
    end,
  }
  require("telescope").extensions.harpoon.marks(opts)
end
vim.keymap.set('n', '<leader>e', launch_harpoon_marks, {})
