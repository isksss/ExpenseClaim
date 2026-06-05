#!/usr/bin/env sh
set -eu

mode="${1:-}"
target_dir="apps/frontend"

if [ "$mode" != "format" ] && [ "$mode" != "lint" ] && [ "$mode" != "check" ]; then
  echo "usage: sh scripts/run-frontend-tool.sh {format|lint|check}" >&2
  exit 2
fi

if [ ! -d "$target_dir" ]; then
  echo "$target_dir does not exist. Skipping frontend $mode."
  exit 0
fi

has_targets="$(
  find "$target_dir" -type f \( \
    -name '*.js' -o \
    -name '*.jsx' -o \
    -name '*.ts' -o \
    -name '*.tsx' -o \
    -name '*.vue' -o \
    -name '*.mjs' -o \
    -name '*.cjs' \
  \) -print -quit
)"

if [ -z "$has_targets" ]; then
  echo "No frontend source files found. Skipping frontend $mode."
  exit 0
fi

case "$mode" in
  format)
    exec oxfmt --write "$target_dir"
    ;;
  lint)
    exec oxlint "$target_dir"
    ;;
  check)
    oxfmt --check "$target_dir"
    exec oxlint "$target_dir"
    ;;
esac
