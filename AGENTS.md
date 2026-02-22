# PROJECT KNOWLEDGE BASE

**Repository:** dotfiles-term
**Role:** Terminal emulator configuration — WezTerm, Tilix, and other terminal settings

## STRUCTURE

```text
dotfiles-term/
├── tilix/                      # Tilix terminal config
│   └── tilix.dconf             # dconf export for Tilix
└── Makefile                    # Setup entry point
```

> This is currently a minimal component. WezTerm config and other terminal settings will be added.

## COMPONENT LAYOUT CONVENTION

This repository is part of the **dotfiles polyrepo** orchestrated by `dotfiles-core`.
All changes MUST comply with the central layout rules. Please refer to [`dotfiles-core/docs/ARCHITECTURE.md`](../../docs/ARCHITECTURE.md) for the full, authoritative rules and constraints.

## THIS COMPONENT — SPECIAL NOTES

- `tilix/tilix.dconf` is a dconf export — applied via `dconf load`, NOT Stow-linked.
- WezTerm config (`.wezterm.lua` or `.config/wezterm/`) should be a Stow target when added.
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
