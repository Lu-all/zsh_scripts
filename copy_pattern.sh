#!/bin/zsh

if [ "$1" = "-h" ]; then
    echo "Usage: copy_pattern <initial_file_folder> <filename> <min> <max> <repeated_pattern>"
    echo "This script copies a file into multiple directories with a repeated pattern."
    echo "For example, copy_pattern folderX initial_file 1 5 folder will copy the file folderX/initial_file into folder1/initial_file, folder2/initial_file, folder3/initial_file, folder4/initial_file, folder5/initial_file."
    echo "Arguments:"
    echo "  <initial_file_folder>  The folder containing the initial file"
    echo "  <filename>             The name of the file to be copied"
    echo "  <min>                  The starting number for the pattern"
    echo "  <max>                  The ending number for the pattern"
    echo "  <repeated_pattern>     The pattern for the directories where the file will be copied"
    exit 0
fi

if [ "$#" -ne 5 ]; then
    echo "Error: Illegal number of parameters"
    echo "Usage: copy_pattern <initial_file_folder> <filename> <min> <max> <repeated_pattern>"
    echo "(Or use -h for help)"
    exit 1
fi

# Set variables
parent_path=$(pwd)
echo "Parent path:" $parent_path

initial_file_folder=$1
echo "Initial file folder:" $initial_file_folder

filename=$2
echo "Filename:" $filename

min=$3
echo "Min:" $min

max=$4
echo "Max:" $max

pattern=$5
echo "Repeated pattern:" $pattern

initial_file=$parent_path/$initial_file_folder/$filename
echo "Initial file:" $initial_file"\n"

# Validate that min and max are integers
if ! [[ "$min" =~ ^[0-9]+$ ]] || ! [[ "$max" =~ ^[0-9]+$ ]]; then
    echo "Error: <min> and <max> must be positive integers."
    exit 1
fi

# Validate that min is less than or equal to max
if [ "$min" -gt "$max" ]; then
    echo "Error: <min> must be less than or equal to <max>."
    exit 1
fi

# Check if the initial file exists
if [ ! -f "$initial_file" ]; then
    echo "Error: Initial file '$initial_file' does not exist."
    exit 1
fi

# Copy the file into the directories
for i in $(seq "$min" "$max"); do
    target_dir="$parent_path/$pattern$i"
    target_file="$target_dir/$filename"

    # Create the target directory if it doesn't exist
    if [ ! -d "$target_dir" ]; then
        echo "Creating directory: $target_dir"
        if ! mkdir -p "$target_dir"; then
            echo "Error: Failed to create directory '$target_dir'." >&2
            continue
        fi
    fi

    # Copy the file
    echo "Copying $initial_file to $target_file"
    if ! cp "$initial_file" "$target_file"; then
        echo "Error: Failed to copy '$initial_file' to '$target_file'." >&2
        continue
    fi
done