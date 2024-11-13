#!/bin/bash

# Define the config file path explicitly in the user's home directory
CONFIG_FILE="$HOME/.chronosync_config.sh"
BACKUP_LOG="$HOME/Backups/chronosync_log.csv"  # Ensure this is set correctly

# Function to install required dependencies (rsync and inotify-tools)
install_dependencies() {
    # Install rsync and inotifywait (if not already installed)
    if ! command -v rsync &> /dev/null; then
        echo "rsync not found, installing..."
        sudo apt-get install rsync -y
    fi
    if ! command -v inotifywait &> /dev/null; then
        echo "inotify-tools not found, installing..."
        sudo apt-get install inotify-tools -y
    fi
}

# Function to save the configuration
configure_backup() {
    echo "Please enter the files you want to backup (space-separated):"
    read -a BACKUP_FILES
    echo "Please enter the destination folder for backup:"
    read DEST

    # Ensure destination exists
    if [ ! -d "$DEST" ]; then
        mkdir -p "$DEST"
    fi

    # Save the configuration to $HOME/.chronosync_config.sh
    cat << EOF > "$CONFIG_FILE"
BACKUP_FILES=("$(echo ${BACKUP_FILES[@]} | sed 's/ /" "/g')")
DEST="$DEST"
EOF

    echo "Configuration saved to $CONFIG_FILE"
}

# Function to load configuration from the saved file
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        echo "Loaded configuration from $CONFIG_FILE"
    else
        echo "Configuration file not found. Please configure first."
        exit 1
    fi
}

# Function to initialize the backup log
initialize_log() {
    # Ensure log file exists and has headers
    if [[ ! -f "$BACKUP_LOG" ]]; then
        touch "$BACKUP_LOG"
        echo "Version,File,Backup Time,Size,Permission" > "$BACKUP_LOG"
    fi
}

# Function to get the next version number
get_next_version() {
    local file_name="$1"
    local destination="$2"
    local version=1
    while [[ -f "$destination/$(basename "$file_name" .txt)_v$version.txt" ]]; do
        ((version++))
    done
    echo $version
}

# Function to perform the backup
perform_backup() {
    for file in "${BACKUP_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            # Get the next version number
            VERSION=$(get_next_version "$file" "$DEST")
            BACKUP_FILE="$DEST/$(basename "$file" .txt)_v$VERSION.txt"
            
            # Use rsync to backup the file
            rsync -av --progress "$file" "$BACKUP_FILE"
            
            # Log the backup information
            SIZE=$(stat --printf="%s" "$file")
            PERMISSIONS=$(stat --printf="%A" "$file")
            echo "$VERSION,$file,$(date +"%Y-%m-%d %H:%M:%S"),$SIZE,$PERMISSIONS" >> "$BACKUP_LOG"

            echo "Backup created: $BACKUP_FILE"
        else
            echo "File not found: $file"
        fi
    done
}

# Function to watch for changes and backup
watch_and_backup() {
    initialize_log
    echo "Monitoring for changes in files and directories..."

    # Print which files are being watched for debugging
    echo "Watching the following files/directories: ${BACKUP_FILES[@]}"

    while true; do
        # Use inotifywait to monitor file changes (modify, create, delete)
        inotifywait -q -e modify,create,delete -r "${BACKUP_FILES[@]}" > /dev/null
        
        # If inotifywait detects a change, trigger a backup
        echo "Change detected, starting backup..."
        perform_backup
    done
}

# Function to check if files exist before monitoring
check_files_exist() {
    for file in "${BACKUP_FILES[@]}"; do
        if [[ ! -e "$file" ]]; then
            echo "Error: $file does not exist. Please check the paths."
            exit 1
        fi
    done
}

# Function to add the script to startup
add_to_startup() {
    SCRIPT_PATH=$(realpath "$0")
    CRON_JOB="@reboot nohup $SCRIPT_PATH > $HOME/chronosync.log 2>&1 &"
    if ! crontab -l | grep -q "$SCRIPT_PATH"; then
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo "Script added to startup and will run in background."
    else
        echo "Script is already configured to run on startup."
    fi
}

# Main execution
echo "Starting ChronoSync script..."

# Install dependencies
install_dependencies

# Check for --config flag to configure the backup
if [[ "$1" == "--config" ]]; then
    configure_backup
    exit 0
fi

# Set default config file if not set
CONFIG_FILE="${CONFIG_FILE:-$HOME/.chronosync_config.sh}"

# Load the configuration
load_config

# Check if the files exist before starting the monitoring
check_files_exist

# Add script to startup
add_to_startup

# Start monitoring files for changes
watch_and_backup
