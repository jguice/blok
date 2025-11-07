#!/bin/bash
# Install screensaver and refresh icon cache

SAVER_PATH="$1"

if [ -z "$SAVER_PATH" ]; then
    # Try to find it in DerivedData
    SAVER_PATH=$(find ~/Library/Developer/Xcode/DerivedData/Blok-*/Build/Products -name "Blok.saver" 2>/dev/null | head -1)
fi

if [ ! -d "$SAVER_PATH" ]; then
    echo "Error: Cannot find Blok.saver"
    echo "Usage: $0 /path/to/Blok.saver"
    exit 1
fi

echo "Installing from: $SAVER_PATH"

# Kill System Settings if running
killall "System Settings" 2>/dev/null || killall "System Preferences" 2>/dev/null

# Remove old version
rm -rf ~/Library/Screen\ Savers/Blok.saver

# Copy new version
cp -R "$SAVER_PATH" ~/Library/Screen\ Savers/

# Clear icon cache
rm -rf /Library/Caches/com.apple.iconservices.store
rm -rf ~/Library/Caches/com.apple.iconservices.store
killall Dock
killall Finder

# Touch the file to update modification date
touch ~/Library/Screen\ Savers/Blok.saver

echo "✓ Installed to ~/Library/Screen Savers/Blok.saver"
echo "✓ Cleared icon cache"
echo "✓ Restarted Dock and Finder"
echo ""
echo "Now open System Settings > Screen Saver and select Blok"
