#!/bin/zsh

# Initialize an empty array to hold the modified parameters
modified_params=()
verbose=false

# Loop through all the parameters and check if -v is present (and delete it)
for param in "$@"; do
  if [ "$param" != "-v" ]; then
    if [ "$param" = "-h" ]; then
        echo "Usage: replace_shared_name <source_folder> <parent_folder> [<custom_ending>]"
        echo "This command replaces files in the parent folder with files from the source folder."
        echo "For example, replace_shared_name /home/user/source /home/user/destination will replace all files in /home/user/destination with files from /home/user/source."
        echo "If a custom ending is provided, the script will look for files with the same name in the source folder with the custom ending."
        echo "Adding -v will enable verbose mode."
        echo "Arguments:"
        echo "  <source_folder>    The source folder containing the files to replace."
        echo "  <parent_folder>    The parent folder containing the files to be replaced."
        echo "  <custom_ending>    A custom ending to look for in the source folder."
        echo "  -v                 Enable verbose mode."
        exit 0
    fi
    modified_params+=("$param")
  else
    verbose=true
  fi
done

if [ ${#modified_params[@]} -lt 2 ]; then
    echo "Usage: replace_shared_name <source_folder> <parent_folder> [<custom_ending>]"
    echo "(Or use -h for help)"
    exit 1
fi

source_folder=${modified_params[1]}
destination=${modified_params[2]}

if [ ${#modified_params[@]} -lt 3 ]; then
    pattern=""
else
    pattern=${modified_params[3]}
fi

# Check if source_folder exists
if [ ! -d "$source_folder" ]; then
  echo "Error: Source folder '$source_folder' does not exist."
  exit 1
fi

# Check if destination exists, create it if not
if [ ! -d "$destination" ]; then
  echo "Error: Folder '$destination' does not exist or is empty."; exit 1;
fi

echo "Replacing files in $destination with files from $source_folder"
echo ""
exit_code=0
# Process files in the destination folder
find "$destination" -type f | while read file; do
  extension="${file##*.}"
  filename="${file##*/}"
  compressed_file="$source_folder/${filename%.*}$pattern.${extension}"

  if [ "$verbose" = true ]; then
    echo "Checking $destination/$filename"
    echo "Trying to replace with $compressed_file"
  fi

  if [ -f "$compressed_file" ]; then
    if cp "$compressed_file" "$(dirname "$file")/$(basename "$file")"; then
      if [ "$verbose" = true ]; then
        echo "Replaced $destination/$filename with $compressed_file"
      fi
    else
      echo "Error: Failed to copy $compressed_file to $(dirname "$file")/$filename"
      exit_code=1
    fi
  else
    if [ "$verbose" = true ]; then
      echo "No file found for $compressed_file"
    fi
  fi

  if [ "$verbose" = true ]; then
    echo ""
  fi

  exit $exit_code

done || { echo "Error: Failed to process files in $destination."; exit 1; }
