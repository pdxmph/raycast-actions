#!/usr/bin/env zsh -l
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title imgup (Finder)
# @raycast.mode silent
# @raycast.icon 📷
# @raycast.description Upload an image from Photos.app or Finder and copy the snippet
# @raycast.author pdxmph
# @raycast.authorURL https://raycast.com/pdxmph
#
# @raycast.argument1 { "type": "text", "placeholder": "Title" }
# @raycast.argument2 { "type": "text", "placeholder": "Desc/alt text" }
# @raycast.argument3 { "type": "text", "placeholder": "Tags (comma-delimited)" }

set -euo pipefail

TITLE=$1
ALT_TEXT=$2
TAGS=$3
SOURCE="finder"

# 1) Determine IMAGE path
if [[ $SOURCE == "photos" ]]; then
  # export the selected photo to a temp directory
  EXPORT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/imgup.XXXXXX")
  osascript <<EOF
set exportPath to POSIX file "$EXPORT_DIR" as alias
tell application "Photos"
  set sel to selection
  if sel = {} then error "No photo selected."
  export sel to exportPath using originals yes
end tell
EOF
  # slight pause to ensure file appears
  sleep 1
  IMAGE="$EXPORT_DIR/$(ls -1t "$EXPORT_DIR" | head -n1)"
else
  # get the first selected file in Finder
  IMAGE=$(
    osascript <<AS
tell application "Finder"
  set sel to selection
  if sel = {} then error "No file selected."
  return POSIX path of (item 1 of sel as alias)
end tell
AS
  )
fi

# 2) Notify start
terminal-notifier -title "🤖 📦" -message "Processing …"

# 3) Run imgup CLI
SNIPPET=$(
  imgup \
    --title ${TITLE// / } \
    --caption ${ALT_TEXT// / } \
    --tags ${TAGS// / } \
    "$IMAGE"
)

# 4) Copy result and notify
printf '%s' "$SNIPPET" | pbcopy
terminal-notifier \
  -title "Image uploaded" \
  -message "📋 Snippet ready" \
  -sound default \
  -remove com.Apple.terminal

# 5) Cleanup temp if used
if [[ $SOURCE == "photos" ]]; then
  rm -rf "$EXPORT_DIR"
fi
