#!/bin/zsh
# Build Maccy with slot shortcuts (Apple Silicon + Intel), install it as "/Applications/Maccy Slots.app"
# and zip it as "Maccy Slots.zip" for sharing.
set -e
cd "${0:A:h}"
./test_slots.sh

xcodebuild -project Maccy.xcodeproj -scheme Maccy -configuration Release -derivedDataPath build \
  -destination 'generic/platform=macOS' CODE_SIGN_IDENTITY="-" CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM="" ENABLE_HARDENED_RUNTIME=NO \
  build | grep -E "error:|BUILD (SUCCEEDED|FAILED)"

app=build/Build/Products/Release/Maccy.app
osascript -e 'quit app id "local.MaccySlots"' 2>/dev/null || true
rm -rf "/Applications/Maccy Slots.app"
ditto "$app" "/Applications/Maccy Slots.app"
rm -f "Maccy Slots.zip"
ditto -c -k --keepParent "/Applications/Maccy Slots.app" "Maccy Slots.zip"
open "/Applications/Maccy Slots.app"
