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
	@if command -v tic >/dev/null 2>&1; then \
		echo "Installing xterm-ghostty terminfo..."; \
		mkdir -p "$(HOME)/.terminfo"; \
		tic -o "$(HOME)/.terminfo" -x "$(CURDIR)/ghostty/xterm-ghostty.terminfo" || echo "Warning: Failed to install xterm-ghostty terminfo"; \
	else \
		echo "Warning: tic command not found, skipping terminfo setup"; \
	fi
	chmod +x "$(CURDIR)/ghostty/ghostty-ssh-wrapper.sh"
	mkdir -p "$(HOME)/.local/bin"
	ln -sfn "$(CURDIR)/ghostty/ghostty-ssh-wrapper.sh" "$(HOME)/.local/bin/ghostty-ssh-wrapper.sh"
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
	fi
	@if command -v tmux >/dev/null 2>&1 && [ -f "$(HOME)/.tmux/plugins/tpm/bin/install_plugins" ]; then \
		echo "Installing tmux plugins via TPM..."; \
		"$(HOME)/.tmux/plugins/tpm/bin/install_plugins" || true; \
	fi

	@# IME 連動カーソル色デーモン (IBus GlobalEngineChanged -> OSC 12)
	mkdir -p "$(HOME)/.local/bin"
	chmod +x "$(CURDIR)/ime-cursor/ime-cursor-daemon.sh"
	ln -sfn "$(CURDIR)/ime-cursor/ime-cursor-daemon.sh" "$(HOME)/.local/bin/ime-cursor-daemon.sh"
	mkdir -p "$(HOME)/.config/systemd/user"
	ln -sfn "$(CURDIR)/ime-cursor/ime-cursor.service" "$(HOME)/.config/systemd/user/ime-cursor.service"
	@if command -v systemctl >/dev/null 2>&1; then \
		systemctl --user daemon-reload || true; \
		systemctl --user enable --now ime-cursor.service || echo "Warning: could not enable ime-cursor.service (user systemd session not available?)"; \
	else \
		echo "Warning: systemctl not found, skipping ime-cursor.service setup"; \
	fi
