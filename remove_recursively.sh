if [ "$1" == "-h" ]; then
    echo "Usage: remove_recursively <pattern>"
    echo "This script removes all files matching the given pattern in the current directory and its subdirectories."
    echo "For example, remove_recursively *1.txt will remove all .txt files in the current directory and its subdirectories whose name ends with 1."
    echo "Arguments:"
    echo "    <pattern> : The pattern to match the files to remove"
    exit 0
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: remove_recursively <pattern>"
    echo "(Or use -h for help)"
    exit 1
fi

local_folder=$(pwd)
pattern=$1
echo "Removing files in "  $local_folder " with pattern" $pattern
find $local_folder -name $pattern -type f -delete