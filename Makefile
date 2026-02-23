REPO_ROOT ?= $(CURDIR)
.DEFAULT_GOAL := setup
include _mk/term.mk

.PHONY: all clean test link setup

all: setup

clean:
	@echo "==> Cleaning dotfiles-term"

test:
	@echo "==> Testing dotfiles-term"

link:
	@echo "==> Linking dotfiles-term"
	mkdir -p $(HOME)
	ln -sfn $(REPO_ROOT)/wezterm.lua $(HOME)/.wezterm.lua

setup:
	@echo "==> Setting up dotfiles-term"
	$(MAKE) setup-term
