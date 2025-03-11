# Zsh Scripts

This repository contains a collection of Zsh scripts designed to make your life easier. For detailed options and examples, run each script with the `-h` flag.

## Available Scripts

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Zsh Scripts](#zsh-scripts)
  - [Available Scripts](#available-scripts)
    - [Add to path](#add-to-path)
    - [Copy pattern](#copy-pattern)
    - [Git combine](#git-combine)
    - [Multiple mkdir](#multiple-mkdir)
    - [Remove recursively](#remove-recursively)
    - [Rename by RegEx](#rename-by-regex)
    - [Replace shared name](#replace-shared-name)
    - [Reprint](#reprint)

<!-- /code_chunk_output -->

### Add to path

- **File:** `add_to_path.sh`
- **Description:** Add an internal script `<source_file>` to the path so it can be launched from ✨anywhere✨ as the command `<name_of_command>`. It will ask for the root password.
- **Usage:** `add_to_path.sh <source_file> <name_of_command>`
- **Example:** `add_to_path.sh my_script.sh test_script` will make `my_script.sh` available as `test_script`.
- **Good-to-know behavior:**
  - If the command already exists, it will be overwritten.
  - It creates a temporary file with a random name (it is deleted at the end of execution).
  - The root password is required to copy the soft link created to `/usr/local/bin/`.
- **Arguments:**

| Argument           | Description                               |
|---------------------|-------------------------------------------|
| `<source_file>`     | The **executable** file to be added to the path |
| `<name_of_command>` | The name of the command to be created |

### Copy pattern

- **File:** `copy_pattern.sh`
- **Description:** This script copies a file into multiple directories with a repeated pattern.
- **Usage:** `copy_pattern.sh <initial_file_folder> <filename> <min> <max> <repeated_pattern>`
- **Example:** `copy_pattern.sh folderX initial_file 1 5 folder` will copy the file `folderX/initial_file` into `folder1/initial_file`, `folder2/initial_file`, `folder3/initial_file`, `folder4/initial_file`, `folder5/initial_file`.
- **Good-to-know behavior:**
  - If the exact file already exists in the destination folder, it will be overwritten.
  - If the origin folder-file is included in the list of destination folders, it will be skipped.
  - It starts copying the file from the `<min>` directory to the `<max>` directory.
- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<initial_file_folder>` | The folder containing the initial file                      |
| `<filename>`            | The name of the file to be copied                              |
| `<min>`                 | The starting number for the pattern                            |
| `<max>`                 | The ending number for the pattern                              |
| `<repeated_pattern>`    | The pattern for the directories where the file will be copied  |

### Git combine

- **File:** `git_combine.sh`
- **Description:** This script combines the incoming changes from the cloud branch into the current local branch. Conflict resolution may be required.
- **Usage:** `git_combine.sh`
- **Example:** `git_combine.sh`, without arguments. If you have a dirty folder, it will store the current changes, pull the latest commit, and restore the local changes over it.
- **Good-to-know behavior:**
  - stash -> merge origin -> stash pop
- **Arguments:** None

### Multiple mkdir

- **File:** `multiple_mkdir.sh` (suggested alias: `mmkdir`)
- **Description:** This script creates multiple subdirectories under the current path with names from `pattern&min` to `pattern&max`.
- **Usage:** `multiple_mkdir.sh <pattern> <min> <max>`
- **Example:** `multiple_mkdir.sh folder 1 5` will create folders `folder1`, `folder2`, `folder3`, `folder4`, `folder5`.
- **Good-to-know behavior:**
  - Uses the `mkdir` command.
  - It starts creating folders from the `<min>` to `<max>`.
- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<pattern>` | The name of the directories to be created |
| `<min>`     | The starting number for the pattern       |
| `<max>`     | The ending number for the pattern         |

### Remove recursively

- **File:** `remove_recursively.sh`
- **Description:** This script removes all files matching the given pattern in the current directory and its subdirectories.
- **Usage:** `remove_recursively.sh <pattern>`
- **Example:** `remove_recursively.sh *1.txt` will remove all .txt files in the current directory and its subdirectories whose names end with 1.
- **Good-to-know behavior:**
  - The pattern is a regex pattern.
  - It uses the `find` command.
- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<pattern>` | The regular expression used to find the files to be removed |

### Rename by RegEx

- **File:** `rename_by_regex.sh`
- **Description:** This command renames all files in the given directory and its subdirectories that match the source regex to the destination regex. Adding -t will transform from traditional RegEx syntax `(\d\w(.*)\$1)` to sed's syntax `([0-9][a-zA-Z](\.*)\1`.
- **Usage:** `rename_by_regex <directory> <source_regex> <destination_regex>`
- **Example:** `rename_by_regex.sh example '^5_([0-9]\.*) '4_\1'` will rename all files starting with "5_" in /example and its subdirectories to "4_", followed by the rest of the name.
- **Good-to-know behavior:**
  - The pattern is a regex pattern.
  - For security, it creates a backup of the files before renaming them. At the end of execution, it will ask if you want to delete the backups (they are conserved by default).
  - If two files are going to be named the same:
    - In Mac: the script will add a number to the end of the file name.
    - In Unix: the command `cp` will be used with the flag `--backup=t`.
- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<directory>` | The directory containing the files to be renamed |
| `<source_regex>` | The regular expression used to find the files to be renamed |
| `<destination_regex>` | The replacement pattern for the files |

### Replace shared name

- **File:** `replace_shared_name.sh`
- **Description:** This command replaces files in the parent folder with files from the source folder.
- **Usage:** `replace_shared_name.sh <source_folder> <parent_folder> [<custom_ending>]`
- **Example:** `replace_shared_name.sh /home/user/source /home/user/destination` will replace all files in `/home/user/destination` with files from `/home/user/source`.
- **Good-to-know behavior:**
  - `<custom_ending>` is optional. If not provided, it will use only the file name.
  - It will display more information about the current status of the operation if the `-v` flag is used (before or after any argument).
- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<source_folder>` | The source folder containing the files to replace |
| `<parent_folder>` | The parent folder containing the files to be replaced |
| `<custom_ending>` | A custom ending to look for in the source folder |

### Reprint

- **File:** `reprint.sh`
- **Description:** This command highlights the lines of a file according to the rules provided.
- **Usage:** `reprint.sh <input_file> <output_file> <rules>`
- **Example:** `reprint.sh examples/example_reprint.txt examples/example_out.txt "{'error': 'red', 'warn': 'yellow', 'info': 'blue', 'debug': 'green'}"`. This example file is included in the repository.
- **Good-to-know behavior:**
  - Needs the termcolor python package.
  - If `reprint.sh` is added to the path using the script, `reprint.py` needs to be added as well, as `reprint.py`. Otherwise, the python file needs to be in the same folder as the script (or in a subfolder).
  - If `reprint.py` is not found, the script will ask for its path.
  - `reprint.py` can be used as a standalone script as `python reprint.py`.
  - Rules are written as a python dictionary.
  - The output file will use terminal color codes like ` [31`, so it
    is recommended to use a terminal that supports them.
- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<input_file>` | The input file to be processed |
| `<output_file>` | The output file to be generated |
| `<rules>` | The rules for highlighting lines, modeled as a python dictionary |
