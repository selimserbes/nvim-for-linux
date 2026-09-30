require "nvchad.mappings"

local map = vim.keymap.set
local M = {}

-- ==== Global Mappingler ====
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- ==== Visual Indent (keep selection) ====
map("v", ">", ">gv", { desc = "Indent right (keep selection)" })
map("v", "<", "<gv", { desc = "Indent left (keep selection)" })

-- ==== Diagnostic Mappings ====
map("n", "<leader>q", function()
  vim.diagnostic.setloclist()
end, { desc = "Show buffer diagnostics (loclist)" })

map("n", "<leader>Q", "<cmd>Telescope diagnostics<cr>", { desc = "Telescope: workspace diagnostics" })


-- ==== Save Mapping ====
-- Ctrl+s triggers a normal :write, so BufWritePre format-on-save runs automatically.
map({ "n", "i", "v" }, "<C-s>", function()
  if vim.fn.mode():match "^[ivV]" then
    vim.cmd "stopinsert"
  end
  vim.cmd "write"
end, { desc = "Save file" })



-- ==== Terminal Window Navigation ====
-- Terminal mode input yakaladığı için default <C-h/j/k/l> terminalden çıkamaz.
-- Bu mappingler önce terminal mode'dan normal mode'a çıkar, sonra pencereye geçer.
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Terminal: window left" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Terminal: window down" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Terminal: window up" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Terminal: window right" })

-- Terminal emülatörü <C-h>'yi Backspace gibi yakalarsa alternatif: Alt+h/j/k/l
map("t", "<M-h>", [[<C-\><C-n><C-w>h]], { desc = "Terminal: window left" })
map("t", "<M-j>", [[<C-\><C-n><C-w>j]], { desc = "Terminal: window down" })
map("t", "<M-k>", [[<C-\><C-n><C-w>k]], { desc = "Terminal: window up" })
map("t", "<M-l>", [[<C-\><C-n><C-w>l]], { desc = "Terminal: window right" })

-- Terminal input modundan sadece çıkmak için
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Terminal: normal mode" })


-- ==== plugin-specific mappingler ====

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = { "<cmd>DapToggleBreakpoint<cr>", "DAP: toggle breakpoint" },
    ["<leader>dr"] = { "<cmd>DapContinue<cr>", "DAP: run or continue" },
  },
}

M.gopher = {
  plugin = true,
  n = {
    ["<leader>gsj"] = { "<cmd>GoTagAdd json<cr>", "Go: add JSON struct tags" },
    ["<leader>gsy"] = { "<cmd>GoTagAdd yaml<cr>", "Go: add YAML struct tags" },
  },
}

M.spectre = {
  plugin = true,
  n = {
    ["<leader>ss"] = { "<cmd>lua require('spectre').open()<cr>", "Spectre: open" },
    ["<leader>sw"] = {
      "<cmd>lua require('spectre').open_file_search({select_word=true})<cr>",
      "Spectre: search current file",
    },
    ["<leader>sp"] = { "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "Spectre: project search" },
    ["<leader>sc"] = { "<cmd>lua require('spectre').open_visual()<cr>", "Spectre: search current word" },
  },
}

-- ==== fonksiyon: plugin mappingleri yükle ====
function M.load_plugin(name)
  local plugin_maps = M[name]
  if not plugin_maps then
    return
  end

  for mode, maps in pairs(plugin_maps) do
    if mode ~= "plugin" then
      for lhs, rhs in pairs(maps) do
        map(mode, lhs, rhs[1], { desc = rhs[2] })
      end
    end
  end
end

return M
