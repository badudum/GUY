# GUY: the Glanceable Utility Yokai

A little Linux penguin who lives in a liquid-glass island at the top of the screen (Hyprland).
After [Coucou](https://github.com/Louis-CFM/coucou), rebuilt as a Python + GTK4 layer-shell
daemon to match the rest of the `glass*` tools. The penguin, the glass and all the code are new;
none of Coucou's reserved assets (Mochi, sounds, icon) are used.

| Do this | GUY does that |
|---|---|
| `Alt+Space` | grows into **Ask GUY** (apps, windows, math, stock prices, `Alt+F` files, `Tab` ask GUY, `Ctrl+Enter` web) |
| `Esc` / click elsewhere | retracts straight back up into the top edge |
| Hover the top-centre edge | peeks out |
| Click the peek | opens the overview: Claude Code sessions, activity, routines, your stocks, the news |
| Drag the pill down | pulls GUY out: he floats on your screen, over every desktop ([below](#pull-guy-out)) |
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

## Pull GUY out

Hover the top edge so the pill peeks out, grab it and drag down. The glass stretches into a drop on a
thinning neck; let go early and it springs back in, pull far enough and the neck snaps and GUY floats
free as a little glass orb. He stays on top of everything: every desktop, fullscreen apps, and orbit's
desktop cube.

| Floating GUY | |
|---|---|
| Drag him | anywhere on the screen; he follows a little behind and wobbles like a drop |
| Click him | selects him (his rim lights up) and shows what you can do |
| `Esc` while selected | he rises to the top at the size he is (orb or open panel); the edge catches him with a liquid bridge, and he's drawn up into it |
| Drag him toward the top edge | within about 60 px the edge reaches for him and joins him with a liquid neck that widens as he gets closer (pull away and it thins and pinches off); let go while joined and he attaches and is absorbed |
| Double-click | the overview, opening out of the orb |
| `Alt+Space` | Ask GUY grows out of the orb (below it, or above it near the bottom of the screen) |
| Something happening (a timer, a download, Claude done) | it pops out of the orb as a pill, as it would from the top edge |

An open panel (the overview, Ask GUY, an approval) comes out the same way: grab its top strip, by the
penguin or the title, and pull down. It stretches, tears off the edge and floats, still open; drag it by
the same strip. `Esc` closes it into the orb, and `Esc` again sends him home.

`guy --float` pops him out (or puts him back) from a key binding. He remembers where he floated and
whether he was out, across restarts.

## Ask GUY

`Alt+Space`, then type. Apps, open windows and math show up as you type; `Enter` opens the top one.

- **Ask GUY anything** with `Tab`. GUY is Claude Code with hands: it can run commands, edit files, browse
  the web, use the screen (`guy-computer`) and remember things about you (`~/.local/share/guy/memory.md`).
  Anything risky (deleting, `sudo`, installing, sending something to someone) waits for your
  **Allow / Deny** on the island first.
- **It's a chat.** Your question stays in the panel as a bubble with GUY's answer under it, and the text
  field clears so you can type a follow-up and press `Enter`. `Esc` goes back to searching (the
  conversation is still there if you press `Tab` again); `Esc` again closes it. `Ctrl+Shift+C` copies the
  last answer.
- **Stock prices**: type "google stock", "GOOGL price", "what's tesla trading at", "royal bank share price"
  or "$NVDA" for the live price, change and day range of the best matches. `Enter` opens the chart, and
  **Add to my stocks** puts it in the overview.
- `Alt+F` searches your files, `Ctrl+Enter` searches the web, and dropping a file on the island asks
  GUY about it.

## The overview

Click the peek (or run `guy --home`). Every row can be clicked. A row with something to open (a
Claude Code reply, a routine's report, a downloaded file) opens it. Any other row expands in place
to show everything about it, with its buttons.

| Row | Click to |
|---|---|
| Claude Code sessions | read Claude's last reply, or see its folder and what it's doing |
| Downloads, package runs, timers, tasks | open the file, or see the full status; **Cancel** a timer |
| Reminders and routines | see the full text, next run and last run; **Run now**, **Last result**, **Cancel** |
| Stocks | each of your stocks with price, change and day range; click one for its chart |
| News | the latest headlines; click one to read it, **Brief me** to have GUY sum them up |
| Updates | the package list; **Update** opens kitty running `yay -Syu` |

### Stocks

Prices come from Yahoo Finance (no account or key needed), every 10 minutes and whenever you open the
overview on prices older than 2 minutes. Add stocks from Ask GUY ("google stock", then **Add to my
stocks**), or list them in `~/.config/guy/stocks.json`:

```json
{"watch": ["GOOGL", "AAPL", "SHOP.TO", "BTC-USD"]}
```

### News

The newest headlines from CBC Top Stories and BBC World, fetched every 30 minutes. Choose your own RSS
or Atom feeds, or switch it off with `"feeds": []`, in `~/.config/guy/news.json`:

```json
{"feeds": ["https://www.cbc.ca/webfeed/rss/rss-topstories", "https://feeds.npr.org/1001/rss.xml"], "count": 6}
```

## Reminders and routines

Ask GUY ("remind me at 5pm to call mom", "every weekday at 8:30 give me a morning brief with the weather and
my calendar"), or use the command line:

```sh
guy --remind "17:00" "call mom"                                   # a reminder: chime, notification, spoken
guy --task "08:30" "morning brief: weather and my calendar" --every weekdays   # GUY does it and reports back
guy --schedule                                                     # list them
guy --unschedule 2                                                 # remove one
```

`WHEN` is "YYYY-MM-DD HH:MM", "17:00", "5pm", "tomorrow 9:00", "+25m" or "+2h"; `--every` is daily, weekdays,
weekly or hourly. A routine's result pops up on the island when it's done and stays under **Last result**
in the overview.

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
| "google stock price", "GOOGL price", "$TSLA" | the price card (by voice, GUY says the price and today's change) |
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
the helper process, started at login next to `guy`. Only the wake word stays loaded (~220 MB):
Whisper and Piper load the moment you start talking, ready before you've finished, and leave
memory again after 10 minutes without use.

- `guy --voice off` (or the **Hey GUY** button in the overview) closes the microphone entirely;
  Super+Space still works. `guy --voice on` turns it back on. The choice is remembered.
- While "Hey GUY" is on, the microphone is open, so the bar's privacy indicator shows it.
- Closing the Ask panel (Esc) also stops GUY talking.

## Performance

GUY is meant to sit there all day without costing anything: ~0.3% of one core when idle.

- The glass is only redrawn when its shape changes, not every time the penguin moves.
- GUY's surface covers the screen (so he can float anywhere) but takes clicks only on his glass; only
  the parts that change are redrawn.
- The penguin draws at 30 fps when he's just breathing, and stops entirely while hidden.
- The overview's rows are only rebuilt while it's open, and only when something on them changed.
- The app list is read once and again only when apps are installed or removed.
- The terminal-prompt check looks at process names only, unless `sudo`, `pacman` or `yay` is running.

## Files

- `guy`: the daemon (`guy`, `guy --ask`, `guy --install-hooks`, `guy --uninstall-hooks`)
- `guy-hook`: the relay Claude Code runs; talks to `$XDG_RUNTIME_DIR/guy.sock`
- `guy-voice`: listening and speaking (runs in `~/.local/share/guy/venv`); `$XDG_RUNTIME_DIR/guy-voice.sock`
- `guy-computer`: screenshots, clicks and typing for GUY's assistant (needs `wtype`, and `wlrctl` from the AUR to click)
- `install.sh`: the installer (see [Install](#install))
- `hypr/`: Hyprland layer rules (blur, and `order = 100` so a floating GUY stays above other overlays),
  key bindings and autostart, for the Lua and the classic config

## Settings files

| File | What |
|---|---|
| `~/.config/guy/stocks.json` | your stocks (`{"watch": [...]}`) |
| `~/.config/guy/news.json` | news feeds and how many headlines (`{"feeds": [...], "count": 6}`) |
| `~/.local/share/guy/schedule.json` | reminders and routines, with each routine's last result |
| `~/.local/share/guy/memory.md` | what GUY remembers about you; edit it freely |
| `~/.local/state/guy/voice.json` | whether "Hey GUY" is on |
| `~/.local/state/guy/float.json` | whether GUY is pulled out, and where |

## Claude Code hooks

```sh
guy --install-hooks     # shows the diff, backs up ~/.claude/settings.json, writes on "y"
guy --uninstall-hooks   # removes only GUY's entries
```

Ask GUY's own `claude -p` calls run with `--setting-sources ""`, so they never report to GUY.
