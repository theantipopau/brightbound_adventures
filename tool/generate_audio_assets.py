"""Generate BrightBound audio assets procedurally (v2.1 task A4).

All audio is 100% original — synthesised sine/pulse/noise compositions
written by this script — so there is no third-party licence to track.

Outputs (16-bit, mono):
  assets/sounds/sfx/correct/correct1..3.wav   upbeat chime rides (<1 s)
  assets/sounds/sfx/incorrect/wrong1..2.wav   soft thud / gentle wobble
  assets/sounds/sfx/celebration/perfect.wav   skill-mastered jingle (~2 s)
  assets/sounds/sfx/celebration/streak3/5/10.wav  celebration bursts
  assets/sounds/sfx/celebration/levelup.wav   fanfare (~2 s)
  assets/sounds/sfx/celebration/unlock.wav    discovery shimmer (~1.5 s)
  assets/sounds/sfx/ui/click.wav whoosh.wav popup.wav
  assets/sounds/music/menu.wav, splash.wav    ambience loops
  assets/sounds/music/zones/<zone>.wav        8 zone ambient loops (~12 s)

Run: python tool/generate_audio_assets.py
"""
import math
import os
import random
import struct
import wave

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sounds')
SR = 22050  # mono, CD-quality-2x for spoken-register music is ample


def _write(name, samples):
    path = os.path.join(OUT, name)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = b''.join(
            struct.pack('<h', int(max(-1.0, min(1.0, s)) * 32000))
            for s in samples)
        w.writeframes(frames)
    print(f'{name}: {len(samples) / SR:.2f}s')


def tone(freq, dur, vol=0.5, wave_type='sine', decay='exp', attack=0.01):
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        env = math.exp(-3.0 * t / dur * (2.2 if decay == 'exp' else 1.0))
        # Fade the head in fast to avoid clicks.
        env = min(env, 1.0 - math.exp(-t / max(attack, 1e-4)))
        ph = 2 * math.pi * freq * t
        if wave_type == 'sine':
            v = math.sin(ph)
        elif wave_type == 'triangle':
            v = 2 / math.pi * math.asin(math.sin(ph))
        elif wave_type == 'square':
            v = 1.0 if math.sin(ph) > 0 else -1.0
        else:
            v = math.sin(ph)
        out.append(v * env * vol)
    return out


def silence(dur):
    return [0.0] * int(SR * dur)


def seq(*parts):
    out = []
    for p in parts:
        out.extend(p)
    return out


def arpeggio(notes, note_dur, vol=0.45, wave_type='triangle'):
    parts = [tone(f, note_dur, vol, wave_type) for f in notes]
    return seq(*parts)


def shimmer(freqs, dur, vol=0.4):
    n = int(SR * dur)
    out = []
    rng = random.Random(3)
    phases = [rng.random() * 2 * math.pi for _ in freqs]
    for i in range(n):
        t = i / SR
        v = sum(math.sin(2 * math.pi * f * t + p) for f, p in zip(freqs,
                                                                  phases))
        env = math.sin(t / dur * math.pi)
        out.append(v / len(freqs) * env * vol)
    return out


def ambient_loop(seed, base_freq, motif_scale, dur=12.0, vol=0.32):
    """Seamless loop: motif scheduled inside a window that fades to a
    shared bed drifting at zero crossings on both edges."""
    n = int(SR * dur)
    rng = random.Random(seed)
    # Slow bed: two detuned sines a fifth apart, panned by phase.
    out = []
    for i in range(n):
        t = i / SR
        v = (math.sin(2 * math.pi * base_freq * t) * 0.6 +
             math.sin(2 * math.pi * base_freq * 1.5 * t + 1.3) * 0.4)
        out.append(v * vol * 0.5)

    # Motif notes: gentle bell-like tones on a pentatonic-ish scale.
    total = len(motif_scale)
    t_offset = 0.4
    while t_offset < dur - 2.0:
        step = [0, 2, 4, 2, 5, 3, 1, 4][rng.randrange(8)]
        f = base_freq * 4 * 2 ** (motif_scale[step % total] / 12)
        note = tone(f, 0.9, 0.25, 'triangle', decay='exp')
        start = int(t_offset * SR)
        for j, s in enumerate(note):
            idx = start + j
            if idx < n:
                out[idx] += s
        t_offset += rng.uniform(0.9, 2.4)

    # Cross-fade the last 0.5 s over the first 0.5 s for a seamless loop.
    fade = int(0.5 * SR)
    for i in range(fade):
        a = i / fade
        out[n - fade + i] = out[n - fade + i] * (1 - a) + out[i] * a
    return out[:n - fade] if False else out


def noise_burst(dur, vol=0.4, lowpass=True):
    rng = random.Random(9)
    out = []
    last = 0.0
    for i in range(int(SR * dur)):
        x = rng.uniform(-1, 1)
        if lowpass:
            last = last * 0.82 + x * 0.18
            x = last
        decay = math.exp(-5 * i / (SR * dur))
        out.append(x * decay * vol)
    return out


def main():
    # ── Correct answers: 3 rising chime variations ────────────────────────
    _write('sfx/correct/correct1.wav',
           seq(tone(523, 0.10, 0.4), tone(659, 0.10, 0.4), tone(784, 0.28,
                                                               0.5)))
    _write('sfx/correct/correct2.wav',
           seq(tone(587, 0.09, 0.4), tone(784, 0.09, 0.4), tone(988, 0.26,
                                                               0.5)))
    _write('sfx/correct/correct3.wav',
           seq(tone(659, 0.08, 0.4), tone(698, 0.08, 0.4), tone(659, 0.08,
                                                               0.4),
               tone(1046, 0.26, 0.5)))

    # ── Wrong answers: soft, kind, not punishing ──────────────────────────
    wrong_mod = tone(185, 0.3, 0.35, 'triangle', decay='lin')
    thud = noise_burst(0.18, 0.22)
    _write('sfx/incorrect/wrong1.wav', seq(thud, wrong_mod))
    _write('sfx/incorrect/wrong2.wav',
           seq(tone(220, 0.14, 0.32, 'triangle'), tone(196, 0.30, 0.30,
                                                       'triangle')))

    # ── Celebrations ──────────────────────────────────────────────────────
    _write('sfx/celebration/perfect.wav', arpeggio(
        [523, 659, 784, 1046, 784, 1046], 0.14, 0.45))
    _write('sfx/celebration/streak3.wav',
           arpeggio([440, 554, 659], 0.12, 0.4))
    _write('sfx/celebration/streak5.wav',
           arpeggio([440, 554, 659, 880], 0.11, 0.42))
    _write('sfx/celebration/streak10.wav', arpeggio(
        [523, 659, 784, 1046, 1318], 0.10, 0.45))
    _write('sfx/celebration/levelup.wav', arpeggio(
        [392, 523, 659, 784, 659, 784, 1046], 0.16, 0.42))
    _write('sfx/celebration/unlock.wav',
           shimmer([1318, 1568, 2093], 1.5, 0.35))

    # ── UI ────────────────────────────────────────────────────────────────
    _write('sfx/ui/click.wav', tone(2000, 0.05, 0.25, 'sine', decay='exp',
                                    attack=0.002))
    whoosh = noise_burst(0.35, 0.30)
    _write('sfx/ui/whoosh.wav', whoosh)
    _write('sfx/ui/popup.wav', seq(tone(660, 0.06, 0.3), tone(880, 0.10,
                                                              0.35)))

    # ── Ambience loops ────────────────────────────────────────────────────
    # Pentatonic offsets keep the melodies cheerful and never atonal.
    scale = [0, 2, 4, 7, 9, 12]
    _write('sfx/../music/zones/word_woods.wav',
           ambient_loop(11, 110.0, scale))           # gentle forest
    _write('sfx/../music/zones/number_nebula.wav',
           ambient_loop(12, 87.3, scale, vol=0.28))  # soft space hum
    _write('sfx/../music/zones/math_facts.wav',
           ambient_loop(13, 131.8, scale, vol=0.26))  # clockwork feel
    _write('sfx/../music/zones/story_springs.wav',
           ambient_loop(14, 98.0, scale))            # water meadow
    _write('sfx/../music/zones/science_explorers.wav',
           ambient_loop(15, 82.4, scale, vol=0.24))  # crisp lab hum
    _write('sfx/../music/zones/creative_corner.wav',
           ambient_loop(16, 116.5, scale, vol=0.34))  # playful bright
    _write('sfx/../music/zones/puzzle_peaks.wav',
           ambient_loop(17, 103.8, scale, vol=0.22))  # airy cave drift
    _write('sfx/../music/zones/adventure_arena.wav',
           ambient_loop(18, 123.5, scale, vol=0.30))  # warm arena
    _write('sfx/../music/menu.wav', ambient_loop(19, 110.0, scale))
    _write('sfx/../music/splash.wav', ambient_loop(20, 87.3, scale,
                                                   vol=0.24))

    print('done.')


if __name__ == '__main__':
    main()
