// Web implementation of JS interop bindings for automated recorder.
import 'dart:js_interop';

@JS('_tubatureGrid')
external set _jsTubatureGrid(JSString? value);

@JS('_tubatureReady')
external set _jsTubatureReady(JSBoolean? value);

void updateJsTubatureGrid(String jsonData) {
  try {
    _jsTubatureGrid = jsonData.toJS;
  } catch (_) {}
}

void updateJsTubatureReady(bool ready) {
  try {
    _jsTubatureReady = ready.toJS;
  } catch (_) {}
}
