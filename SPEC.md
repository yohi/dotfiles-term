# dotfiles-term 仕様書 (SPEC)

`dotfiles-term` は、ターミナルエミュレータおよびターミナルマルチプレクサの設定を管理するコンポーネントリポジトリです。本書はリポジトリの構成・セットアップの仕組み・各設定の役割をまとめます。

> [!NOTE]
> 本リポジトリは [dotfiles-core](https://github.com/yohi/dotfiles-core) が管理するポリレポの 1 コンポーネントです。共通ルールは共有の `common-mk` に依存し、単体利用はサポートされません。詳細は [README.md](./README.md) / [AGENTS.md](./AGENTS.md) を参照してください。

## 1. 概要

- **役割**: WezTerm・Tilix・Ghostty・tmux の設定を一元管理し、`make setup` でシステムへ配備する。
- **配備方式**: シンボリックリンク（tmux / WezTerm / Ghostty）または dconf ロード（Tilix）で適用する。
- **依存**: ポリレポ直下の `common-mk/`（`_mk/` 配下の `.mk` が `../../../common-mk/` への固定相対シンボリックリンクとして include）。

## 2. ディレクトリ構成

```text
dotfiles-term/
├── Makefile           # エントリーポイント (include: _mk/core.mk, help.mk, term.mk)
├── _mk/               # Makefile サブターゲット
│   ├── core.mk        # 既定ゴール(help)・all/install/setup の骨格
│   ├── help.mk        # `make help` のヘルプ表示
│   ├── term.mk        # setup-term 本体（リンク配備・dconf・TPM 導入）
│   └── idempotency.mk # 冪等性マーカー用ユーティリティ
├── wezterm.lua        # WezTerm 設定 → ~/.wezterm.lua
├── ghostty/config     # Ghostty 設定 → ~/.config/ghostty/config
├── tilix/tilix.dconf  # Tilix 設定 (dconf エクスポート、load で適用)
├── tmux/tmux.conf     # tmux 設定 → ~/.tmux.conf
├── ghostty-src/       # Ghostty ソース（参照用）
├── docs/              # ドキュメント
├── README.md          # 利用者向け説明 (日本語)
├── AGENTS.md          # エージェント向け指示 (英語)
└── SPEC.md            # 本仕様書
```

## 3. セットアップ (Makefile)

| ターゲット | 説明 |
| --- | --- |
| `make setup` | `setup-term` を実行し、各設定をシステムへ適用する |
| `make install` | `install-term`（No-op。ターミナル本体は外部管理） |
| `make help` | 利用可能なターゲット一覧を表示する |
| `make clean` | 生成物・一時ファイルを削除する |
| `make test` | テストを実行する |

`setup-term`（[_mk/term.mk](./_mk/term.mk)）の処理内容:

1. **WezTerm**: `ln -sfn wezterm.lua ~/.wezterm.lua`
2. **Ghostty**: 既存の実体ファイルがあればタイムスタンプ付きでバックアップ後、`ghostty/config` を `~/.config/ghostty/config` へリンクする。
3. **Tilix**: `dconf` が存在する場合のみ `tilix/tilix.dconf` を `dconf load /com/gexperts/Tilix/` で適用する。
4. **tmux**: 既存 `~/.tmux.conf` をバックアップ後 `tmux/tmux.conf` をリンクし、TPM が未導入なら clone、続けて `tpm/bin/install_plugins` を実行する。

### シンボリックリンク対応表

| リポジトリ内 | 配備先 | 方式 |
| --- | --- | --- |
| `wezterm.lua` | `~/.wezterm.lua` | symlink |
| `ghostty/config` | `~/.config/ghostty/config` | symlink |
| `tmux/tmux.conf` | `~/.tmux.conf` | symlink |
| `tilix/tilix.dconf` | dconf `/com/gexperts/Tilix/` | `dconf load`（リンクではない） |

## 4. 各設定の役割

### 4.1 WezTerm (`wezterm.lua`)

GPU アクセラレーション対応ターミナルの Lua 設定。

### 4.2 Tilix (`tilix/tilix.dconf`)

タイリングターミナル Tilix の dconf エクスポート。リンクではなく `dconf load` で適用する。

### 4.3 Ghostty (`ghostty/config`)

高速・ネイティブなターミナル Ghostty の設定。フォント（Cica）・Monokai 系配色・背景ぼかしなどに加え、`command = tmux` により全サーフェスで tmux を起動する（→ 6 章）。

### 4.4 tmux (`tmux/tmux.conf`)

プレフィックス `C-a`・マウス有効・履歴 50000 行などの基本設定に加え、TPM 管理のプラグイン群でセッション復元・テーマ・ステータス表示を構成する（→ 5 章）。

## 5. tmux セッション復元の仕組み

ウィンドウ／ペインのレイアウトや作業ディレクトリを、tmux サーバ再起動後も復元する。

- **[tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)**: セッションの保存／復元エンジン。
  - `@resurrect-capture-pane-contents 'on'`: ペインの表示内容も保存・復元する。
  - `@resurrect-strategy-nvim 'session'`: Neovim のセッションを復元する。
- **[tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)**: 定期自動保存とサーバ起動時の自動復元。
  - `@continuum-restore 'on'`: tmux サーバ起動時に前回セッションを自動復元する。

### 重要な制約

1. **`tmux-continuum` はプラグイン列の最後に置く。** continuum は `status-right` に自動保存フック（`#(.../continuum_save.sh)`）を追記して動作する。`catppuccin` / `tmux-colortag` / `tmux-cpu` など `status-right` を書き換えるプラグインを continuum より後にロードするとフックが消え、自動保存が無言で停止する（公式 README の Known Issues）。
2. **`set-environment -g TMUX_COLORTAG_TAG_ONLY yes` を設定する。** `tmux-colortag` は既定で `status-left` / `status-right` を loadavg+hostname へ上書きする。この環境変数でステータス行の上書きを抑止し、タブ色付け機能のみを有効化する。
3. **単一 tmux サーバを前提とする。** continuum は他サーバ稼働時、保存の相互上書きを避けるため自動保存フックの付与をスキップする。

### 手動操作

| 操作 | キー |
| --- | --- |
| 保存 | `prefix + Ctrl-s` |
| 復元 | `prefix + Ctrl-r` |
| 設定リロード | `prefix + r` |
| プラグイン導入 | `prefix + I` |

## 6. Ghostty × tmux 連携

`ghostty/config` の `command = zsh --login -c tmux` により、Ghostty の各サーフェス（ウィンドウ／タブ／スプリット）はログインシェル経由で PATH を確立したうえで tmux 上で起動する。

- 各サーフェスは共有 tmux サーバ上の個別セッションになる。
- サーバ初回起動時に tmux-continuum が前回セッションを自動復元する。
- **前提**: `tmux` が Ghostty の PATH 上にあること。`ghostty/config` では `command = zsh --login -c tmux` とし、ログインシェル経由で PATH を確立してから tmux を起動する。

## 7. 制約・禁止事項

- **絶対パス禁止**: ユーザー／マシン固有の絶対パス（`/home/<user>/...`）をコミットしない。`~` / `$HOME` / 相対パスを用いる。
- **シンボリックリンク**: `common-mk` へのリンクを実体ファイルへ置換しない（SSOT 遵守）。
- **禁止操作**（`opencode.jsonc` 準拠）: `rm` / `ssh` / `sudo`。
- **アーキテクチャ準拠**: 変更は dotfiles-core の [ARCHITECTURE.md](https://github.com/yohi/dotfiles-core/blob/master/docs/ARCHITECTURE.md) に従う。
