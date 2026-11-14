import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

@JS('window')
external _JSWindow get _window;

@JS('_puffinFlutterBridge')
external _JSPuffinFlutterBridge? get _jsBridge;

extension type _JSWindow._(JSObject _) implements JSObject {
  external _JSStorage get localStorage;
  external _JSLocation get location;
  external _JSNavigator get navigator;
  external void addEventListener(JSString type, JSFunction listener);
}

extension type _JSStorage._(JSObject _) implements JSObject {
  external JSString? getItem(JSString key);
  external void setItem(JSString key, JSString value);
  external void removeItem(JSString key);
}

extension type _JSLocation._(JSObject _) implements JSObject {
  external JSString get hostname;
}

extension type _JSNavigator._(JSObject _) implements JSObject {
  external JSString get platform;
}

extension type _JSPuffinFlutterBridge._(JSObject _) implements JSObject {
  external void openModal([JSString? preselectUserId]);
  external void setHallOfFameVisible(JSBoolean visible);
  external JSPromise<JSString>? submitScoreFromFlutter(JSString payloadJson);
}

@JS('XMLHttpRequest')
extension type _JSXMLHttpRequest._(JSObject _) implements JSObject {
  external factory _JSXMLHttpRequest();
  external void open(JSString method, JSString url, JSBoolean async);
  external void setRequestHeader(JSString name, JSString value);
  external set timeout(JSNumber ms);
  external int get status;
  external String get responseText;
  external set onload(JSFunction? fn);
  external set onerror(JSFunction? fn);
  external set ontimeout(JSFunction? fn);
  external void send([JSAny? body]);
}

/// Web (`dart:js_interop`) platform bridge for PuffinLogin.
/// Syncs directly with `<puffin-login>` in `web/index.html` and raw `window.localStorage`
/// so all `https://palladius.github.io/*` games share login state and scores!
class PuffinPlatformBridge {
  static bool _listenersAttached = false;

  static void clearMockStorage() {}

  static String? getRawStorageItem(String key) {
    try {
      return _window.localStorage.getItem(key.toJS)?.toDart;
    } catch (_) {
      return null;
    }
  }

  static void setRawStorageItem(String key, String value) {
    try {
      _window.localStorage.setItem(key.toJS, value.toJS);
    } catch (_) {}
  }

  static void removeRawStorageItem(String key) {
    try {
      _window.localStorage.removeItem(key.toJS);
    } catch (_) {}
  }

  static void listenToWebEvents({
    required void Function() onAuthOrScoreChanged,
  }) {
    if (_listenersAttached) return;
    _listenersAttached = true;

    final handler = ((JSObject _) {
      onAuthOrScoreChanged();
    }).toJS;

    _window.addEventListener('puffin-user-changed'.toJS, handler);
    _window.addEventListener('puffin-auth-change'.toJS, handler);
    _window.addEventListener('puffin-score-recorded'.toJS, handler);
    _window.addEventListener('puffin-lang-changed'.toJS, handler);
    _window.addEventListener('storage'.toJS, handler);
  }

  static bool openWebModal([String? preselectUserId]) {
    try {
      final bridge = _jsBridge;
      if (bridge != null) {
        bridge.openModal(preselectUserId?.toJS);
        return true;
      }
    } catch (_) {}
    return false;
  }

  static void setWebHallOfFameVisible(bool visible) {
    try {
      _jsBridge?.setHallOfFameVisible(visible.toJS);
    } catch (_) {}
  }

  static Future<String?> submitScoreViaWebBridge(Map<String, dynamic> payload) async {
    try {
      final bridge = _jsBridge;
      if (bridge != null) {
        final promise = bridge.submitScoreFromFlutter(jsonEncode(payload).toJS);
        if (promise != null) {
          final res = await promise.toDart;
          return res.toDart;
        }
      }
    } catch (_) {}
    return null;
  }

  static String getHostname() {
    try {
      final host = _window.location.hostname.toDart;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        return host;
      }
    } catch (_) {}
    return '';
  }

  static String getDeviceLabel() {
    try {
      final platform = _window.navigator.platform.toDart;
      if (platform.isNotEmpty) return '$platform (Browser)';
    } catch (_) {}
    return 'Web Browser';
  }

  static Future<String?> httpGet(String url) async {
    final completer = Completer<String?>();
    try {
      final xhr = _JSXMLHttpRequest();
      xhr.open('GET'.toJS, url.toJS, true.toJS);
      xhr.timeout = 2500.toJS;
      xhr.onload = ((JSObject _) {
        if (!completer.isCompleted) {
          if (xhr.status >= 200 && xhr.status < 300) {
            completer.complete(xhr.responseText);
          } else {
            completer.complete(null);
          }
        }
      }).toJS;
      xhr.onerror = ((JSObject _) {
        if (!completer.isCompleted) completer.complete(null);
      }).toJS;
      xhr.ontimeout = ((JSObject _) {
        if (!completer.isCompleted) completer.complete(null);
      }).toJS;
      xhr.send();
    } catch (_) {
      if (!completer.isCompleted) completer.complete(null);
    }
    return completer.future;
  }

  static Future<String?> httpPostJson(String url, Map<String, dynamic> body) async {
    final completer = Completer<String?>();
    try {
      final xhr = _JSXMLHttpRequest();
      xhr.open('POST'.toJS, url.toJS, true.toJS);
      xhr.setRequestHeader('Content-Type'.toJS, 'application/json'.toJS);
      xhr.timeout = 2500.toJS;
      xhr.onload = ((JSObject _) {
        if (!completer.isCompleted) {
          if (xhr.status >= 200 && xhr.status < 300) {
            completer.complete(xhr.responseText);
          } else {
            completer.complete(null);
          }
        }
      }).toJS;
      xhr.onerror = ((JSObject _) {
        if (!completer.isCompleted) completer.complete(null);
      }).toJS;
      xhr.ontimeout = ((JSObject _) {
        if (!completer.isCompleted) completer.complete(null);
      }).toJS;
      xhr.send(jsonEncode(body).toJS);
    } catch (_) {
      if (!completer.isCompleted) completer.complete(null);
    }
    return completer.future;
  }
}
