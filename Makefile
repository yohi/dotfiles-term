include _mk/core.mk
include _mk/help.mk
include _mk/term.mk

.PHONY: install setup install-term setup-term clean test

install: install-term ## Terminal 関連のインストール
setup: setup-term ## Terminal の設定適用

install-term: ## No-op: terminal dotfiles managed externally
	@echo "No-op: terminal dotfiles managed externally—see README for instructions"
clean: ## 生成物や一時ファイルを削除します
	@echo "==> Cleaning dotfiles-term"

test: ## テスト実行
	@echo "==> Testing dotfiles-term"
