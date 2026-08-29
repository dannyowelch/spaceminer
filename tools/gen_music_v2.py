#!/usr/bin/env python3
"""
Reed's Music Pack V2 - Extended loops
Spacey ethereal pads, warmer starbase, energetic chase
"""
import numpy as np
import wave

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
    if d_samples > 0 and a_samples + d_samples < length:
        env[a_samples:a_samples+d_samples] = np.linspace(1, sustain, d_samples)
    if r_samples > 0:
        env[-r_samples:] = np.linspace(sustain, 0, r_samples)
    return samples * env

def gen_dustbelt_v2():
    """2:07 spacey ethereal pads for exploration"""
    duration = 127.0
    bpm = 78
    beat_len = 60.0 / bpm
    
    # Deep bass pad
    bass_notes = [55, 55, 49, 49, 52, 52, 58, 58] * 4
    bass = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(bass_notes):
        start = int(i * beat_len * 4 * SAMPLE_RATE)
        if start >= len(bass):
            break
        note = osc(freq, beat_len * 3.8, 'sine') * 0.15
        note += osc(freq * 2, beat_len * 3.8, 'sine') * 0.08
        note = envelope(note, 0.3, 0.5, 0.9, 0.8)
        end = min(start + len(note), len(bass))
        bass[start:end] += note[:end-start]
    
    # Ethereal pad chords
    pad_progression = [
        [165, 196, 220],
        [147, 175, 196],
        [131, 165, 196],
        [147, 185, 220]
    ] * 2
    pad = np.zeros(int(SAMPLE_RATE * duration))
    for i, chord in enumerate(pad_progression):
        start = int(i * beat_len * 8 * SAMPLE_RATE)
        if start >= len(pad):
            break
        chord_dur = beat_len * 7.5
        for freq in chord:
            note = osc(freq, chord_dur, 'sine') * 0.12
            note += osc(freq * 1.5, chord_dur, 'sine') * 0.06
            note = envelope(note, 0.5, 0.3, 0.85, 1.0)
            end = min(start + len(note), len(pad))
            pad[start:end] += note[:end-start]
    
    # Sparse melody
    melody_notes = [330, 0, 0, 392, 0, 440, 0, 0, 392, 0, 330, 0, 0, 294, 0, 0] * 4
    melody = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(melody_notes):
        if freq > 0:
            start = int(i * beat_len * 2 * SAMPLE_RATE)
            if start >= len(melody):
                break
            note = osc(freq, beat_len * 1.5, 'triangle') * 0.18
            note = envelope(note, 0.05, 0.2, 0.7, 0.4)
            end = min(start + len(note), len(melody))
            melody[start:end] += note[:end-start]
    
    left = bass * 0.7 + pad * 0.9 + melody * 0.6
    right = bass * 0.6 + pad * 1.0 + melody * 0.7
    stereo = np.column_stack((left, right)).flatten()
    write_wav('../audio/music/dustbelt_loop.wav', stereo, stereo=True)

def gen_starbase_v2():
    """1:45 warmer docked atmosphere"""
    duration = 105.0
    bpm = 95
    beat_len = 60.0 / bpm
    
    # Warm bass
    bass_notes = [110, 110, 123, 123, 131, 131, 110, 110] * 3
    bass = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(bass_notes):
        start = int(i * beat_len * 4 * SAMPLE_RATE)
        if start >= len(bass):
            break
        note = osc(freq, beat_len * 3.5, 'sine') * 0.2
        note = envelope(note, 0.1, 0.2, 0.8, 0.3)
        end = min(start + len(note), len(bass))
        bass[start:end] += note[:end-start]
    
    # Bell-like melody
    bell_pattern = [
        330, 0, 392, 0, 330, 0, 440, 0,
        392, 0, 330, 0, 294, 0, 0, 0,
        349, 0, 392, 0, 440, 0, 523, 0,
        440, 0, 392, 0, 349, 0, 0, 0
    ] * 2
    bells = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(bell_pattern):
        if freq > 0:
            start = int(i * beat_len * SAMPLE_RATE)
            if start >= len(bells):
                break
            note = osc(freq, beat_len * 1.2, 'sine') * 0.15
            note += osc(freq * 2, beat_len * 1.2, 'sine') * 0.08
            note = envelope(note, 0.01, 0.15, 0.6, 0.4)
            end = min(start + len(note), len(bells))
            bells[start:end] += note[:end-start]
    
    # Warm pad
    pad = np.zeros(int(SAMPLE_RATE * duration))
    pad_chords = [[220, 277], [196, 247], [220, 277], [247, 311]] * 6
    for i, chord in enumerate(pad_chords):
        start = int(i * beat_len * 4 * SAMPLE_RATE)
        if start >= len(pad):
            break
        for freq in chord:
            note = osc(freq, beat_len * 5, 'sine') * 0.13
            note = envelope(note, 0.2, 0.2, 0.9, 0.5)
            end = min(start + len(note), len(pad))
            pad[start:end] += note[:end-start]
    
    left = bass * 0.8 + bells * 0.9 + pad * 0.7
    right = bass * 0.7 + bells * 0.8 + pad * 0.8
    stereo = np.column_stack((left, right)).flatten()
    write_wav('../audio/music/starbase_loop.wav', stereo, stereo=True)

def gen_razor_v2():
    """1:38 energetic chase with varied riff"""
    duration = 98.0
    bpm = 145
    beat_len = 60.0 / bpm
    
    # Driving bass riff
    bass_riff = [
        98, 98, 0, 98, 92, 92, 0, 92,
        87, 87, 0, 87, 82, 82, 0, 82,
        98, 98, 0, 98, 110, 110, 0, 92,
        87, 87, 0, 87, 98, 98, 0, 98
    ] * 3
    bass = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(bass_riff):
        if freq > 0:
            start = int(i * beat_len * 0.5 * SAMPLE_RATE)
            if start >= len(bass):
                break
            note = osc(freq, beat_len * 0.4, 'square') * 0.25
            note = envelope(note, 0.005, 0.05, 0.8, 0.05)
            end = min(start + len(note), len(bass))
            bass[start:end] += note[:end-start]
    
    # Urgent pulse
    pulse = np.zeros(int(SAMPLE_RATE * duration))
    num_pulses = int(duration / (beat_len * 0.25))
    for i in range(num_pulses):
        start = int(i * beat_len * 0.25 * SAMPLE_RATE)
        if start >= len(pulse):
            break
        freq = 1760 if i % 8 < 4 else 2093
        hit = osc(freq, 0.05, 'sine') * 0.12
        hit = envelope(hit, 0.001, 0.01, 0.5, 0.02)
        end = min(start + len(hit), len(pulse))
        pulse[start:end] += hit[:end-start]
    
    # Lead riff
    lead_notes = [
        0, 0, 392, 440, 0, 523, 0, 440,
        392, 0, 349, 0, 330, 0, 0, 0
    ] * 6
    lead = np.zeros(int(SAMPLE_RATE * duration))
    for i, freq in enumerate(lead_notes):
        if freq > 0:
            start = int(i * beat_len * SAMPLE_RATE)
            if start >= len(lead):
                break
            note = osc(freq, beat_len * 0.8, 'triangle') * 0.2
            note = envelope(note, 0.01, 0.1, 0.7, 0.15)
            end = min(start + len(note), len(lead))
            lead[start:end] += note[:end-start]
    
    left = bass * 0.8 + pulse * 0.9 + lead * 0.7
    right = bass * 0.7 + pulse * 0.8 + lead * 0.8
    stereo = np.column_stack((left, right)).flatten()
    write_wav('../audio/music/razor_loop.wav', stereo, stereo=True)

print("Generating Reed's Music V2 (extended loops)...")
print("\nDust Belt: 2:07 spacey ethereal...")
gen_dustbelt_v2()
print("\nStarbase: 1:45 warmer docked...")
gen_starbase_v2()
print("\nRazor Reach: 1:38 energetic chase...")
gen_razor_v2()
print("\n=== Music V2 complete! ===")
