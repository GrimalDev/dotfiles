#!/bin/bash

closeoption=$1

if [[ closeoption == "close" ]]; then
 osascript -e 'tell application "System Events" to keystroke "w" using {command down}'
 exit 0
fi

if [[ closeoption == "quit" ]]; then
  osascript -e 'tell application "System Events" to keystroke "q" using {command down}'
  exit 0
fi

echo "Invalid option"
exit 1
