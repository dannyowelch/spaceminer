#!/usr/bin/env python3
"""
Reed's Audio Pack Generator
1992 PC / AdLib-SB16 / SC2 Super Melee feel
Numpy synthesis, seed 1992, 22050 Hz
"""
import numpy as np
import wave
import struct

SAMPLE_RATE = 22050
SEED = 1992
np.random.seed(SEED)

def write_wav(filename, samples, stereo=False):
    samples = np.clip(samples, -1.0, 1.0)
    samples_int = (samples * 32767).astype(np.int16)
    
    with wave.open(filename, 'w') as wav:
        nchannels = 2 if stereo else 1
        wav.setnchannels(nchannels)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(samples_int.tobytes())
    print(f"Generated: {filename}")

def osc(freq, duration, wave_type='sine'):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    if wave_type == 'sine':
        return np.sin(2 * np.pi * freq * t)
    elif wave_type == 'square':
        return np.sign(np.sin(2 * np.pi * freq * t))
    elif wave_type == 'saw':
        return 2 * (t * freq - np.floor(t * freq + 0.5))
    elif wave_type == 'triangle':
        return 2 * np.abs(2 * (t * freq - np.floor(t * freq + 0.5))) - 1
    return np.sin(2 * np.pi * freq * t)

def envelope(samples, attack=0.01, decay=0.05, sustain=0.7, release=0.1):
    length = len(samples)
    env = np.ones(length)
    
    a_samples = int(attack * SAMPLE_RATE)
    d_samples = int(decay * SAMPLE_RATE)
    r_samples = int(release * SAMPLE_RATE)
    
    if a_samples > 0:
        env[:a_samples] = np.linspace(0, 1, a_samples)
    if d_samples > 0:
        env[a_samples:a_samples+d_samples] = np.linspace(1, sustain, d_samples)
    if r_samples > 0:
        env[-r_samples:] = np.linspace(sustain, 0, r_samples)
    
    return samples * env

def noise(duration):
    return np.random.uniform(-1, 1, int(SAMPLE_RATE * duration))

# SFX Generation
def gen_thrust_loop():
    duration = 0.5
    base = osc(120, duration, 'square') * 0.3
    rumble = noise(duration) * 0.15
    mod = osc(8, duration, 'sine') * 0.2
    signal = (base + rumble) * (1 + mod)
    signal = envelope(signal, 0.01, 0.05, 0.9, 0.01)
    write_wav('../audio/sfx/thrust_loop.wav', signal)

def gen_mine():
    duration = 0.12
    carrier = osc(1200, duration, 'square') * 0.4
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    sweep_freq = np.linspace(1200, 800, len(t))
    sweep = np.sin(2 * np.pi * sweep_freq * t) * 0.3
    crunch = noise(duration) * 0.2
    signal = carrier + sweep + crunch
    signal = envelope(signal, 0.001, 0.02, 0.6, 0.05)
    write_wav('../audio/sfx/mine.wav', signal)

def gen_fire():
    duration = 0.15
    hit = osc(440, duration, 'square') * 0.5
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    sweep_freq = np.linspace(800, 200, len(t))
    chirp = np.sin(2 * np.pi * sweep_freq * t) * 0.3
    signal = hit + chirp
    signal = envelope(signal, 0.001, 0.03, 0.4, 0.08)
    write_wav('../audio/sfx/fire.wav', signal)

def gen_ore_pickup():
    duration = 0.2
    notes = [523, 659, 784]
    signal = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(notes):
        start = int(i * 0.06 * SAMPLE_RATE)
        note_dur = 0.08
        note = osc(freq, note_dur, 'sine') * 0.3
        note = envelope(note, 0.005, 0.02, 0.7, 0.03)
        end = min(start + len(note), len(signal))
        signal[start:end] += note[:end-start]
    write_wav('../audio/sfx/ore_pickup.wav', signal)

def gen_hull_hit():
    duration = 0.25
    impact = osc(80, duration, 'square') * 0.6
    clang = noise(duration) * 0.4
    signal = impact + clang
    signal = envelope(signal, 0.001, 0.05, 0.3, 0.15)
    write_wav('../audio/sfx/hull_hit.wav', signal)

def gen_asteroid_break():
    duration = 0.3
    crack = noise(duration) * 0.5
    rumble = osc(60, duration, 'sine') * 0.4
    signal = crack + rumble
    signal = envelope(signal, 0.001, 0.1, 0.3, 0.15)
    write_wav('../audio/sfx/asteroid_break.wav', signal)

def gen_explosion():
    duration = 1.0
    boom = noise(duration) * 0.7
    bass = osc(40, duration, 'sine') * 0.5
    signal = boom + bass
    signal = envelope(signal, 0.001, 0.2, 0.2, 0.6)
    write_wav('../audio/sfx/explosion.wav', signal)

def gen_pirate_sting():
    duration = 1.5
    notes = [110, 104, 98, 92]
    signal = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(notes):
        start = int(i * 0.35 * SAMPLE_RATE)
        note_dur = 0.4
        note = osc(freq, note_dur, 'square') * 0.5
        note += osc(freq * 1.5, note_dur, 'sine') * 0.2
        note = envelope(note, 0.01, 0.1, 0.7, 0.2)
        end = min(start + len(note), len(signal))
        signal[start:end] += note[:end-start]
    write_wav('../audio/sfx/pirate_sting.wav', signal)

def gen_dock():
    duration = 0.4
    notes = [330, 392, 523]
    signal = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(notes):
        start = int(i * 0.1 * SAMPLE_RATE)
        note_dur = 0.15
        note = osc(freq, note_dur, 'triangle') * 0.4
        note = envelope(note, 0.01, 0.03, 0.8, 0.05)
        end = min(start + len(note), len(signal))
        signal[start:end] += note[:end-start]
    write_wav('../audio/sfx/dock.wav', signal)

def gen_sell():
    duration = 0.3
    notes = [659, 784, 880, 1047]
    signal = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(notes):
        start = int(i * 0.06 * SAMPLE_RATE)
        note_dur = 0.1
        note = osc(freq, note_dur, 'sine') * 0.3
        note = envelope(note, 0.005, 0.02, 0.7, 0.04)
        end = min(start + len(note), len(signal))
        signal[start:end] += note[:end-start]
    write_wav('../audio/sfx/sell.wav', signal)

def gen_ui_ok():
    duration = 0.15
    signal = osc(880, duration, 'sine') * 0.4
    signal = envelope(signal, 0.01, 0.03, 0.8, 0.06)
    write_wav('../audio/sfx/ui_ok.wav', signal)

def gen_ui_deny():
    duration = 0.2
    signal = osc(220, duration, 'square') * 0.5
    signal = envelope(signal, 0.01, 0.05, 0.6, 0.1)
    write_wav('../audio/sfx/ui_deny.wav', signal)

# Music Generation
def gen_dustbelt_loop():
    duration = 8.0
    bpm = 110
    beat_len = 60.0 / bpm
    
    # Bass line
    bass_notes = [110, 110, 98, 98, 104, 104, 110, 110]
    bass = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(bass_notes):
        start = int(i * beat_len * SAMPLE_RATE)
        note = osc(freq, beat_len * 0.8, 'square') * 0.3
        note = envelope(note, 0.01, 0.1, 0.7, 0.1)
        end = min(start + len(note), len(bass))
        bass[start:end] += note[:end-start]
    
    # Melody
    melody_notes = [330, 0, 392, 0, 330, 294, 0, 330, 0, 392, 440, 0, 392, 330, 0, 294]
    melody = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(melody_notes):
        if freq > 0:
            start = int(i * beat_len * 0.5 * SAMPLE_RATE)
            note = osc(freq, beat_len * 0.4, 'triangle') * 0.25
            note = envelope(note, 0.01, 0.05, 0.8, 0.05)
            end = min(start + len(note), len(melody))
            melody[start:end] += note[:end-start]
    
    # Stereo mix
    left = bass * 0.6 + melody * 0.8
    right = bass * 0.5 + melody * 0.9
    stereo = np.column_stack((left, right)).flatten()
    write_wav('../audio/music/dustbelt_loop.wav', stereo, stereo=True)

def gen_razor_loop():
    duration = 6.0
    bpm = 140
    beat_len = 60.0 / bpm
    
    # Fast driving bass
    bass_notes = [98, 98, 92, 92, 87, 87, 82, 82, 98, 98, 92, 92]
    bass = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(bass_notes):
        start = int(i * beat_len * 0.5 * SAMPLE_RATE)
        note = osc(freq, beat_len * 0.4, 'square') * 0.35
        note = envelope(note, 0.005, 0.05, 0.8, 0.05)
        end = min(start + len(note), len(bass))
        bass[start:end] += note[:end-start]
    
    # Urgent pulse
    pulse = np.zeros(int(SAMPLE_RATE * duration))
    for i in range(int(duration / (beat_len * 0.25))):
        start = int(i * beat_len * 0.25 * SAMPLE_RATE)
        hit = osc(1760, 0.05, 'sine') * 0.15
        hit = envelope(hit, 0.001, 0.01, 0.5, 0.02)
        end = min(start + len(hit), len(pulse))
        pulse[start:end] += hit[:end-start]
    
    left = bass * 0.7 + pulse * 0.9
    right = bass * 0.6 + pulse * 0.8
    stereo = np.column_stack((left, right)).flatten()
    write_wav('../audio/music/razor_loop.wav', stereo, stereo=True)

def gen_starbase_loop():
    duration = 10.0
    bpm = 90
    beat_len = 60.0 / bpm
    
    # Calm pad
    pad_notes = [220, 220, 220, 220, 247, 247, 247, 247, 262, 262, 220, 220]
    pad = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(pad_notes):
        start = int(i * beat_len * 0.8 * SAMPLE_RATE)
        note = osc(freq, beat_len * 0.9, 'sine') * 0.2
        note += osc(freq * 1.5, beat_len * 0.9, 'sine') * 0.1
        note = envelope(note, 0.1, 0.1, 0.8, 0.2)
        end = min(start + len(note), len(pad))
        pad[start:end] += note[:end-start]
    
    # Bell melody
    bell_notes = [0, 523, 0, 659, 0, 523, 0, 440, 0, 523, 0, 587, 0, 659, 0, 523]
    bells = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(bell_notes):
        if freq > 0:
            start = int(i * beat_len * 0.5 * SAMPLE_RATE)
            note = osc(freq, beat_len * 0.6, 'sine') * 0.2
            note += osc(freq * 2, beat_len * 0.6, 'sine') * 0.1
            note = envelope(note, 0.01, 0.1, 0.6, 0.3)
            end = min(start + len(note), len(bells))
            bells[start:end] += note[:end-start]
    
    left = pad * 0.8 + bells * 0.7
    right = pad * 0.7 + bells * 0.8
    stereo = np.column_stack((left, right)).flatten()
    write_wav('../audio/music/starbase_loop.wav', stereo, stereo=True)

if __name__ == '__main__':
    print("Generating Reed's Audio Pack (seed 1992, 22050 Hz)")
    print("\n=== SFX ===")
    gen_thrust_loop()
    gen_mine()
    gen_fire()
    gen_ore_pickup()
    gen_hull_hit()
    gen_asteroid_break()
    gen_explosion()
    gen_pirate_sting()
    gen_dock()
    gen_sell()
    gen_ui_ok()
    gen_ui_deny()
    
    print("\n=== Music ===")
    gen_dustbelt_loop()
    gen_razor_loop()
    gen_starbase_loop()
    
    print("\n=== Audio pack complete! ===")
