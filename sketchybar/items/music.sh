sketchybar -m --add item music center                         \
  --set music script="~/.config/sketchybar/plugins/music.sh"  \
  click_script="~/.config/sketchybar/plugins/music_click"  \
  label.padding_right=10                                   \
  drawing=off                                              \
  --subscribe music song_update
