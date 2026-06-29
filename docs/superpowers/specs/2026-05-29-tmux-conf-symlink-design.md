# 設計ドキュメント: tmux.conf シンボリックリンクの追加

## 概要
`dotfiles-term` コンポーネントにおいて、`tmux/tmux.conf` を `~/.tmux.conf` にシンボリックリンクとして適用する処理を `Makefile` (`_mk/term.mk`) に追加します。

## 目的
- `make setup` (実体は `setup-term`) 実行時に、tmux の設定が自動的に適用されるようにする。
- 既存のターミナル設定（WezTerm, Ghostty）と同様の管理フローに統合する。

## 設計詳細

### 統合先
- ファイル: `_mk/term.mk`
- ターゲット: `setup-term`

### 実装ロジック
既存の Ghostty の設定に倣い、以下の手順でシンボリックリンクを作成します：

1. **実ファイルのバックアップ**:
   - `~/.tmux.conf` が存在し、かつそれがシンボリックリンクではない（実ファイルである）場合、タイムスタンプ付きでバックアップを作成します。
   - バックアップ名形式: `~/.tmux.conf.bak.YYYYMMDD_HHMMSS`
2. **シンボリックリンクの作成**:
   - `ln -sfn` を使用して、リポジトリ内の `tmux/tmux.conf` から `~/.tmux.conf` へのリンクを強制的に作成/更新します。

### Makefile への追加コード（予定）
```makefile
	@# tmux
	@if [ -f "$(HOME)/.tmux.conf" ] && [ ! -L "$(HOME)/.tmux.conf" ]; then \
		TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
		mv "$(HOME)/.tmux.conf" "$(HOME)/.tmux.conf.bak.$$TIMESTAMP"; \
		echo "Backed up existing tmux config to .tmux.conf.bak.$$TIMESTAMP"; \
	fi
	ln -sfn "$(CURDIR)/tmux/tmux.conf" "$(HOME)/.tmux.conf"
```

## 検証計画

### 1. 正常系（新規リンク作成）
- `~/.tmux.conf` が存在しない状態で `make setup` を実行。
- `~/.tmux.conf` が `tmux/tmux.conf` への正しいリンクであることを確認。

### 2. バックアップ機能の検証
- `~/.tmux.conf` に適当な実ファイルを作成。
- `make setup` を実行。
- 元のファイルがバックアップされていること、および新しいリンクが作成されていることを確認。

### 3. 冪等性の検証
- 既にシンボリックリンクが存在する状態で `make setup` を再実行。
- エラーが発生せず、リンクが維持（または更新）されていることを確認。
