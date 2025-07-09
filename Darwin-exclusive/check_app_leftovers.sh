#!/bin/zsh
exit_code=0
APP=$1
if [ -z "$APP" ]; then
    echo "Error: No application name provided."
    echo "Usage: check_app_leftovers.sh <app_name>"
    exit 1
fi

if [ "$1" = "-h" ]; then
    echo "Usage: check_app_leftovers.sh <app_name>"
    echo "This script checks for leftover files of a specified application in various directories."
    echo "While removing these, it will create a backup of the files in a directory on your Desktop (~/Desktop/?.nosync)."
    echo "If the backup cannot be created, the files will not be removed."
    exit 0
fi

LEFTOVERS=""
APP_SUPPORT=""
PREFERENCES=""
CACHES=""
LAUNCH_AGENTS=""
LOGS=""

echo "Checking for leftovers of $APP"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

# Function to check for leftovers in a specific directory
check_leftovers() {
    local dir=$1
    local var_name=$2
    local label=$3

    PRINT=$(find "$dir" -type d -name "*$APP*" -maxdepth 1 2>/dev/null)
    if [ -z "$PRINT" ]; then
        echo "No leftovers found in $label"
    else
        LEFTOVERS="$LEFTOVERS\n$PRINT"
        eval "$var_name=\$PRINT"
    fi
}

# Check for leftovers in various directories
check_leftovers "/Users/main/Library/Application Support" APP_SUPPORT "Application Support"
check_leftovers "/Users/main/Library/Preferences" PREFERENCES "Preferences"
check_leftovers "/Users/main/Library/Caches" CACHES "Caches"
check_leftovers "/Users/main/Library/LaunchAgents" LAUNCH_AGENTS "LaunchAgents"
check_leftovers "/Users/main/Library/Logs" LOGS "Logs"

echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
if [ -z "$LEFTOVERS" ]; then
    echo "No leftovers found"
    exit 0
fi

echo "Leftovers found:"
echo "$LEFTOVERS"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "Do you want to remove these leftovers? (y/[n])"
read -r ANSWER

if [ "$ANSWER" = "y" ]; then
    RANDOM_NAME=$RANDOM
    BACKUP_DIR=~/Desktop/$RANDOM_NAME.nosync

    # Create backup directories
    echo "Creating backup directory at $BACKUP_DIR"
    if ! mkdir -p "$BACKUP_DIR/Application_Support" "$BACKUP_DIR/Preferences" "$BACKUP_DIR/Caches" "$BACKUP_DIR/LaunchAgents" "$BACKUP_DIR/Logs"; then
        echo "Error: Failed to create backup directories." >&2
        exit 1
    fi

    # Function to move leftovers to backup
    move_leftovers() {
        local leftovers=$1
        local backup_subdir=$2
        local label=$3

        for i in $leftovers; do
            DIR=$(basename "$i")
            echo "Moving $label: $DIR"
            if ! mv "$i" "$BACKUP_DIR/$backup_subdir/$DIR" 2>/dev/null; then
                echo "Error: Failed to move $i to $BACKUP_DIR/$backup_subdir/$DIR." >&2
                exit_code=1
            fi
        done
    }

    # Move leftovers to backup
    move_leftovers "$APP_SUPPORT" "Application_Support" "Application Support"
    move_leftovers "$PREFERENCES" "Preferences" "Preferences"
    move_leftovers "$CACHES" "Caches" "Caches"
    move_leftovers "$LAUNCH_AGENTS" "LaunchAgents" "LaunchAgents"
    move_leftovers "$LOGS" "Logs" "Logs"

    if [ $exit_code -ne 0 ]; then
        echo "Error: Some leftovers could not be moved. Check permissions?" >&2
        exit 1
    else
        echo "Backup created at $BACKUP_DIR"
        echo "Leftovers removed"
    fi
else
    echo "Leftovers not removed"
fi
exit $exit_code
