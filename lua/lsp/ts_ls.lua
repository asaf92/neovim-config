local uv = vim.uv or vim.loop

local function path_exists(path)
  return path ~= nil and uv.fs_stat(path) ~= nil
end

local function read_file(path)
  if not path_exists(path) then
    return nil
  end

  return table.concat(vim.fn.readfile(path), "\n")
end

local function write_file(path, content)
  if read_file(path) == content then
    return
  end

  vim.fn.writefile(vim.split(content, "\n", { plain = true }), path)
end

local function read_package_version(tsserver_path)
  local package_json = vim.fs.joinpath(vim.fs.dirname(vim.fs.dirname(tsserver_path)), "package.json")
  local content = read_file(package_json)
  if not content then
    return "0.0.0"
  end

  local ok, decoded = pcall(vim.json.decode, content)
  if not ok or type(decoded) ~= "table" then
    return "0.0.0"
  end

  return decoded.version or "0.0.0"
end

local function add_candidate(candidates, seen, path)
  if not path or path == "" then
    return
  end

  local normalized = uv.fs_realpath(path) or path
  if seen[normalized] then
    return
  end

  seen[normalized] = true
  table.insert(candidates, normalized)
end

local function gather_tsserver_candidates(root_dir)
  local candidates = {}
  local seen = {}

  if root_dir and root_dir ~= "" then
    add_candidate(candidates, seen, vim.fs.joinpath(root_dir, "node_modules", "typescript", "lib", "tsserver.js"))
    add_candidate(
      candidates,
      seen,
      vim.fs.joinpath(root_dir, "node_modules", "typescript-language-server", "node_modules", "typescript", "lib", "tsserver.js")
    )
  end

  local tsls_bin = vim.fn.exepath("typescript-language-server")
  if tsls_bin ~= "" then
    local real_tsls_bin = uv.fs_realpath(tsls_bin) or tsls_bin
    local tsls_root = vim.fs.dirname(vim.fs.dirname(real_tsls_bin))
    add_candidate(candidates, seen, vim.fs.joinpath(tsls_root, "node_modules", "typescript", "lib", "tsserver.js"))
  end

  local tsserver_bin = vim.fn.exepath("tsserver")
  if tsserver_bin ~= "" then
    local real_tsserver_bin = uv.fs_realpath(tsserver_bin) or tsserver_bin
    local ts_root = vim.fs.dirname(vim.fs.dirname(real_tsserver_bin))
    add_candidate(candidates, seen, vim.fs.joinpath(ts_root, "lib", "tsserver.js"))
  end

  local node_bin = vim.fn.exepath("node")
  if node_bin ~= "" then
    local node_root = vim.fs.dirname(vim.fs.dirname(node_bin))
    add_candidate(candidates, seen, vim.fs.joinpath(node_root, "lib", "node_modules", "typescript", "lib", "tsserver.js"))
    add_candidate(
      candidates,
      seen,
      vim.fs.joinpath(node_root, "lib", "node_modules", "typescript-language-server", "node_modules", "typescript", "lib", "tsserver.js")
    )
  end

  if vim.fn.executable("npm") == 1 then
    local npm_root = vim.trim(vim.fn.system({ "npm", "root", "-g" }))
    if vim.v.shell_error == 0 and npm_root ~= "" then
      add_candidate(candidates, seen, vim.fs.joinpath(npm_root, "typescript", "lib", "tsserver.js"))
      add_candidate(
        candidates,
        seen,
        vim.fs.joinpath(npm_root, "typescript-language-server", "node_modules", "typescript", "lib", "tsserver.js")
      )
    end
  end

  return candidates
end

local function resolve_tsserver(root_dir)
  for _, candidate in ipairs(gather_tsserver_candidates(root_dir)) do
    if path_exists(candidate) then
      return candidate
    end
  end
end

local function ensure_wrapper(tsserver_path)
  local typescript_path = vim.fs.joinpath(vim.fs.dirname(tsserver_path), "typescript.js")
  if not path_exists(typescript_path) then
    return nil
  end

  local wrapper_root = vim.fs.joinpath("/tmp", "nvim-tsserver-no-error-truncation", vim.fn.sha256(tsserver_path))
  local wrapper_lib = vim.fs.joinpath(wrapper_root, "lib")
  local wrapper_path = vim.fs.joinpath(wrapper_lib, "tsserver.js")

  vim.fn.mkdir(wrapper_lib, "p")

  write_file(wrapper_path, table.concat({
    "const fs = require(\"node:fs\");",
    "const Module = require(\"node:module\");",
    "const path = require(\"node:path\");",
    "const actualTypescriptPath = " .. vim.json.encode(typescript_path) .. ";",
    "const realTsserver = " .. vim.json.encode(tsserver_path) .. ";",
    "",
    "const source = fs.readFileSync(actualTypescriptPath, \"utf8\")",
    "  .replace(\"var defaultMaximumTruncationLength = 160;\", \"var defaultMaximumTruncationLength = 1000000;\")",
    "  .replace(\"var noTruncationMaximumTruncationLength = 1e6;\", \"var noTruncationMaximumTruncationLength = 1000000;\");",
    "",
    "const patchedTypescript = new Module(actualTypescriptPath, module);",
    "patchedTypescript.filename = actualTypescriptPath;",
    "patchedTypescript.paths = Module._nodeModulePaths(path.dirname(actualTypescriptPath));",
    "patchedTypescript._compile(source, actualTypescriptPath);",
    "require.cache[actualTypescriptPath] = patchedTypescript;",
    "",
    "require(realTsserver);",
  }, "\n"))

  write_file(wrapper_root .. "/package.json", vim.json.encode({
    name = "tsserver-no-error-truncation",
    version = read_package_version(tsserver_path),
  }))

  return wrapper_path
end

local function configure_tsserver_path(new_config, root_dir)
  local tsserver_path = resolve_tsserver(root_dir)
  if not tsserver_path then
    return
  end

  local wrapper_path = ensure_wrapper(tsserver_path)
  if not wrapper_path then
    return
  end

  new_config.init_options = vim.tbl_deep_extend("force", new_config.init_options or {}, {
    hostInfo = "neovim",
    tsserver = {
      path = wrapper_path,
    },
  })
end

return {
  init_options = {
    hostInfo = "neovim",
  },
  on_new_config = configure_tsserver_path,
}
