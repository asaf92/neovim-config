return {
  cmd = { "ruff", "server" },
  init_options = {
    settings = {
      args = {},
      lint = {
        ignore = { "F403", "F405" },
      },
    },
  },
}
