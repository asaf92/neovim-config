-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.5',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {'nvim-telescope/telescope-ui-select.nvim' }

  use 'Mofiqul/vscode.nvim' 

  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
  use('theprimeagen/harpoon')
  use('mbbill/undotree')
  use('tpope/vim-fugitive')
  -- LSP and completion plugins
  use {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup({
        registries = {
          'github:mason-org/mason-registry',
          'github:Crashdummyy/mason-registry',  -- Required for roslyn
        },
      })
    end
  }
  use 'neovim/nvim-lspconfig'
  use {
    'seblyng/roslyn.nvim',
    ft = { 'cs', 'razor' },
    config = function()
      require('roslyn').setup({
        filewatching = 'roslyn',  -- Better for large projects
        broad_search = true,       -- Find solutions in parent directories
      })
    end
  }
  use {
    'github/copilot.vim',
    config = function()
      vim.g.copilot_no_tab_map = true
      -- Disable all filetypes by default (no automatic suggestions)
      vim.g.copilot_filetypes = { ['*'] = false }
  
      -- Enable for specific filetypes if needed
      -- vim.g.copilot_filetypes = { ['*'] = false, lua = true, python = true }
  
      -- Manual trigger with <leader>p using the built-in suggest plug
      vim.keymap.set('i', '<C-\\>', '<Plug>(copilot-suggest)', { silent = true })  

      -- Accept with Tab
      vim.keymap. set('i', '<Tab>', 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
        silent = true,
      })
    end
  }
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
  use 'rafamadriz/friendly-snippets'
  use {
    'chentoast/marks.nvim',
    config = function()
      require'marks'.setup {
        default_mappings = true,
        builtin_marks = { ".", "<", ">", "^" },
        cyclic = true,
        force_write_shada = false,
        refresh_interval = 250,
        sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
        excluded_filetypes = {},
        excluded_buftypes = {},
        bookmark_0 = {
          sign = "⚑",
          virt_text = "hello world",
          annotate = false,
        },
        mappings = {}
      }
    end
  }
  use 'tpope/vim-surround'
  use {
    'MeanderingProgrammer/render-markdown.nvim',
    config = function()
      require('render-markdown').setup({
        file_types = {"markdown", "Avante" },
      })
    end
  }

  -- Avante.nvim and dependencies
  use {
    'yetone/avante.nvim',
    branch = 'main',
    run = 'make',
    requires = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      'MeanderingProgrammer/render-markdown.nvim',
    },
    config = function()
      require('avante').setup({
        provider = "copilot",
        mode = "agentic",
      
        behaviour = {
          enable_cursor_planning_mode = true,
        },
      
        providers = {
          ollama = {
            endpoint = "http://127.0.0.1:11434",
            model = "qwen3:8b",
            stream = true,
          }
        },
      
        windows = {
          position = "right",
          width = 30,
        }
      })
    end
  }

  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {}
    end
  }
end)
