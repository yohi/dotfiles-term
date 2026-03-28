# Orchestrator core configuration
# Note: These are symlinked from ../../common-mk/ when managed by dotfiles-core
-include _mk/core.mk
-include _mk/help.mk

# Component-specific logic

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
	ln -sfn "$(REPO_ROOT)/wezterm.lua" "$(HOME)/.wezterm.lua"

setup: link
	@echo "==> Setting up dotfiles-term"
	$(MAKE) setup-term
