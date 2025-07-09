#!/bin/sh
echo "Installing add_to_path"
chmod +x add_to_path.sh
ln -s add_to_path.sh add
sudo cp add /usr/local/bin/add_to_path
rm add
echo "Installing common scripts to /usr/local/bin..."
for file in ./*.sh; do
    [ -e "$file" ] || continue
    basename=$(basename "$file")
    name_without_extension="${basename%.sh}"
    if [ "$name_without_extension" != "add_to_path" ] && [ "$name_without_extension" != "INSTALL" ]; then
        echo "   Installing $name_without_extension"
        sudo add_to_path "$file" "$name_without_extension"
    fi
done
if [ "$(uname)" = "Darwin" ] && [ -d "Darwin-exclusive" ]; then
    echo "Installing MacOS scripts..."
    for file in Darwin-exclusive/*.sh; do
        [ -e "$file" ] || continue
        basename=$(basename "$file")
        name_without_extension="${basename%.sh}"
        echo "   Installing $name_without_extension"
        sudo add_to_path "$file" "$name_without_extension"
    done
fi

echo "Installing dependencies..."
# Install the Python script for reprint
echo "   Installing reprint.py"
sudo add_to_path ./reprint/reprint.py reprint.py
