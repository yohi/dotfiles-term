# dotfiles-term

ターミナルソフトウェア（WezTerm、Tilix、Ghosttyなど）の設定ファイルを管理するコンポーネントリポジトリです。

## 管理と共存関係

> [!IMPORTANT]
> 本リポジトリは [dotfiles-core](https://github.com/yohi/dotfiles-core) によって管理されるコンポーネントの一つです。

> [!WARNING]
> **使用時の注意点**
> 本リポジトリは `dotfiles-core` の共通 Makefile ルール（`common-mk`）に依存しており、実行時には `common-mk` へのシンボリックリンクが必要です。そのため、**本リポジトリ単体での使用（クローンしての利用）はサポートされていません。**
>
> 推奨される使用方法は、`dotfiles-core` リポジトリから `make setup` を実行し、適切なディレクトリ構造とシンボリックリンクが構成された状態で利用することです。

## 主要機能

- **WezTerm 設定**: 高機能な GPU 加速ターミナル WezTerm の Lua 設定。
- **Tilix 統合**: タイリングターミナル Tilix の設定（dconf）管理。
- **Ghostty 設定**: 高速かつネイティブなターミナル Ghostty の設定管理、`xterm-ghostty` terminfo の自動セットアップ、および SSH 入力二重化防止用の自動フォールバック設定。
- **tmux 設定**: tmux-resurrect / tmux-continuum によるセッション自動保存・復元に対応した tmux 設定の管理。

## ターゲット

- `make setup`: 各ターミナルの設定をシステムに適用します（Ghostty 用 terminfo のコンパイルや SSH ラッパースクリプトのシンボリックリンク配置含む）。
- `make install-term`: No-op. ターミナル設定は外部で管理されています（README参照）。

## ディレクトリ構成

```text
.
├── Makefile
├── README.md
├── AGENTS.md
├── _mk/                    # Makefile sub-targets
├── tilix/                  # Tilix 設定 (dconf)
├── ghostty/                # Ghostty 設定 (config, xterm-ghostty.terminfo, ssh-wrapper.sh)
├── ghostty-src/            # Ghostty ソース（参照）
├── tmux/                   # tmux 設定 (tmux.conf、セッション復元)
├── wezterm.lua             # WezTerm 設定 (Lua)
└── zsh-functions/          # zsh 用関数スクリプト (ghostty-ssh.zsh)
```
