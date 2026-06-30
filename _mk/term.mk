setup-term: ## ターミナルの設定をシステムに適用します
	@echo "==> Setting up dotfiles-term"
	@# WezTerm
	ln -sfn "$(CURDIR)/wezterm.lua" "$(HOME)/.wezterm.lua"
	@# Ghostty
	mkdir -p "$(HOME)/.config/ghostty"
	@if [ -f "$(HOME)/.config/ghostty/config" ] && [ ! -L "$(HOME)/.config/ghostty/config" ]; then \
		TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
		mv "$(HOME)/.config/ghostty/config" "$(HOME)/.config/ghostty/config.bak.$$TIMESTAMP"; \
		echo "Backed up existing Ghostty config to config.bak.$$TIMESTAMP"; \
	fi
	ln -sfn "$(CURDIR)/ghostty/config" "$(HOME)/.config/ghostty/config"
	@# Tilix
	@if command -v dconf >/dev/null 2>&1; then \
		echo "Loading Tilix settings via dconf..."; \
		dconf load /com/gexperts/Tilix/ < "$(CURDIR)/tilix/tilix.dconf"; \
	else \
		echo "Warning: dconf command not found, skipping Tilix setup"; \
	fi
	@# tmux
	@if [ -f "$(HOME)/.tmux.conf" ] && [ ! -L "$(HOME)/.tmux.conf" ]; then \
		TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
		mv "$(HOME)/.tmux.conf" "$(HOME)/.tmux.conf.bak.$$TIMESTAMP"; \
		echo "Backed up existing tmux config to .tmux.conf.bak.$$TIMESTAMP"; \
	fi
	ln -sfn "$(CURDIR)/tmux/tmux.conf" "$(HOME)/.tmux.conf"
	@if [ ! -d "$(HOME)/.tmux/plugins/tpm" ]; then \
		echo "Installing Tmux Plugin Manager (TPM)..."; \
		mkdir -p "$(HOME)/.tmux/plugins"; \
		git clone https://github.com/tmux-plugins/tpm "$(HOME)/.tmux/plugins/tpm"; \
		echo "Installing tmux plugins via TPM..."; \
		"$(HOME)/.tmux/plugins/tpm/bin/install_plugins"; \
	fi

