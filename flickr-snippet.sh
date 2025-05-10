#!/usr/bin/env zsh
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title  Flickr snippet from active tab
# @raycast.mode silent
# @raycast.icon 🌄
# @raycast.description  Grab the URL of your frontmost browser tab (Flickr only) and copy a Markdown/Org/HTML <img> snippet
# @raycast.argument1 { "type": "dropdown", "placeholder": "Format", "optional": false, "data": [ { "title": "Markdown", "value": "md" }, { "title": "Org‑mode", "value": "org" }, { "title": "HTML", "value": "html" } ] }
# @raycast.argument2 { "type": "text", "placeholder": "Alt text (optional)", "optional": true }

set -euo pipefail

FORMAT=$1
ALT_TEXT=${2:-""}

# 1) Get frontmost browser’s URL
APP=$(osascript -e 'tell application "System Events" to name of first application process whose frontmost is true')
case "$APP" in
Safari)
    URL=$(osascript -e 'tell application "Safari" to return URL of front document') # :contentReference[oaicite:0]{index=0}
    ;;
"Google Chrome" | "Brave Browser" | "Microsoft Edge")
    URL=$(osascript -e 'tell application "Google Chrome" to return URL of active tab of first window') # :contentReference[oaicite:1]{index=1}
    ;;
*)
    echo "⚠️ Unsupported app: $APP"
    exit 1
    ;;
esac

# 2) Validate it’s a Flickr photo page
if [[ ! $URL =~ https?://(www\.)?flickr\.com/photos/ ]]; then
    echo "⚠️ Not a Flickr photo URL: $URL"
    exit 1
fi

# 3) oEmbed → JSON
ENC=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=""))' "$URL")
OEMBED=$(curl -s "https://www.flickr.com/services/oembed?format=json&url=$ENC")

# 4) Extract direct image URL
IMG_URL=$(echo "$OEMBED" | /usr/bin/jq -r .url)
if [[ -z $IMG_URL || $IMG_URL == "null" ]]; then
    echo "⚠️ Failed to extract image URL."
    exit 1
fi

# 5) Build snippet
case $FORMAT in
md)
    [[ -n $ALT_TEXT ]] && SNIP="![${ALT_TEXT//\"/\\\"}]($IMG_URL)" || SNIP="![]($IMG_URL)"
    ;;
org)
    [[ -n $ALT_TEXT ]] && SNIP="[[img:${IMG_URL}][${ALT_TEXT//\]/\\]}]]" || SNIP="[[${IMG_URL}]]"
    ;;
html)
    [[ -n $ALT_TEXT ]] && SNIP="<img src=\"$IMG_URL\" alt=\"${ALT_TEXT//\"/\\\"}\">" || SNIP="<img src=\"$IMG_URL\">"
    ;;
esac

# 6) Copy & notify
printf '%s' "$SNIP" | pbcopy
terminal-notifier -title "Flickr snippet" -message "Copied $FORMAT snippet" -sound default
