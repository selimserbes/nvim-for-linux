---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "nightfox",

  hl_override = {
    -- Java keyword/modifier colors. These are Treesitter groups.
    ["@keyword.java"] = { fg = "#c678dd" },
    ["@keyword.modifier.java"] = { fg = "#ff9e64", italic = true },
    ["@keyword.type.java"] = { fg = "#c678dd", bold = true },
    ["@type.java"] = { fg = "#61afef" },
    ["@type.builtin.java"] = { fg = "#56b6c2" },
    ["@function.method.java"] = { fg = "#98c379" },
    ["@variable.member.java"] = { fg = "#e06c75" },

    -- If a Java semantic token still slips through, keep it readable.
    ["@lsp.type.modifier.java"] = { fg = "#ff9e64", italic = true },
    ["@lsp.type.class.java"] = { fg = "#61afef", bold = true },
    ["@lsp.type.interface.java"] = { fg = "#56b6c2", bold = true },
    ["@lsp.type.enum.java"] = { fg = "#d19a66", bold = true },
    ["@lsp.type.method.java"] = { fg = "#98c379" },
    ["@lsp.type.property.java"] = { fg = "#e06c75" },
  },
}

-- Extra tools that NvChad's :MasonInstallAll should install explicitly.
-- LSP/formatter/linter packages are also discovered from their configs;
-- duplicates are harmless and are de-duplicated by NvChad.
M.mason = {
  pkgs = {
    -- LSP
    "lua-language-server",
    "typescript-language-server",
    "eslint-lsp",
    "tailwindcss-language-server",
    "css-lsp",
    "html-lsp",
    "rust-analyzer",
    "gopls",
    "pyright",
    "slint-lsp",
    "jdtls",

    -- Formatters / linters
    "prettier",
    "stylua",
    "isort",
    "black",
    "ruff",
    "eslint_d",
    "yamlfmt",
    "gofumpt",
    "golines",

    -- DAP
    "js-debug-adapter",
    "codelldb",
    "cpptools",
    "delve",
    "debugpy",
    "java-debug-adapter",
    "java-test",
  },
}

return M
