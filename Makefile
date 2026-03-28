# Orchestrator core configuration
# Note: These are symlinked from ../../common-mk/ when managed by dotfiles-core
-include _mk/core.mk
-include _mk/help.mk

# Component-specific logic





REPO_ROOT ?= $(CURDIR)
include _mk/term.mk

.PHONY: all clean test link setup

all: setup

clean: ## 生成物や一時ファイルを削除します
	@echo "==> Cleaning dotfiles-term"

test:
	@echo "==> Testing dotfiles-term"

link: ## シンボリックリンクを展開し、dotfiles を配置します
	@echo "==> Linking dotfiles-term"
	ln -sfn "$(REPO_ROOT)/wezterm.lua" "$(HOME)/.wezterm.lua"

setup: link
	@echo "==> Setting up dotfiles-term"
	$(MAKE) setup-term
