set -e

find /downloads -name '*.cue' | sort | while read cue; do
  echo "Consider the cue: $cue"
  flac="${cue%.cue}.flac"
  ape="${cue%.cue}.ape"
  wavpack="${cue%.cue}.wv"
  dir="$(dirname "$cue")"


  if ! [ -f "$flac" ]; then
    if [ -f "$ape" ]; then
      echo "It has an ape"
      ffmpeg -i "$ape" "$flac"
    elif [ -f "$wavpack" ]; then
      echo "It has a wavpack :|"
      ffmpeg -i "$wavpack" "$flac"
    else
      echo "It has no flac"
      continue 
    fi
  fi

  if [ "$(find "$dir" -name '*.flac' -maxdepth 1 | wc -l)" -gt 1 ]; then
    echo "There is more than one flac..."
    continue
  fi

  cd "$dir"
  echo "Splitting"
  shnsplit -f "$cue" -t "%n - %t" -o flac "$flac" 2>/dev/null >/dev/null
  cd ..
done
