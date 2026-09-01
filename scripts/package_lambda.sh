#!/usr/bin/env bash
# Builds the Lambda deployment zip from app/src. Used by CI before
# `terraform apply`; safe to run locally too for a quick sanity check.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/../app"
BUILD_DIR="$APP_DIR/build"
OUTPUT_ZIP="${1:-$APP_DIR/build/app.zip}"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$(dirname "$OUTPUT_ZIP")"

pip install \
  --requirement "$APP_DIR/src/requirements.txt" \
  --target "$BUILD_DIR" \
  --no-cache-dir \
  --quiet

cp "$APP_DIR/src/handler.py" "$BUILD_DIR/"

# Zip into a temp file outside BUILD_DIR, then move into place. Avoids
# `mv samefile samefile` when OUTPUT_ZIP lives under BUILD_DIR (the default).
TMP_ZIP="$(mktemp "${TMPDIR:-/tmp}/app.zip.XXXXXX")"
(cd "$BUILD_DIR" && zip -r -q "$TMP_ZIP" .)
mv -f "$TMP_ZIP" "$OUTPUT_ZIP"

echo "Built $OUTPUT_ZIP"
