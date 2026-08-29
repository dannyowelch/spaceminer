# Spaceminer Audio Integration - Reed's Pack

**Generated**: 2026-08-28  
**Method**: Numpy synthesis, seed 1992, 22050 Hz  
**Style**: 1992 PC / AdLib-SB16 / SC2 Super Melee feel

## Audio Files Generated

### SFX (res://audio/sfx/) - Mono WAV
1. `thrust_loop.wav` - Engine loop (plays while W held)
2. `mine.wav` - Mining beam activation (retriggerable ~8 Hz)
3. `fire.wav` - Weapon shot
4. `ore_pickup.wav` - Ore enters cargo slot
5. `hull_hit.wav` - Hull pip lost
6. `asteroid_break.wav` - Asteroid destroyed
7. `explosion.wav` - Pirate ship destroyed
8. `pirate_sting.wav` - Chase begins (1.5s, triggers music duck)
9. `dock.wav` - Docking success
10. `sell.wav` - Ore sold
11. `ui_ok.wav` - Upgrade purchased
12. `ui_deny.wav` - Not enough credits / cargo full

### Music (res://audio/music/) - Stereo WAV loops
1. `dustbelt_loop.wav` (8s, 110 BPM) - Dust Belt exploration
2. `razor_loop.wav` (6s, 140 BPM) - Razor Reach combat
3. `starbase_loop.wav` (10s, 90 BPM) - Docked at starbase

## Audio System Architecture

**Buses**: 
- Master
- Music (child of Master)
- SFX (child of Master)

**Audio Manager** (`audio_manager.gd`):
- Dual AudioStreamPlayer setup for crossfading
- Crossfade time: 0.4 seconds
- Music ducking: -3 dB when pirate sting plays
- All SFX pre-loaded in scene tree

## Mode-Specific Audio

### Dust Belt Mode
**Music**: `dustbelt_loop.wav`
**SFX Triggered**:
- `thrust_loop.wav` - while W key held
- `mine.wav` - when SPACE held near asteroid
- `ore_pickup.wav` - when ore enters cargo
- `asteroid_break.wav` - when asteroid depleted
- `dock.wav` - when pressing E near starbase (transitions to Dock)

### Dock Mode (Starbase)
**Music**: `starbase_loop.wav` (crossfade 0.4s from Dust Belt)
**SFX Triggered**:
- `dock.wav` - on entry
- `sell.wav` - when selling ore
- `ui_ok.wav` - when upgrade purchased
- `ui_deny.wav` - when insufficient credits
- Continues to Razor Reach on button press

### Razor Reach Mode
**Music**: `razor_loop.wav` (crossfade 0.4s from Dock)
**SFX Triggered**:
- `pirate_sting.wav` - on mode entry (ducks music for 1.5s)
- `thrust_loop.wav` - while W key held
- `fire.wav` - when SPACE pressed (if weapon equipped)
- `hull_hit.wav` - when player takes damage
- `explosion.wav` - when pirate destroyed
- Returns to Dust Belt on victory/escape

## Technical Details

**Synthesis Method**:
- All sounds generated with numpy waveform synthesis
- Square waves for engines and bass
- Sine waves for melody and bells
- Triangle waves for pads
- Noise for impact/explosion effects
- ADSR envelopes on all notes

**Implementation**:
- AudioStreamPlayer for music (dual for crossfade)
- AudioStreamPlayer for SFX (one per effect)
- Music loop enabled via Godot import settings (loop_mode=2)
- SFX one-shots (loop_mode=0)
- Thrust loop exception: loop_mode=2, controlled by start/stop

## Verification

✅ All 15 audio files generated and imported  
✅ Audio manager integrated into main scene  
✅ Music crossfades between modes (0.4s)  
✅ Music ducks on pirate sting (-3 dB, 1.5s)  
✅ SFX trigger at correct gameplay moments  
✅ Thrust loop starts/stops with input  
✅ All automated tests pass with audio  
✅ No audio system errors in headless mode

## Original PC Audio Character

The synthesis recreates 1992-era PC game audio:
- Square/triangle/saw waves (AdLib FM synthesis style)
- Low sample rate feel (22050 Hz)
- Simple ADSR envelopes
- Chiptune melodic patterns
- No reverb or modern effects
- Authentic retro arcade feel

All sounds are original compositions generated from code - no SC2 samples copied.
