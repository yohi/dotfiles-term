# dotfiles-term

## 管理と共存関係

本リポジトリは [dotfiles-core](https://github.com/yohi/dotfiles) によって管理されるコンポーネントの一つです。

### ⚠️ 使用時の注意点
本リポジトリは `dotfiles-core` の共通 Makefile ルール（`common-mk`）に依存しており、実行時には `common-mk` へのシンボリックリンクが必要です。そのため、**本リポジトリ単体での使用（クローンしての利用）はサポートされていません。**

推奨される使用方法は、`dotfiles-core` リポジトリから `make setup` を実行し、適切なディレクトリ構造とシンボリックリンクが構成された状態で利用することです。

ターミナルソフトウェア（WezTerm、Tilixなど）の設定ファイルを管理するコンポーネントリポジトリです。
`dotfiles-core` と連携して動作します。

## 主要機能

- **WezTerm 設定**: 高機能な GPU 加速ターミナル WezTerm の Lua 設定。
- **Tilix 統合**: タイリングターミナル Tilix の設定（dconf）管理。

## ディレクトリ構成

```text
.
├── Makefile
├── README.md
├── AGENTS.md
├── _mk/                    # Makefile sub-targets
├── tilix/                  # Tilix configuration (dconf)
└── wezterm.lua             # WezTerm configuration (Lua)
```
