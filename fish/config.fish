alias immozia="cd /Users/thehiddengeek/Desktop/oxianet/immozia"

alias tree='exa --tree'
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing

alias python=/opt/homebrew/bin/python3.11


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

# Set the PATH
set -gx PATH $HOME/.pyenv/shims $PATH

# Set the M2_HOME and update the PATH for Apache Maven
set -gx M2_HOME /Users/thehiddengeek/apache-maven-3.9.0
set -gx PATH $M2_HOME/bin $PATH

# Set BUN_INSTALL and update PATH for bun
set -gx BUN_INSTALL /Users/thehiddengeek/.bun
set -gx PATH $BUN_INSTALL/bin $PATH

# Update PATH for ImageMagick
set -gx PATH /usr/local/opt/imagemagick@7/bin $PATH

set -gx EDITOR "nvim"

# Custom aliases
alias uninstall="uninstall-cli.sh"

# Set NODE_PATH
set -gx NODE_PATH /usr/local/Lib/node_modules

# Set JAVA_HOME
set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home
set -gx PATH $JAVA_HOME/bin $PATH

alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

set -U FZF_CD_WITH_HIDDEN_COMMAND "fd -H -u --type d --exclude node_modules . \$dir"
set -U FZF_PRINT_WITH_HIDDEN_COMMAND "fd -H -u --type d --exclude node_modules ."
set -U FZF_OPEN_COMMAND "fd -H -u --type f --exclude node_modules . \$dir"
bind -M insert \co '__fzf_open --editor'
set -U FZF_TMUX 1
set -e FZF_COMPLETE 0
bind -M insert -e \t '__fzf_complete'
set -U FZF_ENABLE_OPEN_PREVIEW 0

bind -M insert \ee "nvim"
bind -M insert \ec "nvim ~/.config/fish/config.fish"
bind -M insert \er "ranger"
bind -M insert \el __fish_list_current_token # my preferred listing
bind -M insert \ew "/bin/bash ~/.config/scripts/tmux-sessions-fzf.sh"
