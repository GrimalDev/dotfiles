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
#   Fresh machine (no repo yet):
#     bash -c "$(curl -fsSL https://raw.githubusercontent.com/GrimalDev/dotfiles/aerospace/install.sh)"
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

# Third-party taps Homebrew refuses to load until explicitly trusted.
TRUSTED_TAPS="felixkratz/formulae joshmedeski/sesh nikitabobko/tap"

# Flags
SKIP_BREW=0
SKIP_CHECKOUT=0
SKIP_POST=0
START_SERVICES=1
EXA_SHIM=1
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

usage() { sed -n '2,34p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//' || true; }

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
      -n|--dry-run)     DRY_RUN=1; shift ;;
      -h|--help)        usage; exit 0 ;;
      *) die "unknown option: $1 (try --help)" ;;
    esac
  done
  [ -n "$BRANCH" ] || die "--branch needs a value"
  [ -n "$REPO_URL" ] || die "--repo needs a value"
}

# ---------------------------------------------------------------------------
# Step 1 — preflight
# ---------------------------------------------------------------------------
preflight() {
  log "Preflight"
  [ "$(uname -s)" = "Darwin" ] || die "this installer only supports macOS"
  [ "$(id -u)" -ne 0 ] || die "do not run as root; run as your normal user"
  [ -n "${HOME:-}" ] || die "HOME is not set"

  if ! command -v git >/dev/null 2>&1; then
    warn "git not found. Installing Xcode Command Line Tools."
    xcode-select --install 2>/dev/null || true
    die "re-run this script once the Command Line Tools finish installing"
  fi
  step "git: $(git --version)"
  step "branch: $BRANCH"
  step "work-tree: $CONFIG_DIR"
  step "git-dir:   $DOTFILES_DIR"
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

# tmux/plugins/* are gitlinks (mode 160000) with no .gitmodules, so a fresh
# checkout leaves them empty. Bootstrap tpm, then let it install the plugins
# declared in tmux.conf.
install_tmux_plugins() {
  local dir="$CONFIG_DIR/tmux/plugins"
  [ -d "$CONFIG_DIR/tmux" ] || return 0

  log "tmux plugins"
  if [ ! -e "$dir/tpm/bin/install_plugins" ]; then
    step "tpm missing — cloning"
    run git clone --depth 1 https://github.com/tmux-plugins/tpm "$dir/tpm"
  fi
  if [ "$DRY_RUN" = 1 ]; then
    printf '%s  [dry-run] tpm install_plugins%s\n' "$C_DIM" "$C_RESET"
    return 0
  fi
  if [ -x "$dir/tpm/bin/install_plugins" ]; then
    "$dir/tpm/bin/install_plugins" || warn "tmux plugins incomplete — run prefix+I inside tmux"
  fi
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
  install_sketchybar
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
