# ============================================================================
# GrimalDev/dotfiles — Homebrew dependency manifest
# ============================================================================
# Scope: ONLY the tools the configs tracked in this repo actually need.
# This is deliberately NOT a `brew bundle dump` of the whole machine.
#
#   brew bundle install --file="$HOME/.config/Brewfile"
#
# Third-party taps below require trust on recent Homebrew; install.sh runs
# `brew trust <tap>` first. See: https://docs.brew.sh/Tap-Trust
# ============================================================================

# --- taps (must precede the packages that live in them) ----------------------
tap "felixkratz/formulae"   # sketchybar, borders
tap "joshmedeski/sesh"      # sesh
tap "nikitabobko/tap"       # aerospace

# --- shell / prompt / fuzzy navigation --------------------------------------
# fish/config.fish + fish/fish_plugins + starship.toml
brew "fish"
brew "starship"
brew "zoxide"
brew "fzf"
brew "fd"
brew "ripgrep"
brew "bat"
brew "eza"                  # NOTE: config aliases `ls|ll|lt` -> exa. `exa` is
                            # removed from Homebrew; install.sh adds an
                            # `exa` -> `eza` shim unless you update config.fish.
brew "grc"                  # fish alias `tail` -> grc
brew "jq"                   # fish `brew` function pipes formulae API through jq
brew "make"                 # sketchybar/helpers build

# --- editor -----------------------------------------------------------------
brew "neovim"               # EDITOR/VISUAL + `ee` binding in fish/config.fish

# --- terminal / multiplexer / file manager ----------------------------------
brew "tmux"
brew "yazi"                 # config + vendored plugins are tracked
brew "ffmpeg"               # yazi video previews
brew "sevenzip"             # yazi archive previews
brew "poppler"              # yazi pdf previews

# --- dashboards / status ----------------------------------------------------
brew "lazygit"
brew "lazydocker"
brew "btop"
brew "fastfetch"
brew "git-delta"
brew "gh"

# --- window management (active branch: aerospace) ---------------------------
# sketchybar runs on the Lua config committed in sketchybar/ (sketchybarrc
# shebang is `#!/usr/bin/env lua`), so it needs lua + the SbarLua module.
brew "sketchybar"
brew "borders"
brew "lua"
brew "switchaudio-osx"      # sketchybar/helpers (volume item)
brew "nowplaying-cli"       # sketchybar/helpers (media item)
brew "sesh"                 # tmux C-space session picker + skhd/sesh-sessions.sh

# --- casks ------------------------------------------------------------------
cask "kitty"
cask "font-jetbrains-mono-nerd-font"   # kitty.conf font_family
cask "font-hack-nerd-font"
cask "sf-symbols"                      # sketchybar icons
cask "font-sf-mono"                    # sketchybar numbers (helpers/default_font.lua)
cask "font-sf-pro"                     # sketchybar text    (helpers/default_font.lua)
cask "aerospace"
cask "karabiner-elements"
cask "raycast"
cask "1password"                       # desktop app
cask "1password-cli"                   # op/config
cask "vivaldi"                         # vivaldi/ custom CSS is tracked in this repo

# --- legacy window management (replaced by aerospace; commented) ------------
# Requires: brew tap koekeishiya/formulae
# brew "yabai"              # yabai/yabairc — also needs scripting-addon + SIP changes
# brew "skhd"               # skhd/skhdrc   — skhd 0.3.9 is installed on this machine

# --- optional extras referenced by tracked configs but not strictly required -
# brew "leohenon/tap/ocv"   # tmux.conf + fish use `ocv` / ~/.local/bin/ocv-link-open
# brew "julien-cpsn/atac"   # fish sets ATAC_* and DOTFILES/atac/custom_keybindings.toml
# brew "oven-sh/bun/bun"    # fish sets BUN_INSTALL
