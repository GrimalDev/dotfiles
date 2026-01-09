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

