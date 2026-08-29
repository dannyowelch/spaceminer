# 1080p Spec Verification

## Commit SHA
`0ae2d2b10ea32dba2465185e5ed8989c909fb495`

## Window & Viewport
- ✅ Window: 1920x1080 (project.godot lines 20-21)
- ✅ Title: "Spaceminer" (project.godot line 7)

## Playfield
- ✅ Playfield clip: x=280, y=40, w=1320, h=1000 (main.tscn lines 17-20)
- ✅ SubViewport size: 1320x1000 (main.tscn line 25)
- ✅ World draws only in the clipped area

## HUD Layout
- ✅ Left HUD: (0,0,280,1080) with signed ColorRect chrome (hud_1080.tscn)
- ✅ Radar: (20,800,240,240) with green border (hud_1080.tscn lines 34-65)
- ✅ Right HUD: (1600,0,320,1080) with signed ColorRect chrome (hud_1080.tscn)
- ✅ Cargo list: (1620,108,280,756) - 12 rows, sorted by quantity descending (hud_1080.gd lines 68-103)

## World & Physics
- ✅ Sector: 4x4 screens = 5280x4000 world (main.gd lines 23-24)
- ✅ Torus wrap: leaving an edge appears on opposite edge (ship.gd lines 50-59)
- ✅ No invisible walls - full wrap implemented

## Asteroids
- ✅ 4-6 clumps spread across sector (main.gd line 112)
- ✅ Not spawned at player start position (main.gd lines 121-123)
- ✅ Each clump has 8 asteroids with random offset (main.gd lines 115-131)

## Scanner & Radar
- ✅ Range: 900 (main.gd line 25, hud_1080.gd line 105)
- ✅ Complexity: 1 (shows stations, planets, large asteroids)
- ✅ Radar dots: stations/planets (cyan), asteroids (green), enemies (red)
- ✅ Player dot: yellow at center (hud_1080.gd lines 137-141)

## Galactic Map
- ✅ Key: M (project.godot lines 62-66, hud_1080.gd lines 31-32)
- ✅ Two nodes: Dust Belt (blue) and Razor Reach (red) (hud_1080.tscn lines 170-206)
- ✅ Jump cost: 2 fuel pips (hud_1080.gd lines 49, 55)
- ✅ Click system to jump

## Cargo Display
- ✅ Not a 12-slot grid - now a sorted list (retired vga_hud.gd grid)
- ✅ 12 rows maximum (hud_1080.gd line 81)
- ✅ Each row: icon + name + qty (hud_1080.gd lines 85-103)
- ✅ Sorted by quantity descending (hud_1080.gd line 77)

## Sprites & Assets
- ✅ All sprites kept: ship, asteroids, planet, starbase, pirate, starfield
- ✅ Runtime Image.load + nearest filter (all .gd files use Image.load_from_file)
- ✅ No PNG bytes replaced - same sprite files referenced
- ✅ Yellow scoop beam kept (ship.gd lines 70-74)
- ✅ Nose-aim controls kept (ship.gd lines 28-31)
- ✅ Hold SPACE to mine (project.godot lines 46-50)

## Testing Instructions
1. Open project in Godot 4.3
2. Press F5 to run
3. Verify all HUD elements are visible and positioned correctly
4. Test movement and verify torus wrap at world edges
5. Fly around to find asteroid clumps (4-6 total)
6. Mine asteroids and verify cargo list updates with sorted quantities
7. Press M to open galactic map
8. Click Razor Reach to jump (costs 2 fuel)
9. Verify radar shows nearby objects within 900 units

## Notes
- Used signed ColorRect/Label chrome (no final overlay art)
- All spec-locked numbers implemented exactly
- Playfield borders shown with yellow ColorRect lines
- Ready for F5 testing in Godot editor
