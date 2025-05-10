#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Notes Check
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Check git sync status of notes
# @raycast.author pdxmph
# @raycast.authorURL https://raycast.com/pdxmph

cd ~/notes
osascript -e "display dialog \"$(git log -1)\" with title \"Git $(git log -1 --pretty=format:%h)\" buttons {\"OK\"} default button 1"
