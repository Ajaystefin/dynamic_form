import "package:wcas_frontend/core/services/session/session_visibility_service_impl.dart"
    if (dart.library.html) "session_visibility_service_web.dart";

/// Session Visibility Service
///
/// Manages application visibility changes and invokes the provided
/// callback when the application becomes visible.
class SessionVisibilityService {
  /// Creates a session visibility service.
  SessionVisibilityService({required this.onVisible});

  /// Callback invoked when the application becomes visible.
  final void Function() onVisible;

  final _impl = SessionVisibilityServiceImpl();

  /// Registers visibility event listeners.
  void register() => _impl.register(onVisible);

  /// Unregisters visibility event listeners.
  void unregister() => _impl.unregister();
}
