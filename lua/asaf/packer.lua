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
  use 'nvim-treesitter/nvim-treesitter-context'
  use('theprimeagen/harpoon')
  use('mbbill/undotree')
  use('tpope/vim-fugitive')
  use {
    'ThePrimeagen/refactoring.nvim',
    requires = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-treesitter/nvim-treesitter' },
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
    disable = true -- It's annoying + clashes with my <leader>a
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
      local vertex_project = os.getenv("VERTEXAI_PROJECT") or os.getenv("GOOGLE_CLOUD_PROJECT")
      local vertex_location = os.getenv("VERTEXAI_LOCATION") or os.getenv("GOOGLE_CLOUD_LOCATION") or "global"

      if vertex_project and vertex_project ~= "" then
        vim.env.GOOGLE_CLOUD_PROJECT = vertex_project
      end
      if vertex_location and vertex_location ~= "" then
        vim.env.GOOGLE_CLOUD_LOCATION = vertex_location
      end

      require('avante').setup({
        provider = "vertex",
        behaviour = {
            enable_cursor_planning_mode = true,
        },
        providers = {
          vertex = {
            endpoint = string.format(
              "https://aiplatform.googleapis.com/v1/projects/%s/locations/%s/publishers/google/models",
              vertex_project or "PROJECT_ID",
              vertex_location or "global"
            ),
            model = "gemini-2.5-flash",
            model_names = { "gemini-2.5-flash" },
            extra_request_body = {
              temperature = 0.5,
            }
          },
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
