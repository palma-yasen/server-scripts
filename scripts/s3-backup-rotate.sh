#!/bin/bash

BACKUP_DIR="/home/backup/daily"

PROFILE="timeweb-ru-1"
ENDPOINT="https://s3.twcstorage.ru"
S3_PATH="s3://934cf527-89ff-47b2-bd9d-99abe40de4e0/daily/"

KEEP=30

echo "=== START $(date) ==="

# -------------------------------------------------
# 0. CyberPanel backup (spinner оставляем)
# -------------------------------------------------

echo "Running CyberPanel daily backup..."

spinner() {
    local pid=$!
    local spin='-\|/'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\rRunning local backup task... ${spin:$i:1}"
        sleep .2
    done
    printf "\rRunning CyberPanel daily backup... done!\n"
}

START_TIME=$(date +%s)

/usr/local/CyberCP/bin/python /usr/local/CyberCP/IncBackups/IncScheduler.py Daily > /dev/null 2>&1 &
spinner
wait $!

RET=$?
END_TIME=$(date +%s)

if [ $RET -ne 0 ]; then
    echo "CyberPanel daily backup failed!"
    exit 1
fi

echo "CyberPanel daily backup completed in $((END_TIME-START_TIME)) sec."

# -------------------------------------------------
# 1. S3 sync (добавили endpoint)
# -------------------------------------------------

echo "Starting S3 sync..."

aws --endpoint-url="$ENDPOINT" \
    s3 sync "$BACKUP_DIR" "$S3_PATH" \
    --profile $PROFILE

if [ $? -ne 0 ]; then
    echo "S3 sync failed!"
    exit 1
fi

echo "S3 sync completed successfully."

# -------------------------------------------------
# 2. Rotation логика (оставил как у тебя)
# -------------------------------------------------

echo "Collecting S3 backup list..."

BACKUPS=$(aws --endpoint-url="$ENDPOINT" \
    s3 ls "$S3_PATH" \
    --profile $PROFILE | awk '{print $2}' | sort)

COUNT=$(echo "$BACKUPS" | wc -l)

if [ $COUNT -gt $KEEP ]; then
    REMOVE_COUNT=$((COUNT - KEEP))
    echo "Found $COUNT backups, removing $REMOVE_COUNT oldest..."

    echo "$BACKUPS" | head -n $REMOVE_COUNT | while read folder; do
        aws --endpoint-url="$ENDPOINT" \
            s3 rm "${S3_PATH}${folder}" \
            --recursive \
            --profile $PROFILE

        echo "Removed old S3 backup: $folder"
    done
fi

# -------------------------------------------------
# 3. Cleanup local backups (оставлено как есть)
# -------------------------------------------------

echo "Cleaning local backups..."
rm -rf ${BACKUP_DIR}/*
echo "Local backups cleaned."

echo "=== END $(date) ==="
