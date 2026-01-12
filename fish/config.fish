set fish_greeting

set -gx XDG_CONFIG_HOME $HOME/.config
set -gx DOTFILES "$HOME/.config"
if test -d $HOME/.dotfiles
    set -gx DOTFILES_MIRROR "$HOME/.dotfiles"
end
set -gx EDITOR "nvim"
set -gx XDEBUG_SESSION 1

set -e fish_user_paths

set -l bun_path "$HOME/.bun"
set -l esp_rust "$HOME/.rustup/toolchains/esp/xtensa-esp-elf/esp-14.2.0_20240906/xtensa-esp-elf/bin"
set -l go_bin "$HOME/go/bin"

fish_add_path \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.pub-cache/bin" \
    "$HOME/.rbenv/versions/3.4.2/bin" \
    "$HOME/.pyenv/bin" \
    "$HOME/.avr/bin" \
    "$HOME/esp/xtensa-lx106-elf/bin" \
    "$m2_path/bin" \
    "$bun_path/bin" \
    "$go_bin" \
    "$esp_rust" \

function __fish_command_not_found_handler --on-event fish_command_not_found
    echo "fish: Unknown command '$argv'"
end

function sudo
    if test "$argv" = !!
        eval command sudo -E $history[1]
    else
        set -x TERMINFO "$TERMINFO"
        command sudo -E $argv
    end
end

function jj
    if test "$argv" = ""
        command jj --limit 5
    else
        command jj $argv
    end
end

function jqf
    set -l search_string $argv[1]
    set -l file $argv[2]
    jq 'paths | map(tostring) | join(".") | select(contains("'$search_string'"))' $file
end

function share
    curl -F "file=@$argv" https://0x0.st | pbcopy
end

if test -f /etc/.env
    cat /etc/.env | while read line
        if test -z $line; or string match -q -r "^#" $line
            continue
        end
        set -l env_var (string split -m 1 "=" $line)
        set -gx $env_var[1] $env_var[2]
    end
end

set nvimSessionsPath "$HOME/sessions/"
if test ! -d $nvimSessionsPath
    mkdir -p $nvimSessionsPath
end
set -gx NVIM_SESSIONS $nvimSessionsPath

set -gx ATAC_MAIN_DIR ~/ATAC_MAIN_DIR
set -gx ATAC_KEY_BINDINGS $DOTFILES/atac/custom_keybindings.toml
if test ! -d ~/ATAC_MAIN_DIR
    mkdir ~/ATAC_MAIN_DIR
    touch ~/ATAC_MAIN_DIR/custom_keybindings.toml
    touch ~/ATAC_MAIN_DIR/atac.toml
end

if status is-interactive
    fish_vi_key_bindings

    set -U FZF_CD_WITH_HIDDEN_COMMAND "fd -H -u --type d --exclude node_modules . \$dir"
    set -U FZF_PRINT_WITH_HIDDEN_COMMAND "fd -H -u --type d --exclude node_modules ."
    set -U FZF_OPEN_COMMAND "fd -H -u --type f --exclude node_modules . \$dir"
    set -U FZF_TMUX 1
    set -e FZF_COMPLETE 0
    set -U FZF_ENABLE_OPEN_PREVIEW 0

    bind -M insert \Co '__fzf_open --editor'
    bind -M insert \t '__fzf_complete'
    bind -M insert \ee "nvim"
    bind -M insert \el __fish_list_current_token
    bind -M insert \ex list_run_files
    bind -M insert \er yazi
    bind -M insert \ed "lazydocker"

    alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'
    alias immozia="cd $HOME/Desktop/oxianet/immozia"
    alias tree='exa --tree'
    alias ls='exa -a --color=always --group-directories-first'
    alias ll='exa -alhg --color=always --group-directories-first'
    alias lt='exa -aT --color=always --group-directories-first'
    alias cat='bat'
    alias icat='kitten icat'
    alias uninstall="uninstall-cli.sh"
    alias dots="git --git-dir=$DOTFILES_MIRROR --work-tree=$DOTFILES"
    alias tail="grc tail"
    alias ff="fastfetch --config ~/.config/fastfetch/config.json"
    alias trash="rm -rf ~/.Trash/* && rm -rf ~/.Trash/.*"
    alias col="colima start --vm-type=vz --mount-type=virtiofs"
    alias z="zathura"
    alias pulse="pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon"
    alias nx-usbloader="java -jar ~/nintendo-switch/tools/ns-usbloader-7.2-m1.jar"
    alias sc="sesh connect"

    zoxide init fish | source
    starship init fish | source
end

