import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("AppAssets", () {
    test("image asset paths are correct", () {
      expect(AppAssets.imagesPath, "assets/images/");
      expect(AppAssets.logo, "assets/images/logo.png");
      expect(AppAssets.logoDark, "assets/images/logo_dark.png");
    });

    test("config asset paths are correct", () {
      testAppAssets();
      expect(AppAssets.configPath, "assets/configs/");
      expect(AppAssets.devEnvConfig, "assets/configs/dev.json");
      expect(AppAssets.sitEnvConfig, "assets/configs/sit.json");
      expect(AppAssets.uatEnvConfig, "assets/configs/uat.json");
      expect(AppAssets.prodEnvConfig, "assets/configs/prod.json");
    });
  });
}
