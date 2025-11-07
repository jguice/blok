# Custom Icon for Blok Screensaver

The Blok screensaver now includes a custom icon that shows a white rectangle on a black background, representing what the screensaver actually displays.

## Building the Icon (on macOS)

To build the icon file from the iconset:

```bash
./build_icon.sh
```

Or manually:

```bash
iconutil -c icns Blok.iconset -o Blok.icns
```

## Icon Files

- `Blok.iconset/` - Directory containing all icon sizes (16x16 through 1024x1024 in both 1x and 2x resolutions)
- `Blok_Icon.png` - Preview of the icon at 512x512 resolution
- `build_icon.sh` - Script to build the .icns file
- `generate_icon.py` - Python script to regenerate icon images if needed

## After Building

Once you've built `Blok.icns`, it will automatically be included in your screensaver bundle when you build the Xcode project. The screensaver icon will appear in System Settings > Screen Saver instead of the generic macOS screensaver icon.

## Customizing the Icon

To customize the icon appearance, edit `generate_icon.py` and adjust:
- Background color (currently black)
- Rectangle color (currently white)
- Rectangle size (currently 1/3 of icon size)
- Rectangle position (currently slightly off-center)

After making changes, run:

```bash
python3 generate_icon.py
./build_icon.sh
```

Then rebuild the Xcode project.
