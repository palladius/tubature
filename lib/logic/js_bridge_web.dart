import 'dart:js_interop';

@JS('_tubatureGrid')
external set _jsTubatureGrid(JSString? value);

@JS('_tubatureReady')
external set _jsTubatureReady(JSBoolean? value);

void setJsTubatureGrid(String? jsonData) {
  try {
    _jsTubatureGrid = jsonData?.toJS;
  } catch (_) {}
}

void setJsTubatureReady(bool value) {
  try {
    _jsTubatureReady = value.toJS;
  } catch (_) {}
}
