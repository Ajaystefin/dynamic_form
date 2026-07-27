import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("LocalStorageBoxes", () {
    test("contains the correct box names", () {
      testLocalStorageBoxes();
      expect(LocalStorageBoxes.user, "user");
      expect(LocalStorageBoxes.references, "references");
      expect(LocalStorageBoxes.referenceData, "referenceData");
    });
  });

  group("LocalStorageKeys", () {
    test("contains the correct key names", () {
      testLocalStorageKeys();
      expect(LocalStorageKeys.authToken, "authToken");
      expect(LocalStorageKeys.refreshToken, "refreshToken");
      expect(LocalStorageKeys.sessionID, "sessionID");
      expect(LocalStorageKeys.tokenExpiryTime, "tokenExpiryTime");
      expect(
        LocalStorageKeys.isGracePeriodPopupShown,
        "isGracePeriodPopupShown",
      );
      expect(LocalStorageKeys.userInfo, "userInfo");
    });
  });
}
