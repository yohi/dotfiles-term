# tmux.conf シンボリックリンク追加 実装プラン

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `tmux/tmux.conf` を `~/.tmux.conf` にシンボリックリンクとして貼る処理を `_mk/term.mk` に追加し、既存の実ファイルがある場合はバックアップを作成するようにします。

**Architecture:** `_mk/term.mk` の `setup-term` ターゲットを修正し、Ghostty の設定で使われているバックアップロジックを tmux 用に適用します。

**Tech Stack:** GNU Make, Shell

---

### Task 1: Makefile の修正

**Files:**
- Modify: `_mk/term.mk`

- [ ] **Step 1: tmux 用のシンボリックリンク作成とバックアップロジックを追加**

`_mk/term.mk` の末尾（または適切な位置）に以下のコードを挿入します。

```makefile
	@# tmux
	@if [ -f "$(HOME)/.tmux.conf" ] && [ ! -L "$(HOME)/.tmux.conf" ]; then \
		TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
		mv "$(HOME)/.tmux.conf" "$(HOME)/.tmux.conf.bak.$$TIMESTAMP"; \
		echo "Backed up existing tmux config to .tmux.conf.bak.$$TIMESTAMP"; \
	fi
	ln -sfn "$(CURDIR)/tmux/tmux.conf" "$(HOME)/.tmux.conf"
```

### Task 2: 動作検証 (新規作成)

- [ ] **Step 1: 既存のリンクがない状態で実行**

`~/.tmux.conf` が存在しないことを確認してから `make setup` を実行します。

```bash
rm -f ~/.tmux.conf
make setup
ls -l ~/.tmux.conf
```

**Expected:** `~/.tmux.conf` が `.../tmux/tmux.conf` へのシンボリックリンクとして作成されていること。

### Task 3: 動作検証 (バックアップ)

- [ ] **Step 1: 実ファイルが存在する状態で実行**

`~/.tmux.conf` にダミーの実ファイルを作成してから `make setup` を実行します。

```bash
rm -f ~/.tmux.conf
echo "old config" > ~/.tmux.conf
make setup
ls -l ~/.tmux.conf*
```

**Expected:**
- `~/.tmux.conf` がシンボリックリンクに更新されていること。
- `~/.tmux.conf.bak.YYYYMMDD_HHMMSS` という名前のファイルが存在し、内容が "old config" であること。

### Task 4: 冪等性の検証

- [ ] **Step 1: 連続実行**

既にリンクがある状態で再度 `make setup` を実行します。

```bash
make setup
ls -l ~/.tmux.conf
```

**Expected:** エラーが発生せず、リンクが維持されていること。バックアップが新たに作成されないこと（既存がリンクのため）。

### Task 5: 完了

- [ ] **Step 1: 不要なバックアップファイルの削除 (任意)**

検証用に作成したバックアップファイルがある場合は削除します。

- [ ] **Step 2: 変更のコミット**

```bash
git add _mk/term.mk
git commit -m "feat(tmux): add symlink rule for tmux.conf with backup logic"
```
