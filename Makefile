include _mk/core.mk
include _mk/help.mk
include _mk/term.mk

.PHONY: install setup install-term install-herdr setup-term clean test

install: install-term install-herdr ## Terminal 関連のインストール
setup: setup-term ## Terminal の設定適用

install-term: ## ==> No-op: terminal dotfiles managed externally
	@echo "==> No-op: terminal dotfiles managed externally—see README for instructions"

install-herdr: ## Herdr をインストールします
	@echo "==> Installing Herdr"
	@if ! command -v herdr >/dev/null 2>&1; then \
		curl -fsSL https://herdr.dev/install.sh | sh; \
	else \
		echo "Herdr is already installed."; \
	fi

clean: ## 生成物や一時ファイルを削除します
	@echo "==> Cleaning dotfiles-term"

test: ## テスト実行
	@echo "==> Testing dotfiles-term"
