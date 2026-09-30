local dap = require "dap"

local function command(name)
  local resolved = vim.fn.exepath(name)
  return resolved ~= "" and resolved or name
end

-- Go / Delve. Mason exposes `dlv` in its bin directory and prepends it to PATH.
dap.adapters.delve = {
  type = "server",
  port = "${port}",
  executable = {
    command = command "dlv",
    args = { "dap", "-l", "127.0.0.1:${port}" },
    detached = false,
  },
}

dap.configurations.go = {
  {
    type = "delve",
    name = "Debug",
    request = "launch",
    program = "${file}",
  },
}

-- Rust / CodeLLDB. Mason exposes `codelldb` in PATH.
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = command "codelldb",
    args = { "--port", "${port}" },
    detached = false,
  },
}

dap.configurations.rust = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}

-- Node.js / TypeScript / JavaScript. Mason exposes `js-debug-adapter` in PATH.
dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = 8123,
  executable = {
    command = command "js-debug-adapter",
  },
}

for _, language in ipairs { "typescript", "javascript" } do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      runtimeExecutable = "node",
    },
  }
end
