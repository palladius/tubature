import 'dart:js_interop';

@JS('_tubatureGrid')
external set _jsTubatureGrid(JSString? value);

@JS('_tubatureReady')
external set _jsTubatureReady(JSBoolean? value);

@JS('_tubatureBoardRect')
external set _jsTubatureBoardRect(JSString? value);

@JS('_tubatureHomeRects')
external set _jsTubatureHomeRects(JSString? value);

@JS('_tubatureLowEnd')
external JSBoolean? get _jsTubatureLowEnd;

@JS('_tubatureLowEnd')
external set _jsTubatureLowEnd(JSBoolean? value);

@JS('_setTubatureRpiMode')
external void _jsSetTubatureRpiMode(JSBoolean value);

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

bool getJsTubatureLowEnd() {
  try {
    return _jsTubatureLowEnd?.toDart ?? false;
  } catch (_) {
    return false;
  }
}

void setJsTubatureLowEnd(bool value) {
  try {
    _jsTubatureLowEnd = value.toJS;
    _jsSetTubatureRpiMode(value.toJS);
  } catch (_) {}
}
