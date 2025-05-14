#!/bin/bash

# --- CONFIGURATION ---
SITE_NAME="GalaxyERP.com"
BACKUP_DIR="/mnt/c/Users/Admin/OneDrive/Desktop/GalaxyERP"
REMOTE_USER="lavesh"
REMOTE_HOST="192.168.1.41"
REMOTE_DIR="/mnt/c/Users/gi13/Desktop/GalaxyERP"

# --- CODE SYNC ---
echo "Starting code synchronization..."
cd "$BACKUP_DIR"
git add .
git commit -m "Auto sync: $(date)"
git push origin main

# --- DATABASE BACKUP & SYNC ---
echo "Starting database backup..."
cd frappe-bench
bench backup --with-files

# Get the latest backup file
LATEST_BACKUP=$(ls -t sites/$SITE_NAME/private/backups/*.sql.gz | head -1)

if [ -f "$LATEST_BACKUP" ]; then
    echo "Copying backup to remote..."
    # Create backup directory on remote if it doesn't exist
    ssh $REMOTE_USER@$REMOTE_HOST "mkdir -p $REMOTE_DIR/frappe-bench/sites/$SITE_NAME/private/backups"
    
    # Copy backup to remote
    scp "$LATEST_BACKUP" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/frappe-bench/sites/$SITE_NAME/private/backups/"
    
    # Restore on remote
    echo "Restoring on remote..."
    ssh $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_DIR/frappe-bench && bench --site $SITE_NAME --force restore sites/$SITE_NAME/private/backups/$(basename $LATEST_BACKUP)"
else
    echo "Error: Backup file not found!"
    exit 1
fi

echo "Sync completed at $(date)" 