#!/bin/zsh

# Argument check and help

transformation=false
modified_params=()
iterative=0

for param in "$@"; do
  if [ "$param" != "-t" ]; then
    if [ "$param" = "-h" ]; then
        echo "Usage: rename_by_regex <directory> <source_regex> <destination_regex>"
        echo "This command renames all files in the given directory and its subdirectories that match the source regex to the destination regex."
        echo "Adding -t will transform from traditional regex syntax (\d\w(.*)\$1) to sed syntax ([0-9][a-zA-Z](\.*)\1."
        echo "Arguments:"
        echo "<directory>         The directory containing the files to rename."
        echo "<source_regex>      The regex pattern to match the source files. For example: '^5_([0-9]\.*)'"
        echo "<destination_regex> The regex pattern to rename the files. For example '4_\1'"
        echo "-t                  Transform regular expression syntax."
        exit 0
    fi
    modified_params+=("$param")
  else
    transformation=true
  fi
done

if [ "${#modified_params[@]}" -lt 3 ]; then
  echo "Usage: rename_by_regex <directory> <source_regex> <destination_regex>"
  echo "This command renames files in the directory that match the source regex to the destination regex."
  exit 1
fi

DIR=${modified_params[1]}
SOURCE_REGEX=${modified_params[2]}
DESTINATION_REGEX=${modified_params[3]}

# Check if the directory exists
if [ ! -d "$DIR" ]; then
  echo "Error: Directory '$DIR' does not exist." >&2
  exit 1
fi

if [ $transformation = true ]; then
  echo "Transforming REGEX $SOURCE_REGEX"
  SOURCE_REGEX=$(echo "$SOURCE_REGEX" | sed -E 's/\\d/[0-9]/' | sed -E 's/\\w/[a-zA-Z]/' | sed -E 's/\$([0-9]+)/\\\1/')
  echo "    Transformed to $SOURCE_REGEX"

  echo "Transforming REGEX $DESTINATION_REGEX"
  DESTINATION_REGEX=$(echo "$DESTINATION_REGEX" | sed -E 's/\\d/[0-9]/g;s/\\w/[a-zA-Z]/g;s/\$([0-9]+)/\\\1/g')
  echo "    Transformed to $DESTINATION_REGEX"
fi

# Obtain a random number
RANDOM_NUMBER=$RANDOM
# Make a safe directory
BACKUP_DIR="$DIR/$RANDOM_NUMBER"
if ! mkdir "$BACKUP_DIR"; then
  echo "Error: Failed to create backup directory '$BACKUP_DIR'." >&2
  exit 1
fi

echo "Renaming files in $DIR that match $SOURCE_REGEX to $DESTINATION_REGEX"

# Iterate on all files in DIR or subfolders
function rename_file {
  local FILE=$1
  # Obtain the name of the file without path
  local FILENAME=$(basename "$FILE")
  # Obtain file path
  local DIRNAME=$(dirname "$FILE")

  # Verify if the name of the file matches the pattern and is not the backup directory
  if echo "$FILENAME" | grep -Eq "$SOURCE_REGEX" && [ "$FILENAME" != "$RANDOM_NUMBER" ]; then
    echo "Match found for $FILENAME"
    # Generate the new file name
    local NEW_NAME=$(echo "$FILENAME" | sed -E "s/$SOURCE_REGEX/$DESTINATION_REGEX/")

    # Make a safe copy of the file
    if [ "$(uname)" = "Darwin" ]; then
      if [ -f "$BACKUP_DIR/$FILENAME" ]; then
        cp "$FILE" "$BACKUP_DIR/$FILENAME$iterative" || { echo "Error: Failed to copy '$FILE' to backup directory." >&2; exit 1; }
        ((iterative++))
      else
        cp "$FILE" "$BACKUP_DIR/$FILENAME" || { echo "Error: Failed to copy '$FILE' to backup directory." >&2; exit 1; }
      fi
    else
      cp -r --backup=t "$FILE" "$BACKUP_DIR/$FILENAME" || { echo "Error: Failed to copy '$FILE' to backup directory." >&2; exit 1; }
    fi

    # Rename the file
    echo "    Renaming $FILENAME to $NEW_NAME"
    if ! mv "$FILE" "$DIRNAME/$NEW_NAME"; then
      echo "Error: Failed to rename '$FILENAME' to '$NEW_NAME'." >&2
      exit 1
    fi
  fi
}

#export -f rename_file
#find "$DIR" -type f -exec zsh -c 'rename_file "$0"' {} \;
find "$DIR" -type f | while read -r file; do
  rename_file "$file"
done

echo "Files renamed. Backup directory: $BACKUP_DIR"
echo "Remove backup directory? Y/[N]"
read -r REMOVE
if [ "$REMOVE" = "Y" ]; then
  if ! rm -rf "$BACKUP_DIR"; then
    echo "Error: Failed to remove backup directory '$BACKUP_DIR'." >&2
    exit 1
  fi
fi

echo "Done"
