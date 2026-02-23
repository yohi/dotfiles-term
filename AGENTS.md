# PROJECT KNOWLEDGE BASE

**Repository:** dotfiles-term
**Role:** Terminal emulator configuration — WezTerm, Tilix, and other terminal settings

## STRUCTURE

```text
dotfiles-term/
├── wezterm.lua                 # [Link Target] WezTerm configuration → ~/.wezterm.lua
├── tilix/                      # Tilix terminal config
│   └── tilix.dconf             # dconf export for Tilix
└── Makefile                    # Setup entry point
```

## COMPONENT LAYOUT CONVENTION

This repository is part of the **dotfiles polyrepo** orchestrated by `dotfiles-core`.
All changes MUST comply with the central layout rules. Please refer to the central [ARCHITECTURE.md](https://raw.githubusercontent.com/yohi/dotfiles-core/refs/heads/master/docs/ARCHITECTURE.md) for the full, authoritative rules and constraints.

## THIS COMPONENT — SPECIAL NOTES

- `tilix/tilix.dconf` is a dconf export — applied via `dconf load`, NOT linked.
- `wezterm.lua` is linked to `~/.wezterm.lua` via `ln -sfn` in the Makefile (`make link`).
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
