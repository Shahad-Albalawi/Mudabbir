#!/usr/bin/env bash
# Archive legacy JSON stores from backend/storage/app for off-site backup.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${ROOT}/backend/storage/app"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
OUT="${ROOT}/mudabbir-json-backup-${STAMP}.tar.gz"

if [ ! -d "${APP_DIR}" ]; then
  echo "ERROR: ${APP_DIR} not found" >&2
  exit 1
fi

files=()
for name in expenses.json goals.json budgets.json challenges.json; do
  if [ -f "${APP_DIR}/${name}" ]; then
    files+=("${name}")
  fi
done

if [ "${#files[@]}" -eq 0 ]; then
  echo "WARN: no JSON store files found in ${APP_DIR}" >&2
  exit 0
fi

tar -czf "${OUT}" -C "${APP_DIR}" "${files[@]}"
echo "Backup written: ${OUT}"
ls -lh "${OUT}"
