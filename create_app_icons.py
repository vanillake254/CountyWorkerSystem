#!/usr/bin/env python3
"""Generate app icons from government building design"""
from PIL import Image, ImageDraw

def create_app_icon(size, with_padding=False):
    """Create a government building icon for app launcher"""
    img = Image.new('RGBA', (size, size), (59, 89, 152, 255) if not with_padding else (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Add padding for foreground icon
    padding = int(size * 0.15) if with_padding else 0
    effective_size = size - (2 * padding)
    scale = effective_size / 200
    offset = padding
    
    # Colors
    blue = (59, 89, 152)  # #3B5998
    dark_blue = (44, 67, 115)  # #2C4373
    white = (255, 255, 255)
    
    # Building body
    building_left = int(50 * scale) + offset
    building_top = int(60 * scale) + offset
    building_right = int(150 * scale) + offset
    building_bottom = int(140 * scale) + offset
    draw.rectangle([building_left, building_top, building_right, building_bottom], 
                   fill=blue, outline=dark_blue, width=max(2, int(3*scale)))
    
    # Columns (white pillars)
    col_width = int(10 * scale)
    col_top = int(70 * scale) + offset
    col_bottom = int(130 * scale) + offset
    
    for x in [60, 85, 110, 135]:
        col_left = int(x * scale) + offset
        col_right = col_left + col_width
        draw.rectangle([col_left, col_top, col_right, col_bottom], fill=white)
    
    # Roof (triangle)
    roof_points = [
        (int(100 * scale) + offset, int(40 * scale) + offset),  # top
        (int(40 * scale) + offset, int(60 * scale) + offset),   # left
        (int(160 * scale) + offset, int(60 * scale) + offset)   # right
    ]
    draw.polygon(roof_points, fill=dark_blue)
    
    # Base
    base_left = int(40 * scale) + offset
    base_top = int(140 * scale) + offset
    base_right = int(160 * scale) + offset
    base_bottom = int(150 * scale) + offset
    draw.rectangle([base_left, base_top, base_right, base_bottom], fill=dark_blue)
    
    # Door
    door_left = int(85 * scale) + offset
    door_top = int(110 * scale) + offset
    door_right = int(115 * scale) + offset
    door_bottom = int(140 * scale) + offset
    draw.rectangle([door_left, door_top, door_right, door_bottom], fill=dark_blue)
    
    return img

# Create main icon (1024x1024 for best quality)
print("Creating app icons...")
main_icon = create_app_icon(1024)
main_icon.save('/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend/assets/images/icon.png')
print("✅ Main icon created: assets/images/icon.png")

# Create adaptive icon foreground (with transparency and padding)
foreground_icon = create_app_icon(1024, with_padding=True)
foreground_icon.save('/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend/assets/images/icon_foreground.png')
print("✅ Foreground icon created: assets/images/icon_foreground.png")

print("\n✅ All app icons created successfully!")
print("Run: flutter pub get && flutter pub run flutter_launcher_icons")
