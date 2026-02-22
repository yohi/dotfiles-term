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
All changes MUST comply with the following layout rules.

### Required Files

Every component repository MUST have:

| File | Purpose |
| :--- | :--- |
| `Makefile` | Exposes a `setup` target; called by `dotfiles-core` via delegation |
| `.stow-local-ignore` | Lists files/dirs excluded from Stow symlink creation |
| `README.md` | Component overview (written in Japanese) |
| `LICENSE` | MIT license |
| `.gitignore` | Git exclusion rules |

### Stow Symlink Rules

GNU Stow creates symlinks from this repo's root into `~/`.
**Only dotfiles and directories intended for the user's `$HOME` should be Stow targets.**

- Files/dirs listed in `.stow-local-ignore` are **excluded** from Stow.
- When `.stow-local-ignore` exists, Stow's default exclusions (README.*, LICENSE, etc.) are **disabled** — you must list them explicitly.
- `.stow-local-ignore` patterns are interpreted as **regex** — escape dots: `README\.md`, not `README.md`.

### Makefile Rules

```makefile
.DEFAULT_GOAL := setup
# include mk/<feature>.mk    # if using mk/ subdirectory

.PHONY: setup
setup:
 @echo "==> Setting up dotfiles-<name>"
```

1. `setup` target is **mandatory** (interface for dotfiles-core delegation).
2. Set `.DEFAULT_GOAL := setup` when using `include` directives.
3. Declare all non-file targets with `.PHONY`.
4. Use `mk/` subdirectory to split complex Makefiles.
5. Print progress with `@echo "==> ..."`.

### `bin/` vs `scripts/`

| Directory | Purpose | On `$PATH` | Stow target |
| :--- | :--- | :--- | :--- |
| `bin/` | Public commands callable by users or other components | ✅ Added dynamically by dotfiles-zsh | ❌ Excluded |
| `scripts/` | Internal helpers for this component only | ❌ | ❌ Excluded |

### Path Resolution (MANDATORY)

All scripts must resolve paths dynamically. Hardcoded absolute paths are **forbidden**.

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
```

**Forbidden:**

- Hardcoded paths like `~/dotfiles/components/dotfiles-term/...`
- Legacy `$DOTFILES_DIR` references from monorepo era

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
