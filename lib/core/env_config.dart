import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'services/api_service/api_manager.dart';
import 'utils/logger.dart';

class EnvConfig {
  static Map<String, dynamic>? _config;

  /// Sets the environment configuration by loading from an external source
  /// [apiManager] is optional and primarily used for testing purposes
  static Future<void> setEnvironment({APIManager? apiManager}) async {
    try {
      logger.d('Attempting to load external config from /config.json');
      final manager =
          apiManager ?? APIManager(dio: Dio(), addDefaultInterceptors: false);
      final response = await manager.get('/config.json');

      if (response.status == ResponseStatus.success && response.body != null) {
        _config = response.body is Map<String, dynamic>
            ? response.body
            : json.decode(response.body.toString());

        logger.i(
            'External config loaded successfully with ${_config!.keys.length} configuration keys');
        logger.d('External config keys: ${_config!.keys.toList()}');
      } else {
        logger.w(
            'External config request completed but returned no data or error status');
        logger.d(
            'Response status: ${response.status}, Response code: ${response.code}');
      }
    } catch (e) {
      logger.d('Error details: ${e.toString()}');
    }
  }

  /// Sets the config directly - visible for testing only
  @visibleForTesting
  static void setConfigForTesting(Map<String, dynamic>? config) {
    _config = config;
  }

  static bool get enableLogging =>
      const bool.fromEnvironment("ENABLE_LOGGING", defaultValue: false);

  //Get from json configurations
  static String get baseUrl =>
      _config?["baseUrl"] ??
      const String.fromEnvironment("BASE_URL",
          defaultValue: "https://api.wcas.cbd.dev/wcas/") ??
      "";
  static int get requestTimeoutSeconds =>
      _config?["requestTimeoutSeconds"] ?? 2000; // in seconds
  static int get sessionTimeoutSeconds =>
      _config?["sessionTimeoutSeconds"] ?? 600;
  static int get sessionGracePeriodSeconds =>
      _config?["sessionGracePeriodSeconds"] ?? 300;
  static String get channelID => _config?["channelID"] ?? "WCAS";
  static bool get shouldMockReference =>
      _config?["shouldMockReference"] ??
      const bool.fromEnvironment("shouldMockReference", defaultValue: true);

  static bool get useTinyMceEditor =>
      _config?["useTinyMceEditor"] ??
      const bool.fromEnvironment("USE_TINYMCE_EDITOR", defaultValue: false);
}
