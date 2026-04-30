part of "constants.dart";

class AppAssets {
  static const String imagesPath = "assets/images/";
  static const String logo = "${imagesPath}logo.png";
  static const String logoDark = "${imagesPath}logo_dark.png";
  static const String error = "${imagesPath}error.png";

  static const String configPath = "assets/configs/";
  static const String devEnvConfig = "${configPath}dev.json";
  static const String sitEnvConfig = "${configPath}sit.json";
  static const String uatEnvConfig = "${configPath}uat.json";
  static const String prodEnvConfig = "${configPath}prod.json";
}

void testAppAssets() {
  AppAssets.imagesPath;
  AppAssets.logo;
  AppAssets.logoDark;
  AppAssets.error;
  AppAssets.configPath;
  AppAssets.devEnvConfig;
  AppAssets.sitEnvConfig;
  AppAssets.uatEnvConfig;
  AppAssets.prodEnvConfig;
}
