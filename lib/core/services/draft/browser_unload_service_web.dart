import "dart:js_interop";

import "package:wcas_frontend/core/globals.dart";
import "package:web/web.dart" as web;

/// External JS binding for the browser native `fetch` API.
///
/// Accepts a plain [JSAny] for the init options to avoid dart2js extension-type
/// interop issues when passing typed [web.RequestInit] directly.
@JS("fetch")
external JSPromise _jsFetch(JSString url, JSAny options);

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
  BrowserUnloadServiceImpl() {
    // Convert Dart closures to JSFunction using .toJS (dart:js_interop style).
    _beforeUnloadListener = ((web.Event _) => _onUnload()).toJS;
    _visibilityChangeListener = ((web.Event _) {
      if (web.document.visibilityState == "hidden") {
        _onUnload();
      }
    }).toJS;
  }
  bool _registered = false;

  // Stored JS function references so we can pass the exact same object
  // to removeEventListener later (required by the browser API).
  late final web.EventListener _beforeUnloadListener;
  late final web.EventListener _visibilityChangeListener;

  /// Begin listening for browser unload events.
  /// Safe to call multiple times — only registers once.
  void register() {
    if (_registered) return;
    _registered = true;

    web.window.addEventListener("beforeunload", _beforeUnloadListener);
    web.document
        .addEventListener("visibilitychange", _visibilityChangeListener);
  }

  /// Stop listening for browser unload events.
  void unregister() {
    if (!_registered) return;
    _registered = false;

    web.window.removeEventListener("beforeunload", _beforeUnloadListener);
    web.document
        .removeEventListener("visibilitychange", _visibilityChangeListener);
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
  /// codebase that uses `dart:js_interop` / `package:web`.
  static bool tryFetchWithKeepalive({
    required String url,
    required String body,
    required Map<String, String> headers,
  }) {
    try {
      // Build a plain JS object for fetch options.
      // Using jsify() on a Dart Map<String, Object> is the dart2js-safe way
      // to construct the init object — avoids extension-type tear-off issues.
      final Map<String, Object> headersMap = Map<String, Object>.from(headers);
      final Map<String, Object> options = <String, Object>{
        "method": "POST",
        "keepalive": true,
        "headers": headersMap,
        "body": body,
      };

      _jsFetch(url.toJS, options.jsify()!);
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
