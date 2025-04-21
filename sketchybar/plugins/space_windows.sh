#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# Debug configuration
DEBUG=false  # Master debug switch
LOG_FILE="$CONFIG_DIR/test.log"

log_debug() {
  if [ "$DEBUG" = true ]; then
    echo "$@" >> "$LOG_FILE"
  fi
}

time_start() {
  if [ "$DEBUG" = true ]; then
    TIME_BEGIN=$(get_ms_time)
    log_debug "---------------------------------"
  fi
}

time_checkpoint() {
  if [ "$DEBUG" = true ]; then
    local checkpoint_name="$1"
    local current_time=$(get_ms_time)
    local elapsed=$((current_time - TIME_BEGIN))
    log_debug "Checkpoint [$checkpoint_name]: $elapsed ms"
  fi
}

time_end() {
  if [ "$DEBUG" = true ]; then
    local end_time=$(get_ms_time)
    local elapsed=$((end_time - TIME_BEGIN))
    log_debug "Elapsed time end: $elapsed ms"
  fi
}

# Define state file
STATE_FILE="$HOME/.cache/sketchybar/space_windows_state"

# Make sure everything is set up
if [ ! -d "$HOME/.cache/sketchybar" ]; then
  mkdir -p "$HOME/.cache/sketchybar"
fi
if [ ! -f "$STATE_FILE" ]; then
  touch "$STATE_FILE"
  echo "AEROSPACE_LAST_FOCUSED_WORKSPACE=" > "$STATE_FILE"
fi

# Load previous state
if [ -f "$STATE_FILE" ]; then
  source "$STATE_FILE"
fi

STATE_CACHE_UPDATE=""

get_ms_time() {
  echo $(($(gdate +%s%N)/1000000))
}

# Initialize timing if enabled
time_start

reload_workspace_icon() {
  local apps="$AEROSPACE_APPS_CURRENT_WORKSPACE"

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi

  # SKETCHYBAR_CMD+="--animate sin 10 --set space.$@ label=\"$icon_strip\""
  sketchybar --animate sin 10 --set space.$@ label="$icon_strip"
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  # Log the persisted last workspace value
  log_debug "last workspace: $AEROSPACE_LAST_FOCUSED_WORKSPACE"
  log_debug "last apps: $AEROSPACE_APPS_PREV_WORKSPACE"

  AEROSPACE_APPS_CURRENT_WORKSPACE=$(aerospace list-windows --workspace "$AEROSPACE_FOCUSED_WORKSPACE" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
  time_checkpoint "after aerospace query"
  reload_workspace_icon "$AEROSPACE_FOCUSED_WORKSPACE"
  time_checkpoint "after reload_workspace_icon"

  # Set display for all non-empty workspaces on the focused monitor
  # TODO: Activate if needed
  # for i in $AEROSAPCE_WORKSPACE_FOCUSED_MONITOR; do
  #   if [ "$i" != "$AEROSPACE_FOCUSED_WORKSPACE" ]; then
  #     sketchybar --set space.$i display=$AEROSPACE_FOCUSED_MONITOR
  #   fi
  # done

  if [ "$AEROSPACE_FOCUSED_WORKSPACE" != "$AEROSPACE_PREV_WORKSPACE" ]; then
    SKETCHYBAR_CMD=""

    # Current workspace space settings
    SKETCHYBAR_CMD+=" --set space.$AEROSPACE_FOCUSED_WORKSPACE icon.highlight=true \
                   label.highlight=true \
                   background.border_color=$GREY \
                   display=$AEROSPACE_FOCUSED_MONITOR"

    # Previous workspace space settings
    SKETCHYBAR_CMD+=" --set space.$AEROSPACE_PREV_WORKSPACE icon.highlight=false \
                   label.highlight=false \
                   background.border_color=$BACKGROUND_2 \
                   display=$AEROSPACE_FOCUSED_MONITOR"

    # Hide empty workspaces
    # TODO: Deactivate if not needed
    if [ -z "$AEROSPACE_APPS_PREV_WORKSPACE" ]; then
      SKETCHYBAR_CMD+=" --set space.$AEROSPACE_PREV_WORKSPACE display=0"
    fi

    sketchybar $SKETCHYBAR_CMD
    time_checkpoint "after sketchybar update"

    AEROSPACE_APPS_PREV_WORKSPACE=$(echo "$AEROSPACE_APPS_CURRENT_WORKSPACE" | tr '\n' ',' | sed 's/,$//')
    STATE_CACHE_UPDATE+="\nAEROSPACE_APPS_PREV_WORKSPACE=\"$AEROSPACE_APPS_PREV_WORKSPACE\""
  fi

  log_debug "current workspace: $AEROSPACE_FOCUSED_WORKSPACE"
  log_debug "current apps: $AEROSPACE_APPS_CURRENT_WORKSPACE"
fi

STATE_CACHE_UPDATE+="\nAEROSPACE_PREV_FOCUSED_WORKSPACE=\"$AEROSPACE_FOCUSED_WORKSPACE\""

if [ "$STATE_CACHE_UPDATE" != "" ]; then
  echo -e "$STATE_CACHE_UPDATE" > "$STATE_FILE"
fi

# Log final timing and workspace information
time_end
