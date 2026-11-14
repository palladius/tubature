import 'dart:js_interop';

@JS('_tubatureGrid')
external set _jsTubatureGrid(JSString? value);

@JS('_tubatureReady')
external set _jsTubatureReady(JSBoolean? value);

@JS('_tubatureBoardRect')
external set _jsTubatureBoardRect(JSString? value);

@JS('_tubatureHomeRects')
external set _jsTubatureHomeRects(JSString? value);

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

void setJsTubatureBoardRect(String? jsonData) {
  try {
    _jsTubatureBoardRect = jsonData?.toJS;
  } catch (_) {}
}

void setJsTubatureHomeRects(String? jsonData) {
  try {
    _jsTubatureHomeRects = jsonData?.toJS;
  } catch (_) {}
}
