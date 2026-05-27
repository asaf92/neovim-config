-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
    'nvim-telescope/telescope.nvim', tag = 'v0.2.2',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use 'nvim-tree/nvim-web-devicons'
  use {'nvim-telescope/telescope-ui-select.nvim' }

  use 'Mofiqul/vscode.nvim' 

  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
  use 'nvim-treesitter/nvim-treesitter-context'
  use 'windwp/nvim-autopairs'
  use {
    'windwp/nvim-ts-autotag',
    after = 'nvim-treesitter',
  }
  use('theprimeagen/harpoon')
  use('mbbill/undotree')
  use('tpope/vim-fugitive')
  use {
    'ThePrimeagen/refactoring.nvim',
    requires = {
      { 'lewis6991/async.nvim' },
    },
  }
  -- LSP and completion plugins
  use 'williamboman/mason.nvim'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
  use 'rafamadriz/friendly-snippets'
  use 'stevearc/conform.nvim'
  use {
    "pmizio/typescript-tools.nvim",
    requires = { "nvim-lua/plenary.nvim" },
  }
  use {
    'ggml-org/llama.vim',
    setup = function()
      vim.g.llama_config = {
        auto_fim = false,
        endpoint_fim = 'http://127.0.0.1:8012/infill',
        keymap_fim_trigger = '<C-f>',
        keymap_fim_accept_full = '<Tab>',
        keymap_fim_accept_line = '<S-Tab>',
        keymap_inst_trigger = '',
        keymap_inst_rerun = '',
        keymap_inst_continue = '',
        keymap_inst_accept = '',
        keymap_inst_cancel = '',
        enable_at_startup = false,
      }
    end,
  }
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

  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {}
    end
  }
  use 'folke/snacks.nvim'
  use 'nickjvandyke/opencode.nvim'
end)
