#!/usr/bin/env bash

# Set the source and destination directories
SOURCE_DIR="$HOME/nixstuff/.config"
DEST_DIR="$HOME/.config"

# Function to create symlinks
create_symlink() {
    local src="$1"
    local dest="$2"

    # Check if the destination already exists
    if [ -e "$dest" ]; then
        if [ -L "$dest" ]; then
            echo "Symlink already exists: $dest"
        else
            echo "File/directory already exists, not a symlink: $dest"
        fi
    else
        ln -s "$src" "$dest"
        echo "Created symlink: $src -> $dest"
    fi
}

# Function to process directories
process_directory() {
    local current_source="$1"
    local current_dest="$2"

    # Create the destination directory if it doesn't exist
    mkdir -p "$current_dest"

    # Iterate through all items in the current source directory
    find "$current_source" -mindepth 1 -maxdepth 1 | while read item; do
        local base_name=$(basename "$item")
        local dest_path="$current_dest/$base_name"

        if [ -d "$item" ]; then
            # If it's a directory, recurse into it
            process_directory "$item" "$dest_path"
        else
            # If it's a file, create a symlink
            create_symlink "$item" "$dest_path"
        fi
    done
}

# Main script
echo "Starting symlinking process..."

# Start processing from the root of the source directory
process_directory "$SOURCE_DIR" "$DEST_DIR"

echo "Symlinking process completed."
