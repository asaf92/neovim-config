local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "Find Files" })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Git Files" })
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end, { desc = "Grep String" })
vim.keymap.set('n', '<leader>pq', builtin.quickfix, { desc = "Quickfix List" })

-- Setup for telescope-ui-select extension
require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--glob',
      '!**/.git/*',
    },
    layout_strategy = "flex",
    layout_config = {
      flex = {
        flip_columns = 140,
        flip_lines = 15,
      },
      vertical = {
        mirror = true,
      },
    },
    path_display = {
      "smart",
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
  },
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
vim.keymap.set('n', '<leader>e', launch_harpoon_marks, { desc = "Harpoon Marks" })

-- LSP Actions
vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions, { desc = "LSP Definitions" })
vim.keymap.set('n', '<leader>gi', builtin.lsp_implementations, { desc = "LSP Implementations" })
vim.keymap.set('n', '<leader>rr', builtin.lsp_references, { desc = "LSP References" })
vim.keymap.set('n', '<leader>t', builtin.lsp_dynamic_workspace_symbols, { desc = "LSP Workspace Symbols" })
