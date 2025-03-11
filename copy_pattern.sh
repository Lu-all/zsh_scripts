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
    echo "Illegal number of parameters"
    echo "Usage: copy_pattern <initial_file_folder> <filename> <min> <max> <repeated_pattern>"
    echo "(Or use -h for help)"
    exit 1
fi

# This line sets the variable 'current_folder' to the first argument passed to the script
parent_path=$(pwd)
echo "Parent path:" $parent_path

#This line sets the variable 'initial_file_folder' to the first argument passed to the script
initial_file_folder=$1
echo "Initial file folder:" $initial_file_folder

# This line sets the variable 'filename' to the second argument passed to the script
filename=$2
echo "Filename:" $filename

# This line sets the variable 'min' to the third argument passed to the script
min=$3
echo "Min:" $min

# This line sets the variable 'max' to the fourth argument passed to the script
max=$4
echo "Max:" $max

# This line sets the variable 'repeated_pattern' to the fifth argument passed to the script
pattern=$5
echo "Repeated pattern:" $pattern

initial_file=$parent_path/$initial_file_folder/$filename
echo "Initial file:" $initial_file"\n"

for i in {$min..$max}; do echo "copying " $initial_file_folder/$filename " into " $pattern$i/$filename; cp $initial_file $parent_path/$pattern$i/$filename; done