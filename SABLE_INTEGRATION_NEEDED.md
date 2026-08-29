# Sable Real Texture Pack Integration

## Issue
The attached PNG files from Sable's pack were not accessible on the cloud agent VM filesystem. Paths listed by the system (`/workspace/sable-real/`) don't exist when checked.

## Required Files (Push to Repo)

Push these 6 files directly to the repository at:

```
/workspace/sprites/hud_overlay.png  - 1280x720 metallic HUD, transparent 4:3 hole
/workspace/sprites/starfield.png    - Black background with colored pixel stars
/workspace/sprites/planet.png       - 256px orange Dust Belt globe
/workspace/sprites/ship.png         - 128px miner, nose UP
/workspace/sprites/starbase.png     - 256px station
/workspace/sprites/pirate.png       - 160px hooked cutter, nose UP
```

## Code Changes Needed (Once Files Are Pushed)

1. **Update vga_hud.tscn**: Change `res://ui/hud_overlay.png` → `res://sprites/hud_overlay.png`
2. **Update main.tscn**: Change `res://ui/starfield.png` → `res://sprites/starfield.png`
3. **Delete import files** for old ui/ paths
4. **Reimport**: `rm -rf .godot && godot --headless --import`

## Alternative: Base64 Pack
If you have the files as `tools/sable_pack/pack.*.b64`:
```bash
cat tools/sable_pack/pack.*.b64 | base64 -d > /tmp/sable_pack.tar
tar xf /tmp/sable_pack.tar -C /tmp/sable
cp /tmp/sable/*.png /workspace/sprites/
```

Once files are on the VM filesystem, integration can proceed immediately.
