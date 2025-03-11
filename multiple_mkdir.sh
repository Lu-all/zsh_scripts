#!/bin/zsh

if [ "$1" = "-h" ]; then
    echo "Usage: mmkdir <pattern> <min> <max>"
    echo "This script creates multiple subdirectories under the current path with name from pattern&min to pattern&max."
    echo "For example, mmkdir folder 1 5 will create folders folder1, folder2, folder3, folder4, folder5"
    echo "Arguments:"
    echo "  <pattern>              The name of the directories to be created"
    echo "  <min>                  The starting number for the pattern"
    echo "  <max>                  The ending number for the pattern"
    exit 0
fi

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Usage: mmkdir <repeated_pattern> <min> <max>"
    echo "(Or use -h for help)"
    exit 1
fi

# This line sets the variable 'current_folder' to the first argument passed to the script
parent_path=$(pwd)
echo "Parent path:" $parent_path

# This line sets the variable 'repeated_pattern' to the fifth argument passed to the script
pattern=$1
echo "Repeated pattern:" $pattern

# This line sets the variable 'min' to the third argument passed to the script
min=$2
echo "Min:" $min

# This line sets the variable 'max' to the fourth argument passed to the script
max=$3
echo "Max:" $max

for i in {$min..$max}; do echo "creating directory " $pattern$i; mkdir $parent_path/$pattern$i; done