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

# Function to update the codebase
update_codebase() {
    print_message "Updating codebase..." "$YELLOW"
    
    # Fetch latest changes
    git fetch origin
    
    # Check if there are any changes
    if [ $(git rev-list HEAD...origin/main --count) -gt 0 ]; then
        print_message "New changes detected. Updating..." "$YELLOW"
        
        # Reset to latest version
        git reset --hard origin/main
        
        # Update bench
        if [ -d "frappe-bench" ]; then
            cd frappe-bench
            bench update
            
            # Restart bench
            bench restart
            
            print_message "Codebase updated and bench restarted successfully!" "$GREEN"
        else
            print_message "Error: frappe-bench directory not found" "$RED"
            return 1
        fi
    else
        print_message "No new changes detected" "$GREEN"
    fi
}

# Function to check database access
check_database_access() {
    print_message "Checking database access..." "$YELLOW"
    
    # Try to connect to MySQL with read-only user
    mysql -u galaxyerp_viewer -p'GalaxyERP@DB' -e "SHOW DATABASES;" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_message "Database access verified" "$GREEN"
        return 0
    else
        print_message "Error: Could not access database" "$RED"
        return 1
    fi
}

# Main function
main() {
    print_message "Starting GalaxyERP update process..." "$GREEN"
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_message "Error: Please do not run this script as root" "$RED"
        exit 1
    fi
    
    # Update codebase
    update_codebase
    
    # Check database access
    check_database_access
    
    print_message "Update process completed!" "$GREEN"
}

# Run main function
main 