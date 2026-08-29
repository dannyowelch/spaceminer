#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont

# Load assets
try:
    overlay = Image.open('/workspace/ui/hud_overlay.png')
    starfield = Image.open('/workspace/ui/starfield.png')
    planet = Image.open('/workspace/sprites/planet_256.png')
    ship = Image.open('/workspace/sprites/ship.png')
    starbase = Image.open('/workspace/sprites/starbase.png')
    asteroid = Image.open('/workspace/sprites/asteroid_common.png')
except:
    print("Some assets not found, using placeholders")

# Create composite screenshot
screenshot = Image.new('RGB', (1280, 720), (0, 0, 0))

# Place starfield in playfield area
screenshot.paste(starfield, (160, 0))

# Add planet at left edge of playfield
if planet.mode == 'RGBA':
    screenshot.paste(planet, (160 + 20, 360 - 128), planet)
else:
    screenshot.paste(planet, (160 + 20, 360 - 128))

# Add ship in center
if ship.mode == 'RGBA':
    screenshot.paste(ship, (640 - 64, 360 - 64), ship)
else:
    screenshot.paste(ship, (640 - 64, 360 - 64))

# Add starbase above
if starbase.mode == 'RGBA':
    screenshot.paste(starbase, (640 - 128, 180 - 128), starbase)
else:
    screenshot.paste(starbase, (640 - 128, 180 - 128))

# Add a couple asteroids
if asteroid.mode == 'RGBA':
    screenshot.paste(asteroid, (400, 250), asteroid)
    screenshot.paste(asteroid, (850, 450), asteroid)
else:
    screenshot.paste(asteroid, (400, 250))
    screenshot.paste(asteroid, (850, 450))

# Overlay the HUD frame on top
if overlay.mode == 'RGBA':
    screenshot.paste(overlay, (0, 0), overlay)
else:
    screenshot.paste(overlay, (0, 0))

# Add HUD elements
draw = ImageDraw.Draw(screenshot)

# Hull pips (green)
for i in range(10):
    x = 25 + (i * 12)
    y = 290
    draw.rectangle([x, y, x+10, y+10], fill=(0, 255, 0))

# Credits
draw.text((1145, 25), "0000000", fill=(255, 230, 77))

# Sector name
draw.text((1145, 445), "DUST BELT", fill=(77, 230, 230))

# Cargo slots (empty boxes outline)
for row in range(4):
    for col in range(3):
        x = 1135 + (col * 45)
        y = 120 + (row * 45)
        draw.rectangle([x, y, x+40, y+40], outline=(100, 110, 120), width=2)

screenshot.save('/workspace/spaceminer_screenshot.png')
print("Screenshot created: spaceminer_screenshot.png")
