# FLACover

Small Bash script to **automatically download and embed album art** into FLAC files using the `MUSICBRAINZ_ALBUMID` tag.

- Works on any already-ripped FLAC album folder (from Whipper or any other ripper, as long as the tag is present).
- Fetches from [Cover Art Archive](https://coverartarchive.org/).
- **Only** works in directories that contain flacs of the same release.
- Prefers high-resolution (`front-1200`) covers, falls back to normal `front`.
- Detects correct image type (JPG, PNG, WEBP, GIF) before embedding.
- Safe for file names with spaces.
- **Optional**: Includes a `whip-and-add-album-art.sh` wrapper that rips CDs with [Whipper](https://github.com/whipper-team/whipper) and runs the cover art script automatically.

---

## Why not just use Whipper's `--cover embed`?

Whipper can embed cover art at rip time if you install the optional dependency **Pillow**:
```bash
pip install pillow
whipper cd rip --cover complete
```
But:
- It only works **during ripping** — can’t fix albums that are already ripped.
- It doesn’t retry different image sizes.
- It doesn’t check MIME types or save a local copy alongside your FLACs.

`add-album-art.sh` works **any time after ripping**, has retries, MIME detection, and can save the image locally.

---

## Dependencies

- `curl`
- `file` (for MIME type detection)
- `flac` (provides `metaflac`)
- `bash` ≥ 4
- FLACs must have a `MUSICBRAINZ_ALBUMID` tag

Optional if using the whipper wrapper:
- `whipper` (and its dependencies: `cdparanoia`, `cdrdao`)

---

## Usage

### Add cover art to an existing album
```bash
cd /path/to/album/folder
/path/to/add-album-art.sh
```
This will:
1. Read the `MUSICBRAINZ_ALBUMID` from the first FLAC.
2. Fetch high-res front cover from Cover Art Archive (retry and fallback).
3. Detect image type and save as `cover.<ext>`.
4. Remove any existing embedded picture blocks in the FLACs.
5. Embed the downloaded cover in all `.flac` files.

### Rip and embed in one go (optional)
The included `whip-and-add-album-art.sh` wraps `whipper cd rip` and runs the art script on the newest ripped album folder:
```bash
whip-and-add-album-art /path/to/output-root
```

---

## Install (run without `./`)

Make both scripts executable:
```bash
chmod +x add-album-art.sh whip-and-add-album-art.sh
```

Install to your `$HOME/.local/bin`:
```bash
mkdir -p "$HOME/.local/bin"
cp add-album-art.sh "$HOME/.local/bin/add-album-art"
cp whip-and-add-album-art.sh "$HOME/.local/bin/whip-and-add-album-art"
```

Ensure `~/.local/bin` is on your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

Now you can run:
```bash
add-album-art
whip-and-add-album-art ~/Music/whipper
```

---

## Troubleshooting

- **"Could not find MUSICBRAINZ_ALBUMID"**  
  → Tag the album with [MusicBrainz Picard](https://picard.musicbrainz.org/) first.

- **"No cover image downloaded"**  
  → No art found in Cover Art Archive for that release ID. Try a different edition or tag.
