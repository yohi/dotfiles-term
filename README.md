# dotfiles-term

ターミナルソフトウェア（WezTerm、Tilixなど）の設定ファイルを管理するコンポーネントリポジトリです。
`dotfiles-core` と連携して動作します。

## 管理と依存関係

本リポジトリは [dotfiles-core](https://github.com/yohi/dotfiles-core) によって管理されるコンポーネントの一つです。

### ⚠️ 単体使用時の注意点
本リポジトリは `dotfiles-core` の共通 Makefile ルール（`common-mk`）に依存しています。単体で使用（クローン）する場合は、以下の手順が必要です：

1. `common-mk` ディレクトリを本リポジトリの親ディレクトリ（`../common-mk/`）に配置するか、親ディレクトリに向けた symlink を作成してください。
   （※ `_mk/` 内の include は固定の相対パスで行われるため、これ以外の場所への配置やパス設定の変更はサポートされていません。）
2. `make help` を実行して、正しく設定されていることを確認してください。

推奨される使用方法は、`dotfiles-core` から `make setup` を実行することです。

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
