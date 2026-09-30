-- NVChad autocmds
require "nvchad.autocmds"

-- Detect KUKA KRL files and set filetype
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.src", "*.dat" },
  callback = function()
    vim.bo.filetype = "krl"
  end,
})

local kuka_aug = vim.api.nvim_create_augroup("KukaKRL", { clear = true })

vim.api.nvim_create_autocmd({ "bufread", "bufnewfile" }, {
  group = kuka_aug,
  pattern = { "*.src", "*.dat" },
  desc = "Set file format and encoding for KUKA files.",
  callback = function()
    vim.bo.fileformat = "dos"
    vim.bo.fileencoding = "cp1252"
    vim.bo.bomb = false
  end,
})

vim.api.nvim_create_autocmd("bufwritepre", {
  group = kuka_aug,
  pattern = { "*.src", "*.dat" },
  desc = "Apply formatting (trim, indent, and transliterate) for KUKA files.",
  callback = function()
    local function make_ascii_compatible(str)
      if not str then
        return ""
      end
      str = str:gsub("Ç", "C"):gsub("Ğ", "G"):gsub("İ", "I"):gsub("Ö", "O"):gsub("Ş", "S"):gsub("Ü", "U")
      str = str:gsub("ç", "c"):gsub("ğ", "g"):gsub("ı", "i"):gsub("ö", "o"):gsub("ş", "s"):gsub("ü", "u")
      str = str:gsub("[^%z\t\n\r -~]", "?")
      return str
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    local compatible_lines = {}
    for _, line in ipairs(lines) do
      table.insert(compatible_lines, make_ascii_compatible(line))
    end
    lines = compatible_lines

    while #lines > 0 and lines[1]:match "^%s*$" do
      table.remove(lines, 1)
    end
    while #lines > 0 and lines[#lines]:match "^%s*$" do
      table.remove(lines)
    end

    local new_lines = {}
    local indent_level = 0
    local indent_str = string.rep(" ", 4)
    local block_stack = {}

    local block_starters = {
      ["DEF"] = "END",
      ["DEFDAT"] = "ENDDAT",
      ["FOR"] = "ENDFOR",
      ["WHILE"] = "ENDWHILE",
      ["IF"] = "ENDIF",
      ["SWITCH"] = "ENDSWITCH",
      ["REPEAT"] = "UNTIL",
      ["LOOP"] = "ENDLOOP",
    }
    local mid_blocks = {
      ["ELSEIF"] = true,
      ["ELSE"] = true,
      ["CASE"] = true,
      ["DEFAULT"] = true,
    }
    local block_enders = {
      ["END"] = true,
      ["ENDDAT"] = true,
      ["ENDFOR"] = true,
      ["ENDWHILE"] = true,
      ["ENDIF"] = true,
      ["ENDSWITCH"] = true,
      ["UNTIL"] = true,
      ["ENDLOOP"] = true,
      ["ENDINT"] = true,
    }

    for _, line in ipairs(lines) do
      local trimmed = line:gsub("^%s+", "")
      local upper_trim = trimmed:upper()
      local first_word = upper_trim:match "^(%S+)" or ""

      if trimmed == "" then
        table.insert(new_lines, "")
        goto continue
      end

      if trimmed:sub(1, 1) == ";" then
        table.insert(new_lines, string.rep(indent_str, indent_level) .. trimmed)
        goto continue
      end

      if upper_trim:match "^IF.+THEN.+ENDIF$" then
        table.insert(new_lines, string.rep(indent_str, indent_level) .. trimmed)
        goto continue
      end

      if mid_blocks[first_word] then
        indent_level = math.max(indent_level - 1, 0)
      elseif block_enders[first_word] then
        indent_level = math.max(indent_level - 1, 0)
        if #block_stack > 0 then
          table.remove(block_stack)
        end
      end

      table.insert(new_lines, string.rep(indent_str, indent_level) .. trimmed)

      if block_starters[first_word] then
        indent_level = indent_level + 1
        table.insert(block_stack, block_starters[first_word])
      elseif mid_blocks[first_word] then
        indent_level = indent_level + 1
      elseif first_word == "INTERRUPT" and upper_trim:match "^INTERRUPT. +%s+DO%s*$" then
        if indent_level >= 0 then
          indent_level = indent_level + 1
          table.insert(block_stack, "ENDINT")
        end
      end

      ::continue::
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.slint" },
  callback = function()
    vim.bo.filetype = "slint"
  end,
})
