# nvim-for-linux

Modern Neovim/NvChad configuration for Linux with LSP, Treesitter, DAP,
formatting, linting, OSC52 remote clipboard, and development support for
Python, Go, Rust, Java, Lua, JavaScript/TypeScript, and more.

## Features

- NvChad-based configuration
- LSP support with Mason-managed tooling
- Treesitter syntax highlighting and indentation
- DAP debugging support
- Formatting with `conform.nvim`
- Linting with `nvim-lint`
- Autocompletion and snippets
- LuaSnip with `jsregexp` support
- OSC52 clipboard support over SSH
- Telescope-based UI integrations
- Language-specific tooling and configuration

## Language Support

The configuration includes support for:

- Lua
- Python
- Go
- Rust
- Java
- JavaScript
- TypeScript
- TSX
- HTML
- CSS
- Bash
- JSON
- YAML
- TOML
- Markdown
- Slint
- KUKA KRL

Additional languages can be added through Treesitter, Mason and LSP
configuration.

## Requirements

The configuration is intended for modern Linux environments.

Recommended base tools:

- Neovim 0.12 or newer
- Git
- curl
- ripgrep
- fd (`fd-find` on Debian/Ubuntu)
- make / build tools
- Node.js and npm
- Python 3
- Go
- Rust / Cargo
- Java / JDK
- tree-sitter CLI

The current configuration is tested with:

```text
Neovim          0.12.5
tree-sitter CLI 0.26.8
Node.js         22.x
Java            21
Go              1.22+
```

Not every language runtime is required. Install the runtimes needed for the
languages you use.

## Installation

Back up an existing Neovim installation first:

```bash
timestamp=$(date +%Y%m%d-%H%M%S)

[ -d ~/.config/nvim ] &&
  mv ~/.config/nvim ~/.config/nvim.backup-$timestamp

[ -d ~/.local/share/nvim ] &&
  mv ~/.local/share/nvim ~/.local/share/nvim.backup-$timestamp

[ -d ~/.local/state/nvim ] &&
  mv ~/.local/state/nvim ~/.local/state/nvim.backup-$timestamp

[ -d ~/.cache/nvim ] &&
  mv ~/.cache/nvim ~/.cache/nvim.backup-$timestamp
```

Clone the repository:

```bash
git clone https://github.com/selimserbes/nvim-for-linux.git ~/.config/nvim
```

Start Neovim:

```bash
nvim
```

Lazy.nvim will install the configured plugins automatically.

## Mason

Update the Mason registry:

```vim
:MasonUpdate
```

Install the tools configured by NvChad and this configuration:

```vim
:MasonInstallAll
```

Installed tools depend on the language configuration in `lua/chadrc.lua` and
the LSP/DAP configuration.

## Treesitter

This configuration uses the current `nvim-treesitter` API.

Install the configured parsers with:

```vim
:TSInstallAll
```

Treesitter parsers are installed under the Neovim data directory.

Verify the installation with:

```vim
:checkhealth nvim-treesitter
```

## LuaSnip

LuaSnip uses the optional `jsregexp` module for additional snippet features.

If it was not built automatically:

```bash
cd ~/.local/share/nvim/lazy/LuaSnip
make install_jsregexp
```

Verify it with:

```vim
:checkhealth luasnip
```

## Remote Clipboard over SSH

When Neovim detects an SSH session, the configuration enables the OSC52
clipboard provider automatically.

The relevant behavior is equivalent to:

```lua
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  vim.g.clipboard = "osc52"
  vim.opt.clipboard = "unnamedplus"
end
```

This allows text yanked in a remote Neovim session to reach the clipboard of
the local machine when the terminal path supports OSC52.

The clipboard data path is:

```text
remote Neovim
    -> OSC52
    -> tmux
    -> SSH
    -> local terminal
    -> local clipboard
```

The terminal emulator and any intermediate multiplexer must allow OSC52
clipboard sequences.

### tmux

A compatible tmux configuration can include:

```tmux
set -g default-terminal "tmux-256color"

set -as terminal-features ',xterm-kitty:RGB'
set -as terminal-features ',xterm-kitty:clipboard'

set -g set-clipboard on
set -g mouse on
set -g history-limit 100000
```

OSC52 support does not require Kitty to be installed on the remote host.
The local terminal emulator is responsible for receiving the clipboard
sequence.

## Plugin Versions

Plugin revisions are tracked in `lazy-lock.json` to make installations more
reproducible.

Keep `lazy-lock.json` under version control. Use Lazy.nvim when you
intentionally want to update plugin revisions:

```vim
:Lazy update
```

## Configuration Structure

```text
nvim/
├── init.lua
├── lazy-lock.json
├── LICENSE
├── lua/
│   ├── autocmds.lua
│   ├── chadrc.lua
│   ├── configs/
│   │   ├── conform.lua
│   │   ├── dap.lua
│   │   ├── lazy.lua
│   │   ├── lint.lua
│   │   ├── lspconfig.lua
│   │   └── treesitter.lua
│   ├── mappings.lua
│   ├── options.lua
│   └── plugins/
│       └── init.lua
└── README.md
```

## Main Configuration Files

`lua/chadrc.lua`
: NvChad configuration and additional Mason packages.

`lua/plugins/init.lua`
: Plugin specifications and plugin-specific setup.

`lua/configs/lspconfig.lua`
: Language Server Protocol configuration.

`lua/configs/treesitter.lua`
: Treesitter parser installation and runtime setup.

`lua/configs/dap.lua`
: Debug Adapter Protocol configuration.

`lua/configs/conform.lua`
: Formatter configuration.

`lua/configs/lint.lua`
: Linter configuration.

`lua/mappings.lua`
: Custom key mappings.

`lua/options.lua`
: Additional Neovim options.

## Health Check

Run the complete Neovim health check with:

```vim
:checkhealth
```

Useful focused checks include:

```vim
:checkhealth vim.health
:checkhealth vim.provider
:checkhealth vim.treesitter
:checkhealth nvim-treesitter
:checkhealth mason
:checkhealth luasnip
```

Some Mason health checks may warn about language runtimes that are not
installed, such as PHP, Ruby or Julia. These warnings can be ignored when those
languages are not used.

## Updating

Update plugins through Lazy:

```vim
:Lazy update
```

Update Mason registries:

```vim
:MasonUpdate
```

Update Treesitter parsers:

```vim
:TSUpdate
```

After major Neovim or plugin upgrades, run:

```vim
:checkhealth
```

## Notes

This repository contains editor configuration only.

Machine-specific credentials, proxy configuration, SSH configuration, tokens,
private hostnames and other secrets should not be committed to this repository.

The configuration is primarily maintained and tested on Linux.
