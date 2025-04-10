#!/bin/bash

# === CONFIGURATION ===
OUTDIR="$HOME/Music/Captures"
mkdir -p "$OUTDIR"
LOGFILE="$OUTDIR/log.txt"

sanitize_soft() {
  echo "$1" \
    | iconv -f utf-8 -t ascii//TRANSLIT \
    | sed 's/[\/:*?"<>|]//g' \
    | sed 's/  */ /g' \
    | sed 's/^ *//;s/ *$//' \
    | tr -d '\n'
}

PID_REC=""
CURRENT_META=""
CURRENT_TITLE=""
CURRENT_ARTIST=""
CURRENT_ALBUM=""
TMPRAW=""
TMPMETA=""
PLAYER=""
INTERRUPTED=false

SOURCE=$(pactl list short sources | grep monitor | fzf --prompt="🎚 Choose a source: " | awk '{print $2}')
[[ -z "$SOURCE" ]] && echo "❌ No source selected." && exit 1
echo "[🎧] Source selected: $SOURCE"

PLAYER=$(playerctl -l | fzf --prompt="🎛 Choose a player: ")
[[ -z "$PLAYER" ]] && echo "❌ No player selected." && exit 1
echo "[🎛] Player selected: $PLAYER"

process_track() {
  local RAW="$1"
  local META="$2"

  [[ ! -f "$RAW" || ! -f "$META" ]] && echo "[⚠️] Missing raw or metadata file." && return

  local DATE=$(basename "$RAW" .raw | cut -d'_' -f2)
  local WAV="$OUTDIR/recording_${DATE}.wav"

  local TITLE=$(grep "^TITLE=" "$META" | cut -d'=' -f2-)
  local ARTIST=$(grep "^ARTIST=" "$META" | cut -d'=' -f2-)
  local ALBUM=$(grep "^ALBUM=" "$META" | cut -d'=' -f2-)

  local SAFE_TITLE=$(sanitize_soft "$TITLE")
  local SAFE_ARTIST=$(sanitize_soft "$ARTIST")
  local SAFE_ALBUM=$(sanitize_soft "$ALBUM")

  local MP3="$OUTDIR/${DATE}__${SAFE_ARTIST} - ${SAFE_TITLE} - ${SAFE_ALBUM}.mp3"

  sox -t raw -r 44100 -e signed -b 16 -c 2 "$RAW" "$WAV" && \
  lame "$WAV" "$MP3" && \
  id3v2 -t "$TITLE" -a "$ARTIST" -A "$ALBUM" "$MP3"

  echo "[💾] Saved: $MP3"
  echo "$DATE | $ARTIST - $TITLE | Album: $ALBUM"  >> "$LOGFILE"

  rm -f "$RAW" "$WAV" "$META"
}

cleanup_and_exit() {
  echo
  echo "[🛑] Exit requested..."
  INTERRUPTED=true

  kill "$PID_REC" 2>/dev/null
  wait "$PID_REC" 2>/dev/null

  if [[ -n "$TMPRAW" && -f "$TMPRAW" && -f "$TMPMETA" ]]; then
    process_track "$TMPRAW" "$TMPMETA" 
  fi

  echo "[👋] Done."
  exit 0
}

trap cleanup_and_exit INT

echo "[🎙] Multi mode — automatic track detection on \"$PLAYER\"... CTRL+C to quit"

while true; do
  META=$(playerctl -p "$PLAYER" metadata 2>/dev/null)

  TITLE=$(echo "$META" | grep -oP '(?<=xesam:title\s).*' | head -n 1)
  ARTIST=$(echo "$META" | grep -oP '(?<=xesam:artist\s).*' | head -n 1)
  ALBUM=$(echo "$META" | grep -oP '(?<=xesam:album\s).*' | head -n 1)

  [[ -z "$TITLE" ]] && sleep 1 && continue

  if [[ "$META" != "$CURRENT_META" ]]; then
    if [[ -n "$CURRENT_META" ]]; then
      kill "$PID_REC" 2>/dev/null
      wait "$PID_REC" 2>/dev/null
      process_track "$TMPRAW" "$TMPMETA" &
    fi

    CURRENT_META="$META"
    CURRENT_TITLE="$TITLE"
    CURRENT_ARTIST="$ARTIST"
    CURRENT_ALBUM="$ALBUM"
    DATE=$(date +%Y%m%d-%H%M%S)

    TMPRAW="$OUTDIR/recording_${DATE}.raw"
    TMPMETA="$OUTDIR/recording_${DATE}.metadata"

    echo "TITLE=$CURRENT_TITLE" > "$TMPMETA"
    echo "ARTIST=$CURRENT_ARTIST" >> "$TMPMETA"
    echo "ALBUM=$CURRENT_ALBUM" >> "$TMPMETA"

    echo
    echo "[▶] New track: $CURRENT_TITLE - $CURRENT_ARTIST"

    parec --device="$SOURCE" --rate=44100 --channels=2 --format=s16le > "$TMPRAW" &
    PID_REC=$!
  fi

  sleep 1
done

