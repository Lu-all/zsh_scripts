#!/bin/zsh

function check_args {
    if [ "$1" = "-h" ]; then
        echo "Search for an article in local files or online by specifying the reference tag of its BiBTeX entry (e.g. 'doe2000examples') or filename (e.g. 'doe-examples.pdf')"
        echo "App can only be specified if tag is also specified"
        echo "Compatible apps: 'edge', 'firefox', 'chrome', 'safari' or 'acrobat'"
        echo "WARNING: for now it only tested in MAC"
        echo "Usage: search_article.sh <tag> <app>"
        echo "Arguments:"
        echo "    <tag> : The reference tag of the article you want to search for"
        echo "    <app> : The app you want to open the file with"
        exit 0
    fi

    if [ "$#" -eq 2 ]; then
        REFERENCE_TAG=$1
        APP=$2
        parse_app_name
    else
        if [ "$#" -eq 1 ]; then
            REFERENCE_TAG=$1
            echo "Searching for article $REFERENCE_TAG"
        else
            # Ask for the reference tag
            echo "Enter the reference tag of the article you want to search for"
            read REFERENCE_TAG
            #check if not empty
            if [ -z "$REFERENCE_TAG" ]; then
                echo "..."
                exit 3
            fi
            # Ask for the app to open the file
            echo "Enter the app you want to open the file with ('edge', 'firefox', 'chrome', 'safari' or 'acrobat')"
            read APP
            if [ -z "$APP" ]; then
                echo "..."
                exit 3
            fi
            parse_app_name
        fi
    fi
    find_database_path
}

function find_bib_path {
    # Check if the path of the bib collection is defined
    if [ -z "$BIB_PATH" ]; then
        echo "The path of the bibtex file collection (BIB_PATH) is not defined. What is the path?"
        read BIB_PATH
        # check if it exists
        if ! [ -d "$BIB_PATH" ]; then
            echo "Error: The database path provided does not exist"
            exit 1
        fi
        if ! grep -q "BIB_PATH" ~/.zshrc; then
            echo "export BIB_PATH=\"$BIB_PATH\"" >> ~/.zshrc
        else
            echo "... Check your BIB_PATH variable"
        fi
    fi
}

function find_database_path {
    # Check if the path of the database is defined
    if [ -z "$DATABASE_PATH" ]; then
        echo "The path of the database (DATABASE_PATH) is not defined. What is the path?"
        read DATABASE_PATH
        # check if it exists
        if ! [ -d "$DATABASE_PATH" ]; then
            echo "Error: The database path provided does not exist"
            exit 1
        fi
        # and" export it, saving it for future use
        # BUT first check if DATABASE_PATH is already on ~./zshrc
        if ! grep -q "DATABASE_PATH" ~/.zshrc; then
            echo "export DATABASE_PATH=\"$DATABASE_PATH\"" >> ~/.zshrc
        else
            echo "... Check your DATABASE_PATH variable"
        fi
    fi
}

function find_file {
    # Strip the extension from reference tag
    REFERENCE_TAG=$(echo $REFERENCE_TAG | sed 's/\.[^.]*$//')

    # find recursively the file that has the same name, ending with ".pdf"
    FILEPATH=$(find $DATABASE_PATH -name "$REFERENCE_TAG.pdf")
    if [ -z "$FILEPATH" ]; then
        echo " ⚠ Error: The article with reference tag $REFERENCE_TAG was not found in $DATABASE_PATH"
        echo "   Searching online version"
        search_online
    else
        echo "   Found $FILEPATH!"
    fi
}

function open_app {
    if [ -z $APP ]; then
        search_compatible_app
    fi
    echo "Opening $APP ..."
    open -a $APP $FILEPATH
}

function parse_app_name {
    if [ $APP = 'edge' ] || [ $APP = "Microsoft Edge" ]; then
        APP="Microsoft Edge"
    else
        if [ $APP = 'firefox' ] || [ $APP = "Firefox" ]; then
            APP="Firefox"
        else
            if [ $APP = 'chrome' ] || [ $APP = "Google Chrome" ]; then
                APP="Google Chrome"
            else
                if [ $APP = 'safari' ] || [ $APP = "Safari" ]; then
                    APP="Safari"
                else
                    if [ $APP = 'acrobat' ] || [ $APP = "Adobe Acrobat Reader" ]; then
                        APP="Adobe Acrobat Reader"
                    else
                        echo "Error: App $APP not supported, searching compatible app..."
                        APP=""
                    fi
                fi
            fi
        fi
    fi
}

function parse_app_path {
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     os_type=Linux;;
        Darwin*)    os_type=Mac;;
        MINGW*)     os_type=MinGw;;
        *)          os_type="UNKNOWN:${unameOut}"
    esac

    if [ $os_type = "Mac" ]; then
        APP_PATH="/Applications"
    else
        if [ $os_type = "Linux" ]; then
            APP_PATH="/usr/bin"
        else
            if [ $os_type = "MinGw" ]; then
                APP_PATH="/mnt/c/Program Files"
            else
                echo "Error: OS not supported"
                exit 1
            fi
        fi
    fi
}

function search_compatible_app {
    search_compatible_browser
    RETURN_BROWSER=$?
    if [ $RETURN_BROWSER != 0 ]; then
        if ! find $APP_PATH/Adobe\ Acrobat\ Reader* -maxdepth 1 > /dev/null; then
            echo 'Error: No supported app found (edge, firefox, chrome, safari or acrobat). Is this a supported OS?' >&2
            exit 1
        else
            APP="Adobe Acrobat Reader"
        fi
    fi
}

function search_compatible_browser {
    if [ -z $APP_PATH ]; then
        parse_app_path
    fi
    if ! find $APP_PATH/Microsoft\ Edge* -maxdepth 1 > /dev/null; then
        if ! find $APP_PATH/Firefox* -maxdepth 1 > /dev/null; then
            if ! find $APP_PATH/Google\ Chrome* -maxdepth 1 > /dev/null; then
                if ! find $APP_PATH/Safari* -maxdepth 1 > /dev/null; then
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
                echo "Error: No supported browser found (edge, firefox, chrome, safari)." >&2
                exit 1
            fi
        fi
    fi
}

# MAIN
APP=""
check_args $@
find_file
open_app
