# Initialize an empty array to hold the modified parameters
modified_params=()
verbose=false

# Loop through all the parameters and check if -v is present (and delete it)
for param in "$@"; do
  if [ "$param" != "-v" ]; then
    if [ "$param" == "-h" ]; then
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

source_folder=${modified_params[0]}

destination=${modified_params[1]}

if [ ${#modified_params[@]} -lt 3 ]; then
    pattern=""
else
    pattern=${modified_params[2]}
fi

echo "Replacing files in $destination with files from $source_folder"
echo "\n"

find $destination -type f | while read file; do
  extension="${file##*.}"
  filename="${file##*/}"
  compressed_file="$source_folder/${filename%.*}$pattern.${extension}"
  if [ $verbose == true ]; then
    echo "Checking $destination/$filename"
    echo "Trying to replace with $compressed_file"
    if [ -f "$compressed_file" ]; then
      echo "Replacing $destination/$file with $source_folder/$compressed_file"
      cp "$compressed_file" "$(dirname "$file")/$filename"
    else
      echo "No file found for $compressed_file"
    fi
    echo "\n"
  else
    if [ -f "$compressed_file" ]; then
      cp "$compressed_file" "$(dirname "$file")/$filename"
    fi
  fi
done

