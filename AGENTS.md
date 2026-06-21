# Repository Guidelines

## Project Structure & Module Organization
- `init.lua` is the entry point and loads the Lua modules in `lua/`.
- `lua/asaf/` contains core configuration (LSP, keymaps, options, plugins).
- `lua/lsp/` holds per-server LSP settings (e.g., `rust_analyzer.lua`).
- `after/plugin/` and `after/ftdetect/` contain plugin-specific setup and filetype tweaks that load after plugins.
- `plugin/` holds generated or loader scripts (e.g., `packer_compiled.lua`).
- `syntax/` includes custom syntax definitions.

## Build, Test, and Development Commands
- `nvim` — launches Neovim with this config.
- `:PackerSync` — installs/updates plugins declared in `lua/asaf/packer.lua`.
- Headless packer sync: `nvim --headless -u NONE -c "set runtimepath^=/home/aagami/.config/nvim" -c "lua require('asaf.packer')" -c "autocmd User PackerComplete quitall" -c "PackerSync"`.
- `:TSUpdate` — updates Tree-sitter parsers (used by `nvim-treesitter`).
- `:LspInfo` — verifies LSP client status and settings.

## Coding Style & Naming Conventions
- Lua is the primary language; keep indentation at 2 spaces.
- Prefer small, focused modules under `lua/asaf/` and `lua/lsp/`.
- Use descriptive, lowercase file names (e.g., `rust_analyzer.lua`).
- Keymap descriptions should be short and consistent (see `lua/asaf/lsp.lua`).

## Testing Guidelines
- No automated test framework is configured.
- Validate changes by opening Neovim and exercising the relevant feature.
- For LSP changes, verify with `:LspInfo` and a sample file in the target language.

## Local Dev & Test Harness
- Prefer a temporary sandbox when testing changes that touch LSP, treesitter, or plugins.
- Use `/tmp/` for scratch work (more reliable permissions); delete it after tests.
- Redirect XDG dirs to keep tests isolated (data/state/cache).
- Use a minimal headless init that prepends the repo to `runtimepath` and stubs heavy plugins.
- When testing packer headlessly, load `lua/asaf/packer.lua` first so `PackerSync` is defined; plain headless startup in this repo does not expose that command.
- Example layout: `/tmp/nvim-config-test/rust-proj/` for a toy project, `/tmp/nvim-config-test/nvim-data/`, `/tmp/nvim-config-test/nvim-state/`, `/tmp/nvim-config-test/nvim-cache/` for isolated Neovim dirs.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and lowercase (e.g., "add rust_analyzer", "fix packer").
- Keep commits scoped to a single change when possible.
- PRs should include a brief summary, key files touched, and any manual test steps.

## Configuration Notes
- Plugins are managed via Packer in `lua/asaf/packer.lua`.
- Some plugin configs include external tooling (e.g., `mason.nvim`, `conform.nvim`); ensure those tools are installed locally when needed.
