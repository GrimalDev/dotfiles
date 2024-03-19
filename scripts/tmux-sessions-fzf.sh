#!/bin/bash

# if no sessions diplay a message
if [ -z "$(tmux list-session)" ] ; then
  # ask to create a new session
  create_new_session=$(echo -e "y\nn" | choose --prompt="No sessions found. Create a new session? ")

  ["$create_new_session" == "n"] && exit 1

  # create a new session
  tmux new -s "$create_new_session"

  exit 0
fi

# selected_session=$(tmux list-session -F '#S' | fzf --reverse --height 40% --border --prompt="Select a session: ")
selected_session=$(tmux list-session -F '#S' | choose)

# if no session selected, exit
[ -z "$selected_session" ] && exit 1

tmux attach -t "$selected_session"
