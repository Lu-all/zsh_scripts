if [ "$1" = "-h" ]; then
    echo "This command highlights the lines of a file according to the rules provided."
    echo "Usage: reprint <input_file> <output_file> <rules>"
    echo "Arguments:"
    echo "    <input_file> : Path to the file to be read"
    echo "    <output_file> : Path to the file to be written with highlight markers for terminal"
    echo "      The use of the command 'less' is recommended for better visualization"
    echo "    <rules> : Dictionary of case-sensitive rules to be applied"
    echo "      Reminder: they are input as a dictionary surrounded by double quotes"
    echo "        Default rules: {'error': 'red', 'warn': 'yellow', 'info': 'blue'}"
    echo "        Example rules: {'error': 'red', 'warn': 'yellow', 'info': 'blue', 'debug': 'green'}"
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage: reprint <input_file> <output_file> <rules>"
    echo "(Or use -h for help)"
    exit 1
fi
DIR=$(dirname -- "$0")
# See help in reprint.py
# NEEDS reprint.py on the same folder or in a subfolder
REPRINT_PATH=$(find $DIR -name "reprint.py" -type f)
if [ -z "$REPRINT_PATH" ]; then
    echo "reprint.py not found, where is it? (Write complete path, e.g. /home/user/reprint.py)"
    read REPRINT_PATH
fi

python $REPRINT_PATH "$@"