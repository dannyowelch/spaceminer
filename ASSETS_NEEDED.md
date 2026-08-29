# Assets Needed from Sable

The following actual texture files are needed to replace PIL-generated placeholders:

## UI Assets
- `ui/hud_overlay.png` - Metallic HUD with wings, screws, ship portrait, HULL/FUEL/CREDITS/CARGO/SECTOR/DATE labels, transparent 4:3 center hole (1280x720)
- `ui/starfield.png` - Black background with colored pixel stars

## Sprite Assets  
- `sprites/planet_256.png` - 256x256 planet for Dust Belt
- `sprites/ship.png` - 128x128 player miner ship (nose UP)
- `sprites/starbase.png` - 256x256 starbase station

## Current Status
- Fake PIL composite screenshot deleted ✓
- Cargo grid verified as 3x4 (12 slots) ✓  
- Clip + scroll implemented ✓
- Music V2 (longer loops) integrated ✓

## To Integrate
Once the actual PNG files are available (pushed to repo or accessible on VM), they can be quickly integrated by:
1. Copying to correct paths (ui/ and sprites/ directories)
2. Deleting corresponding .import files
3. Running `godot --headless --import` to regenerate imports
4. Committing the new assets

The game structure is ready for the real assets.
