import ast
import os
import re
import sys
from termcolor import colored

def help():
    print("Usage: python reprint.py <input_file> <output_file> <rules>")
    print("     (or reprint <input_file> <output_file> <rules> if running from terminal")
    print("Arguments:")
    print("    <input_file> : Path to the file to be read")
    print("    <output_file> : Path to the file to be written with highlight markers for terminal")
    print("      The use of the command 'less' is recommended for better visualization")
    print("    <rules> : Dictionary of case-sensitive rules to be applied")
    print("      Reminder: they are input as a dictionary surrounded by double quotes")
    print("        Default rules: {'error': 'red', 'warn': 'yellow', 'info': 'blue'}")
    print("        Example rules: {'error': 'red', 'warn': 'yellow', 'info': 'blue', 'debug': 'green'}")

def color_text(text, rules):
    words = re.split(r'(\W)', text)
    colored_text = []
    for word in words:
        for rule, color in rules.items():
            if rule == word:
                word = colored(word, color)
        colored_text.append(word)
    return ''.join(colored_text)

# Default rules for 2 arguments
default_rules = {
    'error': 'red',
    'warn': 'yellow',
    'info': 'blue'
}

# Read the .txt file
if len(sys.argv) < 2:
    sys.tracebacklimit = 0
    raise IndexError('Cannot find input file, consult help with -h or --help')
# just in case error is not invoked correctly, use if-else
else:
    if str(sys.argv[1]) == "-h" or str(sys.argv[1]) == "--help":
        help()
        exit(0)
    file_path = str(os.path.abspath(str(sys.argv[1])))
    if len(sys.argv) > 2:
        output_path = str(os.path.abspath(str(sys.argv[2])))
        if not os.path.exists(output_path):
            # Create file if it does not exist
            create = open(output_path, 'w')
            create.close()
    else:
        output_path = file_path
    if len(sys.argv) > 3:
        try:
            rules = ast.literal_eval(str(sys.argv[3]))
        except ValueError:
            sys.tracebacklimit = 0
            print('Invalid rules input, consult help with -h or --help. Try literal "{\'a\' : \'b\'}", with double quotes')
            exit(2)
    else:
        rules = default_rules
    with open(file_path, 'r') as file:
        text = file.read()
    file.close()

    # Apply the rules and print the colored text
    with open(output_path, 'w') as output_file:
        print(color_text(text, rules), sep="", file=output_file)
    output_file.close()

