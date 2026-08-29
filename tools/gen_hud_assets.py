#!/usr/bin/env python3
"""
Generate HUD assets for Spaceminer VGA look
Based on Sable's reference images
"""
from PIL import Image, ImageDraw
import math

def create_hud_overlay():
    """1280x720 overlay with transparent 4:3 center hole (960x720)"""
    img = Image.new('RGBA', (1280, 720), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    panel_color = (40, 45, 60, 255)
    frame_color = (80, 85, 100, 255)
    light_color = (120, 130, 150, 255)
    
    draw.rectangle([0, 0, 160, 720], fill=panel_color)
    draw.rectangle([1120, 0, 1280, 720], fill=panel_color)
    
    draw.rectangle([155, 0, 160, 720], fill=frame_color)
    draw.rectangle([1120, 0, 1125, 720], fill=frame_color)
    
    for i in range(0, 720, 40):
        draw.rectangle([157, i, 158, i+20], fill=light_color)
        draw.rectangle([1122, i, 1123, i+20], fill=light_color)
    
    for y in [10, 60, 230, 400]:
        draw.rectangle([10, y, 150, y+2], fill=frame_color)
    
    for y in [10, 60, 230, 400, 520]:
        draw.rectangle([1130, y, 1270, y+2], fill=frame_color)
    
    return img

def create_starfield():
    """960x720 starfield for playfield background"""
    img = Image.new('RGB', (960, 720), (0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    import random
    random.seed(1992)
    
    for _ in range(80):
        x = random.randint(0, 959)
        y = random.randint(0, 719)
        color_choice = random.choice([
            (255, 255, 255),
            (200, 220, 255),
            (255, 200, 220),
            (220, 255, 200)
        ])
        draw.point((x, y), fill=color_choice)
    
    return img

def create_planet():
    """256x256 orange planet"""
    img = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = 128
    radius = 120
    
    base_color = (200, 120, 60, 255)
    dark_color = (120, 70, 30, 255)
    light_color = (240, 160, 90, 255)
    
    draw.ellipse([center-radius, center-radius, center+radius, center+radius], 
                 fill=base_color)
    
    draw.ellipse([center-80, center-80, center+80, center+80], 
                 outline=dark_color, width=15)
    
    for i in range(5):
        crater_x = center + int(math.cos(i * 1.3) * 60)
        crater_y = center + int(math.sin(i * 1.3) * 60)
        crater_size = 20 + i * 5
        draw.ellipse([crater_x-crater_size, crater_y-crater_size,
                     crater_x+crater_size, crater_y+crater_size],
                    outline=dark_color, width=3)
    
    for x in range(0, 256, 4):
        for y in range(0, 256):
            dist = math.sqrt((x - center)**2 + (y - center)**2)
            if dist < radius and dist > radius - 10:
                alpha = int(255 * (1 - (radius - dist) / 10))
                pixel = img.getpixel((x, y))
                if pixel[3] > 0:
                    img.putpixel((x, y), (pixel[0]//2, pixel[1]//2, pixel[2]//2, alpha))
    
    return img

def create_ship_128():
    """128x128 cyan miner ship"""
    img = Image.new('RGBA', (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cyan = (77, 220, 220, 255)
    dark_cyan = (40, 160, 160, 255)
    light_cyan = (150, 255, 255, 255)
    gray = (100, 110, 120, 255)
    
    cx, cy = 64, 64
    
    body = [(cx, cy-40), (cx-25, cy), (cx-25, cy+30), (cx, cy+45), 
            (cx+25, cy+30), (cx+25, cy), (cx, cy-40)]
    draw.polygon(body, fill=cyan, outline=dark_cyan, width=2)
    
    draw.rectangle([cx-30, cy+25, cx-25, cy+50], fill=gray, outline=dark_cyan)
    draw.rectangle([cx+25, cy+25, cx+30, cy+50], fill=gray, outline=dark_cyan)
    
    draw.ellipse([cx-12, cy-20, cx+12, cy-5], fill=light_cyan)
    
    draw.rectangle([cx-8, cy+45, cx-4, cy+52], fill=(255, 120, 50, 255))
    draw.rectangle([cx+4, cy+45, cx+8, cy+52], fill=(255, 120, 50, 255))
    
    return img

def create_pirate_160():
    """160x160 orange pirate cutter"""
    img = Image.new('RGBA', (160, 160), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    orange = (200, 100, 50, 255)
    dark_orange = (140, 60, 30, 255)
    red = (220, 60, 40, 255)
    
    cx, cy = 80, 80
    
    body = [(cx, cy-50), (cx-20, cy-10), (cx-30, cy+20), (cx, cy+50),
            (cx+30, cy+20), (cx+20, cy-10)]
    draw.polygon(body, fill=orange, outline=dark_orange, width=2)
    
    wing_left = [(cx-30, cy-10), (cx-55, cy+10), (cx-45, cy+30), (cx-30, cy+20)]
    draw.polygon(wing_left, fill=dark_orange, outline=red)
    
    wing_right = [(cx+30, cy-10), (cx+55, cy+10), (cx+45, cy+30), (cx+30, cy+20)]
    draw.polygon(wing_right, fill=dark_orange, outline=red)
    
    draw.polygon([(cx-8, cy-30), (cx, cy-50), (cx+8, cy-30)], fill=red)
    
    return img

def create_starbase_256():
    """256x256 orbital starbase"""
    img = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    gray = (120, 120, 130, 255)
    dark_gray = (70, 70, 80, 255)
    light_gray = (170, 170, 180, 255)
    cyan = (100, 180, 200, 255)
    
    cx, cy = 128, 128
    
    draw.ellipse([cx-70, cy-70, cx+70, cy+70], fill=gray, outline=dark_gray, width=3)
    draw.ellipse([cx-50, cy-50, cx+50, cy+50], fill=dark_gray)
    draw.ellipse([cx-30, cy-30, cx+30, cy+30], fill=gray)
    
    draw.ellipse([cx-90, cy-90, cx+90, cy+90], outline=light_gray, width=4)
    draw.ellipse([cx-110, cy-110, cx+110, cy+110], outline=dark_gray, width=2)
    
    for angle in [0, 90, 180, 270]:
        rad = math.radians(angle)
        x1 = cx + int(40 * math.cos(rad))
        y1 = cy + int(40 * math.sin(rad))
        x2 = cx + int(95 * math.cos(rad))
        y2 = cy + int(95 * math.sin(rad))
        draw.line([(x1, y1), (x2, y2)], fill=light_gray, width=6)
        draw.ellipse([x2-8, y2-8, x2+8, y2+8], fill=cyan, outline=light_gray)
    
    return img

def create_asteroid_96(rarity):
    """96x96 asteroid"""
    img = Image.new('RGBA', (96, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    colors = {
        'common': (140, 140, 140, 255),
        'uncommon': (160, 120, 80, 255),
        'rare': (80, 180, 160, 255)
    }
    base_color = colors[rarity]
    dark = tuple(max(0, c - 50) if i < 3 else c for i, c in enumerate(base_color))
    
    cx, cy = 48, 48
    size = 40
    
    points = []
    for i in range(8):
        angle = i * math.pi / 4 + 0.2
        r = size + ((-1) ** i) * (size * 0.2)
        x = cx + int(r * math.cos(angle))
        y = cy + int(r * math.sin(angle))
        points.append((x, y))
    
    draw.polygon(points, fill=base_color, outline=dark, width=2)
    
    for i in range(4):
        crater_x = cx + int(math.cos(i * 1.5) * 15)
        crater_y = cy + int(math.sin(i * 1.5) * 15)
        draw.ellipse([crater_x-5, crater_y-5, crater_x+5, crater_y+5], 
                    outline=dark, width=2)
    
    return img

print("Generating HUD assets...")
create_hud_overlay().save('/workspace/ui/hud_overlay.png')
print("Created hud_overlay.png")

create_starfield().save('/workspace/ui/starfield.png')
print("Created starfield.png")

create_planet().save('/workspace/sprites/planet_256.png')
print("Created planet_256.png")

create_ship_128().save('/workspace/sprites/ship.png')
print("Created ship.png (128x128)")

create_pirate_160().save('/workspace/sprites/pirate.png')
print("Created pirate.png (160x160)")

create_starbase_256().save('/workspace/sprites/starbase.png')
print("Created starbase.png (256x256)")

create_asteroid_96('common').save('/workspace/sprites/asteroid_common.png')
create_asteroid_96('uncommon').save('/workspace/sprites/asteroid_uncommon.png')
create_asteroid_96('rare').save('/workspace/sprites/asteroid_rare.png')
print("Created asteroid sprites (96x96)")

print("\n=== All HUD assets generated! ===")
