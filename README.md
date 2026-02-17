# Zsh Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Tag](https://img.shields.io/github/v/tag/Lu-all/zsh_scripts)](https://github.com/Lu-all/zsh_scripts/releases/)


This repository contains a collection of Zsh scripts designed to make your life easier. For detailed options and examples, run each script with the `-h` flag.

## Available Scripts

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Zsh Scripts](#zsh-scripts)
  - [Available Scripts](#available-scripts)
    - [Add alias](#add-alias)
    - [Add to path](#add-to-path)
    - [Better freeze](#better-freeze)
    - [Check app leftovers](#check-app-leftovers)
    - [Color functions (colorfun)](#color-functions-colorfun)
    - [Copy pattern](#copy-pattern)
    - [Git combine](#git-combine)
    - [Multiple mkdir](#multiple-mkdir)
    - [Remove recursively](#remove-recursively)
    - [Rename by RegEx](#rename-by-regex)
    - [Replace shared name](#replace-shared-name)
    - [Reprint](#reprint)
    - [Search article](#search-article)

<!-- /code_chunk_output -->

### Add alias

- **File:** `add_alias.sh`
- **Description:** Add an alias to the Zsh configuration file.
- **Usage:** `add_alias.sh <alias_name> '<command>'`
- **Example** `add_alias example_alias 'echo \"$0\"'`
  (execute `example_alias` for `echo "$0"`).
- **Good-to-know behavior:**
  - Remember to reload (`source ~/.zshrc`) to apply the changes!
  - It will add the alias to the file specified by the variable `ALIAS_FILE_PATH`.
    - If it is not set, it will be set with the value `$HOME/.zshrc`.
  - You should replace all occurrences of `"` with `\"` in the command.
- **Arguments:**

| Argument      | Description                               |
|---------------|-------------------------------------------|
| `<alias_name>` | The name of the alias to be created       |
| `<command>`    | The command to be executed when the alias is called |


### Add to path

- **File:** `add_to_path.sh`
- **Description:** Add an internal script `<source_file>` to the path so it can be launched from ✨anywhere✨ as the command `<name_of_command>`. It will ask for the root password.
- **Usage:** `add_to_path.sh <source_file> <name_of_command>`
- **Example:** `add_to_path.sh my_script.sh test_script` will make `my_script.sh` available as `test_script`.
- **Good-to-know behavior:**
  - To add `add_to_path.sh` to the path, you need to manually execute the following commands:

    ```sh
    chmod +x add_to_path.sh
    ln -s add_to_path.sh add
    sudo cp add /usr/local/bin/add_to_path
    rm add
    ```

  - If the command already exists, it will be overwritten.
  - It creates a temporary file with a random name (it is deleted at the end of execution).
  - The root password is required to copy the soft link created to `/usr/local/bin/`.
- **Arguments:**

| Argument           | Description                               |
|---------------------|-------------------------------------------|
| `<source_file>`     | The **executable** file to be added to the path |
| `<name_of_command>` | The name of the command to be created |


### Better freeze

- **File:** `better_freeze.sh`
- ***Description:** This script generates a `requirements.txt` file with the current Python environment's packages, the time of creation of the requirements file, and the Python version used in the virtual environment.
- **Usage:** `better_freeze.sh`
- ***Good-to-know behavior:**
  - This script should be run inside a virtual environment.
  - It uses `pipdeptree` to create a detailed list of dependencies.
  - If `pipdeptree` is not installed, it will fall back to `pip freeze`.
  - If the script is run with the `-h` flag, it will display usage.

### Check app leftovers

- **File:** `Darwin-exclusive/check_app_leftovers.sh`
- **Description:** This script checks for leftover files of a specified application in various directories. While removing these, it will create a backup of the files in a directory on your Desktop.
- **Usage:** `check_app_leftovers.sh <app_name>`
- **Example:** `check_app_leftovers.sh MyApp` will check for leftover files of `MyApp` in the following directories:
  - `~/Library/Application Support/`
  - `~/Library/Preferences/`
  - `~/Library/Caches/`
  - `~/Library/Logs/`
  - `~/Library/LaunchAgents/`
- **Good-to-know behavior:**
  - If the script is run with the `-h` flag, it will display usage
  - If the backup cannot be created, the files will not be removed.
  - The backup directory is created with a random name in the format `~/Desktop/?.nosync`, where `?` is a random string.
- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<app_name>` | The name of the application to check for leftovers |


### Color functions (colorfun)

- **File:** `colorfun/colorfun.sh`
- **Description:** This script provides various color manipulation functions, including obtaining dominant colors from images, adjusting lightness, calculating saturation and more.
- **Usage:** `Usage: colorfun <function> <function_arguments> [--format=<target_format>]`
- **Example:** `colorfun obtain_color path/to/image.jpg --format=RRGGBB` will obtain the dominant color from the specified image and output it in `RRGGBB` format. Another example: `For example, 'colorfun redder "#005566" 100 --format="#RRGGBB"' returns '#645566'.
- **Good-to-know behavior:**
  - Requires 'colourpeek' Python package.
  - The color outputs are in 0xAARRGGBB format by default.
  - If `reprint.sh` is added to the path using the script, `adjust_lightness.py` needs to be added as well, as `adjust_lightness.py`. Otherwise, the python file needs to be in the same folder as the script (or in a subfolder).
  - If `adjust_lightness.py` or `colourpeek` is not found, the script will ask for its path.
- **Arguments:**

| Argument           | Description                               |
|---------------------|-------------------------------------------|
| `<function>`        | The color manipulation function to be executed. Currently supported functions: `redder`, `greener`, `bluer`, `yellower`, `purpler`, `half_color`, `darker`, `lighter`, `saturation`, `obtain_color` |
| `--format=<target_format>` | (Optional) Specify output format: `RRGGBB`, `AARRGGBB`, `#RRGGBB`, `#AARRGGBB`, `0xRRGGBB`, `0xAARRGGBB` |

- **Functions**

| Function           | Arguments | Description                               |
|---------------------|----------|---------------------------------|
| `redder` | `<color> [increment]`    | Make color redder |
| `greener` | `<color> [increment]`   | Make color greener |
| `bluer` | `<color> [increment]`     | Make color bluer |
| `yellower` | `<color> [increment]`  | Make color yellower |
| `purpler` | `<color> [increment]`   | Make color purpler |
| `half_color` | `<color>`            | Make color half transparent |
| `darker` | `<color> [increment]`    | Make color darker |
| `lighter` | `<color> [increment]`   | Make color lighter |
| `saturation` | `<color>`            | Get saturation of color as a number in the range 0-255 |
| `obtain_color` | `<image_path>` | Obtain dominant color from image and adjust its lightness. Optimized to get an accent color in dark backgrounds. |

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

### Delete spaces in filenames
- **File:** `delete_spaces_in_filenames.sh`
- **Description:** This script renames files in the specified directory by replacing spaces in filenames with underscores.
- **Usage:** `delete_spaces_in_filenames.sh <directory>`
- **Example:** `delete_spaces_in_filenames.sh ./dir1` will rename all files in `dir1`. For example, `my file.txt` will be renamed to `my_file.txt`.
- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<directory>` | The directory containing the files to be renamed |

### Git combine

- **File:** `git_combine.sh`
- **Description:** This script combines the incoming changes from the cloud branch into the current local branch. Conflict resolution may be required.
- **Usage:** `git_combine.sh`
- **Example:** `git_combine.sh`, without arguments. If you have a dirty folder, it will store the current changes, pull the latest commit, and restore the local changes over it.
- **Good-to-know behavior:**
  - stash -> merge origin -> stash pop
- **Arguments:** None

### Multiple mkdir

- **File:** `mmkdir.sh`
- **Description:** This script creates multiple subdirectories under the current path with names from `pattern&min` to `pattern&max`.
- **Usage:** `mmkdir.sh <pattern> <min> <max>`
- **Example:** `mmkdir.sh folder 1 5` will create folders `folder1`, `folder2`, `folder3`, `folder4`, `folder5`.
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
- **Usage:** `remove_recursively.sh '<pattern>'`
- **Example:** `remove_recursively.sh '*1.txt'` will remove all .txt files in the current directory and its subdirectories whose names end with 1.
- **Good-to-know behavior:**
  - The pattern is a regex pattern.
  - Remember to add the quotes around the regex patterns to avoid shell expansion!
  - It uses the `find` command.
  - For security, it creates a backup of the files before removing them. At the end of execution, it will ask if you want to delete the backups (they are conserved by default).
- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<pattern>` | The regular expression used to find the files to be removed |

### Rename by RegEx

- **File:** `rename_by_regex.sh`
- **Description:** This command renames all files in the given directory and its subdirectories that match the source regex to the destination regex.
- **Usage:** `rename_by_regex <directory> '<source_regex>' '<destination_regex>'`
- **Example:** `rename_by_regex.sh example '^5_([0-9]\.*) '4_\1'` will rename all files starting with "5_" in /example and its subdirectories to "4_", followed by the rest of the name.
- **Good-to-know behavior:**
  - The pattern is a regex pattern.
  - Remember to add the quotes around the regex patterns to avoid shell expansion!
  - It uses the `find` command.
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

### Search article

- **File:** `search_article.sh`
- **Description:** Search for an article in local files or online by specifying the reference tag of its BiBTeX entry (e.g. 'doe2000examples') or filename (e.g. 'doe-examples.pdf').
Compatible apps: `edge`, `firefox`, `chrome`, `safari` or `acrobat`.
- **Usage:** `search_article.sh <tag> <app>`
- **Example:** `search_article.sh doe2000examples acrobat`.
- **Good-to-know behavior:**
  - App can only be specified if tag is also specified.
  - Needs to declare the environment variables `BIB_DIR` and `DATABASE_PATH` to the folder where the bibTeX and PDF files are stored, respectively. If the needed variable not declared, it will ask for the path.
  - If the file is not found in the local folder, it will search for it online using the doi or url from the bibTeX file.
  - Adding `-t` will search for the file by token instead of tag, for example, `search_article.sh -t greatexamples acrobat` will search for an article containing the token `greatexamples` instead of `greatexamples.pdf`.
  - Adding `-l` will only search ion the local PDF filenames (by regex), not searching in the bibTeX files.
  - To add compatibility with more apps, modify the following functions:
    - `parse_app_name`
    - `search_compatible_browser` or `search_compatible_app`

- **Arguments:**

| Argument    | Description                               |
|-------------|-------------------------------------------|
| `<tag>`     | The input file to be processed |
| `<app>`     | The output file to be generated |
