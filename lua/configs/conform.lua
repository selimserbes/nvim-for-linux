return {
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    svelte = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "yamlfmt" },
    markdown = { "prettier" },
    graphql = { "prettier" },
    python = { "ruff", "black", "isort" },
    rust = { "rustfmt" },
    go = { "gofumpt", "golines" },
    slint = { "slint_lsp" },
  },

  default_format_opts = {
    lsp_format = "fallback",
  },

  -- Ctrl+s and :w use the same save path. Conform formats before saving.
  -- Java has no external formatter here; it falls back to JDTLS LSP formatting.
  format_on_save = {
    lsp_format = "fallback",
    async = false,
    timeout_ms = 5000,
  },

  formatters = {
    slint_lsp = {
      command = "slint-lsp",
      args = { "format", "-i", "$FILENAME" },
      stdin = false,
      tmpfile_format = ".conform.$RANDOM.$FILENAME",
    },
  },
}
