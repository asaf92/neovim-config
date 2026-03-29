local M = {}

function M.setup()
  -- Mason for managing external tools
  require("mason").setup()

  -- Diagnostics configuration
  vim.diagnostic.config({ virtual_text = true, signs = true, update_in_insert = false })

  local function inlay_hints_available()
    return (vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable) or (vim.lsp.buf and vim.lsp.buf.inlay_hint)
  end

  local function set_inlay_hints(bufnr, enabled)
    if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
      vim.lsp.inlay_hint.enable(enabled, { bufnr = bufnr })
    elseif vim.lsp.buf and vim.lsp.buf.inlay_hint then
      pcall(vim.lsp.buf.inlay_hint, bufnr, enabled)
    end
    vim.b[bufnr].asaf_inlay_hints_enabled = enabled
  end

  local function user_disabled_inlay_hints(bufnr)
    return vim.b[bufnr].asaf_inlay_hints_user_disabled == true
  end

  local function inlay_hints_enabled(bufnr)
    if vim.lsp.inlay_hint and vim.lsp.inlay_hint.is_enabled then
      return vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
    end
    return vim.b[bufnr].asaf_inlay_hints_enabled == true
  end

  local function enable_inlay_hints_if_allowed(bufnr)
    if not inlay_hints_available() then
      return
    end
    if user_disabled_inlay_hints(bufnr) then
      return
    end
    if not inlay_hints_enabled(bufnr) then
      set_inlay_hints(bufnr, true)
    end
  end

  local function mark_lsp_ready(bufnr, source)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if vim.b[bufnr].asaf_lsp_ready then
      return
    end
    vim.b[bufnr].asaf_lsp_ready = true
    vim.b[bufnr].asaf_lsp_ready_source = source
    if vim.g.asaf_lsp_status_debug then
      local name = vim.api.nvim_buf_get_name(bufnr)
      local display = name ~= "" and name or string.format("buffer %d", bufnr)
      vim.notify(string.format("LSP ready (%s) for %s", source, display), vim.log.levels.INFO)
    end
  end

  local default_inlay_handler = vim.lsp.handlers["textDocument/inlayHint"]
  vim.lsp.handlers["textDocument/inlayHint"] = function(err, result, ctx, config)
    local bufnr = ctx and ctx.bufnr or nil
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "rust" then
      enable_inlay_hints_if_allowed(bufnr)
    end

    if bufnr and result and not vim.tbl_isempty(result) then
      mark_lsp_ready(bufnr, "inlay_hint")
    end

    if default_inlay_handler then
      default_inlay_handler(err, result, ctx, config)
    end
  end

  local default_diagnostics_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
  vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    local bufnr = ctx and ctx.bufnr or nil
    local has_diagnostics = result and result.diagnostics and not vim.tbl_isempty(result.diagnostics)
    if bufnr and has_diagnostics then
      mark_lsp_ready(bufnr, "diagnostics")
    end

    if default_diagnostics_handler then
      default_diagnostics_handler(err, result, ctx, config)
    end
  end

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
      local client_id = args.data and args.data.client_id or nil
      local client = client_id and vim.lsp.get_client_by_id(client_id) or nil
      local is_rust = vim.bo[bufnr].filetype == "rust" or (client and client.name == "rust_analyzer")
      if vim.b[bufnr].asaf_lsp_ready == nil then
        vim.b[bufnr].asaf_lsp_ready = false
      end
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
      bufmap({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
      bufmap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
      vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature Help" })

      bufmap("n", "<leader>f", function()
        format_buffer(bufnr)
      end, { desc = "Format Buffer" })

      if is_rust and client and inlay_hints_available() and client.supports_method and client.supports_method("textDocument/inlayHint") then
        enable_inlay_hints_if_allowed(bufnr)
        bufmap("n", "<leader>h", function()
          local enable = not inlay_hints_enabled(bufnr)
          vim.b[bufnr].asaf_inlay_hints_user_disabled = not enable
          set_inlay_hints(bufnr, enable)
        end, { desc = "Toggle Inlay Hints" })
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspNotify", {
    group = vim.api.nvim_create_augroup("UserInlayHintsRefresh", {}),
    callback = function(args)
      if not args.data or args.data.method ~= "textDocument/didOpen" then
        return
      end
      local bufnr = args.buf
      if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "rust" then
        enable_inlay_hints_if_allowed(bufnr)
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("UserLspReadyReset", {}),
    callback = function(args)
      local bufnr = args.buf
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      if vim.tbl_isempty(vim.lsp.get_clients({ bufnr = bufnr })) then
        vim.b[bufnr].asaf_lsp_ready = nil
        vim.b[bufnr].asaf_lsp_ready_source = nil
      end
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

  local function lsp_status_icon(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if not clients or vim.tbl_isempty(clients) then
      return "–"
    end

    for _, client in ipairs(clients) do
      if client.is_stopped and client.is_stopped() then
        return "✗"
      end
    end

    if vim.b[bufnr].asaf_lsp_ready == true then
      return "✓"
    end

    return "…"
  end

  function _G.asaf_lsp_status()
    return string.format("LSP:%s", lsp_status_icon(0))
  end

  local statusline_suffix = "%{v:lua.asaf_lsp_status()}"
  if vim.o.statusline == "" then
    vim.o.statusline = "%f %h%m%r%=%-14.(%l,%c%V%) %P " .. statusline_suffix
  else
    vim.o.statusline = vim.o.statusline .. " " .. statusline_suffix
  end

  -- LspRestart command
  vim.api.nvim_create_user_command("LspRestart", function()
    for _, client in pairs(vim.lsp.get_clients()) do
      client.stop()
    end
  end, { desc = "Restart LSP clients" })
end

return M
