#!/usr/bin/env bash

set -Eeuo pipefail

DATE="$(date '+%Y-%m-%d_%H-%M-%S')"
FILE="/tmp/mirzabot_${DATE}.sql"
ARCHIVE="/tmp/mirzabot_${DATE}.sql.gz"

echo "Starting backup..."

mysqldump \
  --single-transaction \
  --routines \
  --triggers \
  --skip-lock-tables \
  --no-tablespaces \
  -h "${MYSQLHOST}" \
  -P "${MYSQLPORT}" \
  -u "${MYSQLUSER}" \
  -p"${MYSQLPASSWORD}" \
  "${MYSQLDATABASE}" > "${FILE}"

gzip -f "${FILE}"

if [ ! -s "${ARCHIVE}" ]; then
    echo "Backup file is empty."
    exit 1
fi

curl --fail --silent --show-error \
  -F "chat_id=${BACKUP_CHAT_ID}" \
  -F "document=@${ARCHIVE}" \
  -F "caption=MirzaBot backup - ${DATE}" \
  "https://api.telegram.org/bot${BACKUP_BOT_TOKEN}/sendDocument"

rm -f "${ARCHIVE}"

echo "Backup sent successfully."
