#!/usr/bin/env bash
# Ghostty SSH Wrapper Script
# Automatically checks if xterm-ghostty is supported on the remote host.
# If xterm-ghostty exists on the remote host, connects normally.
# Otherwise, falls back to TERM=xterm-256color to prevent double-echo issues without modifying the remote server.

if [ "$TERM_PROGRAM" = "ghostty" ] || [ "$TERM" = "xterm-ghostty" ]; then
    # Extract target host (first argument not starting with -)
    TARGET_HOST=""
    for arg in "$@"; do
        if [[ "$arg" != -* ]]; then
            TARGET_HOST="$arg"
            break
        fi
    done

    if [ -n "$TARGET_HOST" ] && command ssh -o ConnectTimeout=2 -o BatchMode=yes "$TARGET_HOST" "infocmp xterm-ghostty" >/dev/null 2>&1; then
        exec command ssh "$@"
    else
        exec env TERM=xterm-256color command ssh "$@"
    fi
else
    exec command ssh "$@"
fi
