import "dart:js_interop";
import "package:web/web.dart" as web;

/// Web implementation of the session visibility service.
///
/// Listens to the browser `visibilitychange` event and triggers [`callback`]
/// whenever the document becomes visible (e.g. user switches back to the tab).
///
/// Uses [package:web] + [dart:js_interop] — the modern, non-deprecated
/// replacement for the old `dart:html` approach.
class SessionVisibilityServiceImpl {
  // Stored JS function reference so we can pass the exact same object
  // to removeEventListener later (required by the browser API).
  web.EventListener? _listener;

  /// Registers a [callback] to fire when the page becomes visible.
  /// Safe to call multiple times — only registers once.
  void register(void Function() callback) {
    if (_listener != null) {
      return;
    }
    // Convert the Dart closure to a JSFunction using .toJS (dart:js_interop).
    _listener = ((web.Event _) {
      if (web.document.visibilityState == "visible") {
        callback();
      }
    }).toJS;
    web.document.addEventListener("visibilitychange", _listener);
  }

  /// Removes the previously registered visibility listener.
  void unregister() {
    if (_listener != null) {
      web.document.removeEventListener("visibilitychange", _listener);
      _listener = null;
    }
  }
}
