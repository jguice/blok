#!/bin/bash
# Build the Blok.icns icon file from the iconset
# This script must be run on macOS as it uses the iconutil command

if [ ! -d "Blok.iconset" ]; then
    echo "Error: Blok.iconset directory not found"
    exit 1
fi

echo "Building Blok.icns from Blok.iconset..."
iconutil -c icns Blok.iconset -o Blok.icns

if [ $? -eq 0 ]; then
    echo "Successfully created Blok.icns"
    echo "The icon will be included in the next build"
else
    echo "Failed to create Blok.icns"
    exit 1
fi
