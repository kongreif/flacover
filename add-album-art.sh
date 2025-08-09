#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

echo "Starting process to add cover to all flac files."

flac_files=( *.flac )
if (( ${#flac_files[@]} == 0 )); then
  echo "No .flac files in this folder"
  exit 1
fi

metaflac_line=$(metaflac --show-tag=MUSICBRAINZ_ALBUMID "${flac_files[0]}" | head -n1 || true)
musicbrainz_albumid=${metaflac_line#*=}

if [[ -z "${musicbrainz_albumid:-}" || "$musicbrainz_albumid" == "$metaflac_line" ]]; then
  echo "Could not find MUSICBRAINZ_ALBUMID tag in ${flac_files[0]}"
  exit 1
else
  echo "MUSICBRAINZ_ALBUMID is $musicbrainz_albumid."
fi

headers_tmp=$(mktemp)
img_tmp=$(mktemp)
cleanup() { rm -f "$headers_tmp" "$img_tmp"; }
trap cleanup EXIT

echo "Fetching cover from Cover Art Archive."

url_base=https://coverartarchive.org/release/${musicbrainz_albumid}
if ! curl -fSL --retry 3 --retry-delay 1 -D "$headers_tmp" -o "$img_tmp" "$url_base/front-1200"; then
  echo "High-res cover not available, downloading normal res."
  curl -fSL --retry 3 --retry-delay 1 -D "$headers_tmp" -o "$img_tmp" "$url_base/front"
fi

if [ ! -s "$img_tmp" ]; then
  echo "No cover image downloaded."
  exit 1
fi

cover_mime=$(file --mime-type -b "$img_tmp")
echo "Cover mime-type determined as $cover_mime"

case "$cover_mime" in
  image/jpeg) extension="jpg" ;;
  image/png) extension="png" ;;
  image/webp) extension="webp" ;;
  image/gif) extension="gif" ;;
  *) extension="jpg" ;;
esac

out="cover.$extension"
echo "Saving cover as $out."
mv -f "$img_tmp" "$out"

echo "Adding cover to flac files."
metaflac --remove --block-type=PICTURE "${flac_files[@]}"
metaflac --import-picture-from="$out" "${flac_files[@]}"

echo "Done adding album art."
