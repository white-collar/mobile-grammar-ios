#!/bin/sh
# Copies lessons, categories and About pages from the web app (white-collar/mobile-grammar-web),
# so both apps show the same content.
#   tools/sync_content.sh ../mobile-grammar-web
set -eu
web="${1:?usage: tools/sync_content.sh <mobile-grammar-web checkout>}"
target="$(dirname "$0")/../MobileGrammar/Resources/Content"
rm -rf "$target"
mkdir -p "$target"
cp "$web/data/lessons.json" "$web/data/categories.json" "$target/"
cp -R "$web/data/lessons" "$target/lessons"
cp -R "$web/data/about" "$target/about"
echo "copied $(ls "$target/lessons" | wc -l | tr -d ' ') lessons"
