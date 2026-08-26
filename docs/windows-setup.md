# Windows setup

What `install.ps1` runs, and the pieces around it. Setup itself is in the [README](../README.md#windows); hand-written notes from setting machines up live in [windows.md](windows.md).

## What it runs

| Script | Does |
| --- | --- |
| `bootstrap.ps1` | Writes a `$PROFILE` that sources `windows/*.ps1` from the clone |
| `setup-nvim.ps1` | Links `.config/nvim` → `%LOCALAPPDATA%\nvim` |
| `setup-wezterm.ps1` | Links `.wezterm.lua` → `%USERPROFILE%` |
| `setup-komorebi.ps1` | Links `.config/komorebi/*.json` → `%USERPROFILE%\.config` |
| `setup-whkdrc.ps1` | Links `.config/whkdrc` → `%USERPROFILE%\.config` |
| `setup-yasb.ps1` | Links `.yasb` → `%USERPROFILE%` |
| `setup-defaults.ps1` | Key repeat and the persistent `PROMPT` variable |

Each runs standalone too. Linking follows the same rule as `make` on Unix: a
link we made before is replaced, and anything else already at the destination is
left alone with a warning.

`setup-ahk.ps1` links `ahk/*.ahk` into the Startup folder so they run at login —
remapping Windows to Ctrl, switching input language, and a few shortcuts.
`install.ps1` does **not** call it, since whether those should start
automatically is a choice rather than part of setting the machine up.

The profile is a loader, not a copy: a `git pull` takes effect on the next
shell. Edit `windows/*.ps1` here rather than `$PROFILE`, which is overwritten.
Any profile you already had is copied to `$PROFILE.bak` first, once.

## Other pieces

The window manager is [komorebi](https://github.com/LGUG2Z/komorebi) with
[whkd](https://github.com/LGUG2Z/whkd) for hotkeys and
[yasb](https://github.com/amnweb/yasb) for the status bar;
`powershell/komorebi-start.ps1` and `komorebi-stop.ps1` (plus `.bat` wrappers)
drive it.

`manage_rules` in `.config/komorebi/.komorebi.json` force-manages windows
komorebi would otherwise leave floating. Scope those rules as tightly as the
application allows: a bare `Exe` rule matches *every* window of that process,
so an app whose plugin or dialog windows are separate top-level windows would
get all of them tiled too. A nested array is a composite rule — every entry in
it has to match — which is how the UAD Console entry keeps to the main window.
Note that `manage_rules` wins over `ignore_rules`, so a too-broad force-manage
rule cannot be walked back with an ignore rule; narrow the rule itself.

`ignore_rules` is for the other direction: windows komorebi *would* tile on its
own but shouldn't. The UAD entry is the negative of its manage rule — every
window of that process whose title is not the Console's — so the plugin editor
windows stay floating however they are titled. A window already on screen when
the config is reloaded keeps its current state; reopen it to re-evaluate.

`komorebic visible-windows` prints the exe, title and class of what is on
screen, which is where the ids in those rules come from. Matching is exact for
`Equals`, so a wrong id is a silent no-op. Changes need
`komorebic reload-configuration`.

There is no `Brewfile` equivalent: those tools, plus whatever
`windows/path.ps1` expects (scoop, direnv, poetry), have to be installed by
hand.

CI runs on Linux and macOS only. The PowerShell scripts are parsed and linted
with PSScriptAnalyzer on every push, but nothing exercises them on Windows —
changes there are worth trying on a real machine.

[Back to the README](../README.md).
