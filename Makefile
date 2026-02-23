REPO_ROOT ?= $(CURDIR)
.DEFAULT_GOAL := setup
include _mk/term.mk

.PHONY: link
link:
	@echo "==> Linking dotfiles-term"
	mkdir -p $(HOME)
	ln -sfn $(REPO_ROOT)/wezterm.lua $(HOME)/.wezterm.lua

.PHONY: setup
setup:
	@echo "==> Setting up dotfiles-term"
	$(MAKE) setup-term
