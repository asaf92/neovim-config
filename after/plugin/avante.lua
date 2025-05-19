local ollama        = require("avante.providers.ollama")
local original_parse = ollama.parse_curl_args
local Utils          = require("avante.utils")

local function transform_tool(tool)
  local props, req = {}, {}
  for _, f in ipairs(tool.param.fields) do
    props[f.name] = { type=f.type, description=f.description }
    if not f.optional then table.insert(req, f.name) end
  end
  return {
    name        = tool.name,
    description = tool.description,
    parameters  = {
      type                 = "object",
      properties           = props,
      required             = req,
      additionalProperties = false,
    },
  }
end

function ollama:parse_curl_args(prompt_opts)
  local out = original_parse(self, prompt_opts)
  out.body.stream = false
  if prompt_opts.tools then
    out.body.tools = vim.tbl_map(transform_tool, prompt_opts.tools)
  end
  return out
end

-- require("avante").setup({
--   provider = "ollama",
--   behaviour = { enable_cursor_planning_mode = true },
--   ollama   = {
--     endpoint = "http://127.0.0.1:11434",
--     model    = "qwen3:14b",
--   },
--   windows = { position = "right", width = 30 },
--   debug   = true,
-- })
