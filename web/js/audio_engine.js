class AudioEngine {
  constructor() {
    this.ctx = null;
    this.isBgmActive = false;
    this.isRainActive = false;
    this.bgmTimer = null;
    this.rainNode = null;
    this.chordIndex = 0;
    this.chords = [
      [220.0, 261.63, 329.63, 392.0],  // Am7 (Monsoon longing)
      [174.61, 220.0, 261.63, 329.63], // Fmaj7 (Warm affection)
      [261.63, 329.63, 392.0, 523.25],  // C (Hope)
      [196.0, 246.94, 293.66, 392.0]   // G (Long distance journey)
    ];
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioCtx();
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  playBgm() {
    this.init();
    if (this.isBgmActive) return;
    this.isBgmActive = true;

    const playNextChord = () => {
      if (!this.isBgmActive || !this.ctx) return;
      const notes = this.chords[this.chordIndex];
      this.chordIndex = (this.chordIndex + 1) % this.chords.length;

      // Play soft arpeggiated piano-like chord
      notes.forEach((freq, idx) => {
        setTimeout(() => {
          if (!this.isBgmActive || !this.ctx) return;
          this._playSynthNote(freq, 2.8, 0.04);
        }, idx * 180);
      });

      this.bgmTimer = setTimeout(playNextChord, 3400);
    };

    playNextChord();
  }

  stopBgm() {
    this.isBgmActive = false;
    if (this.bgmTimer) clearTimeout(this.bgmTimer);
  }

  _playSynthNote(freq, duration, gainVal) {
    if (!this.ctx) return;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    const filter = this.ctx.createBiquadFilter();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, this.ctx.currentTime);

    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(800, this.ctx.currentTime);

    const now = this.ctx.currentTime;
    gain.gain.setValueAtTime(0.001, now);
    gain.gain.exponentialRampToValueAtTime(gainVal, now + 0.05);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + duration);

    osc.connect(filter);
    filter.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start(now);
    osc.stop(now + duration);
  }

  playRain() {
    this.init();
    if (this.isRainActive) return;
    this.isRainActive = true;

    // Buffer noise for gentle monsoon patter
    const bufferSize = this.ctx.sampleRate * 2;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const output = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      output[i] = (Math.random() * 2 - 1) * 0.035;
    }

    const whiteNoise = this.ctx.createBufferSource();
    whiteNoise.buffer = buffer;
    whiteNoise.loop = true;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(1000, this.ctx.currentTime);

    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(0.3, this.ctx.currentTime);

    whiteNoise.connect(filter);
    filter.connect(gain);
    gain.connect(this.ctx.destination);

    whiteNoise.start();
    this.rainNode = whiteNoise;
  }

  stopRain() {
    this.isRainActive = false;
    if (this.rainNode) {
      try { this.rainNode.stop(); } catch(e) {}
      this.rainNode = null;
    }
  }

  playSfx(name) {
    this.init();
    if (!this.ctx) return;

    let freq = 520;
    let dur = 0.08;
    switch (name) {
      case 'blip': freq = 680; dur = 0.04; break;
      case 'catch': freq = 1046.5; dur = 0.35; break;
      case 'choice': freq = 880; dur = 0.12; break;
      case 'phone': freq = 987.77; dur = 0.25; break;
      case 'mission': freq = 659.25; dur = 0.5; break;
    }

    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(freq, this.ctx.currentTime);

    const now = this.ctx.currentTime;
    gain.gain.setValueAtTime(0.08, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + dur);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start(now);
    osc.stop(now + dur);
  }
}

window.audioEngine = new AudioEngine();
