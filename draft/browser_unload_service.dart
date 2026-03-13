import 'package:wcas_frontend/core/services/draft/browser_unload_service_impl.dart'
    if (dart.library.html) 'package:wcas_frontend/core/services/draft/browser_unload_service_web.dart';

/// Service that listens to browser-level unload events (tab/window close,
/// page refresh) and triggers a fire-and-forget draft save via [Globals.onAutoSaveSync].
///
/// On non-web platforms this is a no-op stub.
/// On web, it uses `beforeunload` + `visibilitychange` and calls the draft save
/// via `navigator.sendBeacon` so the request survives page termination.
///
/// This service is automatically managed by [DraftMixin]:
/// - [DraftMixin.registerDraftCallback] calls [register].
/// - [DraftMixin.unregisterDraftCallback] calls [unregister].
///
/// You do NOT need to call this service directly in any ViewModel.
class BrowserUnloadService {
  // Singleton instance.
  static final BrowserUnloadService instance = BrowserUnloadService._();
  BrowserUnloadService._();

  final BrowserUnloadServiceImpl _impl = BrowserUnloadServiceImpl();

  /// Begin listening for browser unload events.
  /// Safe to call multiple times — only registers once.
  void register() => _impl.register();

  /// Stop listening for browser unload events.
  void unregister() => _impl.unregister();

  /// Calls `navigator.sendBeacon(url, body)` on web; returns `false` on other
  /// platforms. Delegates to [BrowserUnloadServiceImpl.trySendBeacon] which is
  /// the only file that imports `dart:html`.
  static bool trySendBeacon(String url, String body) =>
      BrowserUnloadServiceImpl.trySendBeacon(url, body);
}

