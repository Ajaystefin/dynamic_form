part of "constants.dart";

/// Defines static asset paths used throughout the application.
class AppAssets {
  /// Base path for image assets.
  static const String imagesPath = "assets/images/";

  /// Application logo asset.
  static const String logo = "${imagesPath}logo.png";

  /// Dark theme application logo asset.
  static const String logoDark = "${imagesPath}logo_dark.png";

  /// Base path for environment configuration assets.
  static const String configPath = "assets/configs/";

  /// Development environment configuration file.
  static const String devEnvConfig = "${configPath}dev.json";

  /// SIT environment configuration file.
  static const String sitEnvConfig = "${configPath}sit.json";

  /// UAT environment configuration file.
  static const String uatEnvConfig = "${configPath}uat.json";

  /// Production environment configuration file.
  static const String prodEnvConfig = "${configPath}prod.json";
}

/// Prints all configured application asset paths for debugging purposes.
void testAppAssets() {
  [
    AppAssets.imagesPath,
    AppAssets.logo,
    AppAssets.logoDark,
    AppAssets.configPath,
    AppAssets.devEnvConfig,
    AppAssets.sitEnvConfig,
    AppAssets.uatEnvConfig,
    AppAssets.prodEnvConfig,
  ].forEach(logger.i);
}
