#!/bin/sh
printf '\033c\033]0;%s\a' Panthers Arcade Game
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Panthers Arcade Game.arm64" "$@"
