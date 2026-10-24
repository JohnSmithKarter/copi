#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

flutter build macos --release

app="build/macos/Build/Products/Release/copi.app"
if [ ! -d "$app" ]; then
  echo "Не найден $app" >&2
  exit 1
fi

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

cp -R "$app" "$stage/"
ln -s /Applications "$stage/Applications"

mkdir -p dist
dmg="dist/copi.dmg"

hdiutil create \
  -volname "copi" \
  -srcfolder "$stage" \
  -ov \
  -format UDZO \
  "$dmg"

open -R "$dmg"
