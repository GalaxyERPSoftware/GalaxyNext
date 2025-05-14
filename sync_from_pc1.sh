#!/bin/bash

# --- CONFIGURATION ---
SITE_NAME="GalaxyERP.com"
BACKUP_DIR="/mnt/c/Users/gi13/Desktop/GalaxyERP"

# --- CODE SYNC ---
echo "Starting code synchronization..."
cd "$BACKUP_DIR"
git pull origin main

# --- DATABASE RESTORE ---
echo "Looking for latest backup..."
cd frappe-bench
LATEST_BACKUP=$(ls -t sites/$SITE_NAME/private/backups/*.sql.gz | head -1)

if [ -f "$LATEST_BACKUP" ]; then
    echo "Restoring database from backup..."
    bench --site $SITE_NAME --force restore "$LATEST_BACKUP"
    echo "Database restore completed."
else
    echo "Error: No backup file found!"
    exit 1
fi

echo "Sync completed at $(date)" 