import "package:wcas_frontend/core/services/session/session_visibility_service_impl.dart"
    if (dart.library.html) "session_visibility_service_web.dart";

class SessionVisibilityService {
  SessionVisibilityService({required this.onVisible});
  final void Function() onVisible;

  final _impl = SessionVisibilityServiceImpl();

  void register() => _impl.register(onVisible);
  void unregister() => _impl.unregister();
}
