#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

out_root="${1:-}"

if [[ -z "$out_root" ]]; then
  echo "Usage: $0 /path/to/output-root [/dev/sr0]" >&2
  exit 1
fi

mkdir -p -- "$out_root"
echo "Ripping to: $out_root"
whipper cd rip --output-directory "$out_root"

echo "Done whipping."

latest_album_dir="$(
  find "$out_root" -type f -name '*.flac' -printf '%T@|%h\n' \
  | sort -n \
  | tail -1 \
  | cut -d'|' -f2-
)"

if [[ -z "${latest_album_dir:-}" || ! -d "$latest_album_dir" ]]; then
  echo "Couldn't locate the ripped album directory under: $out_root" >&2
  exit 1
fi

echo "Switching to detected new album directory: '$latest_album_dir'"
cd "$latest_album_dir"

script_src="${BASH_SOURCE[0]}"
script_dir="$(cd -- "$(dirname -- "$(readlink -f -- "$script_src")")" && pwd)"

if [[ ! -x "$script_dir/add-album-art.sh" ]]; then
  echo "Missing or not executable: $script_dir/add-album-art.sh" >&2
  exit 1
fi

"$script_dir/add-album-art.sh"

echo "Done whipping and adding album art."
