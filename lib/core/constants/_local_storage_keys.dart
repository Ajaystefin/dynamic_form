part of 'constants.dart';

class LocalStorageBoxes {
  static const user = 'user';
  static const references = 'references';
  static const referenceData = 'referenceData';
}

class LocalStorageKeys {
  static const authToken = "authToken";
  static const refreshToken = "refreshToken";
  static const sessionID = 'sessionID';
  static const tokenExpiryTime = 'tokenExpiryTime';
  static const isGracePeriodPopupShown = 'isGracePeriodPopupShown';
  static const userInfo = 'userInfo';
}

void testLocalStorageBoxes() {
  LocalStorageBoxes.user;
  LocalStorageBoxes.references;
  LocalStorageBoxes.referenceData;
}

void testLocalStorageKeys() {
  LocalStorageKeys.authToken;
  LocalStorageKeys.refreshToken;
  LocalStorageKeys.sessionID;
  LocalStorageKeys.tokenExpiryTime;
  LocalStorageKeys.isGracePeriodPopupShown;
  LocalStorageKeys.userInfo;
}
