#!/bin/bash
################################################################################
# Script: split_with_number_prefix.sh
# Version: 1.0
#
# Purpose:
#   Renames files created by the `split` command with zero-padded numeric
#   suffixes instead of the default alphabetic suffixes (aa, ab, ac...).
#   Converts: chunk_aa, chunk_ab, chunk_ac... → chunk_001, chunk_002, chunk_003...
#
# Usage:
#   ./split_with_number_prefix.sh <file_prefix>
#
# Example:
#   # First, use the split command to divide a large file
#   $ split -l 1000 largefile.txt chunk_
#   $ ls -la chunk_*
#   chunk_aa  chunk_ab  chunk_ac
#
#   # Then use this script to rename with numeric prefixes
#   $ ./split_with_number_prefix.sh chunk_
#   $ ls -la chunk_*
#   chunk_001  chunk_002  chunk_003
#
# Parameters:
#   $1 - File prefix (same prefix used with the split command)
#
# Configuration:
#   suffixlen - Length of numeric suffix padding (default: 3)
#               Change to 2 for 01, 02, 03... or 4 for 0001, 0002...
#
# Requirements:
#   - Split files already created with the given prefix
#   - Write permissions in the directory containing the files
#
# Notes:
#   - Script iterates through files matching the prefix pattern
#   - Renames each file with zero-padded numeric suffix
#   - Counter starts at 1
#
################################################################################

# Configuration: Length of numeric suffix (controls zero-padding)
# 2 = 01, 02, 03...
# 3 = 001, 002, 003...
# 4 = 0001, 0002, 0003...
SUFFIX_LENGTH=3

if [ $# -ne 1 ]; then
  echo "Error: Missing file prefix argument"
  echo "Usage: $0 <file_prefix>"
  echo ""
  echo "Example:"
  echo "  split -l 1000 largefile.txt chunk_"
  echo "  $0 chunk_"
  exit 1
fi

FILE_PREFIX="$1"
COUNTER=1

echo "Renaming files with prefix: $FILE_PREFIX"
echo "Using suffix length: $SUFFIX_LENGTH"

# Iterate through all files matching the prefix pattern
for file in "${FILE_PREFIX}"*; do
  # Skip if no files match the pattern
  [ -e "$file" ] || continue

  # Format counter with zero-padding
  # printf "%0${SUFFIX_LENGTH}d" formats the number with leading zeros
  # e.g., with SUFFIX_LENGTH=3: 1 → 001, 2 → 002, 10 → 010
  NUMERIC_SUFFIX=$(printf "%0${SUFFIX_LENGTH}d" "$COUNTER")

  # Construct new filename
  NEW_FILENAME="${FILE_PREFIX}${NUMERIC_SUFFIX}"

  # Rename the file
  mv "$file" "$NEW_FILENAME"
  echo "Renamed: $file → $NEW_FILENAME"

  # Increment counter for next file
  ((COUNTER++))
done

echo "File renaming complete. Renamed $((COUNTER - 1)) files."

### END ###
