// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:wcas_frontend/core/globals.dart';

/// Web implementation of [BrowserUnloadService].
///
/// Listens to two complementary browser events:
/// - `beforeunload` — fires on tab close, window close, and page refresh.
/// - `visibilitychange` (hidden) — a more reliable fallback on mobile browsers
///   and Chromium, where `beforeunload` may be suppressed.
///
/// When either event fires, [Globals.onAutoSaveSync] is called (if registered).
/// The actual HTTP call uses `navigator.sendBeacon` via [trySendBeacon] so the
/// request survives page termination.
class BrowserUnloadServiceImpl {
  bool _registered = false;

  // Stored references so we can remove the exact same listener later.
  late final html.EventListener _beforeUnloadListener;
  late final html.EventListener _visibilityChangeListener;

  BrowserUnloadServiceImpl() {
    // Capture `this` once so the closures stay stable across register/unregister.
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
    html.document.addEventListener('visibilitychange', _visibilityChangeListener);
  }

  /// Stop listening for browser unload events.
  void unregister() {
    if (!_registered) return;
    _registered = false;

    html.window.removeEventListener('beforeunload', _beforeUnloadListener);
    html.document.removeEventListener(
        'visibilitychange', _visibilityChangeListener);
  }

  /// Calls the browser's `navigator.sendBeacon(url, body)`.
  ///
  /// Returns `true` if the UA successfully queued the request, `false`
  /// if it was rejected (e.g. body too large). This is the only place in
  /// the codebase that imports `dart:html`, keeping all other files
  /// platform-agnostic.
  static bool trySendBeacon(String url, String body) {
    return html.window.navigator.sendBeacon(url, body);
  }

  /// Fires [Globals.onAutoSaveSync] when a browser unload event is detected.
  void _onUnload() {
    Globals.onAutoSaveSync?.call();
  }
}

