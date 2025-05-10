#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Emacsd
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Emacs

# Documentation:
# @raycast.description Launch Emacs
# @raycast.author pdxmph
# @raycast.authorURL https://raycast.com/pdxmph

/opt/homebrew/bin/emacsclient -c --no-wait

osascript -e 'tell application "Emacs" to activate'
