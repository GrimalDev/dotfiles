zoxide init fish | source
starship init fish | source

set -e fish_user_paths
fish_add_path /opt/homebrew/opt/qt@5/bin
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path /opt/homebrew/Cellar/postgresql@17/17.0/bin
if test -d /opt/homebrew
  set -gx PKG_CONFIG_PATH "/opt/homebrew/opt/qt@5/lib/pkgconfig"
end

function mfzf
  set -l current_dir (pwd)
  cd /Users/grimaldev/Documents/projects/scripts/man-fuzzy/package_docs
  rg --color=always '' * | fzf --ansi --preview 'echo {} | cut -d ":" -f 1 | xargs -I{} sh -c "head -n 20 {}"' --preview-window=up:40%:wrap
  cd $current_dir
end

fish_vi_key_bindings

function sudo
    if test "$argv" = !!
        eval command sudo -E $history[1]
    else
        command sudo -E $argv
    end
end

function emptytrash
  defaults write com.apple.finder EmptyTrashSecurely -bool false
  sudo rm -rf ~/.Trash/*
end 

function brew
  # if there are no params, list all installed packages and install on selection else just forward the params to brew
  if test "$argv" = ""
    set -l packet $(bash -c "(curl -s https://formulae.brew.sh/api/formula.json && curl -s https://formulae.brew.sh/api/cask.json) | jq -r '.[].full_name, .[].full_token | select(.!=null)'" | fzf)
    command brew install $packet
    set -e packages
  else
    command brew $argv
  end
end

function __list_run_files
  if test ! -d .run
    echo "No .run directory"
    return
  end
  if test (fd '^*.sh$' -t f -d 1 .run | wc -l) -eq 0
    echo "no executable files found in .run"
    return
  end
  set -l file_to_run (fd '^*.sh$' -t f -d 1 .run | fzf)
  if test -n "$file_to_run"
    # set file_to_run (string replace -r "(\r\n|\n|\r)" "" $file_to_run)
    commandline -r "bash $file_to_run"
    commandline -f execute
  else
    echo "No file selected"
  end
end

function genSeshConfig
  set -l genFile $DOTFILES/sesh/sesh-autogen.toml

  echo "" > $genFile

  set -l seshTemplate "
\n
[[session]]\n
name = 'NAME ⚙️'\n
path = 'CONFIG'\n
\n
  "

  set -l configNames (fd -p -t d -d 1 . $HOME/.config/)

  #replace NAME and CONFIG placeholders
  for config in $configNames
    set -l configName (string replace -r "$DOTFILES/" "" $config)
    set -l configName (string replace -r "/" "" $configName)

    set -l configExists (rg -q $config $DOTFILES/sesh/sesh.toml)
    if test -n "$configExists"
      echo "$configName already exists in sesh.toml"
      continue
    end

    set -l tempTemplate $seshTemplate
    set -l configPath $DOTFILES/$configName

    set -l tempTemplate (string replace -r "NAME" $configName $tempTemplate)
    set -l tempTemplate (string replace -r "CONFIG" $configPath $tempTemplate)
    printf "$tempTemplate" >> $genFile
  end
end

# Start, hide, show apps
function toogle_app
  set -l app $argv[1]
  set -l title $argv[2]
  set -l options $argv[3]
  set -l mode $argv[4]
  set -l title_search ""
  if test -n "$title"
    set -l title_search " | select(.title == \"$title\")"
  end
  set -l is_running (yabai -m query --windows | jq -r '.[] | select(.app == "'"$app"'")'"$title_search")
  if test -z "$is_running"
    if test "$mode" = "cli"
      echo "Starting $app with cli mode"
      /bin/bash -c "$app $options &"
    else
      echo "starting $app"
      open -a "$app"
    end
  else
    set -l app_id (echo $is_running | jq -r '.id')
    set -l is_minimized (echo $is_running | jq -r '.["is-minimized"]')
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

function share
    curl -F "file=@$argv" https://0x0.st | wl-copy
end

if test -z TMUX
  set -gx TERM xterm-256color
end

fish_add_path $HOME/.pyenv/bin

# Set the M2_HOME and update the PATH for Apache Maven
set -gx M2_HOME $HOME/apache-maven-3.9.0
fish_add_path $M2_HOME/bin

# Set BUN_INSTALL and update PATH for bun
set -gx BUN_INSTALL $HOME/.bun
fish_add_path $BUN_INSTALL/bin

fish_add_path (go env GOPATH)/bin

# Update PATH for ImageMagick
fish_add_path /usr/local/opt/imagemagick@7/bin

# Mac ports
fish_add_path /opt/local/bin:/opt/local/sbin

fish_add_path "/opt/homebrew/opt/mysql@8.4/bin"

# Added by LM Studio CLI (lms)
fish_add_path /Users/grimaldev/.cache/lm-studio/bin

set -gx EDITOR "nvim"

set -gx XDEBUG_SESSION 1

# set -gx DOCKER_DEFAULT_PLATFORM "linux/amd64"

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
  touch ~/ATAC_MAIN_DIR/custom_keybindings.toml
  touch ~/ATAC_MAIN_DIR/atac.toml
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

alias immozia="cd $HOME/Desktop/oxianet/immozia"

alias tree='exa --tree'
alias ls='exa -a --color=always --group-directories-first'
alias ll='exa -alhg --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias cat='bat'
alias icat='kitten icat'
alias uninstall="uninstall-cli.sh"
alias dots="git --git-dir=$DOTFILES_MIRROR --work-tree=$DOTFILES"

# alias ssh="kitty +kitten ssh"
