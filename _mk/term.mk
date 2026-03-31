setup-term:
	@echo "==> Setting up dotfiles-term"
	ln -sfn "$(CURDIR)/wezterm.lua" "$(HOME)/.wezterm.lua"
