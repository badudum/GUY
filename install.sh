#!/usr/bin/env bash
# Install GUY from this checkout.
#
#   ./install.sh                 everything: packages, commands, voice, autostart, Hyprland snippet
#   ./install.sh --no-voice      skip "Hey GUY" (no venv, no ~550 MB of speech models)
#   ./install.sh --no-packages   don't touch system packages (just check them)
#   ./install.sh --uninstall     remove what this script installed (keeps ~/.local/share/guy/memory.md)
#
# The commands are symlinked into ~/.local/bin, so `git pull` updates GUY in place; restart it after with
#   systemctl --user restart guy
# Safe to run again: every step skips what's already there.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
DATA="$HOME/.local/share/guy"
MODELS="$DATA/models"
UNITS="$HOME/.config/systemd/user"
HYPR="$HOME/.config/hypr"
COMMANDS=(guy guy-hook guy-voice guy-computer)

VOICE=1 PACKAGES=1 UNINSTALL=0
for arg in "$@"; do
    case "$arg" in
        --no-voice) VOICE=0 ;;
        --no-packages) PACKAGES=0 ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
    esac
done

bold() { printf '\n\033[1m%s\033[0m\n' "$*"; }
ok() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
ask() {
    local r=""
    if { : </dev/tty; } 2>/dev/null; then read -r -p "  $1 [y/N] " r </dev/tty || true
    else read -r -p "  $1 [y/N] " r || true; fi
    [[ $r == [yY]* ]]
}

# ---------- uninstall ----------
if ((UNINSTALL)); then
    bold "Removing GUY"
    systemctl --user disable --now guy.service guy-voice.service 2>/dev/null || true
    rm -f "$UNITS/guy.service" "$UNITS/guy-voice.service"
    systemctl --user daemon-reload 2>/dev/null || true
    for c in "${COMMANDS[@]}"; do
        if [[ -L $BIN/$c && $(readlink "$BIN/$c") == "$REPO/$c" ]]; then rm -f "$BIN/$c"; fi
    done
    if [[ -x $REPO/guy ]] && grep -q 'guy-hook' "$HOME/.claude/settings.json" 2>/dev/null; then
        warn "Claude Code hooks are still installed; remove them with: $REPO/guy --uninstall-hooks"
    fi
    rm -rf "$DATA/venv" "$MODELS"
    ok "removed the commands, autostart, venv and models"
    warn "kept $DATA (GUY's memory and schedule) and $HYPR/guy.lua / guy.conf; delete them if you like"
    exit 0
fi

# ---------- system packages ----------
bold "1/5  System packages"
# command or file -> Arch package
declare -A NEED=(
    [python3]=python [/usr/lib/libgtk4-layer-shell.so]=gtk4-layer-shell
    [wl-copy]=wl-clipboard [playerctl]=playerctl [wpctl]=wireplumber [pw-play]=pipewire
    [fd]=fd [grim]=grim [notify-send]=libnotify [xdg-open]=xdg-utils [wtype]=wtype
    [curl]=curl [unzip]=unzip
)
missing=()
for thing in "${!NEED[@]}"; do
    if [[ $thing == /* ]]; then [[ -e $thing ]] || missing+=("${NEED[$thing]}")
    else command -v "$thing" >/dev/null || missing+=("${NEED[$thing]}"); fi
done
python3 -c 'import gi, cairo; gi.require_version("Gtk", "4.0"); from gi.repository import Gtk' 2>/dev/null \
    || missing+=(python-gobject python-cairo gtk4)

if ((${#missing[@]} == 0)); then
    ok "all there"
elif command -v pacman >/dev/null; then
    echo "  needs: ${missing[*]}"
    if ((PACKAGES)); then
        sudo pacman -S --needed "${missing[@]}"
    else
        warn "skipped (--no-packages); install them with: sudo pacman -S --needed ${missing[*]}"
    fi
else
    warn "not Arch: install the equivalents of these with your package manager: ${missing[*]}"
fi
command -v wlrctl >/dev/null || warn "optional: wlrctl (AUR) lets GUY click for you: yay -S wlrctl"
command -v hyprctl >/dev/null || warn "GUY is made for Hyprland; hyprctl isn't installed"
if command -v claude >/dev/null; then
    ok "Claude Code found"
else
    warn "Claude Code isn't installed; Ask GUY needs it: curl -fsSL https://claude.ai/install.sh | bash"
fi

# ---------- commands ----------
bold "2/5  Commands in $BIN"
mkdir -p "$BIN" "$DATA"
for c in "${COMMANDS[@]}"; do
    chmod +x "$REPO/$c"
    if [[ -e $BIN/$c && ! -L $BIN/$c ]]; then
        warn "$BIN/$c is a real file, not a link: left alone"
        continue
    fi
    ln -sfn "$REPO/$c" "$BIN/$c"
    ok "$c -> $REPO/$c"
done
[[ :$PATH: == *:$BIN:* ]] || warn "$BIN isn't on your PATH; add it in your shell profile"

# ---------- voice ----------
bold "3/5  Voice (\"Hey GUY\")"
if ((VOICE)); then
    if [[ ! -x $DATA/venv/bin/python ]]; then
        python3 -m venv "$DATA/venv"
    fi
    "$DATA/venv/bin/pip" install --quiet --upgrade pip
    "$DATA/venv/bin/pip" install --quiet numpy vosk faster-whisper piper-tts
    ok "Python packages in $DATA/venv"

    mkdir -p "$MODELS/piper" "$MODELS/whisper"
    if [[ ! -d $MODELS/vosk-model-small-en-us-0.15 ]]; then
        tmp=$(mktemp -d)
        curl -fL --progress-bar -o "$tmp/vosk.zip" https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
        unzip -q "$tmp/vosk.zip" -d "$MODELS"
        rm -rf "$tmp"
    fi
    ok "wake word model (Vosk small-en)"
    piper_url=https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium
    for f in en_US-lessac-medium.onnx en_US-lessac-medium.onnx.json; do
        [[ -s $MODELS/piper/$f ]] || curl -fL --progress-bar -o "$MODELS/piper/$f" "$piper_url/$f"
    done
    ok "voice (Piper lessac)"
    "$DATA/venv/bin/python" -c "
from faster_whisper import WhisperModel
WhisperModel('base.en', device='cpu', compute_type='int8', download_root='$MODELS/whisper')" >/dev/null
    ok "speech to text (Whisper base.en)"
else
    ok "skipped (--no-voice); Ask GUY still works by typing"
fi

# ---------- autostart ----------
bold "4/5  Services"
mkdir -p "$UNITS"
services=(guy)
((VOICE)) && services+=(guy-voice)
for s in "${services[@]}"; do
    cat >"$UNITS/$s.service" <<EOF
[Unit]
Description=$s (GUY, the Glanceable Utility Yokai)
PartOf=graphical-session.target

[Service]
ExecStart=$BIN/$s
Restart=on-failure
RestartSec=3
EOF
done
systemctl --user daemon-reload
ok "systemd user services: ${services[*]} (Hyprland starts them at login, see step 5)"
if pgrep -f "$BIN/guy\$|$REPO/guy\$" >/dev/null && ! systemctl --user -q is-active guy.service; then
    warn "GUY is already running, started some other way: left alone (don't start it twice at login)"
elif [[ -n ${WAYLAND_DISPLAY:-} ]]; then
    systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE 2>/dev/null || true
    for s in "${services[@]}"; do systemctl --user restart "$s.service"; done
    ok "started"
fi

# ---------- Hyprland ----------
bold "5/5  Hyprland (blur, Alt+Space, Super+Space, start at login)"
mkdir -p "$HYPR"
file=""
if [[ -f $HYPR/hyprland.lua ]]; then
    cp "$REPO/hypr/guy.lua" "$HYPR/guy.lua"
    file="$HYPR/hyprland.lua" comment="--"
    line='dofile(os.getenv("HOME") .. "/.config/hypr/guy.lua")'
elif [[ -f $HYPR/hyprland.conf ]]; then
    cp "$REPO/hypr/guy.conf" "$HYPR/guy.conf"
    file="$HYPR/hyprland.conf" comment="#"
    line='source = ~/.config/hypr/guy.conf'
else
    warn "no Hyprland config found; the rules and key bindings are in $REPO/hypr/"
fi
if [[ -n $file ]]; then
    if grep -qF "$line" "$file"; then
        ok "already loaded from $(basename "$file")"
    elif grep -q 'guy --ask' "$file"; then
        ok "$(basename "$file") already sets GUY up by hand: left alone"
    elif ask "Load GUY's rules and keys from $(basename "$file")? (a backup is kept)"; then
        cp "$file" "$file.bak-guy"
        printf '\n%s GUY\n%s\n' "$comment" "$line" >>"$file"
        ok "added; backup at $file.bak-guy"
    else
        warn "skipped; add this line to $file yourself:  $line"
    fi
fi

bold "Done"
echo "  Alt+Space opens Ask GUY. Say \"Hey GUY\" or press Super+Space to talk."
echo "  To see your Claude Code sessions on the island:  guy --install-hooks"
