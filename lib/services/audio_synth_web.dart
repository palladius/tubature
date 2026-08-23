import 'dart:js_interop';

@JS('eval')
external JSAny? _eval(String code);

bool _initialized = false;

void _ensureInitialized() {
  if (_initialized) return;
  _initialized = true;
  try {
    _eval('''
      window._tubatureAudio = {
        ctx: null,
        init: function() {
          if (!this.ctx) {
            var AudioContext = window.AudioContext || window.webkitAudioContext;
            if (AudioContext) this.ctx = new AudioContext();
          }
          if (this.ctx && this.ctx.state === 'suspended') {
            this.ctx.resume();
          }
        },
        click: function() {
          this.init();
          if (!this.ctx) return;
          var t = this.ctx.currentTime;
          var osc = this.ctx.createOscillator();
          var gain = this.ctx.createGain();
          var freq = 600 + Math.random() * 250;
          osc.type = 'triangle';
          osc.frequency.setValueAtTime(freq, t);
          osc.frequency.exponentialRampToValueAtTime(freq * 0.4, t + 0.04);
          gain.gain.setValueAtTime(0.2, t);
          gain.gain.exponentialRampToValueAtTime(0.001, t + 0.04);
          osc.connect(gain);
          gain.connect(this.ctx.destination);
          osc.start(t);
          osc.stop(t + 0.05);
        },
        water: function(chain) {
          this.init();
          if (!this.ctx) return;
          var t = this.ctx.currentTime;
          var count = Math.min(Math.max(chain, 1), 6);
          for (var i = 0; i < count; i++) {
            var delay = i * 0.07;
            var osc = this.ctx.createOscillator();
            var gain = this.ctx.createGain();
            var baseFreq = 400 + Math.random() * 200 + (i * 80);
            osc.type = 'sine';
            osc.frequency.setValueAtTime(baseFreq, t + delay);
            osc.frequency.exponentialRampToValueAtTime(baseFreq * 1.6, t + delay + 0.09);
            gain.gain.setValueAtTime(0.001, t + delay);
            gain.gain.linearRampToValueAtTime(0.18, t + delay + 0.02);
            gain.gain.exponentialRampToValueAtTime(0.001, t + delay + 0.12);
            osc.connect(gain);
            gain.connect(this.ctx.destination);
            osc.start(t + delay);
            osc.stop(t + delay + 0.13);
          }
        },
        glub: function() {
          this.init();
          if (!this.ctx) return;
          var t = this.ctx.currentTime;
          // 4 rising water bubbles with liquid resonance (glub glub glub glub)
          var pitches = [260, 360, 490, 650];
          for (var i = 0; i < pitches.length; i++) {
            var delay = i * 0.13;
            var osc = this.ctx.createOscillator();
            var gain = this.ctx.createGain();
            var freq = pitches[i];
            osc.type = 'sine';
            osc.frequency.setValueAtTime(freq * 0.85, t + delay);
            osc.frequency.exponentialRampToValueAtTime(freq * 1.55, t + delay + 0.09);
            gain.gain.setValueAtTime(0.001, t + delay);
            gain.gain.linearRampToValueAtTime(0.28, t + delay + 0.02);
            gain.gain.exponentialRampToValueAtTime(0.001, t + delay + 0.15);
            osc.connect(gain);
            gain.connect(this.ctx.destination);
            osc.start(t + delay);
            osc.stop(t + delay + 0.16);
          }
        },
        fanfare: function() {
          this.init();
          if (!this.ctx) return;
          var t = this.ctx.currentTime;
          var notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
          for (var i = 0; i < notes.length; i++) {
            var delay = i * 0.14;
            var osc = this.ctx.createOscillator();
            var gain = this.ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(notes[i], t + delay);
            gain.gain.setValueAtTime(0.001, t + delay);
            gain.gain.linearRampToValueAtTime(0.25, t + delay + 0.03);
            gain.gain.exponentialRampToValueAtTime(0.001, t + delay + (i === 3 ? 0.9 : 0.45));
            osc.connect(gain);
            gain.connect(this.ctx.destination);
            osc.start(t + delay);
            osc.stop(t + delay + (i === 3 ? 1.0 : 0.5));
          }
        }
      };
    ''');
  } catch (_) {}
}

void playTileClick() {
  _ensureInitialized();
  try {
    _eval('if (window._tubatureAudio) window._tubatureAudio.click();');
  } catch (_) {}
}

void playWaterFlow(int chainLength) {
  _ensureInitialized();
  try {
    _eval('if (window._tubatureAudio) window._tubatureAudio.water($chainLength);');
  } catch (_) {}
}

void playAmpollaGlub() {
  _ensureInitialized();
  try {
    _eval('if (window._tubatureAudio) window._tubatureAudio.glub();');
  } catch (_) {}
}

void playVictoryFanfare() {
  _ensureInitialized();
  try {
    _eval('if (window._tubatureAudio) window._tubatureAudio.fanfare();');
  } catch (_) {}
}
