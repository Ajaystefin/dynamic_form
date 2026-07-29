import "dart:convert";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/splash/state.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

/// View model responsible for splash screen initialization,
/// SSO handling, and navigation.
class SplashViewModel extends SafeCubit<SplashState> {
  /// Creates a [SplashViewModel].
  SplashViewModel()
      : super(const SplashState(loaderStatus: LoadingStatus.loaded));

  /// Initializes the application and handles SSO flow.
  Future<void> init(Map<String, String> queryParams) async {
    logger
      ..i("queryParams in SplashViewModel: $queryParams")
      ..i("queryParams for  sso-error: ${queryParams['error']}");
    // if (await _checkAuthentication()) return;

    // In debug mode, show debug login screen instead of SSO redirect
    // if (kDebugMode) {
    //   router.go("/debug");
    //   return;
    // }
    await Future.delayed(Duration.zero);

    if (!EnvConfig.isSSOEnabled) {
      router.go(Routes.login);
      return;
    }
    if (queryParams.containsKey("error")) {
      final String errorParam = queryParams["error"]!;
      logger.i("Navigating to Login due to SSO error: $errorParam");
      if (errorParam == "ADFS_UNAVAILABLE") {
        // ADFS downtime gets a friendly, localized message instead of the raw error code.
        AlertManager().showFailureToast("auth.login.errorMessageSSO".tr());
      } else if (errorParam == "USER_ROLE_NULL") {
        // No Region/Segment access gets a friendly, localized message instead of the raw error code.
        AlertManager().showFailureToast("auth.login.errorMessageNoRole".tr());
      } else {
        // Other SSO/Login errors: format raw code (e.g. "Some_error") into readable text ("Some error").
        AlertManager().showFailureToast(
          errorParam.replaceAll("_", " "),
        );
      }
      router.go(Routes.login);
      return;
    }
    if (queryParams.containsKey("tokenResponse")) {
      logger.i(
        "Token found in URL, attempting login with query parameters",
      );
      await _handleTokenFound(queryParams);
    } else {
      await _initiateSSORedirect();
    }
  }

  /// Handles the scenario where a token key is present in the URL.
  Future<void> _handleTokenFound(Map<String, String> queryParams) async {
    try {
      if (!queryParams.containsKey("tokenResponse") ||
          !queryParams.containsKey("userResponse")) {
        throw ApiException("auth.login.errorMessageInvalidResponse".tr());
      }

      // Extract and set sessionID from SSO parameters
      if (queryParams.containsKey("sessionID")) {
        Globals.sessionID = queryParams["sessionID"]!;
        logger.i("Session ID set from SSO: ${Globals.sessionID}");
      }

      final String userEncoded =
          base64Url.normalize(queryParams["userResponse"]!);
      final userResponse =
          jsonDecode(utf8.decode(base64Url.decode(userEncoded)));
      logger.i("User Response: $userResponse");

      final String tokenEncoded =
          base64Url.normalize(queryParams["tokenResponse"]!);
      final tokenResponse =
          jsonDecode(utf8.decode(base64Url.decode(tokenEncoded)));

      await AuthRepository.instance.loginWithSSO(
        tokenResponse: tokenResponse,
        userResponse: userResponse,
      );

      final bool hasRoles = Globals.user?.segments?.isNotEmpty ?? false;
      if (hasRoles) {
        AlertManager().showSuccessToast("auth.login.success".tr());
        if (Globals.user?.availableRoles?.length == 1) {
          await AuthRepository.instance.goToLandingScreen();
        } else {
          router.go(Routes.selectRole);
        }
      } else {
        throw ApiException("auth.login.errorMessageNoRoles".tr());
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      router.go(Routes.login);
    }
  }

  Future<void> _initiateSSORedirect() async {
    final ssoUrl = EnvConfig.ssoUrl;
    if (ssoUrl.isNotEmpty && kIsWeb) {
      final bool result =
          await launchUrl(Uri.parse(ssoUrl), webOnlyWindowName: "_self");
      if (!result) {
        AlertManager().showFailureToast("auth.login.errorMessageADFS".tr());
        // Fallback if SSO URL does not respond.
        router.go(Routes.login);
      }
    } else {
      // Fallback if no SSO URL is configured.
      router.go(Routes.login);
    }
  }
}
