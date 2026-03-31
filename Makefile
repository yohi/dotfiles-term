include _mk/core.mk
include _mk/help.mk
-include _mk/term.mk

install: install-term ## Terminal 関連のインストール
setup: setup-term ## Terminal の設定適用

install-term:
	@echo "==> Installing dotfiles-term"

setup-term:
	@echo "==> Setting up dotfiles-term"
	ln -sfn "$(CURDIR)/wezterm.lua" "$(HOME)/.wezterm.lua"

clean: ## 生成物や一時ファイルを削除します
	@echo "==> Cleaning dotfiles-term"

test: ## テスト実行
	@echo "==> Testing dotfiles-term"
