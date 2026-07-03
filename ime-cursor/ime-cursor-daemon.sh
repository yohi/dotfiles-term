#!/usr/bin/env bash
#
# ime-cursor-daemon.sh
#
# IBus の入力エンジン切替 (GlobalEngineChanged) を監視し、日本語入力 (mozc) が
# 有効なときと直接入力 (xkb) のときで端末カーソル色を OSC 12 で切り替える。
# Vim の IME 連動カーソルを、シェルを含む端末全体へ拡張したもの。
#
#   検知: gdbus monitor で org.freedesktop.IBus の GlobalEngineChanged を購読。
#   反映: 制御端末へ OSC 12 を送出する。
#         制御端末が特定できない場合のみ、自ユーザの pts を列挙してフォールバックする。
#         (IBus のグローバルエンジンはセッション全体で 1 つだが、
#          実際に入力を受けているのはアクティブな端末のみ。)
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

# 制御端末を返す。取得できなければ空文字列。
# process substitution 等で stdin が端末でなくなっていても /dev/tty が制御端末を
# 指すため、まず /dev/tty を試す。テスト・手動呼び出し用に TTY 環境変数でも
# 上書き可能にする。
# shellcheck disable=SC2329 # invoked by broadcast_cursor_color
current_tty() {
	local tty
	if [ -w /dev/tty ]; then
		printf '%s' /dev/tty
		return 0
	fi
	if [ -n "${TTY:-}" ] && [ -w "${TTY:-}" ]; then
		printf '%s' "$TTY"
		return 0
	fi
	tty="$(tty 2>/dev/null || true)"
	[ -n "$tty" ] && [ -w "$tty" ] || return 0
	printf '%s' "$tty"
}
# 単一の write システムコールで seq を pts に書き込む。
# Bash 組み込み printf からのリダイレクトでも大抵は atomic だが、
# 確実性を高めるため /usr/bin/printf を優先する。
# 詰まった pts への書き込みが無限にブロックしないよう timeout 0.2 で保護する。
# shellcheck disable=SC2329 # invoked inside background jobs spawned by broadcast_cursor_color
write_seq_atomic() {
	local seq="$1"
	local pts="$2"
	if [ -x /usr/bin/printf ]; then
		timeout 0.2 /usr/bin/printf '%s' "$seq" >"$pts" 2>/dev/null || true
	else
		timeout 0.2 printf '%s' "$seq" >"$pts" 2>/dev/null || true
	fi
}
# OSC 12 (カーソル色設定) を制御端末へ送出する。
# /dev/pts/N への書き込みは端末出力として解釈され、シェルの stdin には注入されない。
# 環境変数 TTY で対象端末を明示できる。
broadcast_cursor_color() {
	local color="$1"
	local seq
	seq="$(printf '\033]12;%s\007' "$color")"


	local pts sent="" wpids=""
	pts="$(current_tty)"
	if [ -n "$pts" ]; then
		# 制御端末が取得できた場合は、そこだけに送る。
		# IBus のグローバルエンジンはセッション全体で 1 つだが、実際に
		# 入力を受けているのはアクティブな端末のみ。tmux 内部の pane や
		# 別セッションの pts まで送ると、Ghostty 経由で可視端末に届かない、
		# あるいは予期しない端末出力として流れる恐れがある。
		if [ -w "$pts" ]; then
			{ write_seq_atomic "$seq" "$pts" || true; } &
			wpids="$wpids $!"
			sent="$sent $pts"
		fi
	else
		# 制御端末が特定できない場合のみ、自ユーザの pts を列挙してフォールバック。
		local uid
		uid="$(id -u)"
		while IFS= read -r pts; do
			[ -n "$pts" ] || continue
			[ -w "$pts" ] || continue
			{ write_seq_atomic "$seq" "$pts" || true; } &
			wpids="$wpids $!"
			sent="$sent $pts"
		done < <(find /dev/pts -maxdepth 1 -type c -uid "$uid" ! -name ptmx 2>/dev/null)
	fi


	# shellcheck disable=SC2086 # wpids is intentionally space-separated PIDs
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
