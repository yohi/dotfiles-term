#!/usr/bin/env bash
#
# ime-cursor-daemon.sh
#
# IBus の入力エンジン切替 (GlobalEngineChanged) を監視し、日本語入力 (mozc) が
# 有効なときと直接入力 (xkb) のときで端末カーソル色を OSC 12 で切り替える。
# Vim の IME 連動カーソルを、シェルを含む端末全体へ拡張したもの。
#
#   検知: gdbus monitor で org.freedesktop.IBus の GlobalEngineChanged を購読。
#   反映: 自ユーザが所有する擬似端末 (/dev/pts/*) へ OSC 12 をブロードキャスト。
#         (IBus のグローバルエンジンはセッション全体で 1 つのため、全端末へ反映するのが整合的)
#
# 環境変数で色を上書き可能:
#   IME_ON_COLOR  (default: #F92672)  日本語入力  (mozc-jp / mozc-on)
#   IME_OFF_COLOR (default: #F8F8F2)  直接入力    (xkb:* / mozc-off)
#
set -euo pipefail

IME_ON_COLOR="${IME_ON_COLOR:-#F92672}"
IME_OFF_COLOR="${IME_OFF_COLOR:-#F8F8F2}"

log() {
	printf '%s ime-cursor: %s\n' "$(date '+%H:%M:%S')" "$*" >&2
}

# 現在の IBus エンジン名から適用すべきカーソル色を決定する。
#   mozc-off … mozc の直接入力モード → OFF 扱い
#   mozc*    … mozc-jp / mozc-on = 日本語入力 → ON
#   それ以外 … xkb:* などキーボードレイアウト = 直接入力 → OFF
color_for_engine() {
	case "$1" in
	mozc-off) printf '%s' "$IME_OFF_COLOR" ;;
	mozc*) printf '%s' "$IME_ON_COLOR" ;;
	*) printf '%s' "$IME_OFF_COLOR" ;;
	esac
}

# OSC 12 (カーソル色設定) を自ユーザの全 pts へ送出する。
# /dev/pts/N への書き込みは端末出力として解釈され、シェルの stdin には注入されない。
broadcast_cursor_color() {
	local color="$1"
	local seq
	seq="$(printf '\033]12;%s\007' "$color")"

	# /proc/*/environ の読み取りは特定プロセス状態 (D-state 等) でブロックし得るため
	# 使わない。devpts の所有者は端末を開いた本人なので、find で自ユーザの
	# pts を直接列挙する。IBus のグローバルエンジンはセッション全体で 1 つなので、
	# 自分の全端末へ反映するのが整合的。
	local uid pts sent="" wpids=""
	uid="$(id -u)"
	while IFS= read -r pts; do
		[ -n "$pts" ] || continue
		[ -w "$pts" ] || continue
		# 端末が出力を吸えない (ハングした端末) 場合に write が無限ブロック
		# しないよう timeout 付きで、かつ pts ごとに並列送出する。
		{ printf '%s' "$seq" 2>/dev/null | timeout 0.2 tee -- "$pts" >/dev/null 2>&1 || true; } &
		wpids="$wpids $!"
		sent="$sent $pts"
	done < <(find /dev/pts -maxdepth 1 -type c -uid "$uid" ! -name ptmx 2>/dev/null)
	# 明示した書き込みプロセスのみ待機 (gdbus monitor 等は待たない)
	[ -n "$wpids" ] && wait $wpids 2>/dev/null || true

	if [ -n "$sent" ]; then
		log "applied $color to:$sent"
	else
		log "applied $color (no writable pts found)"
	fi
}

apply_engine() {
	local engine="$1"
	[ -n "$engine" ] || return 0
	broadcast_cursor_color "$(color_for_engine "$engine")"
}

# IBus のプライベートバスアドレスを解決する。
# `ibus address` が使えないセッション (DISPLAY 未設定等) では
# ~/.cache/ibus/dbus-* ソケットから最新のものをフォールバックで拾う。
resolve_ibus_address() {
	local a sock
	a="$(ibus address 2>/dev/null || true)"
	case "$a" in
	unix:*)
		printf '%s' "$a"
		return 0
		;;
	esac

	sock="$(find "${XDG_CACHE_HOME:-$HOME/.cache}/ibus" -maxdepth 1 -name 'dbus-*' -type s -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n1 | cut -d' ' -f2- || true)"
	if [ -n "$sock" ]; then
		printf 'unix:path=%s' "$sock"
		return 0
	fi
	return 1
}

main() {
	log "starting (ON=$IME_ON_COLOR OFF=$IME_OFF_COLOR)"

	local addr line rest engine
	while true; do
		if ! addr="$(resolve_ibus_address)"; then
			log "ibus address not found; retrying in 3s"
			sleep 3
			continue
		fi

		# 起動直後に現在のエンジンを反映する。
		apply_engine "$(ibus engine 2>/dev/null || true)"

		log "monitoring GlobalEngineChanged via ${addr%%,*}"
		# gdbus monitor はブロッキング。ibus 再起動等で終了したら再接続する。
		while IFS= read -r line; do
			case "$line" in
			*GlobalEngineChanged*)
				# 例: /org/freedesktop/IBus: org.freedesktop.IBus.GlobalEngineChanged ('mozc-jp',)
				rest="${line#*\'}"
				engine="${rest%%\'*}"
				apply_engine "$engine"
				;;
			esac
		done < <(gdbus monitor --address "$addr" --dest org.freedesktop.IBus --object-path /org/freedesktop/IBus 2>/dev/null)

		log "monitor ended; reconnecting in 2s"
		sleep 2
	done
}

main "$@"
