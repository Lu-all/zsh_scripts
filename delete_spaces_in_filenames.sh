#!/bin/zsh

if [ "$1" = "-h" ] || [ -z "$1" ]; then
  echo "Usage: delete_spaces_in_filenames.sh <directory_path>"
  echo "This script renames files in the specified directory by replacing spaces in filenames with underscores."
  exit 0
fi

echo "Renaming in $1"
find "$1" -type f | while read -r file; do
  echo "Checking $file"
  base=$(basename "$file")
  directory=$(dirname "$file")
  if [[ "$base" == *" "* ]]; then
    renamed="${base// /_}"
	echo "\033[31m   ! Renaming $file to $directory/$renamed\033[0m"
    mv "$file" "$directory/$renamed"
  fi
done
