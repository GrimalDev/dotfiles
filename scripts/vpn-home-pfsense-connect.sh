#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title vpn home pfsense connect
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📡
# @raycast.packageName viscosity connection

# Documentation:
# @raycast.description Connect to home pfsense VPN
# @raycast.author grimaldev
# @raycast.authorURL https://www.baptistegrimaldi.com

/Users/grimaldev/.pyenv/bin/python /opt/homebrew/bin/viscosity-cli home-pfsense-grimaldev connect
