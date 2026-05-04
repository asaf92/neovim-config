vim.filetype.add({
  extension = {
    cs = "cs",
    csharp = "cs",
  },
  pattern = {
    [".*%.csharp"] = "cs",
  }
})

local treesitter = require('nvim-treesitter')

local parsers = {
  "javascript",
  "typescript",
  "tsx",
  "c_sharp",
  "markdown",
  "markdown_inline",
  "c",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "regex",
  "html",
}

treesitter.setup()
treesitter.install(parsers)

vim.treesitter.language.register('c_sharp', 'cs')

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'javascript',
    'typescript',
    'typescriptreact',
    'cs',
    'markdown',
    'c',
    'lua',
    'vim',
    'help',
    'query',
    'html',
  },
  callback = function()
    vim.treesitter.start()
  end,
})
