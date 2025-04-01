#!/usr/bin/env fish

set timestamp (date +%Y-%m-%d_%H-%M-%S)
tmux split-window -h
tmux send-keys 'nvim ~/quick-notes-swap/quick-note_$timestamp' Enter
