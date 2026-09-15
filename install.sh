#!/usr/bin/env bash
# ============================================================================
# GrimalDev/dotfiles — installation script (macOS)
# ============================================================================
#
# This repo is NOT a normal git checkout. It is a **bare repository** whose
# work-tree is ~/.config, so the whole of ~/.config is version controlled:
#
#     git --git-dir="$HOME/.dotfiles" --work-tree="$HOME/.config" <cmd>
#
# That command is aliased to `dots` in fish/config.fish.
#
# Usage
#   One line, always the latest revision of the default branch:
#     /bin/bash -c "$(curl -fsSL https://github.com/GrimalDev/dotfiles/raw/HEAD/install.sh)"
#   Same, passing options through stdin:
#     curl -fsSL https://github.com/GrimalDev/dotfiles/raw/HEAD/install.sh | bash -s -- --dry-run
#   From an existing checkout:
#     ~/.config/install.sh
#   Options:
#     -b, --branch <name>   Branch to check out          (default: aerospace)
#         --repo <url>      Override remote URL
#     -s, --skip-brew       Skip Homebrew + Brewfile
#     -c, --skip-checkout   Only install packages/post-install
#     -p, --skip-post       Skip shell/plugin/service wiring
#         --no-services     Do not start brew services
#         --no-shim         Do not create the exa->eza compatibility shim
#     -n, --dry-run         Print actions, change nothing
#     -h, --help            This help
#
# Idempotent: safe to re-run. Existing files are backed up, never deleted.
# ============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
REPO_URL="${DOTFILES_REPO:-https://github.com/GrimalDev/dotfiles}"
BRANCH="${DOTFILES_BRANCH:-aerospace}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"          # bare git dir
CONFIG_DIR="${DOTFILES_WORKTREE:-$HOME/.config}"         # work tree
BACKUP_ROOT="${DOTFILES_BACKUP_ROOT:-$HOME/.dotfiles-backup}"
CLT_TIMEOUT="${DOTFILES_CLT_TIMEOUT:-1800}"
NVIM_CONFIG_REPO="${DOTFILES_NVIM_REPO:-https://github.com/GrimalDev/nvim-config}"
NVIM_STARTER_REPO="${DOTFILES_NVIM_STARTER_REPO:-https://github.com/NvChad/starter}"
WALLPAPER="${DOTFILES_WALLPAPER:-}"

# Third-party taps Homebrew refuses to load until explicitly trusted.
TRUSTED_TAPS="felixkratz/formulae joshmedeski/sesh nikitabobko/tap"

# Flags
SKIP_BREW=0
SKIP_CHECKOUT=0
SKIP_POST=0
START_SERVICES=1
EXA_SHIM=1
INSTALL_ROSETTA=1
REPLACE_NVIM=0
SET_WALLPAPER=1
DRY_RUN=0

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BLUE=$'\033[1;34m'; C_YEL=$'\033[1;33m'; C_RED=$'\033[1;31m'
  C_DIM=$'\033[2m'
else
  C_RESET=""; C_BLUE=""; C_YEL=""; C_RED=""; C_DIM=""
fi

log()  { printf '%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
step() { printf '%s  - %s%s\n' "$C_DIM" "$*" "$C_RESET"; }
warn() { printf '%swarn:%s %s\n' "$C_YEL" "$C_RESET" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

# run <cmd...> — executes unless --dry-run.
run() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '%s  [dry-run] %s%s\n' "$C_DIM" "$*" "$C_RESET"
    return 0
  fi
  "$@"
}

# ---------------------------------------------------------------------------
# Git wrapper — every git call goes through the bare-repo work-tree pair.
# ---------------------------------------------------------------------------
dots_git() { git --git-dir="$DOTFILES_DIR" --work-tree="$CONFIG_DIR" "$@"; }

usage() {
  cat <<'USAGE'
GrimalDev/dotfiles — installation script (macOS)

This repo is a bare repository whose work-tree is ~/.config:
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME/.config" <cmd>
That command is aliased to `dots` in fish/config.fish.

Latest, one line (default branch):
    /bin/bash -c "$(curl -fsSL https://github.com/GrimalDev/dotfiles/raw/HEAD/install.sh)"

Same, passing options through stdin:
    curl -fsSL https://github.com/GrimalDev/dotfiles/raw/HEAD/install.sh | bash -s -- --dry-run

From an existing checkout:
    ~/.config/install.sh

Installed automatically when missing:
  Xcode Command Line Tools, Homebrew, Rosetta 2 (Apple Silicon only).

Also configured:
  ~/.config/nvim from NvChad/starter + github.com/GrimalDev/nvim-config.
  Desktop picture from ~/.config/wallpapers/ (via desktoppr or osascript).

Options:
  -b, --branch <name>   Branch to check out          (default: aerospace)
      --repo <url>      Override remote URL
  -s, --skip-brew       Skip Homebrew + Brewfile
  -c, --skip-checkout   Only install packages/post-install
  -p, --skip-post       Skip shell/plugin/service wiring
      --no-services     Do not start brew services
      --no-shim         Do not create the exa->eza compatibility shim
      --no-rosetta      Do not install Rosetta 2
      --replace-nvim    Rebuild ~/.config/nvim from the nvim-config repo
      --no-wallpaper    Do not set the desktop picture from wallpapers/
      --clt-timeout <s> Seconds to wait for Command Line Tools (default 1800)
  -n, --dry-run         Print actions, change nothing
  -h, --help            This help

Idempotent: safe to re-run. Existing files are backed up, never deleted.
USAGE
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -b|--branch)      BRANCH="${2:-}"; shift 2 ;;
      --repo)           REPO_URL="${2:-}"; shift 2 ;;
      -s|--skip-brew)   SKIP_BREW=1; shift ;;
      -c|--skip-checkout) SKIP_CHECKOUT=1; shift ;;
      -p|--skip-post)   SKIP_POST=1; shift ;;
      --no-services)    START_SERVICES=0; shift ;;
      --no-shim)        EXA_SHIM=0; shift ;;
      --no-rosetta)     INSTALL_ROSETTA=0; shift ;;
      --replace-nvim)   REPLACE_NVIM=1; shift ;;
      --no-wallpaper)   SET_WALLPAPER=0; shift ;;
      --clt-timeout)    CLT_TIMEOUT="${2:-}"; shift 2 ;;
      -n|--dry-run)     DRY_RUN=1; shift ;;
      -h|--help)        usage; exit 0 ;;
      *) die "unknown option: $1 (try --help)" ;;
    esac
  done
  [ -n "$BRANCH" ] || die "--branch needs a value"
  [ -n "$REPO_URL" ] || die "--repo needs a value"
  [ "$CLT_TIMEOUT" -gt 0 ] 2>/dev/null || die "--clt-timeout needs a positive number of seconds"
}

# ---------------------------------------------------------------------------
# Step 1 — preflight
# ---------------------------------------------------------------------------
preflight() {
  log "Preflight"
  [ "$(uname -s)" = "Darwin" ] || die "this installer only supports macOS"
  [ "$(id -u)" -ne 0 ] || die "do not run as root; run as your normal user"
  [ -n "${HOME:-}" ] || die "HOME is not set"
  step "macOS $(sw_vers -productVersion) ($(uname -m))"
  step "branch: $BRANCH"
  step "work-tree: $CONFIG_DIR"
  step "git-dir:   $DOTFILES_DIR"
}

# ---------------------------------------------------------------------------
# Step 2 — base prerequisites (Xcode Command Line Tools, Rosetta 2)
# ---------------------------------------------------------------------------
ensure_clt() {
  log "Xcode Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then
    step "present: $(xcode-select -p)"
    return 0
  fi

  step "missing — requesting install (a system dialog will open)"
  if [ "$DRY_RUN" = 1 ]; then
    printf '%s  [dry-run] xcode-select --install%s\n' "$C_DIM" "$C_RESET"
    return 0
  fi

  xcode-select --install 2>/dev/null || true
  local waited=0
  while ! xcode-select -p >/dev/null 2>&1; do
    [ "$waited" -lt "$CLT_TIMEOUT" ] \
      || die "Command Line Tools did not finish within ${CLT_TIMEOUT}s — complete the dialog, then re-run"
    sleep 10
    waited=$((waited + 10))
    if [ $((waited % 60)) -eq 0 ]; then
      step "waiting for Command Line Tools (${waited}s)"
    fi
  done
  step "installed: $(xcode-select -p)"
}

ensure_rosetta() {
  [ "$INSTALL_ROSETTA" = 1 ] || return 0
  [ "$(uname -m)" = "arm64" ] || return 0

  log "Rosetta 2"
  if [ -d /Library/Apple/usr/libexec/oah ]; then
    step "present"
    return 0
  fi
  step "missing — installing (license auto-accepted)"
  run /usr/sbin/softwareupdate --install-rosetta --agree-to-license \
    || warn "Rosetta not installed (native tools do not need it)"
}

install_bases() {
  log "Base prerequisites"
  ensure_clt
  command -v git >/dev/null 2>&1 || die "git still missing after the Command Line Tools install"
  step "git: $(git --version)"
  ensure_rosetta
}

# ---------------------------------------------------------------------------
# Step 2 — Homebrew
# ---------------------------------------------------------------------------
detect_brew() {
  if [ -x /opt/homebrew/bin/brew ]; then
    BREW_BIN=/opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then
    BREW_BIN=/usr/local/bin/brew
  elif command -v brew >/dev/null 2>&1; then
    BREW_BIN="$(command -v brew)"
  else
    BREW_BIN=""
  fi
}

install_homebrew() {
  log "Homebrew"
  detect_brew
  if [ -z "$BREW_BIN" ]; then
    step "not found — installing (NONINTERACTIVE)"
    if [ "$DRY_RUN" = 1 ]; then
      printf '%s  [dry-run] install Homebrew%s\n' "$C_DIM" "$C_RESET"
    else
      NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      detect_brew
    fi
  fi
  [ -n "$BREW_BIN" ] || [ "$DRY_RUN" = 1 ] || die "Homebrew install failed"
  if [ "$DRY_RUN" = 0 ]; then
    eval "$("$BREW_BIN" shellenv)"
    HOMEBREW_PREFIX="$("$BREW_BIN" --prefix)"
    export HOMEBREW_PREFIX
    step "prefix: $HOMEBREW_PREFIX"
  fi
}

# ---------------------------------------------------------------------------
# Step 3 — packages (deps live in the tracked Brewfile)
# ---------------------------------------------------------------------------
install_packages() {
  log "Packages (Brewfile)"
  local brewfile="$CONFIG_DIR/Brewfile"
  [ -f "$brewfile" ] || die "Brewfile not found at $brewfile"

  # Recent Homebrew refuses to load third-party taps until trusted.
  local tap
  for tap in $TRUSTED_TAPS; do
    if "$BREW_BIN" trust --help >/dev/null 2>&1; then
      run "$BREW_BIN" trust "$tap" || warn "could not trust $tap (continuing)"
    fi
  done

  run "$BREW_BIN" update || warn "brew update failed (continuing)"
  run "$BREW_BIN" bundle install --file="$brewfile"
  step "done"
}

# ---------------------------------------------------------------------------
# Step 4 — clone the bare repo
# ---------------------------------------------------------------------------
clone_repo() {
  log "Repository"
  if [ -d "$DOTFILES_DIR" ]; then
    FRESH_CLONE=0
    step "bare repo exists — fetching"
    run dots_git fetch --prune origin
  else
    FRESH_CLONE=1
    step "cloning bare repo -> $DOTFILES_DIR"
    run git clone --bare "$REPO_URL" "$DOTFILES_DIR"
  fi

  run dots_git config remote.origin.url "$REPO_URL"
  # Keep `status` quiet: ~/.config legitimately holds many untracked files.
  run dots_git config status.showuntrackedfiles no
}

# ---------------------------------------------------------------------------
# Step 5 — back up anything the checkout would clobber (fresh installs only)
# ---------------------------------------------------------------------------
backup_conflicts() {
  log "Conflict backup"
  [ "${FRESH_CLONE:-1}" = 1 ] || { step "existing install — nothing to back up"; return 0; }

  mkdir -p "$CONFIG_DIR"
  local stamp backup name target moved=0
  stamp="$(date +%Y%m%d-%H%M%S)"
  backup="$BACKUP_ROOT/$stamp"

  # Every top-level path tracked in the target branch.
  for name in $(dots_git ls-tree --name-only "$BRANCH" 2>/dev/null); do
    target="$CONFIG_DIR/$name"
    [ -e "$target" ] || continue
    if [ "$moved" = 0 ]; then
      step "existing files found — backing up to $backup"
      moved=1
    fi
    mkdir -p "$backup"
    run mv "$target" "$backup/$name"
  done

  if [ "$moved" = 1 ]; then
    step "restore anything you want back with: cp -R \"$backup/.\" \"$CONFIG_DIR/\""
  else
    step "no conflicts"
  fi
}

# ---------------------------------------------------------------------------
# Step 6 — checkout
# ---------------------------------------------------------------------------
checkout_branch() {
  log "Checkout"
  run dots_git checkout -f "$BRANCH"
  dots_git branch --set-upstream-to="origin/$BRANCH" "$BRANCH" >/dev/null 2>&1 || true
  if [ "$DRY_RUN" = 0 ]; then
    step "HEAD: $(dots_git rev-parse --short HEAD) on $BRANCH"
  fi
}

# ---------------------------------------------------------------------------
# Post-install
# ---------------------------------------------------------------------------

# Tracked config scripts are 0644 in git; restore the exec bit where needed.
fix_permissions() {
  [ -d "$CONFIG_DIR/skhd/scripts" ] && run chmod +x "$CONFIG_DIR"/skhd/scripts/*.sh 2>/dev/null || true
  [ -d "$CONFIG_DIR/sesh/scripts" ] && run chmod +x "$CONFIG_DIR"/sesh/scripts/* 2>/dev/null || true
  [ -d "$CONFIG_DIR/yabai" ]        && run chmod +x "$CONFIG_DIR"/yabai/*.sh 2>/dev/null || true
  [ -d "$CONFIG_DIR/aerospace/scripts" ] && run chmod +x "$CONFIG_DIR"/aerospace/scripts/*.sh 2>/dev/null || true
  [ -d "$CONFIG_DIR/scripts" ]      && run chmod +x "$CONFIG_DIR"/scripts/*.sh 2>/dev/null || true
  return 0
}

set_default_shell() {
  local fish_bin="$HOMEBREW_PREFIX/bin/fish"
  [ -x "$fish_bin" ] || { warn "fish not installed — skipping shell change"; return 0; }

  log "Default shell"
  if ! grep -qxF "$fish_bin" /etc/shells 2>/dev/null; then
    step "adding $fish_bin to /etc/shells (sudo)"
    if [ "$DRY_RUN" = 0 ]; then
      printf '%s\n' "$fish_bin" | sudo tee -a /etc/shells >/dev/null
    else
      printf '%s  [dry-run] append %s to /etc/shells%s\n' "$C_DIM" "$fish_bin" "$C_RESET"
    fi
  fi
  if [ "${SHELL:-}" != "$fish_bin" ]; then
    step "chsh -s $fish_bin"
    run chsh -s "$fish_bin"
  else
    step "already the login shell"
  fi
}

install_fish_plugins() {
  local fish_bin="$HOMEBREW_PREFIX/bin/fish"
  [ -x "$fish_bin" ] || return 0
  [ -f "$CONFIG_DIR/fish/fish_plugins" ] || return 0

  log "fish plugins (fisher)"
  if [ "$DRY_RUN" = 1 ]; then
    printf '%s  [dry-run] fisher update (reads fish/fish_plugins)%s\n' "$C_DIM" "$C_RESET"
    return 0
  fi
  # fisher update installs/updates every plugin listed in fish_plugins.
  "$fish_bin" -c 'curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher update' \
    || warn "fisher update failed — run it manually inside fish"
}

# tmux/plugins/ is git-ignored and owned by TPM (see tmux.conf @plugin lines),
# so a fresh checkout has no plugins at all.
#
# TPM's CLI resolves its plugin directory from a tmux-server global
# (TMUX_PLUGIN_MANAGER_PATH), which only exists once tmux has sourced the
# config — i.e. never on a brand-new machine. So install deterministically
# from the @plugin lines here; TPM then finds everything already in place.
install_tmux_plugins() {
  local conf="$CONFIG_DIR/tmux/tmux.conf"
  local dir="$CONFIG_DIR/tmux/plugins"
  [ -f "$conf" ] || return 0

  log "tmux plugins"

  if [ ! -e "$dir/tpm/bin/install_plugins" ]; then
    step "cloning tpm"
    run git clone https://github.com/tmux-plugins/tpm "$dir/tpm"
  fi

  local spec name
  while IFS= read -r spec; do
    [ -n "$spec" ] || continue
    name="${spec##*/}"
    name="${name%.git}"
    if [ -e "$dir/$name" ]; then
      step "$name: present"
    else
      step "cloning $name"
      run git clone "https://github.com/$spec" "$dir/$name" \
        || warn "could not clone $name — run prefix+I inside tmux instead"
    fi
  done <<EOF
$(sed -n "s/^[[:space:]]*set[[:space:]].*@plugin[[:space:]]*['\"]\([^'\"]*\)['\"].*/\1/p" "$conf")
EOF
}

install_neovim_config() {
  local dir="$CONFIG_DIR/nvim"

  command -v nvim >/dev/null 2>&1 \
    || { warn "neovim not installed — skipping nvim config"; return 0; }

  log "Neovim config (NvChad starter + nvim-config)"

  if [ -n "$(ls -A "$dir" 2>/dev/null)" ] && [ "$REPLACE_NVIM" != 1 ]; then
    step "already present — leaving alone (--replace-nvim to rebuild)"
    return 0
  fi

  if [ "$DRY_RUN" = 1 ]; then
    printf '%s  [dry-run] clone %s -> %s; replace lua/ with %s; mv lua/main-init.lua init.lua; nvim --headless "+Lazy! sync"%s\n' \
      "$C_DIM" "$NVIM_STARTER_REPO" "$dir" "$NVIM_CONFIG_REPO" "$C_RESET"
    return 0
  fi

  if [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    local backup
    backup="$BACKUP_ROOT/nvim-$(date +%Y%m%d-%H%M%S)"
    step "backing up existing config -> $backup"
    mkdir -p "$BACKUP_ROOT"
    mv "$dir" "$backup"
  fi

  rm -rf "$dir"
  step "cloning NvChad starter"
  git clone "$NVIM_STARTER_REPO" "$dir" || { warn "starter clone failed"; return 0; }

  rm -rf "$dir/lua"
  mkdir -p "$dir/lua"
  step "cloning nvim-config into lua/"
  git clone "$NVIM_CONFIG_REPO" "$dir/lua" || { warn "nvim-config clone failed"; return 0; }

  if [ -f "$dir/lua/main-init.lua" ]; then
    step "lua/main-init.lua -> init.lua"
    mv "$dir/lua/main-init.lua" "$dir/init.lua"
  fi

  step "installing plugins (headless Lazy sync)"
  nvim --headless "+Lazy! sync" +qa \
    || warn "plugin sync did not finish — open nvim and run :Lazy sync"
}

install_sketchybar() {
  [ -d "$CONFIG_DIR/sketchybar" ] || return 0
  log "sketchybar"

  local fontdir="$HOME/Library/Fonts"
  local appfont="$fontdir/sketchybar-app-font.ttf"
  run mkdir -p "$fontdir"
  if [ ! -f "$appfont" ]; then
    step "app font -> $appfont"
    run curl -fsSL \
      "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.5/sketchybar-app-font.ttf" \
      -o "$appfont"
  else
    step "app font already installed"
  fi

  # SbarLua powers the Lua config (sketchybarrc is `#!/usr/bin/env lua`).
  if command -v lua >/dev/null 2>&1 && ! lua -e 'require("sbar")' >/dev/null 2>&1; then
    step "installing SbarLua"
    if [ "$DRY_RUN" = 1 ]; then
      printf '%s  [dry-run] clone+make install FelixKratz/SbarLua%s\n' "$C_DIM" "$C_RESET"
    else
      local tmp
      tmp="$(mktemp -d)"
      if git clone --depth 1 https://github.com/FelixKratz/SbarLua "$tmp/SbarLua"; then
        ( cd "$tmp/SbarLua" && make install ) || warn "SbarLua build failed — see sketchybar/helpers/install.sh"
      fi
      rm -rf "$tmp"
    fi
  else
    step "SbarLua already available"
  fi
}

install_wallpaper() {
  [ "$SET_WALLPAPER" = 1 ] || return 0

  local dir="$CONFIG_DIR/wallpapers"
  [ -d "$dir" ] || return 0

  local image="$WALLPAPER" f
  if [ -z "$image" ]; then
    for f in "$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.png "$dir"/*.heic; do
      if [ -f "$f" ]; then image="$f"; break; fi
    done
  fi

  log "Wallpaper"
  if [ -z "$image" ]; then
    warn "no image found in $dir"
    return 0
  fi
  if [ ! -f "$image" ]; then
    warn "wallpaper not found: $image"
    return 0
  fi

  step "image: $image"

  if [ "$DRY_RUN" = 1 ]; then
    printf '%s  [dry-run] set desktop picture -> %s%s\n' "$C_DIM" "$image" "$C_RESET"
    return 0
  fi

  if command -v desktoppr >/dev/null 2>&1 && desktoppr "$image"; then
    step "applied to all displays (desktoppr)"
    return 0
  fi

  local jxa
  jxa="ObjC.import('AppKit'); var ws=\$.NSWorkspace.sharedWorkspace, u=\$.NSURL.fileURLWithPath('$image'); \$.NSScreen.screens.js.forEach(function(s){ ws.setDesktopImageURLForScreenOptionsError(u, s, \$(), \$()); });"
  if osascript -l JavaScript -e "$jxa" >/dev/null 2>&1; then
    step "applied to all displays"
  else
    warn "could not set the wallpaper"
  fi
}

# fish aliases `ls|ll|lt` to `exa`, which Homebrew no longer ships. Link eza.
install_exa_shim() {
  [ "$EXA_SHIM" = 1 ] || return 0
  command -v exa >/dev/null 2>&1 && return 0
  command -v eza >/dev/null 2>&1 || return 0

  log "exa compatibility shim"
  step "linking exa -> eza (config.fish still calls exa)"
  run ln -sf "$(command -v eza)" "$HOMEBREW_PREFIX/bin/exa"
}

start_services() {
  [ "$START_SERVICES" = 1 ] || return 0
  log "Services"
  local svc
  for svc in sketchybar borders; do
    if "$BREW_BIN" list --formula "$svc" >/dev/null 2>&1; then
      run "$BREW_BIN" services start "$svc" || warn "could not start $svc"
    fi
  done
}

post_install() {
  fix_permissions
  set_default_shell
  install_fish_plugins
  install_tmux_plugins
  install_neovim_config
  install_sketchybar
  install_wallpaper
  install_exa_shim
  start_services
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
summary() {
  log "Done"
  cat <<EOF

  Repo:    $REPO_URL  ($BRANCH)
  Config:  $CONFIG_DIR  managed via $DOTFILES_DIR
  Manage:  dots status | dots add <path> | dots commit -m "..." | dots push

  Manual steps (require GUI / SIP changes, cannot be scripted):
    - AeroSpace      : open it once, enable "Launch at login"
    - Karabiner      : grant Input Monitoring + enable the driver
    - Raycast        : launch and sign in
    - 1Password CLI  : op signin
    - yabai (legacy) : not installed; needs scripting-addon + SIP changes

  Restart your terminal (or run: exec fish) to load the new config.
EOF
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  parse_args "$@"
  [ "$DRY_RUN" = 1 ] && log "DRY RUN — no changes will be made"

  preflight
  install_bases
  [ "$SKIP_BREW" = 1 ] || install_homebrew
  detect_brew
  if [ "$SKIP_BREW" = 0 ] && [ -n "$BREW_BIN" ]; then
    eval "$("$BREW_BIN" shellenv)"
    HOMEBREW_PREFIX="$("$BREW_BIN" --prefix)"; export HOMEBREW_PREFIX
  fi

  if [ "$SKIP_CHECKOUT" = 0 ]; then
    clone_repo
    backup_conflicts
    checkout_branch
  fi

  [ "$SKIP_BREW" = 1 ] || install_packages
  export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$(command -v brew >/dev/null 2>&1 && brew --prefix || echo /opt/homebrew)}"
  [ "$SKIP_POST" = 1 ] || post_install

  summary
}

main "$@"
