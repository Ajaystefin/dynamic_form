// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:wcas_frontend/core/globals.dart';

/// Web implementation of [BrowserUnloadService].
///
/// Listens to two complementary browser events:
/// - `beforeunload` — fires on tab close, window close, and page refresh.
/// - `visibilitychange` (hidden) — fires when the user switches tabs,
///   minimises the browser, or switches to another app.
///
/// When either event fires, [Globals.onAutoSaveSync] is called (if registered).
/// The actual HTTP call uses `fetch` with `keepalive: true` via
/// [tryFetchWithKeepalive], which supports custom headers and survives page
/// termination on Chromium (Chrome & Edge).
class BrowserUnloadServiceImpl {
  bool _registered = false;

  // Stored references so we can remove the exact same listener later.
  late final html.EventListener _beforeUnloadListener;
  late final html.EventListener _visibilityChangeListener;

  BrowserUnloadServiceImpl() {
    _beforeUnloadListener = (_) => _onUnload();
    _visibilityChangeListener = (_) {
      if (html.document.visibilityState == 'hidden') {
        _onUnload();
      }
    };
  }

  /// Begin listening for browser unload events.
  /// Safe to call multiple times — only registers once.
  void register() {
    if (_registered) return;
    _registered = true;

    html.window.addEventListener('beforeunload', _beforeUnloadListener);
    html.document
        .addEventListener('visibilitychange', _visibilityChangeListener);
  }

  /// Stop listening for browser unload events.
  void unregister() {
    if (!_registered) return;
    _registered = false;

    html.window.removeEventListener('beforeunload', _beforeUnloadListener);
    html.document
        .removeEventListener('visibilitychange', _visibilityChangeListener);
  }

  /// Calls the native browser `fetch` API with `keepalive: true`.
  ///
  /// Unlike `sendBeacon`, this supports custom headers (e.g. `Authorization`,
  /// `sessionID`), making it compatible with APIs that require auth headers.
  ///
  /// `keepalive: true` instructs the browser to keep the request alive even
  /// after the page is torn down, guaranteeing delivery on tab/window close
  /// and page refresh on Chromium-based browsers (Chrome & Edge).
  ///
  /// Returns `true` if the fetch call was successfully dispatched, `false`
  /// on any error (e.g. unsupported browser). This is the only file in the
  /// codebase that imports `dart:html` / `dart:js`.
  static bool tryFetchWithKeepalive({
    required String url,
    required String body,
    required Map<String, String> headers,
  }) {
    try {
      js.context.callMethod('fetch', [
        url,
        js.JsObject.jsify({
          'method': 'POST',
          'keepalive': true,
          'headers': headers,
          'body': body,
        }),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fires [Globals.onAutoSaveSync] when a browser unload event is detected.
  void _onUnload() {
    Globals.onAutoSaveSync?.call();
  }
}

