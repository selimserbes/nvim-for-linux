local M = {}

local filetypes = {
  "lua",
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "html",
  "css",
  "go",
  "rust",
  "python",
  "markdown",
  "slint",
  "java",
  "json",
  "yaml",
  "toml",
  "bash",
}

function M.setup(opts)
  -- Preserve NvChad/Base46 syntax highlight integration.
  pcall(function()
    dofile(vim.g.base46_cache .. "syntax")
    dofile(vim.g.base46_cache .. "treesitter")
  end)

  opts = vim.deepcopy(opts or {})
  local ensure_installed = opts.ensure_installed or {}

  -- `ensure_installed` is an NvChad/user convenience key. The rewritten
  -- nvim-treesitter `setup()` only accepts installer configuration, so do not
  -- pass this key through to setup().
  opts.ensure_installed = nil

  local treesitter = require "nvim-treesitter"
  treesitter.setup(opts)

  -- Async and idempotent: already-installed parsers are left untouched.
  treesitter.install(ensure_installed)

  local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = filetypes,
    callback = function()
      -- Highlighting is provided by Neovim core with the new nvim-treesitter.
      pcall(vim.treesitter.start)

      -- Indentation is still provided by nvim-treesitter.
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

return M
