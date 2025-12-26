# C# and Razor LSP in Neovim 0.11+: The definitive 2025 guide

**Microsoft's Roslyn LSP via roslyn.nvim is now the clear winner for Blazor development in Neovim 0.11+.** OmniSharp has entered maintenance mode after VS Code's C# extension dropped it, while the new Roslyn LSP delivers VS Code-equivalent features including native Razor support through co-hosting. For pure C# projects, csharp-ls remains an excellent lightweight alternative with built-in decompilation.

## The three contenders: Roslyn dominates, OmniSharp fades

The C# language server landscape has shifted dramatically in 2024-2025. Microsoft's decision to replace OmniSharp with their Roslyn LSP in VS Code's C# extension has established a clear hierarchy for Neovim users.

**roslyn.nvim (Microsoft's Roslyn LSP)** emerges as the recommended choice for Neovim 0.11+ users, particularly those working with Blazor. The [seblyng/roslyn.nvim](https://github.com/seblyng/roslyn.nvim) plugin (716 stars, actively maintained) provides the same language server powering VS Code's C# Dev Kit. Key advantages include **comprehensive refactoring support** with nested code actions and fix-all capabilities, **Razor/Blazor support** via co-hosting (added late 2025), superior auto-imports, and multi-solution support with the `:Roslyn target` command. The strict requirement of Neovim ≥0.11.0 is a feature, not a limitation—it enables full use of modern LSP capabilities.

**csharp-ls** remains the lightweight champion for pure C# work. Version 0.20.0 (November 2025) delivers fast startup, simple installation via `dotnet tool install --global csharp-ls`, and standard LSP compliance that works seamlessly with Neovim's built-in client. Its major limitation: **no Razor/Blazor support whatsoever**.

**OmniSharp** has effectively entered legacy status. A March 2025 GitHub issue (#2663) questioning its future went unanswered as Microsoft doubled down on Roslyn LSP. Known bugs like the InlayHint error (#2655) remain unresolved, and its non-standard semantic tokens cause errors in newer Neovim (`E5248: Invalid character in group name`). While still receiving maintenance updates (v1.39.15-beta.69), new projects should avoid it.

| Feature | roslyn.nvim | csharp-ls | OmniSharp |
|---------|-------------|-----------|-----------|
| **Diagnostics** | Excellent | Good | Good |
| **Code Actions** | Full (nested, fix-all) | Standard | Standard |
| **Razor Support** | ✅ Native co-hosting | ❌ None | ❌ Limited |
| **Decompilation** | ✅ Built-in | ✅ ILSpy | ✅ Opt-in |
| **Neovim Requirement** | ≥0.11.0 | Any | Any |
| **Status** | Active development | Active | Maintenance mode |

## Decompilation works across all servers

All three language servers support "Go to Definition" on BCL/system libraries like `System.String` or `List<T>`, though configuration differs significantly.

**roslyn.nvim handles decompilation natively**—standard `vim.lsp.buf.definition()` works without additional plugins. Decompiled sources land in `%TEMP%/MetadataAsSource`, and SourceLink automatically navigates to original source code when available.

**csharp-ls requires the csharpls-extended-lsp.nvim plugin** from [Decodetalkers](https://github.com/Decodetalkers/csharpls-extended-lsp.nvim). The server uses a custom `csharp/metadata` LSP extension that returns ILSpy-decompiled source:

```lua
require('lspconfig').csharp_ls.setup({
  handlers = {
    ["textDocument/definition"] = require('csharpls_extended').handler,
    ["textDocument/typeDefinition"] = require('csharpls_extended').handler,
  },
})
require("csharpls_extended").buf_read_cmd_bind()
```

**OmniSharp needs explicit configuration** in `~/.omnisharp/omnisharp.json` plus the [omnisharp-extended-lsp.nvim](https://github.com/Hoffs/omnisharp-extended-lsp.nvim) plugin:

```json
{
  "RoslynExtensionsOptions": {
    "enableDecompilationSupport": true
  }
}
```

## Razor/Blazor: Finally viable in Neovim

Razor development in Neovim crossed from "experimental hack" to "production-viable" in late 2025. The breakthrough came when **roslyn.nvim integrated Microsoft's Razor Language Server (rzls) via co-hosting**, superseding the standalone rzls.nvim plugin (archived December 4, 2025).

The co-hosting architecture means rzls communicates with the Roslyn C# server to provide seamless cross-boundary functionality. Confirmed working features include:

- **Completion** in both C# and HTML contexts within .razor files
- **Diagnostics** with error reporting across language boundaries  
- **Go-to-definition** works across C#/HTML boundaries (may navigate through virtual files)
- **Semantic highlighting**, hover, rename, signature help
- **Code actions** for Razor components
- **Formatting** via rzls

Notable limitations remain: **CodeLens doesn't work**, formatting fails on newly created files, and **native Windows support has path normalization issues**. Opening a `.cs` file before `.razor` can cause connection problems—always open Razor files first.

**Treesitter grammar exists** via [tris203/tree-sitter-razor](https://github.com/tris203/tree-sitter-razor), installable through nvim-treesitter with `:TSInstall razor`. Register the filetype properly:

```lua
vim.filetype.add({
  extension = {
    razor = "razor",
    cshtml = "razor",
  },
})
```

## Complete Blazor configuration for Neovim 0.11+

This configuration uses the native `vim.lsp.config()` and `vim.lsp.enable()` APIs introduced in Neovim 0.11, avoiding external LSP management:

```lua
-- ~/.config/nvim/lua/plugins/blazor.lua (lazy.nvim)
return {
  -- Mason with custom registry for Roslyn/rzls installation
  {
    "williamboman/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",  -- Required for roslyn + rzls
      },
    },
  },

  -- roslyn.nvim: C# + Razor LSP
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      filewatching = "roslyn",  -- Better for large projects
      broad_search = true,       -- Find solutions in parent directories
    },
    init = function()
      -- Register Razor filetype
      vim.filetype.add({
        extension = {
          razor = "razor",
          cshtml = "razor",
        },
      })
    end,
    config = function(_, opts)
      require("roslyn").setup(opts)
      
      -- Configure Roslyn LSP settings
      vim.lsp.config("roslyn", {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
          },
        },
      })
      vim.lsp.enable("roslyn")
    end,
  },

  -- HTML LSP for Razor HTML completions
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = { filetypes = { "html", "razor" } },
      },
    },
  },

  -- Treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "c_sharp", "html", "razor", "css", "javascript" },
    },
  },
}
```

## Native LSP setup without nvim-lspconfig

For users preferring zero external dependencies, Neovim 0.11+ supports LSP configuration through files in `~/.config/nvim/lsp/`:

```lua
-- ~/.config/nvim/lsp/csharp_ls.lua
return {
  cmd = { 'csharp-ls' },
  filetypes = { 'cs' },
  root_markers = { '*.sln', '*.csproj', '.git' },
  init_options = {
    AutomaticWorkspaceInit = true,
  },
}
```

```lua
-- ~/.config/nvim/init.lua
-- Enable native LSP auto-configuration
vim.lsp.enable('csharp_ls')

-- Global LspAttach handler
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local buf = args.buf
    
    -- Enable native completion
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end
  end,
})
```

Neovim 0.11+ provides default keymaps when an LSP attaches: **K** for hover, **grr** for references, **grn** for rename, **gra** for code actions, **gri** for implementations.

## Practical recommendations for Blazor developers

For Blazor/ASP.NET Core development on Neovim 0.11.1, **use roslyn.nvim with the Crashdummyy Mason registry**. This provides:

- Full C# language intelligence matching VS Code
- Native Razor support via co-hosting
- Decompilation without additional plugins
- Source-generated file navigation

Install dependencies: ensure .NET SDK 8+ is installed, add the custom Mason registry, and install both `roslyn` and `rzls` packages. The roslyn.nvim plugin handles co-hosting automatically.

For pure C# projects without Razor, **csharp-ls offers a faster, lighter experience** with the csharpls-extended-lsp.nvim plugin for decompilation. Install with `dotnet tool install --global csharp-ls` and configure minimal handlers.

Avoid OmniSharp for new projects—its uncertain future, semantic token bugs, and heavier resource usage make it a poor choice when superior alternatives exist.

## Conclusion

The C# development story in Neovim has matured significantly. **roslyn.nvim delivers VS Code parity** for the first time, including the Razor support that previously made Blazor development impractical outside Microsoft's editors. The key insight: Microsoft's shift away from OmniSharp isn't just an internal change—it's created a better ecosystem for all LSP clients, including Neovim. For developers on Neovim 0.11+, the combination of roslyn.nvim, the custom Mason registry, and tree-sitter-razor finally makes Blazor development a first-class experience.