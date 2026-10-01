# GUY: the Glanceable Utility Yokai

A little Linux penguin who lives in a liquid-glass island at the top of the screen (Hyprland).
After [Coucou](https://github.com/Louis-CFM/coucou), rebuilt as a Python + GTK4 layer-shell
daemon to match the rest of the `glass*` tools. The penguin, the glass and all the code are new;
none of Coucou's reserved assets (Mochi, sounds, icon) are used.

| Do this | GUY does that |
|---|---|
| `Alt+Space` | grows into **Ask GUY** (apps, windows, math, `Alt+F` files, `Tab` ask Claude, `Ctrl+Enter` web) |
| `Esc` / click elsewhere | retracts straight back up into the top edge |
| Hover the top-centre edge | peeks out |
| Click the peek | opens the overview: your Claude Code sessions |
| Drag a file onto the island | opens Ask GUY with the file attached |
| Click the penguin | squish; three quick clicks and he's dizzy |

Claude Code sessions show up live (what they're reading, editing and running). A permission
request drops the island down with **Allow / Deny / Ask in terminal**. If GUY isn't running, or
nobody clicks, the hook prints nothing and Claude Code asks in the terminal as usual.

## Install

Made for Arch Linux + Hyprland. Ask GUY needs [Claude Code](https://claude.com/claude-code) (`claude`).

```sh
git clone https://github.com/badudum/GUY.git
cd GUY
./install.sh              # add --no-voice to skip "Hey GUY" and its ~550 MB of speech models
guy --install-hooks       # optional: show your Claude Code sessions on the island
```

The installer:

1. installs the missing system packages with `pacman` (GTK 4, gtk4-layer-shell, wl-clipboard,
   playerctl, PipeWire, fd, grim, wtype…), after asking for your password
2. links `guy`, `guy-hook`, `guy-voice` and `guy-computer` into `~/.local/bin`
3. sets up the voice: a venv in `~/.local/share/guy/venv` and the Vosk, Whisper and Piper models
4. adds the systemd user services `guy` and `guy-voice`
5. copies `hypr/guy.lua` (or `hypr/guy.conf` for a classic `hyprland.conf`) into `~/.config/hypr` and,
   if you say yes, loads it from your config. It adds the blur, `Alt+Space`, `Super+Space`, and starts
   GUY at login.

You can run it again safely. To update: `git pull && systemctl --user restart guy guy-voice`.
To remove it: `./install.sh --uninstall`.

## What GUY follows

| Source | On the island |
|---|---|
| Claude Code (hooks) | live steps, Allow / Deny, and Claude's final reply: its first line in the pill, the whole reply when you click the session |
| Browser downloads (`~/Downloads`) | name, size and speed while `.crdownload` / `.part` grows; "Downloaded", click to open |
| pacman / yay (`/var/log/pacman.log`) | syncing, downloading, each upgraded package, done or failed |
| Available updates (`hyde-shell system.update`, every 30 min) | "N updates available" in the overview, with an **Update** button |
| Anything else | `guy --activity ID --title … [--detail …] [--progress 0.4] [--done/--error/--clear] [--open PATH]` |

`guy --home` opens or closes the overview, if you want it on a key.

## Just say it

Ask GUY does these right away (Enter), without asking Claude:

| Say | Does |
|---|---|
| "lower sound", "turn it down a bit", "louder", "volume up by 20", "volume 30", "mute", "unmute" | changes the volume (`wpctl`) and shows the new level |
| "next song", "next music", "skip", "previous song", "pause", "play", "what's playing" | controls whatever is playing (`playerctl`: Spotify, browsers, mpv…) |
| "timer 25m", "set a timer for 10 minutes", "remind me in 5 minutes to call mom", "cancel timer" | a countdown on the pill; chimes, pops out and sends a notification when it's done |
| "update packages", "update my system", "upgrade everything", "install updates", "yay -Syu" | opens kitty running `yay -Syu`, left open afterwards (the overview's **Update** button does the same) |
| "lower sound and next song" | several at once |

Track changes pop the pill with the song; the overview has a now-playing row with ⏮ ⏯ ⏭.

## Voice

Say **"Hey GUY"**, or press **Super+Space**, then talk. The pill shows your words as you speak. GUY waits for you to finish
(longer if the sentence is left hanging), and after answering it keeps listening for a follow-up without
"Hey GUY"; say "thanks" or "never mind", or just stay quiet, and it goes back to sleep. "Open Spotify",
"switch to the terminal", "open downloads" and "open github.com" work too. GUY stops listening when you do, does it
(the same commands as above, instantly), or asks Claude and reads the answer aloud.
Everything runs on this laptop; no audio leaves it.

| Piece | What | Where |
|---|---|---|
| Wake word | Vosk small-en, a tiny grammar around "hey guy" (~6% of one core) | `~/.local/share/guy/models/vosk-model-small-en-us-0.15` |
| Speech to text | faster-whisper `base.en`, int8 on the CPU (~0.8 s) | `~/.local/share/guy/models/whisper` |
| Voice | Piper `en_US-lessac-medium` | `~/.local/share/guy/models/piper` |

The Python packages live in `~/.local/share/guy/venv` (not the system Python). `guy-voice` is
the helper process (~480 MB with the models loaded), started at login next to `guy`.

- `guy --voice off` (or the **Hey GUY** button in the overview) closes the microphone entirely;
  Super+Space still works. `guy --voice on` turns it back on. The choice is remembered.
- While "Hey GUY" is on, the microphone is open, so the bar's privacy indicator shows it.
- Closing the Ask panel (Esc) also stops GUY talking.

## Files

- `guy`: the daemon (`guy`, `guy --ask`, `guy --install-hooks`, `guy --uninstall-hooks`)
- `guy-hook`: the relay Claude Code runs; talks to `$XDG_RUNTIME_DIR/guy.sock`
- `guy-voice`: listening and speaking (runs in `~/.local/share/guy/venv`); `$XDG_RUNTIME_DIR/guy-voice.sock`
- `guy-computer`: screenshots, clicks and typing for GUY's assistant (needs `wtype`, and `wlrctl` from the AUR to click)
- `install.sh`: the installer (see [Install](#install))
- `hypr/`: Hyprland layer rules, key bindings and autostart, for the Lua and the classic config

## Claude Code hooks

```sh
guy --install-hooks     # shows the diff, backs up ~/.claude/settings.json, writes on "y"
guy --uninstall-hooks   # removes only GUY's entries
```

Ask GUY's own `claude -p` calls run with `--setting-sources ""`, so they never report to GUY.
