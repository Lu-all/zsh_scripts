#!/bin/zsh

if [ "$1" == "-h" ]; then
    echo "Usage: better_freeze"
    echo "This script generates a requirements.txt file with the current Python environment's packages."
    echo "It uses pipdeptree to create a detailed list of dependencies."
    echo "If pipdeptree is not installed, it will fall back to pip freeze."
    exit 0
fi

# check if running in a virtual environment
if [ -z "$VIRTUAL_ENV" ]; then
    echo "This script should be run inside a virtual environment."
    echo "Please activate your virtual environment before running this script."
    exit 1
fi
# If Python2*
if python --version 2>&1 | grep -q "Python 2"; then
    echo "# Tested in Python" $(python -c "print(__import__('platform').python_version())") > requirements.txt
else
# If Python3*
    echo "# Tested in" $(python --version) > requirements.txt
fi
echo "# Generated on" $(date) >> requirements.txt
echo "# Requirements:" >> requirements.txt
# check for pipdeptree
if ! command -v pipdeptree &> /dev/null; then
    echo "Consider installing pipdeptree to generate requirements.txt"
    echo "You can install it with: pip install pipdeptree"
    echo "Continuing without pipdeptree..."
    pip freeze >> requirements.txt
else
    # generate requirements.txt
    pipdeptree -f --warn silence | grep -E '^[a-zA-Z0-9\-]+' >> requirements.txt
fi
