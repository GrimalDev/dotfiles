zoxide init fish | source
starship init fish | source

fish_add_path /opt/homebrew/opt/qt@5/bin
set -gx PKG_CONFIG_PATH "/opt/homebrew/opt/qt@5/lib/pkgconfig"

alias immozia="cd $HOME/Desktop/oxianet/immozia"

alias tree='exa --tree'
alias ls='exa -a --color=always --group-directories-first'
alias ll='exa -alhg --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias cat='bat'
alias icat='kitten icat'

function mfzf
  set current_dir (pwd)
  cd /Users/grimaldev/Documents/projects/scripts/man-fuzzy/package_docs
  rg --color=always '' * | fzf --ansi --preview 'echo {} | cut -d ":" -f 1 | xargs -I{} sh -c "head -n 20 {}"' --preview-window=up:40%:wrap
  cd $current_dir
end

# alias ssh="kitty +kitten ssh"

fish_vi_key_bindings

function sudo
    if test "$argv" = !!
        eval command sudo -E $history[1]
    else
        command sudo -E $argv
    end
end

function brew
  # if there are no params, list all installed packages and install on selection else just forward the params to brew
  if test "$argv" = ""
    set packet $(bash -c "(curl -s https://formulae.brew.sh/api/formula.json && curl -s https://formulae.brew.sh/api/cask.json) | jq -r '.[].full_name, .[].full_token | select(.!=null)'" | fzf)
    command brew install $packet
    set -e packages
  else
    command brew $argv
  end
end

function __list_run_files
  echo " "

  if test ! -d .run
    echo "No .run directory"
    return
  end
  if test (fd '^*.sh$' -t f -d 1 .run | wc -l) -eq 0
    echo "no executable files found in .run"
    return
  end
  set file_to_run (fd '^*.sh$' -t f -d 1 .run | fzf)
  if test -n "$file_to_run"
    bash $file_to_run
  else
    echo "No file selected"
  end

  echo -n "Press enter key to continue..."
end


# Start, hide, show apps
function toogle_app
  set app $argv[1]
  set title $argv[2]
  set options $argv[3]
  set mode $argv[4]
  set title_search ""
  if test -n "$title"
    set title_search " | select(.title == \"$title\")"
  end
  set is_running (yabai -m query --windows | jq -r '.[] | select(.app == "'"$app"'")'"$title_search")
  if test -z "$is_running"
    if test "$mode" = "cli"
      echo "Starting $app with cli mode"
      /bin/bash -c "$app $options &"
    else
      echo "starting $app"
      open -a "$app"
    end
  else
    set app_id (echo $is_running | jq -r '.id')
    set is_minimized (echo $is_running | jq -r '.["is-minimized"]')
    if test "$is_minimized" = "false"
      yabai -m window "$app_id" --minimize
    else
      yabai -m window "$app_id" --focus
    end
  end
end

function jqf
  set -l search_string $argv[1]
  set -l file $argv[2]
  jq 'paths | map(tostring) | join(".") | select(contains("'$search_string'"))' $file
end

set -gx TERM xterm-256color

# Set the PATH
set -gx PATH $HOME/.pyenv/bin $PATH

# Set the M2_HOME and update the PATH for Apache Maven
set -gx M2_HOME $HOME/apache-maven-3.9.0
set -gx PATH $M2_HOME/bin $PATH

# Set BUN_INSTALL and update PATH for bun
set -gx BUN_INSTALL $HOME/.bun
set -gx PATH $BUN_INSTALL/bin $PATH

set -gx PATH (go env GOPATH)/bin $PATH

# Update PATH for ImageMagick
set -gx PATH /usr/local/opt/imagemagick@7/bin $PATH

# Mac ports
set -gx PATH /opt/local/bin:/opt/local/sbin:$PATH

set -gx EDITOR "nvim"

set -gx DOTFILES "$HOME/.config"
if test -d $HOME/.dotfiles
  set -gx DOTFILES_MIRROR "$HOME/.dotfiles"
end
set nvimSessionsPath "$HOME/sessions/"
if test ! -d $nvimSessionsPath
  mkdir -p $nvimSessionsPath
  set -gx NVIM_SESSIONS $nvimSessionsPath
else
  set -gx NVIM_SESSIONS $nvimSessionsPath
end

# Custom aliases
alias uninstall="uninstall-cli.sh"
alias dots="git --git-dir=$DOTFILES_MIRROR --work-tree=$DOTFILES"

# Set NODE_PATH
if test -d /usr/local/Lib/node_modules
  set -gx NODE_PATH /usr/local/Lib/node_modules
end

# Set JAVA_HOME
if test -d /Library/Java
  set newest_jdk (find /library/java/javavirtualmachines/ -d -name 'jdk-*.jdk' | sort -V | tail -n 1)
  set -gx JAVA_HOME $newest_jdk/Contents/Home
  set -gx PATH $JAVA_HOME/bin $PATH
end

if test ! -d ~/ATAC_MAIN_DIR
  mkdir ~/ATAC_MAIN_DIR
end
set -gx ATAC_MAIN_DIR ~/ATAC_MAIN_DIR
set -gx ATAC_KEY_BINDINGS $DOTFILES/atac/custom_keybindings.toml

alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

set -U FZF_CD_WITH_HIDDEN_COMMAND "fd -H -u --type d --exclude node_modules . \$dir"
set -U FZF_PRINT_WITH_HIDDEN_COMMAND "fd -H -u --type d --exclude node_modules ."
set -U FZF_OPEN_COMMAND "fd -H -u --type f --exclude node_modules . \$dir"
bind -M insert \Co '__fzf_open --editor'
set -U FZF_TMUX 1
set -e FZF_COMPLETE 0
bind -M insert -e \t '__fzf_complete'
set -U FZF_ENABLE_OPEN_PREVIEW 0

bind -M insert \ee "nvim"
bind -M insert \ec "nvim ~/.config/fish/config.fish"
# bind -M insert \er "ranger"
bind -M insert \el __fish_list_current_token # my preferred listing
bind -M insert \er __list_run_files
bind -M insert \ed "lazydocker"

