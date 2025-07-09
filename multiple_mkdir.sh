#!/bin/zsh

if [ "$1" = "-h" ]; then
    echo "Usage: mmkdir <pattern> <min> <max>"
    echo "This script creates multiple subdirectories under the current path with names from pattern&min to pattern&max."
    echo "For example, mmkdir folder 1 5 will create folders folder1, folder2, folder3, folder4, folder5"
    echo "Arguments:"
    echo "  <pattern>              The name of the directories to be created"
    echo "  <min>                  The starting number for the pattern"
    echo "  <max>                  The ending number for the pattern"
    exit 0
fi

if [ "$#" -ne 3 ]; then
    echo "Error: Illegal number of parameters"
    echo "Usage: mmkdir <pattern> <min> <max>"
    echo "(Or use -h for help)"
    exit 1
fi

# Validate that min and max are integers
if ! [[ "$2" =~ ^[0-9]+$ ]] || ! [[ "$3" =~ ^[0-9]+$ ]]; then
    echo "Error: <min> and <max> must be positive integers."
    exit 1
fi

# Validate that min is less than or equal to max
if [ "$2" -gt "$3" ]; then
    echo "Error: <min> must be less than or equal to <max>."
    exit 1
fi

# Set variables
parent_path=$(pwd)
echo "Parent path:" $parent_path

pattern=$1
echo "Repeated pattern:" $pattern

min=$2
echo "Min:" $min

max=$3
echo "Max:" $max

# Create directories
for i in $(seq $min $max); do
    dir_path="$parent_path/$pattern$i"
    echo "Creating directory: $dir_path"
    if ! mkdir "$dir_path"; then
        echo "Error: Failed to create directory '$dir_path'." >&2
        exit 2
    fi
done
