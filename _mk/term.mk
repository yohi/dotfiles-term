setup-term: ## ターミナルの設定をシステムに適用します
	@echo "==> Setting up dotfiles-term"
	@# WezTerm
	ln -sfn "$(CURDIR)/wezterm.lua" "$(HOME)/.wezterm.lua"
	@# Ghostty
	mkdir -p "$(HOME)/.config/ghostty"
	@if [ -f "$(HOME)/.config/ghostty/config" ] && [ ! -L "$(HOME)/.config/ghostty/config" ]; then \
		mv "$(HOME)/.config/ghostty/config" "$(HOME)/.config/ghostty/config.bak"; \
		echo "Backed up existing Ghostty config to config.bak"; \
	fi
	ln -sfn "$(CURDIR)/ghostty/config" "$(HOME)/.config/ghostty/config"
	@# Tilix
	@if command -v dconf >/dev/null 2>&1; then \
		echo "Loading Tilix settings via dconf..."; \
		dconf load /com/gexperts/Tilix/ < "$(CURDIR)/tilix/tilix.dconf"; \
	else \
		echo "Warning: dconf command not found, skipping Tilix setup"; \
	fi
