#!/bin/bash
################################################################################
# Script: uniquePrograms.sh
# Version: 1.0
#
# Purpose:
#   Cross-references programs from one file with course data from a CSV file.
#   Identifies which programs have associated courses and generates output
#   with course associations appended.
#
# Usage:
#   ./uniquePrograms.sh <programs_file> <courses_csv_file>
#
# Example:
#   ./uniquePrograms.sh active_programs.txt current_courses.csv
#
# Parameters:
#   $1 - File containing list of active programs (one per line)
#   $2 - CSV file with course data (first column must contain program names)
#
# Input File Formats:
#
#   Programs file (active_programs.txt):
#     - One program name per line
#     - Example:
#       Computer Science
#       Mathematics
#       Physics
#
#   Courses CSV file (current_courses.csv):
#     - CSV format with program name in first column
#     - Example:
#       Computer Science,CS101,Intro to CS
#       Computer Science,CS102,Data Structures
#       Mathematics,MATH101,Calculus I
#
# Output:
#   - File: ProgsWithCourseAssocs.csv
#   - Format: <program_from_first_file> ,<program_from_courses_csv>
#   - One line per match
#
# Example Output (ProgsWithCourseAssocs.csv):
#   Computer Science ,Computer Science
#   Computer Science ,Computer Science
#   Mathematics ,Mathematics
#
# Requirements:
#   - Both input files must exist and be readable
#   - Standard utilities: grep, sed, awk, tr
#   - Write permissions in current directory for output file
#
# Notes:
#   - grep searches case-sensitively
#   - Searches for program names as substrings
#   - Appends to output file (does not truncate existing file)
#   - Each matching course line generates one output line
#
################################################################################

# Validate input arguments
if [ $# -ne 2 ]; then
  echo "Error: Incorrect number of arguments"
  echo "Usage: $0 <programs_file> <courses_csv_file>"
  echo ""
  echo "Example:"
  echo "  $0 active_programs.txt current_courses.csv"
  exit 1
fi

ACTIVE_PROGS=$1
CURR_COURSES=$2

# Validate input files exist
if [ ! -f "$ACTIVE_PROGS" ]; then
  echo "Error: Programs file not found: $ACTIVE_PROGS"
  exit 1
fi

if [ ! -f "$CURR_COURSES" ]; then
  echo "Error: Courses CSV file not found: $CURR_COURSES"
  exit 1
fi

echo "Processing programs from: $ACTIVE_PROGS"
echo "Cross-referencing with courses from: $CURR_COURSES"
echo ""

# Remove header row (if present) and extract program names from first column
# awk -F ',' extracts first field using comma as delimiter
# tr '\n' ' ' converts newlines to spaces for single-line iteration
COURSES=$(tail -n+2 "$CURR_COURSES" | awk -F ',' '{print $1}' | tr '\n' ' ')

# Output file
OUTPUT_FILE="ProgsWithCourseAssocs.csv"

# Clear or create output file
: > "$OUTPUT_FILE"

# Iterate through each program from the programs file
for PROGRAM in $COURSES; do
  # Check if program exists in the active programs file
  if grep -q "$PROGRAM" "$ACTIVE_PROGS"; then
    echo "Found match: $PROGRAM"
    # Append all matching lines from courses file to output
    # Format: <program_from_file> ,<program_from_csv>
    grep "$PROGRAM" "$ACTIVE_PROGS" | sed "s/$/ ,${PROGRAM}/" >> "$OUTPUT_FILE"
  fi
done

echo ""
echo "Cross-reference complete."
echo "Output saved to: $OUTPUT_FILE"
if [ -s "$OUTPUT_FILE" ]; then
  echo "Lines in output: $(wc -l < "$OUTPUT_FILE")"
  echo ""
  echo "First few matches:"
  head -5 "$OUTPUT_FILE"
else
  echo "Warning: No matches found. Output file is empty."
fi

### END ###
