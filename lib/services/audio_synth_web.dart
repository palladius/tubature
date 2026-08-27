import 'dart:js_interop';

@JS('window._tubatureAudio.click')
external void _jsClick();

@JS('window._tubatureAudio.water')
external void _jsWater(int chain);

@JS('window._tubatureAudio.glub')
external void _jsGlub();

@JS('window._tubatureAudio.fanfare')
external void _jsFanfare();

@JS('window._tubatureAudio.schmoogle')
external void _jsSchmoogle();

@JS('window._tubatureAudio.playVoice')
external void _jsPlayVoice(String path);

@JS('window._tubatureAudio.crack')
external void _jsCrack();

void playTileClick() {
  try {
    _jsClick();
  } catch (_) {}
}

void playWaterFlow(int chainLength) {
  try {
    _jsWater(chainLength);
  } catch (_) {}
}

void playAmpollaGlub() {
  try {
    _jsGlub();
  } catch (_) {}
}

void playVictoryFanfare() {
  try {
    _jsFanfare();
  } catch (_) {}
}

void playSchmoogleReveal() {
  try {
    _jsSchmoogle();
  } catch (_) {}
}

void playVoiceFile(String assetPath) {
  try {
    _jsPlayVoice(assetPath);
  } catch (_) {}
}

void playPipeCrack() {
  try {
    _jsCrack();
  } catch (_) {}
}
