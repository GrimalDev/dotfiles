#!/bin/bash

while [[ true ]]; do

  yabai -m query --windows | jq -r '.[] | select(.app == "'$1'")'

  sleep 1

done

