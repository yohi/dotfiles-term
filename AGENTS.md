# Agent Instructions for dotfiles-term


## COMPONENT LAYOUT CONVENTION

This repository is part of the **dotfiles polyrepo** managed by [dotfiles-core](https://github.com/yohi/dotfiles-core).

### ⚠️ CRITICAL: SYMBOLIC LINK & STANDALONE USAGE
- **Standalone usage is NOT supported.** This repository depends on the central `common-mk` rules.
- **Symbolic Links:** This repository relies on symbolic links to `common-mk`. **NEVER** suggest or perform a replacement of these symbolic links with physical files/directories. 
- **SSOT:** Always respect the "Single Source of Truth" principle. Shared logic resides in `dotfiles-core`, and components must remain thin wrappers or specific configurations.
- **Architectural Compliance:** All modifications must adhere to the layout defined in the central [ARCHITECTURE.md](https://github.com/yohi/dotfiles-core/blob/master/docs/ARCHITECTURE.md).

> [!IMPORTANT]
> 共通の基本ルールは [DOTFILES_COMMON_RULES.md](./DOTFILES_COMMON_RULES.md) を参照してください。

# PROJECT KNOWLEDGE BASE

**Repository:** dotfiles-term
**Role:** Terminal emulator/multiplexer configuration — WezTerm, Tilix, Ghostty, tmux, and other terminal settings

## STRUCTURE

```text
dotfiles-term/
├── Makefile                    # Setup entry point
├── wezterm.lua                 # [Link Target] WezTerm configuration → ~/.wezterm.lua
├── tilix/                      # Tilix terminal config
│   └── tilix.dconf             # dconf export for Tilix (applied via dconf load)
├── ghostty/                    # Ghostty terminal config
│   ├── config                  # [Link Target] Ghostty configuration → ~/.config/ghostty/config
│   ├── xterm-ghostty.terminfo  # terminfo entry compiled to ~/.terminfo/ via make setup
│   └── ghostty-ssh-wrapper.sh  # [Link Target] SSH wrapper script → ~/.local/bin/ghostty-ssh-wrapper.sh
├── ghostty-src/                # Ghostty source code (for reference)
├── zsh-functions/              # Shell function scripts
│   └── ghostty-ssh.zsh         # zsh SSH wrapper function to auto-detect xterm-ghostty remote support
├── tmux/                       # tmux multiplexer config
│   └── tmux.conf               # [Link Target] tmux config → ~/.tmux.conf (session restore: resurrect+continuum)
├── _mk/                        # Makefile sub-targets
└── ...
```

## THIS COMPONENT — SPECIAL NOTES

- **Makefile Dependency:** This component relies on `common-mk`. It MUST be located at the parent directory (`../common-mk/`) or symlinked there.
- **Fixed Pathing:** Includes in `_mk/` use fixed relative paths. Custom path configuration for `common-mk` is NOT supported. Run `make help` to verify setup.
- `tilix/tilix.dconf` is a dconf export — applied via `dconf load`, NOT linked.
- `wezterm.lua` is linked to `~/.wezterm.lua` via `ln -sfn` in the Makefile (`make setup`).
- `ghostty/config` is linked to `~/.config/ghostty/config` via `ln -sfn` in the Makefile (`make setup`).
- `ghostty/xterm-ghostty.terminfo` is compiled and installed to `~/.terminfo/` via `tic` during `make setup`.
- `ghostty/ghostty-ssh-wrapper.sh` is linked to `~/.local/bin/ghostty-ssh-wrapper.sh` via `make setup`.
- `zsh-functions/ghostty-ssh.zsh` provides an SSH wrapper function for zsh to auto-detect remote `xterm-ghostty` support and fall back to `TERM=xterm-256color` when unsupported.
- `tmux/tmux.conf` is linked to `~/.tmux.conf` via `ln -sfn` in the Makefile (`make setup`); TPM is auto-cloned and its plugins auto-installed by the Makefile.
- **tmux session restore:** `tmux-resurrect` + `tmux-continuum` (`@continuum-restore 'on'`) restore the previous session on tmux server start. `tmux-continuum` MUST remain the LAST `@plugin` — it appends an auto-save hook to `status-right`, and theme/status plugins (`catppuccin`, `tmux-colortag`, `tmux-cpu`) loaded after it would overwrite the hook and silently break auto-save.
- **tmux status bar:** `set-environment -g TMUX_COLORTAG_TAG_ONLY yes` prevents `tmux-colortag` from overwriting the custom `status-left`/`status-right` (window-tab coloring is preserved).
- `ghostty/config` sets `command = tmux`, so every Ghostty surface (window/tab/split) launches tmux; this requires `tmux` to be on Ghostty's PATH.
- Terminal emulator configs that live under `~/.config/<tool>/` should mirror that directory structure at repo root.

## CODE STYLE

- **Documentation / README**: Japanese (日本語)
- **AGENTS.md**: English
- **Commit Messages**: Japanese, Conventional Commits (e.g., `feat: 新機能追加`, `fix: バグ修正`)
- **Shell**: `set -euo pipefail`, dynamic path resolution, idempotent operations

## FORBIDDEN OPERATIONS

Per `opencode.jsonc` (when present), these operations are blocked for agent execution:

- `rm` (destructive file operations)
- `ssh` (remote access)
- `sudo` (privilege escalation)
