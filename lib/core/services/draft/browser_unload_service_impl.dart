/// Non-web stub for [BrowserUnloadService].
///
/// All methods are intentional no-ops on non-web platforms.
class BrowserUnloadServiceImpl {
  /// No-op on non-web platforms.
  void register() {}

  /// No-op on non-web platforms.
  void unregister() {}

  /// Always returns `false` on non-web platforms.
  static bool tryFetchWithKeepalive({
    required String url,
    required String body,
    required Map<String, String> headers,
  }) =>
      false;
}
