import "dart:convert";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";

/// Provides access to environment-specific application configuration.
///
/// Configuration values are loaded from an external `config.json` file
/// and fall back to compile-time environment variables when unavailable.
class EnvConfig {
  static Map<String, dynamic>? _config;

  /// Sets the environment configuration by loading from an external source
  /// [apiManager] is optional and primarily used for testing purposes
  static Future<void> setEnvironment({APIManager? apiManager}) async {
    try {
      logger.d("Attempting to load external config from /config.json");
      final APIManager manager =
          apiManager ?? APIManager(dio: Dio(), addDefaultInterceptors: false);
      final AppResponse response = await manager.get(
        "/config.json",
        additionalHeaders: {
          "Cache-Control": "no-cache, no-store, must-revalidate",
          "Pragma": "no-cache",
          "Expires": "0",
        },
      );

      if (response.status == ResponseStatus.success && response.body != null) {
        _config = response.body is Map<String, dynamic>
            ? response.body
            : json.decode(response.body.toString());

        logger
          ..i(
            "External config loaded successfully with "
            "${_config!.keys.length} configuration keys",
          )
          ..d("External config keys: ${_config!.keys.toList()}");
      } else {
        logger
          ..w(
            "External config request completed but"
            " returned no data or error status",
          )
          ..d(
            "Response status: ${response.status}, "
            "Response code: ${response.code}",
          );
      }
    } on Object catch (e) {
      logger.d("Error details: $e");
    }
  }

  /// Returns the loaded configuration for testing purposes.
  @visibleForTesting
  static Map<String, dynamic>? get configForTesting => _config;

  /// Sets the configuration for testing purposes.
  @visibleForTesting
  static set configForTesting(Map<String, dynamic>? config) {
    _config = config;
  }

  /// Indicates whether application logging is enabled.
  static bool get enableLogging =>
      _config?["enableLogging"] ??
      const bool.fromEnvironment(
        "enableLogging",
      );

  /// Base API URL.
  static String get baseUrl =>
      _config?["baseUrl"] ??
      const String.fromEnvironment(
        "BASE_URL",
        defaultValue: "https://api.wcas-sit.cbd.dev/wcas/",
      ) ??
      "";

  /// Request timeout duration in seconds.
  static int get requestTimeoutSeconds =>
      _config?["requestTimeoutSeconds"] ?? 2000; // in seconds

  /// Session timeout duration in seconds.
  static int get sessionTimeoutSeconds =>
      _config?["sessionTimeoutSeconds"] ?? 600;

  /// Session grace period duration in seconds.
  static int get sessionGracePeriodSeconds =>
      _config?["sessionGracePeriodSeconds"] ?? 300;

  /// Application channel identifier.
  static String get channelID => _config?["channelID"] ?? "WCAS";

  /// Indicates whether reference data should be mocked.
  static bool get shouldMockReference =>
      _config?["shouldMockReference"] ??
      const bool.fromEnvironment("shouldMockReference", defaultValue: true);

  /// Indicates whether the TinyMCE editor should be used.
  static bool get useTinyMceEditor =>
      _config?["useTinyMceEditor"] ??
      const bool.fromEnvironment("useTinyMceEditor");

  /// Indicates whether SSO authentication is enabled.
  static bool get isSSOEnabled =>
      _config?["isSSOEnabled"] ?? const bool.fromEnvironment("isSSOEnabled");

  /// Single sign-on endpoint URL.
  static String get ssoUrl =>
      _config?["ssoUrl"] ?? const String.fromEnvironment("ssoUrl");

  /// SpreadSmart application URL.
  static String get spreadSmartUrl =>
      _config?["spreadSmartUrl"] ??
      const String.fromEnvironment("spreadSmartUrl");

  /// SpreadSmart user manual file name.
  static String get spreadSmartManual =>
      _config?["spreadSmartManual"] ??
      const String.fromEnvironment(
        "spreadSmartManual",
        defaultValue: "spreadsmart_manual.pdf",
      );

  /// WCAS user manual file name.
  static String get wcasManual =>
      _config?["wcasManual"] ??
      const String.fromEnvironment(
        "wcasManual",
        defaultValue: "wcas_manual.pdf",
      );

  /// Indicates whether application restrictions are disabled.
  static bool get disableRestriction =>
      _config?["disableRestriction"] ??
      const bool.fromEnvironment("disableRestriction");

  /// Maximum number of log events retained in memory for `downloadLogs()`.
  static int get logBufferSize => _config?["logBufferSize"] ?? 1000;
}
