REPO_ROOT ?= $(CURDIR)
.DEFAULT_GOAL := setup
include _mk/term.mk

.PHONY: setup
setup: setup-term
	@echo "==> Setting up dotfiles-term"
