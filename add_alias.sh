#!/bin/zsh

if [ "$1" = "-h" ]; then
    echo "Usage: add_alias <alias_name> '<command>'"
    echo "Add an alias to your Zsh configuration."
    echo "Example: add_alias example_alias 'echo \"$0\"'."
    echo "Remember to reload (source ~/.zshrc) to apply the changes!"
    echo "Arguments:"
    echo "  <alias_name> : The name of the alias you want to create."
    echo "  <command>    : The command that the alias will execute. Change all occurrences of \" to \\\"."
    exit 0
fi

# If $ALIAS_FILE is not set, use the default .zshrc file
if [ -z "$ALIAS_FILE_PATH" ]; then
    ALIAS_FILE_PATH="$HOME/.zshrc"
    echo "export ALIAS_FILE_PATH=\"$HOME/.zshrc\"" >> $HOME/.zshrc
fi


echo 'alias '$1'="'$2'"' >> $ALIAS_FILE_PATH
