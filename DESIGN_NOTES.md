# Spaceminer Design Notes

## Control Scheme

**No Cursor / No Reticle**
- Aim with the ship's nose (rotation controls facing)
- No mouse aiming, no crosshair, no targeting reticle
- Tap A/D to rotate, hold W to thrust (Star Control 2 style)

## Combat & Mining

**Weapon Fire**
- Bullets spawn from ship position
- Direction: along ship's rotation/facing (`rotation - PI/2`)
- Velocity: ship's facing direction * 500 + ship's velocity (inherits momentum)
- Player fires with SPACE when `has_weapon` is true

**Mining Beam**
- Proximity-based: checks distance between ship and asteroids
- Range: 120 units
- Activated with SPACE (hold to mine)
- No targeting reticle - if you're close enough and facing doesn't matter, you mine it

## Visual Design

**HUD**
- 1280x720 window, 4:3 playfield center (960x720), HUD panels left/right
- Metallic overlay from Sable's pack (ui/hud_overlay.png)
- Live hull pips, cargo icons, credits, sector name drawn on top
- No debug chrome, no crosshair

**Playfield**
- Camera follows player ship
- Starfield background scrolls
- Planet visible in Dust Belt
- All sprites from Sable's pack (no _draw placeholders)
