return {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic",
        diagnosticSeverityOverrides = {
          reportImplicitOverride = "none",
          reportMissingTypeStubs = "none",
          reportUnknownArgumentType = "none",
          reportUnknownMemberType = "none",
          reportUnknownParameterType = "none",
          reportUnknownVariableType = "none",
          reportWildcardImportFromLibrary = "none",
          reportUnusedCallResult = "none",
        },
      },
    },
  },
}
