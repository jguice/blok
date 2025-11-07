#!/usr/bin/env python3
"""Create a simple .icns file structure for macOS."""
import struct
import os

# Read the 512x512 PNG we already created
with open('Blok.iconset/icon_512x512.png', 'rb') as f:
    png_data = f.read()

# Simple .icns file format:
# Header: 'icns' (4 bytes) + file size (4 bytes)
# Icon entry: type (4 bytes) + size (4 bytes) + data

icon_type = b'ic10'  # 512x512@2x (we'll use it for 512x512)
entry_size = 8 + len(png_data)
total_size = 8 + entry_size

# Write .icns file
with open('Blok.icns', 'wb') as f:
    # Header
    f.write(b'icns')
    f.write(struct.pack('>I', total_size))

    # Icon entry
    f.write(icon_type)
    f.write(struct.pack('>I', entry_size))
    f.write(png_data)

print('Created Blok.icns')
print('Note: This is a basic .icns file. For best results, run ./build_icon.sh on macOS')
