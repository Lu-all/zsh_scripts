if [ "$1" == "-h" ]; then
    echo "Usage: add_to_path <source_file> <name_of_command>"
    echo "Add an internal script <source_file> to path so it can be launched from ✨anywhere✨ as the command <name_of_command>"
    echo "(Needs ROOT permissions)"
    echo "Arguments:"
    echo "    <source_file> : The script you want to add to path"
    echo "    <name_of_command> : The name of the command you want to use to launch the script"
    exit 0
fi

if [ "$#" -ne 2 ]; then
    echo "Usage: add_to_path <source_file> <name_of_command>"
    echo "(Or use -h for help)"
    exit 1
fi


file=$1
name=$2
temporal_file=$RANDOM
chmod +x $file
ln -s $file $temporal_file
timeout 100 sudo cp $temporal_file /usr/local/bin/$name
if [ $? -eq 124 ]; then
    echo "Error: Failed to copy file to /usr/local/bin. Insufficient permissions."
    rm $temporal_file
    exit 2
fi
rm $temporal_file
