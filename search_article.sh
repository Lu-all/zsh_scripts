#!/bin/zsh

#################
# to add compatibility with more apps, modify
# - parse_app_name
# - search_compatible_browser / search_compatible_app
#################

function check_args {
    # Check help
    if [ "$1" = "-h" ]; then
        help
    fi

    # Assign variables by number of parameters
    if [ "$#" -eq 2 ]; then
        REFERENCE_TAG=$1
        APP=$2
        parse_app_name
    elif [ "$#" -eq 1 ]; then
        REFERENCE_TAG=$1
        echo "Searching for article $REFERENCE_TAG"
    else
        # Ask for the reference tag
        echo "Enter the reference tag of the article you want to search for:"
        read REFERENCE_TAG
        if [ -z "$REFERENCE_TAG" ]; then
            echo "Error: Reference tag cannot be empty."
            exit 3
        fi

        # Ask for the app to open the file
        echo "Enter the app you want to open the file with ('edge', 'firefox', 'chrome', 'safari', or 'acrobat'):"
        read APP
        if [ -z "$APP" ]; then
            echo "Error: App cannot be empty."
            exit 3
        fi
        parse_app_name
    fi
    find_database_path
}

function check_token {
    # Check if -t is used
    # For each paramenter, check if it is -t or -h
    for param in "$@"; do
        if [ "$param" != "-t" ]; then
            if [ "$param" = "-h" ]; then
            # If -h, print help
                help
            fi
            # Else, add to a "other parameters" list
            MODIFIED_PARAMS+=("$param")
        else
        # If -t, enable searching by token
            BY_TOKEN=true
        fi
    done
}

function find_bib_path {
    # Check if the path of the bib collection is defined
    if [ -z "$BIB_PATH" ]; then
        echo "The path of the bibtex file collection (BIB_PATH) is not defined. What is the path?"
        read BIB_PATH
        # check if it exists
        if [ ! -d "$BIB_PATH" ]; then
            echo "Error: The database path provided does not exist."
            exit 1
        fi
        if ! grep -q "BIB_PATH" ~/.zshrc; then
            echo "export BIB_PATH=\"$BIB_PATH\"" >> ~/.zshrc
        else
            echo "... Check your BIB_PATH variable."
        fi
    fi
}

function find_database_path {
    # Check if the path of the database is defined
    if [ -z "$DATABASE_PATH" ]; then
        echo "The path of the database (DATABASE_PATH) is not defined. What is the path?"
        read DATABASE_PATH
        # check if it exists
        if [ ! -d "$DATABASE_PATH" ]; then
            echo "Error: The database path provided does not exist."
            exit 1
        fi
        # and export it, saving it for future use
        # BUT first check if DATABASE_PATH is already on ~./zshrc
        if ! grep -q "DATABASE_PATH" ~/.zshrc; then
            echo "export DATABASE_PATH=\"$DATABASE_PATH\"" >> ~/.zshrc
        else
            echo "... Check your DATABASE_PATH variable."
        fi
    fi
}

# Find file by token or tag
function find_file {
    if [ "$BY_TOKEN" = true ]; then
        find_file_by_token
    else
        find_file_by_tag
    fi
}

function find_file_by_tag {
    # Strip the extension from reference tag
    REFERENCE_TAG=$(echo "$REFERENCE_TAG" | sed 's/\.[^.]*$//')

    # find recursively the file that has the same name, ending with ".pdf"
    FILEPATH=$(find "$DATABASE_PATH" -name "$REFERENCE_TAG.pdf")
    if [[ -z "$FILEPATH" ]]; then
        echo "⚠ Error: The article with reference tag $REFERENCE_TAG was not found in $DATABASE_PATH."
        echo "   Searching online version..."
        search_online
    else
        echo "   Found $FILEPATH!"
    fi
}

function find_file_by_token {
    find_bib_path
    # Search for all entries that contain the token in a .bib file in BIB_PATH
    ALL_ENTRIES=$(awk -v token="$REFERENCE_TAG" 'BEGIN {RS="@"; FS="\n"} $0 ~ token {print "@" $0}' "$BIB_PATH"/*.bib)
    if [ -z "$ALL_ENTRIES" ]; then
        # No match in bib files, search in names of .pdf files
        echo "⚠ Error: No entry referencing '$REFERENCE_TAG' was found in the bibliography files."
        echo "Searching in filenames..."
        FILEPATH=$(find "$DATABASE_PATH" -type f -name "*$REFERENCE_TAG*.pdf")
        if [ -z "$FILEPATH" ]; then
            echo "⚠ Error: No file found. Add the entry to your bibliography files or rename the file to include the token."
            exit 1
        else
            # If it returns more than one file, print them giving a number to each one, and ask the user to select one by number
            if [[ $(echo "$FILEPATH" | wc -l) -gt 1 ]]; then
                echo "⚠ Multiple files found!"
                echo ""
                echo "$FILEPATH" | nl -w2 -s'. '
                echo ""
                echo "Select the file you want (input number):"
                read -r FILE_NUMBER
                # Example input: 1
                if ! [[ "$FILE_NUMBER" =~ ^[0-9]+$ ]]; then
                    # Not a number, do not bother, probably the user wants to exit
                    exit 0
                elif [[ "$FILE_NUMBER" -gt $(echo "$FILEPATH" | wc -l) || "$FILE_NUMBER" -lt 1 ]]; then
                    # Number out of range
                    echo "⚠ Error: Not a valid number. Exiting."
                    exit 2
                fi
                # Get filepath
                FILEPATH=$(echo "$FILEPATH" | sed -n "${FILE_NUMBER}p")
                OPEN_FILE="y"
            else
                # Only one match
                REFERENCE_TAG=$(basename "$FILEPATH" | sed 's/\.[^.]*$//')
                echo "   Found $REFERENCE_TAG!"
                echo "   Open file? (y/N)"
                read -r OPEN_FILE
            fi
            # If the user wants to open the file, call open_app (path already resolved)
            if [[ "$OPEN_FILE" =~ ^[Yy]$ ]]; then
                open_app
            fi
        fi
        exit 0
    else
        # Matches in bib files
        echo "\n%%%%%%%%%%%%%%%%%%%%%%%%%"
        echo "$ALL_ENTRIES"
        echo "\n%%%%%%%%%%%%%%%%%%%%%%%%%"
        exit 0
    fi
}

function help {
    echo "Search for an article in local files or online by specifying the reference tag of its BiBTeX entry (e.g. 'doe2000examples') or filename (e.g. 'doe-examples.pdf')"
    echo "App can only be specified if tag is also specified"
    echo "Compatible apps: 'edge', 'firefox', 'chrome', 'safari' or 'acrobat'"
    echo "WARNING: for now it only tested in MAC"
    echo "Usage: search_article.sh <tag> <app>"
    echo "Arguments:"
    echo "    <tag> : The reference tag of the article you want to search for"
    echo "    <app> : The app you want to open the file with"
    echo "Options:"
    echo "    -h : Show this help message"
    echo "    -t : Search by token instead of tag"
    exit 0
}

function parse_app_name {
    # Obtain canonical name of the app
    # add more apps as wanted (example: Skim, Brave, Opera, etc.)
    case "$APP" in
        # App is Microsoft Edge
        edge|Microsoft\ Edge) APP="Microsoft Edge" ;;
        # App is Firefox
        firefox|Firefox) APP="Firefox" ;;
        # App is Google Chrome
        chrome|Google\ Chrome) APP="Google Chrome" ;;
        # App is Safari
        safari|Safari) APP="Safari" ;;
        # App is Acrobat
        acrobat|Adobe\ Acrobat\ Reader) APP="Adobe Acrobat Reader" ;;
        *)
            echo "Error: App $APP not supported. Searching for a compatible app..."
            APP=""
            ;;
    esac
}

function parse_app_path {
    # Determine the application path based on the operating system
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*) APP_PATH="/usr/bin" ;;
        Darwin*) APP_PATH="/Applications" ;;
        MINGW*) APP_PATH="/mnt/c/Program Files" ;;
        *) echo "Error: OS not supported."; exit 1 ;;
    esac
}

function search_compatible_app {
    # Search an app the open the file
    search_compatible_browser
    RETURN_BROWSER=$?
    if [ $RETURN_BROWSER -ne 0 ]; then
        if ! find "$APP_PATH"/Adobe\ Acrobat\ Reader* -maxdepth 1 > /dev/null 2>&1; then
            echo "Error: No supported app found (edge, firefox, chrome, safari, or acrobat). Is this a supported OS?"
            exit 1
        else
            APP="Adobe Acrobat Reader"
        fi
    fi
}

function search_compatible_browser {
    # Return the first compatible browser found,
    # searching by Edge (default in Windows) -> Firefox (def. Linux) -> Chrome (most used) -> Safari (def. Mac)
    # reorder or add more browsers as wanted (example: Brave, Opera, etc.)
    if [ -z "$APP_PATH" ]; then
        parse_app_path
    fi
    if ! find "$APP_PATH"/Microsoft\ Edge* -maxdepth 1 > /dev/null 2>&1; then
        if ! find "$APP_PATH"/Firefox* -maxdepth 1 > /dev/null 2>&1; then
            if ! find "$APP_PATH"/Google\ Chrome* -maxdepth 1 > /dev/null 2>&1; then
                if ! find "$APP_PATH"/Safari* -maxdepth 1 > /dev/null 2>&1; then
                    return 1
                else
                    APP="Safari"
                fi
            else
                APP="Google Chrome"
            fi
        else
            APP="Firefox"
        fi
    else
        APP="Microsoft Edge"
    fi
}

function search_online {
    find_bib_path
    # Search for the URL or DOI of the article with the entry name REFERENCE_TAG in a .bib file in BIB_PATH
    ENTRY=$(awk -v tag="$REFERENCE_TAG" 'BEGIN {RS="@"; FS="\n"} $1 ~ tag {print "@" $0}' $BIB_PATH/*.bib)
    if [ -z "$ENTRY" ]; then
        echo "  ⚠  Error: The entry $REFERENCE_TAG was not found in the bibliography files"
        exit 1
    else
        URL=$(echo "$ENTRY" | grep "url\s*=\s*")
        DOI=$(echo "$ENTRY" | grep "doi\s*=\s*")
        # Strip the URL and DOI from everything except the value between { }
        URL=$(echo $URL | sed 's/.*{\(.*\)}.*/\1/')
        DOI=$(echo $DOI | sed 's/.*{\(.*\)}.*/\1/')
        if [ -n "$URL" ]; then
            echo "     Found URL: $URL"
            FILEPATH=$URL
        elif [ -n "$DOI" ]; then
            echo "     Found DOI: https://doi.org/$DOI"
            FILEPATH="https://doi.org/"$DOI
        else
            echo "  ⚠  Error: No URL or DOI found for the entry $REFERENCE_TAG"
            echo ""
            echo "Entry found:"
            echo ""
            echo $ENTRY
            exit 1
        fi
        if [ "$APP" = "Adobe Acrobat Reader" ]; then
            echo "   Adobe Acrobat Reader does not support opening URLs, opening in browser instead"
            APP="browser"
            search_compatible_browser
            RETURN_BROWSER=$?
            if [ $RETURN_BROWSER != 0 ]; then
                echo "Error: No supported browser found (edge, firefox, chrome, safari)."
                exit 1
            fi
        fi
    fi
}

function open_app {
    if [ -z "$APP" ]; then
        search_compatible_app
    fi

    echo "Opening $APP ..."
    open -a "$APP" "$FILEPATH" || { echo "Error: Failed to open $FILEPATH with $APP."; exit 1; }
}

# MAIN
APP=""
MODIFIED_PARAMS=()
BY_TOKEN=false
check_token "$@"
check_args "${MODIFIED_PARAMS[@]}"
find_file
open_app
