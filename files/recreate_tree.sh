#!/usr/bin/env bash

# Default target directory is the current directory
TARGET_DIR="."
SKIPPED_COUNT=0
CREATED_COUNT=0

# Parse arguments for target directory option (-t <dir>)
while getopts "t:" opt; do
  case $opt in
    t) TARGET_DIR="$OPTARG" ;;
    *) echo "Usage: $0 [-t target_directory] < tree.txt"; exit 1 ;;
  esac
done

# Ensure target directory exists and convert to absolute path
mkdir -p "$TARGET_DIR"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

# Array to keep track of the current path at each depth level
declare -a paths

while IFS= read -r line || [[ -n "$line" ]]; do
    # 1. Skip empty lines
    [[ -z "${line//[:space:]/}" ]] && continue

    # 2. Calculate depth by counting leading tree symbols and spaces
    clean_prefix=$(echo "$line" | sed -E 's/^([ │├└┌─[:space:]\t]*).*/\1/')
    indent_count=$(echo "$clean_prefix" | sed 's/\t/    /g' | tr -d '│├└┌─' | wc -c)
    depth=$(( indent_count / 4 ))

    # 3. Clean the item name (remove leading tree symbols)
    raw_item=$(echo "$line" | sed -E 's/^[ │├└┌─[:space:]\t]*//')
    [[ -z "$raw_item" ]] && continue

    # 4. Check if it is a directory (ends with /)
    is_dir=false
    if [[ "$raw_item" == */ ]]; then
        is_dir=true
        item="${raw_item%/}" # Remove trailing slash for path assembly
    else
        item="$raw_item"
    fi

    # 5. Build the full path relative to the target directory
    if [ "$depth" -eq 0 ]; then
        paths[$depth]="$item"
        current_path="$TARGET_DIR/$item"
    else
        parent_depth=$(( depth - 1 ))
        paths[$depth]="${paths[$parent_depth]}/$item"
        current_path="$TARGET_DIR/${paths[$depth]}"
    fi

    # 6. Safety Check & Creation
    if [ "$is_dir" = true ]; then
        if [ -e "$current_path" ]; then
            # If it exists but is a file, that's a structural conflict
            if [ ! -d "$current_path" ]; then
                echo "⚠️  [CONFLICT] Name exists as FILE but tree expects FOLDER: $current_path"
            else
                echo "ℹ️  [SKIPPED] Folder already exists: $current_path"
            fi
            ((SKIPPED_COUNT++))
        else
            mkdir -p "$current_path"
            echo "📁 [CREATED] Folder: $current_path"
            ((CREATED_COUNT++))
        fi
    else
        if [ -e "$current_path" ]; then
            # If it exists but is a folder, that's a structural conflict
            if [ -d "$current_path" ]; then
                echo "⚠️  [CONFLICT] Name exists as FOLDER but tree expects FILE: $current_path"
            else
                echo "ℹ️  [SKIPPED] File already exists: $current_path"
            fi
            ((SKIPPED_COUNT++))
        else
            # Ensure parent folder exists before touching file
            mkdir -p "$(dirname "$current_path")"
            touch "$current_path"
            echo "📄 [CREATED] File:   $current_path"
            ((CREATED_COUNT++))
        fi
    fi

done

echo -e "\n🎯 Execution complete. Items Created: $CREATED_COUNT | Items Skipped/Conflicted: $SKIPPED_COUNT"

