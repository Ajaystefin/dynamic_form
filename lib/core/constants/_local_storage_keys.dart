part of "constants.dart";

/// Defines Hive/local storage box names used by the application.
class LocalStorageBoxes {
  /// User information storage box.
  static const user = "user";

  /// References storage box.
  static const references = "references";

  /// Reference data storage box.
  static const referenceData = "referenceData";
}

/// Defines keys used for local storage values.
class LocalStorageKeys {
  /// Authentication token key.
  static const authToken = "authToken";

  /// Refresh token key.
  static const refreshToken = "refreshToken";

  /// Session identifier key.
  static const sessionID = "sessionID";

  /// Token expiry timestamp key.
  static const tokenExpiryTime = "tokenExpiryTime";

  /// Indicates whether the grace period popup has been shown.
  static const isGracePeriodPopupShown = "isGracePeriodPopupShown";

  /// User information key.
  static const userInfo = "userInfo";
}

/// Returns all configured local storage box names.
List<String> testLocalStorageBoxes() {
  return [
    LocalStorageBoxes.user,
    LocalStorageBoxes.references,
    LocalStorageBoxes.referenceData,
  ];
}

/// Returns all configured local storage keys.
List<String> testLocalStorageKeys() {
  return [
    LocalStorageKeys.authToken,
    LocalStorageKeys.refreshToken,
    LocalStorageKeys.sessionID,
    LocalStorageKeys.tokenExpiryTime,
    LocalStorageKeys.isGracePeriodPopupShown,
    LocalStorageKeys.userInfo,
  ];
}
