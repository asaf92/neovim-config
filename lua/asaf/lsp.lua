local M = {}

function M.setup()
  -- Note: Mason setup moved to packer.lua to configure custom registries

  -- Diagnostics configuration
  vim.diagnostic.config({ virtual_text = true, signs = true, update_in_insert = false })

  -- nvim-cmp setup
  local cmp = require("cmp")
  local luasnip = require("luasnip")
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-y>"] = cmp.mapping.confirm({ select = true }),
      ["<C-Space>"] = cmp.mapping.complete(),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
    }, {
      { name = "buffer" },
    }),
  })

  -- LSP servers setup
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

  -- Note: csharp_ls removed - using roslyn.nvim instead (configured in packer.lua)
  local servers = { "pyright", "ts_ls", "eslint", "tailwindcss", "gopls" }
  for _, server in ipairs(servers) do
    local ok, config = pcall(require, "lsp." .. server)
    if not ok then
      config = {}
    end
    config.capabilities = vim.tbl_deep_extend("force", config.capabilities or {}, capabilities)
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  end

  -- Keymaps and formatting via LspAttach
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(args)
      local bufnr = args.buf
      local function bufmap(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, lhs, rhs, opts)
      end
      local filetype = vim.bo[bufnr].filetype

      bufmap("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
      bufmap("n", "K", function () 
        vim.lsp.buf.hover({
          -- Otherwise there's no border and it's hard to distinguish
          -- https://www.reddit.com/r/neovim/comments/1jmsl3j/switch_to_011_now_not_showing_borders_on/
          border = "rounded",
        })
      end, { desc = "Show Hover Information" })
      bufmap("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
      bufmap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
      bufmap("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostic Float" })
      bufmap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
      bufmap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
      vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature Help" })

      if filetype ~= "json" and filetype ~= "jsonc" then
        bufmap("n", "<leader>f", function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end, { desc = "Format Buffer" })
      end
    end,
  })

  -- LspRestart command
  vim.api.nvim_create_user_command("LspRestart", function()
    for _, client in pairs(vim.lsp.get_active_clients()) do
      client.stop()
    end
  end, { desc = "Restart LSP clients" })
end

return M
