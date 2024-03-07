#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title vpn home pfsense disconnect
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📡
# @raycast.packageName Viscosity VPN control

# Documentation:
# @raycast.description Disconnect from home VPN
# @raycast.author grimaldev
# @raycast.authorURL https://www.baptistegrimaldi.com

/Users/thehiddengeek/.pyenv/shims/python /opt/homebrew/bin/viscosity-cli home-pfsense-grimaldev disconnect

