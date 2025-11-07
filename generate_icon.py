#!/usr/bin/env python3
"""Generate icon images for the Blok screensaver."""

from PIL import Image, ImageDraw

def create_blok_icon(size):
    """Create a Blok icon at the specified size."""
    # Create black background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    # Calculate rectangle size (about 1/3 of icon size)
    rect_size = size // 3

    # Position rectangle slightly off-center for dynamic look
    x = size // 2 - rect_size // 2 + size // 10
    y = size // 2 - rect_size // 2 - size // 10

    # Draw white rectangle
    draw.rectangle(
        [(x, y), (x + rect_size, y + rect_size)],
        fill=(255, 255, 255, 255),
        outline=None
    )

    return img

# Generate icon sizes
sizes = [16, 32, 64, 128, 256, 512, 1024]

for size in sizes:
    icon = create_blok_icon(size)
    filename = f'icon_{size}x{size}.png'
    icon.save(filename)
    print(f'Created {filename}')

# Also create a combined icon at 512x512 for preview
icon_512 = create_blok_icon(512)
icon_512.save('Blok_Icon.png')
print('Created Blok_Icon.png')
