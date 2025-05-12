#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if a command succeeded
check_command() {
    if [ $? -eq 0 ]; then
        print_message "$1" "$GREEN"
        return 0
    else
        print_message "$2" "$RED"
        return 1
    fi
}

# Function to check for changes
check_changes() {
    print_message "Checking for local changes..." "$YELLOW"
    
    # Check if there are any uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        print_message "Uncommitted changes detected" "$YELLOW"
        return 0
    else
        print_message "No uncommitted changes" "$GREEN"
        return 1
    fi
}

# Function to commit and push changes
sync_changes() {
    print_message "Syncing changes..." "$YELLOW"
    
    # Add all changes
    git add .
    
    # Commit changes
    git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Push changes
    git push origin main
    
    check_command "Changes synced successfully!" "Error syncing changes"
}

# Function to check git status
check_git_status() {
    print_message "Checking git status..." "$YELLOW"
    git status
}

# Main function
main() {
    print_message "Starting GalaxyERP sync process..." "$GREEN"
    
    # Check if running in git repository
    if [ ! -d ".git" ]; then
        print_message "Error: Not a git repository" "$RED"
        exit 1
    fi
    
    # Check for changes
    if check_changes; then
        # Show git status
        check_git_status
        
        # Ask for confirmation
        read -p "Do you want to sync these changes? (y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            sync_changes
        else
            print_message "Sync cancelled by user" "$YELLOW"
        fi
    else
        print_message "No changes to sync" "$GREEN"
    fi
    
    print_message "Sync process completed!" "$GREEN"
}

# Run main function
main 