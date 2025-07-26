#!/bin/zsh
for param in "$@"; do
  if [ "$param" != "-t" ]; then
    if [ "$param" = "-h" ]; then
    echo "Usage: remove_recursively <pattern>"
    echo "This script removes all files matching the given pattern in the current directory and its subdirectories."
    echo "For example, remove_recursively '*1.txt' will remove all .txt files in the current directory and its subdirectories whose name ends with 1."
    echo "Adding -t will transform from traditional regex syntax (\d\w(.*)\$1) to sed syntax ([0-9][a-zA-Z](\.*)\1."
    echo "Remember to add the quotes around the regex patterns to avoid shell expansion!"
    echo "Arguments:"
    echo "    <pattern> : The pattern to match the files to remove"
    exit 0
    fi
    modified_params+=("$param")
  else
    transformation=true
  fi
done

if [ "${#modified_params[@]}" -ne 1 ]; then
    echo "Usage: remove_recursively <pattern>"
    echo "(Or use -h for help)"
    exit 1
fi

local_folder=$(pwd)
pattern=${modified_params[1]}
iterative=0
RANDOM_NUMBER=$RANDOM
backup_folder="$local_folder/$RANDOM_NUMBER"

if [ $transformation = true ]; then
  echo "Transforming REGEX $pattern"
  pattern=$(echo "$pattern" | sed -E 's/\\d/[0-9]/' | sed -E 's/\\w/[a-zA-Z]/' | sed -E 's/\$([0-9]+)/\\\1/')
  echo "    Transformed to $pattern"
fi

echo "Removing files in $local_folder with pattern $pattern"
echo ""

# Find all files matching the pattern
all_files=$(find "$local_folder" -type f -name "$pattern" 2>/dev/null)

if [ -z "$all_files" ]; then
    echo "No files found matching the pattern: $pattern"
    exit 0
fi

# Create backup folder
if ! mkdir "$backup_folder"; then
    echo "Error: Failed to create backup directory '$backup_folder'." >&2
    exit 1
fi

echo "All files matching the pattern:"
echo "$all_files"
echo ""

# Process each file, using IFS to handle spaces in filenames
IFS=$'\n'
for file in $all_files; do
    path=$()
    filename=$(basename "$file")
    file=$(find "$local_folder" -name "$filename" -print0 | head -n 1)
    basedirname=$(dirname "$file")

    if [ "$basedirname" != "$backup_folder" ]; then
        if [ -f "$file" ]; then
            # Check if the file already exists in the backup folder
            if [ -f "$backup_folder/$filename.bk" ]; then
                echo "File already exists in backup folder, adding iterative suffix $iterative"
                filename="${filename}_${iterative}"
                ((iterative++))
            fi

            # Copy the file to the backup folder
            if ! cp "$file" "$backup_folder/$filename.bk"; then
                echo "Error: Failed to copy '$file' to backup directory." >&2
                continue
            fi

            # Remove the file
            echo "Removing file: $file"
            if ! rm "$file"; then
                echo "Error: Failed to remove '$file'." >&2
                exit 2
            fi
        else
            echo "Skipping non-file: $file"
        fi
    fi
done

echo "Files removed. Backup directory: $backup_folder"
echo "Remove backup directory? Y/[N]"
read -r REMOVE
if [ "$REMOVE" = "Y" ]; then
    if ! rm -rf "$backup_folder"; then
        echo "Error: Failed to remove backup directory '$backup_folder'." >&2
        exit 2
    fi
fi

echo "Done"
