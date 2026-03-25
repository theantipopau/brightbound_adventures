/**
 * BrightBound Adventures – Web Audio Synthesiser
 * Generates real-time audio feedback using the Web Audio API.
 * Loaded by index.html and called from Flutter via dart:js.
 */
(function () {
  'use strict';

  let _ctx = null;

  function getCtx() {
    if (!_ctx) {
      _ctx = new (window.AudioContext || window.webkitAudioContext)();
    }
    // Browsers suspend context until a user gesture; resume here
    if (_ctx.state === 'suspended') {
      _ctx.resume();
    }
    return _ctx;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  function note(ctx, type, freq, startTime, duration, gainPeak) {
    const osc  = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.type = type;
    osc.frequency.setValueAtTime(freq, startTime);
    gain.gain.setValueAtTime(gainPeak, startTime);
    gain.gain.exponentialRampToValueAtTime(0.001, startTime + duration);
    osc.start(startTime);
    osc.stop(startTime + duration + 0.02);
  }

  function chord(type, freqs, spacing, duration, gainPeak) {
    const ctx = getCtx();
    freqs.forEach(function (f, i) {
      note(ctx, type, f, ctx.currentTime + i * spacing, duration, gainPeak);
    });
  }

  function noise(ctx, startTime, duration, gainPeak, filterFreqStart, filterFreqEnd) {
    const samples   = Math.floor(ctx.sampleRate * duration);
    const buffer    = ctx.createBuffer(1, samples, ctx.sampleRate);
    const data      = buffer.getChannelData(0);
    for (let i = 0; i < samples; i++) { data[i] = Math.random() * 2 - 1; }
    const src    = ctx.createBufferSource();
    src.buffer   = buffer;
    const filter = ctx.createBiquadFilter();
    filter.type  = 'bandpass';
    filter.frequency.setValueAtTime(filterFreqStart, startTime);
    filter.frequency.exponentialRampToValueAtTime(filterFreqEnd, startTime + duration);
    filter.Q.value = 0.7;
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(gainPeak, startTime);
    gain.gain.exponentialRampToValueAtTime(0.001, startTime + duration);
    src.connect(filter);
    filter.connect(gain);
    gain.connect(ctx.destination);
    src.start(startTime);
    src.stop(startTime + duration + 0.02);
  }

  // ── Sound Definitions ────────────────────────────────────────────────────

  function playClick() {
    const ctx = getCtx();
    const t   = ctx.currentTime;
    note(ctx, 'sine', 900, t,        0.04, 0.18);
    note(ctx, 'sine', 450, t + 0.03, 0.04, 0.10);
  }

  function playCorrect() {
    // C5 – E5 – G5 ascending major arpeggio
    chord('triangle', [523.25, 659.25, 783.99], 0.10, 0.22, 0.30);
  }

  function playWrong() {
    const ctx = getCtx();
    const t   = ctx.currentTime;
    const osc  = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(220, t);
    osc.frequency.exponentialRampToValueAtTime(100, t + 0.30);
    gain.gain.setValueAtTime(0.22, t);
    gain.gain.exponentialRampToValueAtTime(0.001, t + 0.32);
    osc.start(t);
    osc.stop(t + 0.35);
  }

  function playStreak() {
    // C5 – E5 – G5 – C6 rapid arpeggio
    chord('sine', [523.25, 659.25, 783.99, 1046.50], 0.08, 0.20, 0.32);
  }

  function playLevelUp() {
    // Full fanfare: C5 E5 G5 C6 E6
    chord('triangle', [523.25, 659.25, 783.99, 1046.50, 1318.51], 0.07, 0.30, 0.38);
  }

  function playUnlock() {
    // Rising fifth then octave leap
    chord('sine', [392, 523.25, 784], 0.12, 0.25, 0.30);
  }

  function playWhoosh() {
    const ctx = getCtx();
    noise(ctx, ctx.currentTime, 0.20, 0.28, 2000, 200);
  }

  function playPopup() {
    const ctx = getCtx();
    const t = ctx.currentTime;
    note(ctx, 'sine', 600, t,       0.06, 0.20);
    note(ctx, 'sine', 900, t + 0.05, 0.12, 0.18);
  }

  function playPerfect() {
    // Perfect-score fanfare
    chord('triangle', [523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98], 0.06, 0.35, 0.40);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  window.BBSounds = {
    play: function (type) {
      try {
        switch (type) {
          case 'click':    playClick();   break;
          case 'correct':  playCorrect(); break;
          case 'wrong':    playWrong();   break;
          case 'streak':   playStreak();  break;
          case 'levelup':  playLevelUp(); break;
          case 'unlock':   playUnlock();  break;
          case 'whoosh':   playWhoosh();  break;
          case 'popup':    playPopup();   break;
          case 'perfect':  playPerfect(); break;
        }
      } catch (e) {
        // Silently ignore – audio never crashes the app
      }
    }
  };
})();
