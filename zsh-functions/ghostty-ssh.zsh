# Ghostty SSH Wrapper Function for Zsh / Bash
# Source this file in your ~/.zshrc or autoload from fpath.

ssh() {
    if [ "$TERM_PROGRAM" = "ghostty" ] || [ "$TERM" = "xterm-ghostty" ]; then
        local target_host=""
        for arg in "$@"; do
            if [[ "$arg" != -* ]]; then
                target_host="$arg"
                break
            fi
        done

        if [ -n "$target_host" ] && command ssh -o ConnectTimeout=2 -o BatchMode=yes "$target_host" "infocmp xterm-ghostty" >/dev/null 2>&1; then
            command ssh "$@"
        else
            TERM=xterm-256color command ssh "$@"
        fi
    else
        command ssh "$@"
    fi
}
