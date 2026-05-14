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
  "rust",
  "python",
  "go",
  "bash",
  "yaml",
  "toml",
  "json",
}

treesitter.setup()
treesitter.install(parsers)

vim.treesitter.language.register('c_sharp', 'cs')

-- Start treesitter for any buffer whose filetype has an available parser.
-- Replaces the old `auto_install`/auto-enable behavior of the pre-rewrite
-- nvim-treesitter that went away with the `main`-branch rewrite.
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == '' then
      return
    end
    local lang = vim.treesitter.language.get_lang(ft) or ft
    local ok = pcall(vim.treesitter.language.add, lang)
    if not ok then
      return
    end
    pcall(vim.treesitter.start, args.buf, lang)
  end,
})
