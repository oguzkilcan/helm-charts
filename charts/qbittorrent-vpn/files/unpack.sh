#!/bin/bash
# Usage: unpack.sh <content path> <destination directory>
# Extracts every rar, zip and 7z archive found under the content path into the destination directory.

set -uo pipefail

exec >> /config/unpack.log 2>&1

src=$1
dest=$2

echo "$(date -Iseconds) unpacking ${src} into ${dest}"

find "$src" -type f \( -iname '*.rar' -o -iname '*.zip' -o -iname '*.7z' \) -print0 |
  while IFS= read -r -d '' archive; do
    name=$(basename "$archive")

    # only the first volume of a multi-volume rar, unrar picks up the rest
    if [[ ${name,,} =~ \.part([0-9]+)\.rar$ ]] && ((10#${BASH_REMATCH[1]} != 1)); then
      continue
    fi

    mkdir -p "$dest"

    case ${name,,} in
      *.rar) unrar x -o- -idq "$archive" "$dest/" ;;
      *) 7z x -aos -bd -o"$dest" "$archive" > /dev/null ;;
    esac || echo "$(date -Iseconds) failed to extract ${archive}"
  done
