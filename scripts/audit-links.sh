#!/usr/bin/env bash
set -euo pipefail

TARGET_FILE="${1:-README.md}"
OUT_DIR="research"
OUT_FILE="$OUT_DIR/link-audit-$(date +%Y%m%d-%H%M%S).txt"

mkdir -p "$OUT_DIR"

rg -o 'https?://[^) ]+' "$TARGET_FILE" \
  | sed 's/[.,]$//' \
  | sed 's/"$//' \
  | sort -u \
  | while IFS= read -r url; do
      code=$(curl -L -I -o /dev/null -s -w '%{http_code}' --max-time 12 "$url" || true)
      if [ -z "$code" ]; then code="000"; fi
      printf '%s %s\n' "$code" "$url"
    done > "$OUT_FILE"

printf 'Wrote %s\n' "$OUT_FILE"
awk '{print $1}' "$OUT_FILE" | sort | uniq -c | sort -nr
