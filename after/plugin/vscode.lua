-- Lua:
-- For dark theme (neovim's default)
vim.o.background = 'dark'
-- For light theme
-- vim.o.background = 'light'

local c = require('vscode.colors').get_colors()
require('vscode').setup({
  -- Alternatively set style in setup
  -- style = 'light'

  -- Enable transparent background
  transparent = false,

  -- Enable italic comment
  italic_comments = true,

  -- Underline `@markup.link.*` variants
  underline_links = false,

  -- Disable nvim-tree background color
  disable_nvimtree_bg = false,

  -- Override colors (see ./lua/vscode/colors.lua)
  color_overrides = {
    vscLineNumber = '#FFFFFF',
  },

  -- Override highlight groups (see ./lua/vscode/theme.lua)
  -- this supports the same val table as vim.api.nvim_set_hl
  -- use colors from this colorscheme by requiring vscode.colors!
  group_overrides = {
    -------- Rust --------
    -- Mutable has underline
    ['@lsp.typemod.variable.mutable.rust'] = { underline = true },
    ['@lsp.typemod.parameter.mutable.rust'] = { underline = true },
    ['@lsp.typemod.selfKeyword.mutable.rust'] = { underline = true },
    -- Ownership is bold
    ['@lsp.typemod.variable.consuming.rust'] = { bold = true, underdashed = true },
    -- References have italic
    ['@lsp.typemod.variable.reference.rust'] = { italic = true },
    -- Type symbols
    ['@lsp.type.interface.rust'] = { fg = c.vscYellowOrange },
    ['@lsp.type.typeParameter.rust'] = { italic = true },
    ['@lsp.type.enumMember.rust'] = { bold = true },
    ['@lsp.type.macro.rust'] = { fg = c.vscPink },
  }
})
require('vscode').load()
