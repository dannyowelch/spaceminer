# Spaceminer

Personal indie game. Godot 4. Top-down arcade space miner.

## How to Run

Requires Godot 4.x (tested with 4.3):
1. Open the project in Godot Editor
2. Press F5 to run

Or run from command line:
```bash
godot --path . --headless
```

## Gameplay Loop

**Vertical Slice - Mine, Sell, Fight**

1. **Dust Belt**: Fly around and mine asteroids (SPACE to mine). Fill your cargo with ore.
2. **Dock**: Approach starbase and press E to dock. Sell ore for credits, buy upgrades.
3. **Razor Reach**: Fight or flee from a pirate encounter. Run far enough to escape.

## Controls

- **A/D or Arrow Keys**: Rotate ship
- **W or Up Arrow**: Thrust
- **SPACE**: Mine asteroids (Dust Belt) / Fire weapon (Razor Reach, if equipped)
- **E**: Dock at starbase (when close)

## Game Systems

- **Hull Integrity**: 10 pips. Reach 0 and you restart.
- **Cargo Grid**: 12 slots. Ore comes in three rarities (common/uncommon/rare).
- **Credits**: Sell ore for credits. Spend on upgrades.
- **Upgrades**: Mining beam, cargo expansion, weapon system.

## Technical

- Engine: Godot 4.3 (GDScript)
- Resolution: 1280x720 (16:9 window)
- Playfield: 4:3 center area (720px wide)
- Art: Original VGA-palette placeholders
