#!/usr/bin/env bash
#
# Backup Mudabbir JSON stores (expenses, goals, budgets, challenges).
# Output: dated .tar.gz OUTSIDE the repo by default.
#
# Usage:
#   ./scripts/backup-json.sh
#   MUDABBIR_BACKUP_DIR=/path/to/safe/place ./scripts/backup-json.sh
#
# GitHub Actions sets MUDABBIR_BACKUP_DIR to a temp dir and uploads the artifact.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STORAGE_APP="${REPO_ROOT}/backend/storage/app"
DATE_STAMP="$(date -u +%Y-%m-%d)"
TIME_STAMP="$(date -u +%H%M%S)"
DEFAULT_OUT="${HOME}/mudabbir-json-backups"
OUT_DIR="${MUDABBIR_BACKUP_DIR:-${DEFAULT_OUT}}"
ARCHIVE_NAME="mudabbir-json-${DATE_STAMP}-${TIME_STAMP}Z.tar.gz"
ARCHIVE_PATH="${OUT_DIR}/${ARCHIVE_NAME}"
MANIFEST_NAME="manifest-${DATE_STAMP}-${TIME_STAMP}Z.txt"

if [[ ! -d "${STORAGE_APP}" ]]; then
  echo "ERROR: storage/app not found at ${STORAGE_APP}" >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"

STAGING="$(mktemp -d)"
trap 'rm -rf "${STAGING}"' EXIT

JSON_COUNT=0
while IFS= read -r -d '' json_file; do
  rel="${json_file#${STORAGE_APP}/}"
  dest_dir="${STAGING}/storage-app/$(dirname "${rel}")"
  mkdir -p "${dest_dir}"
  cp "${json_file}" "${STAGING}/storage-app/${rel}"
  JSON_COUNT=$((JSON_COUNT + 1))
done < <(find "${STORAGE_APP}" -type f -name '*.json' -print0)

if [[ "${JSON_COUNT}" -eq 0 ]]; then
  echo "WARN: no *.json files under ${STORAGE_APP}" >&2
fi

{
  echo "mudabbir-json-backup"
  echo "created_utc=${DATE_STAMP}T${TIME_STAMP}Z"
  echo "repo_root=${REPO_ROOT}"
  echo "storage_app=${STORAGE_APP}"
  echo "json_file_count=${JSON_COUNT}"
  echo ""
  echo "files:"
  find "${STAGING}/storage-app" -type f | sort | while read -r f; do
    rel="${f#${STAGING}/storage-app/}"
    size="$(wc -c < "${f}" | tr -d ' ')"
    if command -v sha256sum >/dev/null 2>&1; then
      hash="$(sha256sum "${f}" | awk '{print $1}')"
    elif command -v shasum >/dev/null 2>&1; then
      hash="$(shasum -a 256 "${f}" | awk '{print $1}')"
    else
      hash="n/a"
    fi
    echo "  ${rel}  bytes=${size}  sha256=${hash}"
  done
} > "${STAGING}/${MANIFEST_NAME}"

tar -czf "${ARCHIVE_PATH}" -C "${STAGING}" .

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "${ARCHIVE_PATH}" | tee "${ARCHIVE_PATH}.sha256"
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "${ARCHIVE_PATH}" | tee "${ARCHIVE_PATH}.sha256"
fi

echo ""
echo "Backup complete."
echo "  Archive: ${ARCHIVE_PATH}"
echo "  JSON files: ${JSON_COUNT}"
echo "  Size: $(wc -c < "${ARCHIVE_PATH}" | tr -d ' ') bytes"
echo ""
echo "Keep at least 3 copies (server + local + off-site artifact) before any migration."
