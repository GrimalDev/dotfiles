function genSeshConfig
    set -l genFile $DOTFILES/sesh/sesh-autogen.toml
    echo "" > $genFile
    set -l seshTemplate "\n[[session]]\nname = 'NAME ⚙️'\npath = 'CONFIG'\n\n"
    set -l configNames (fd -p -t d -d 1 . $HOME/.config/)

    for config in $configNames
        set -l configName (string replace -r "$DOTFILES/" "" $config)
        set -l configName (string replace -r "/" "" $configName)
        if rg -q $config $DOTFILES/sesh/sesh.toml
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
