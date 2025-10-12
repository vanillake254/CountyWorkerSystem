#!/usr/bin/env python3
"""Generate favicon from SVG using PIL"""
from PIL import Image, ImageDraw

def create_government_icon(size):
    """Create a government building icon"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Scale factor
    scale = size / 200
    
    # Colors
    blue = (59, 89, 152)  # #3B5998
    dark_blue = (44, 67, 115)  # #2C4373
    white = (255, 255, 255)
    
    # Building body
    building_left = int(50 * scale)
    building_top = int(60 * scale)
    building_right = int(150 * scale)
    building_bottom = int(140 * scale)
    draw.rectangle([building_left, building_top, building_right, building_bottom], fill=blue, outline=dark_blue, width=max(1, int(2*scale)))
    
    # Columns
    col_width = int(10 * scale)
    col_height = int(60 * scale)
    col_top = int(70 * scale)
    col_bottom = int(130 * scale)
    
    for x in [60, 85, 110, 135]:
        col_left = int(x * scale)
        col_right = col_left + col_width
        draw.rectangle([col_left, col_top, col_right, col_bottom], fill=white)
    
    # Roof (triangle)
    roof_points = [
        (int(100 * scale), int(40 * scale)),  # top
        (int(40 * scale), int(60 * scale)),   # left
        (int(160 * scale), int(60 * scale))   # right
    ]
    draw.polygon(roof_points, fill=dark_blue)
    
    # Base
    base_left = int(40 * scale)
    base_top = int(140 * scale)
    base_right = int(160 * scale)
    base_bottom = int(150 * scale)
    draw.rectangle([base_left, base_top, base_right, base_bottom], fill=dark_blue)
    
    # Door
    door_left = int(85 * scale)
    door_top = int(110 * scale)
    door_right = int(115 * scale)
    door_bottom = int(140 * scale)
    draw.rectangle([door_left, door_top, door_right, door_bottom], fill=dark_blue)
    
    return img

# Create different sizes
sizes = [16, 32, 192, 512]
for size in sizes:
    img = create_government_icon(size)
    if size == 16:
        img.save('/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend/web/favicon.png')
    img.save(f'/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend/web/icons/Icon-{size}.png')
    img.save(f'/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend/web/icons/Icon-maskable-{size}.png')

print("✅ Favicon and icons created successfully!")
