#!/bin/bash
# Builds CleanPaste as a universal (arm64 + x86_64) .app and packages it into a DMG.
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="CleanPaste"
DMG_NAME="CleanPaste-universal.dmg"
DIST_DIR="dist"

echo "==> Building universal release binary"
swift build -c release --arch arm64 --arch x86_64
BIN_DIR=$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)
BINARY="$BIN_DIR/$APP_NAME"

echo "==> Verifying architectures"
lipo -info "$BINARY"

echo "==> Assembling $APP_NAME.app"
rm -rf "$DIST_DIR"
APP_DIR="$DIST_DIR/$APP_NAME.app"
mkdir -p "$APP_DIR/Contents/MacOS"
cp "$BINARY" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp Resources/Info.plist "$APP_DIR/Contents/Info.plist"

echo "==> Ad-hoc code signing"
codesign --force --sign - "$APP_DIR"

echo "==> Creating $DMG_NAME"
DMG_ROOT="$DIST_DIR/dmg-root"
mkdir -p "$DMG_ROOT"
cp -R "$APP_DIR" "$DMG_ROOT/"
ln -s /Applications "$DMG_ROOT/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_ROOT" -ov -format UDZO "$DIST_DIR/$DMG_NAME"
rm -rf "$DMG_ROOT"

echo "==> Done: $DIST_DIR/$DMG_NAME"
