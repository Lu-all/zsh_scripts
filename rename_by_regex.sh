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
mkdir "$DIR/$RANDOM_NUMBER"

echo "Renaming files in $DIR that match $SOURCE_REGEX to $DESTINATION_REGEX"

# Iterate on all files in DIR or subfolders
find "$DIR" | while read FILE; do
# Obtain the name of the file without path
FILENAME=$(basename "$FILE")
# Obtain file path
DIRNAME=$(dirname "$FILE")
  
# Verify if the name of the file coincides with the pattern and is not directory $RANDOM
if echo "$FILENAME" | grep -Eq "$SOURCE_REGEX" && [ "$FILENAME" != "$RANDOM_NUMBER" ]; then
  echo "Match found for $FILENAME"
  # Generate the new file name
  NEW_NAME=$(echo "$FILENAME" | sed -E "s/$SOURCE_REGEX/$DESTINATION_REGEX/")
  
  # Make a safe copy of the file
  if [ "$(uname)" = "Darwin" ]; then
    # if "$DIR/$RANDOM_NUMBER/$FILENAME" exists, then copy with different name
    if [ -f "$DIR/$RANDOM_NUMBER/$FILENAME" ]; then
      cp "$FILE" "$DIR/$RANDOM_NUMBER/$FILENAME$iterative"
      ((iterative++))
    else
      cp "$FILE" "$DIR/$RANDOM_NUMBER/$FILENAME"
    fi
  else
    cp -r --backup=t "$FILE" "$DIR/$RANDOM_NUMBER/$FILENAME"
  fi
  # Rename the file
  echo "    Renaming $FILENAME to $NEW_NAME"
  mv "$FILE" "$DIRNAME/$NEW_NAME"
  fi
done

echo "Files renamed. Backup directory: $DIR/$RANDOM_NUMBER"
echo "Remove backup directory? Y/[N]"
read -r REMOVE
if [ "$REMOVE" = "Y" ]; then
  rm -rf "$DIR/$RANDOM_NUMBER"
fi

echo "Done"