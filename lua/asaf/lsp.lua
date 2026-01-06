local M = {}

function M.setup()
  -- Mason for managing external tools
  require("mason").setup()

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

  local servers = { "rust_analyzer", "basedpyright", "ruff", "ts_ls", "eslint", "tailwindcss", "csharp_ls", "gopls" }
  for _, server in ipairs(servers) do
    local ok, config = pcall(require, "lsp." .. server)
    if not ok then
      config = {}
    end
    config.capabilities = vim.tbl_deep_extend("force", config.capabilities or {}, capabilities)
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  end

  local function format_buffer(bufnr)
    local function log(msg, level)
      if level and level >= vim.log.levels.WARN then
        vim.notify(string.format("[format] %s", msg), level)
      end
    end

    local ok_conform, conform = pcall(require, "conform")
    if ok_conform then
      local ok_format, err = pcall(conform.format, {
        bufnr = bufnr,
        async = false,
        lsp_fallback = true,
      })

      if not ok_format then
        log(string.format("Conform format failed: %s", err), vim.log.levels.ERROR)
      end
      return
    end

    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if not clients or vim.tbl_isempty(clients) then
      log("No LSP clients attached; aborting format.", vim.log.levels.WARN)
      return
    end

    local eslint_id
    local ts_id
    local other_ids = {}

    for _, client in pairs(clients) do
      if client.supports_method("textDocument/formatting") then
        if client.name == "eslint" then
          eslint_id = client.id
          break
        elseif client.name == "ts_ls" then
          ts_id = client.id
        else
          table.insert(other_ids, client.id)
        end
      end
    end

    local allowed_ids = {}
    if eslint_id then
      allowed_ids[eslint_id] = true
    elseif #other_ids > 0 then
      for _, id in ipairs(other_ids) do
        allowed_ids[id] = true
      end
    elseif ts_id then
      allowed_ids[ts_id] = true
      log(string.format("No alternative formatter; falling back to ts_ls (client id %d).", ts_id), vim.log.levels.WARN)
    else
      log("No attached LSP clients support formatting for this buffer.", vim.log.levels.WARN)
      return
    end

    local ok, err = pcall(vim.lsp.buf.format, {
      bufnr = bufnr,
      async = false,
      filter = function(client)
        return allowed_ids[client.id] == true
      end,
    })

    if not ok then
      log(string.format("vim.lsp.buf.format failed: %s", err), vim.log.levels.ERROR)
    end
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
      bufmap("n", "<leader>dq", function()
        vim.diagnostic.setqflist({ open = true })
      end, { desc = "Diagnostics -> Quickfix" })
      bufmap("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostic Float" })
      bufmap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
      bufmap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
      vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature Help" })

      bufmap("n", "<leader>f", function()
        format_buffer(bufnr)
      end, { desc = "Format Buffer" })
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("UserFormatOnSave", {}),
    callback = function(args)
      if vim.bo[args.buf].buftype ~= "" then
        return
      end

      format_buffer(args.buf)
    end,
  })

  -- LspRestart command
  vim.api.nvim_create_user_command("LspRestart", function()
    for _, client in pairs(vim.lsp.get_clients()) do
      client.stop()
    end
  end, { desc = "Restart LSP clients" })
end

return M
