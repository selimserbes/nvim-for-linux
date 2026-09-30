require("nvchad.configs.lspconfig").defaults()

-- Cargo-installed tools (notably tree-sitter-cli) should be visible to Neovim.
local cargo_bin = vim.fn.expand "~/.cargo/bin"
if vim.fn.isdirectory(cargo_bin) == 1 and not vim.env.PATH:find(cargo_bin, 1, true) then
  vim.env.PATH = cargo_bin .. ":" .. vim.env.PATH
end

vim.diagnostic.config {
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}

local function get_python_path()
  local venv = os.getenv "VIRTUAL_ENV"
  if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
    return venv .. "/bin/python"
  end

  return vim.fn.exepath "python3" ~= "" and vim.fn.exepath "python3" or "/usr/bin/python3"
end

local function path_join(...)
  return table.concat({ ... }, "/")
end

local mason_root = path_join(vim.fn.stdpath "data", "mason")
local mason_share = path_join(mason_root, "share")

local function java_bundles()
  local bundles = {}

  -- Mason v2 exposes non-executable package data under $MASON/share.
  -- These paths are part of the package spec and are more stable than
  -- reaching into $MASON/packages/<package>/... internals.
  local debug_jar = path_join(mason_share, "java-debug-adapter", "com.microsoft.java.debug.plugin.jar")
  if vim.fn.filereadable(debug_jar) == 1 then
    bundles[#bundles + 1] = debug_jar
  end

  local test_jars = vim.split(
    vim.fn.glob(path_join(mason_share, "java-test", "*.jar"), true),
    "\n",
    { trimempty = true }
  )

  local excluded = {
    ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
    ["jacocoagent.jar"] = true,
  }

  for _, jar in ipairs(test_jars) do
    local filename = vim.fn.fnamemodify(jar, ":t")
    if not excluded[filename] then
      bundles[#bundles + 1] = jar
    end
  end

  return bundles
end

local function setup_java_buffer(bufnr)
  vim.bo[bufnr].tabstop = 4
  vim.bo[bufnr].shiftwidth = 4
  vim.bo[bufnr].softtabstop = 4
  vim.bo[bufnr].expandtab = true
end

local function start_jdtls(bufnr)
  setup_java_buffer(bufnr)

  local ok, jdtls = pcall(require, "jdtls")
  if not ok then
    vim.notify("nvim-jdtls yüklenemedi. :Lazy açıp kurulumu kontrol et.", vim.log.levels.ERROR, { title = "Java LSP" })
    return
  end

  local jdtls_cmd = vim.fn.exepath "jdtls"
  if jdtls_cmd == "" then
    vim.notify("jdtls bulunamadı. :MasonInstall jdtls çalıştır.", vim.log.levels.ERROR, { title = "Java LSP" })
    return
  end

  local root_markers = {
    "pom.xml",
    "mvnw",
    "gradlew",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    ".git",
  }

  local root_dir = jdtls.setup.find_root(root_markers) or vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = path_join(vim.fn.stdpath "data", "jdtls-workspaces", project_name)

  local config = {
    cmd = { jdtls_cmd, "-data", workspace_dir },
    root_dir = root_dir,

    init_options = {
      bundles = java_bundles(),
    },

    settings = {
      java = {
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        configuration = { updateBuildConfiguration = "interactive" },
        format = { enabled = true },
        saveActions = { organizeImports = true },
        signatureHelp = { enabled = true },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
      },
    },

    on_attach = function(client, attach_bufnr)
      -- Let Treesitter own Java syntax colors; keep the rest of JDTLS features.
      client.server_capabilities.semanticTokensProvider = nil

      local map = vim.keymap.set
      local opts = { buffer = attach_bufnr, silent = true }

      map("n", "<leader>jf", function()
        vim.lsp.buf.format { bufnr = attach_bufnr, async = false }
      end, vim.tbl_extend("force", opts, { desc = "Java: format" }))

      map("n", "<leader>jo", function()
        jdtls.organize_imports()
      end, vim.tbl_extend("force", opts, { desc = "Java: organize imports" }))

      map("n", "<leader>ju", "<cmd>JdtUpdateConfig<cr>", vim.tbl_extend("force", opts, { desc = "Java: update project" }))
      map("n", "<leader>jr", "<cmd>JdtRestart<cr>", vim.tbl_extend("force", opts, { desc = "Java: restart JDTLS" }))
    end,
  }

  jdtls.start_or_attach(config)
end

local java_group = vim.api.nvim_create_augroup("JavaJdtls", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = java_group,
  pattern = "java",
  callback = function(args)
    start_jdtls(args.buf)
  end,
})

vim.lsp.config("pyright", {
  settings = {
    python = {
      pythonPath = get_python_path(),
    },
  },
})

vim.lsp.config("slint_lsp", {})

vim.lsp.enable {
  "rust_analyzer",
  "gopls",
  "pyright",
  "ts_ls",
  "tailwindcss",
  "eslint",
  "cssls",
  "html",
  "slint_lsp",
}
