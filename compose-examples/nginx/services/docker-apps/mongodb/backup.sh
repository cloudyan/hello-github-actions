#!/bin/sh

while true; do
  echo "[$(date)] Starting backup..."
  mongodump --host mongo --out /data/backup/$(date +%Y%m%d_%H%M%S)
  echo "[$(date)] Backup completed"
  sleep 24h
done
