import "dart:convert";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/splash/state.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

class SplashViewModel extends SafeCubit<SplashState> {
  SplashViewModel() : super(SplashState(loaderStatus: LoadingStatus.loaded));

  Future<void> init(Map<String, String> queryParams) async {
    debugPrint("queryParams in SplashViewModel: $queryParams");
    // if (await _checkAuthentication()) return;

    // In debug mode, show debug login screen instead of SSO redirect
    // if (kDebugMode) {
    //   router.go("/debug");
    //   return;
    // }

    if (!EnvConfig.isSSOEnabled) {
      router.go(Routes.login);
      return;
    }
    if (queryParams.containsKey("sso_error")) {
      AlertManager().showFailureToast("auth.login.errorMessageSSO".tr());
      router.go(Routes.login);
      return;
    }
    if (queryParams.containsKey("tokenResponse")) {
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
        throw "auth.login.errorMessageInvalidResponse".tr();
      }

      // Extract and set sessionID from SSO parameters
      if (queryParams.containsKey("sessionID")) {
        Globals.sessionID = queryParams["sessionID"]!;
        debugPrint("Session ID set from SSO: ${Globals.sessionID}");
      }

      final userResponse = jsonDecode(queryParams["userResponse"]!);
      debugPrint("User Response: $userResponse");
      final tokenResponse = jsonDecode(queryParams["tokenResponse"]!);

      await AuthRepository.instance.loginWithSSO(
        tokenResponse: tokenResponse,
        userResponse: userResponse,
      );

      final bool hasRoles = Globals.user?.segments?.isNotEmpty ?? false;
      if (hasRoles) {
        AlertManager().showSuccessToast("auth.login.success".tr());
        (Globals.user?.availableRoles?.length == 1
            ? router.go(Routes.home)
            : router.go(Routes.selectRole));
      } else {
        throw "auth.login.errorMessageNoRoles".tr();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      router.go(Routes.login);
    }
  }

  Future<void> _initiateSSORedirect() async {
    final ssoUrl = EnvConfig.ssoUrl;
    if (ssoUrl.isNotEmpty && kIsWeb) {
      await launchUrl(Uri.parse(ssoUrl), webOnlyWindowName: "_self");
    } else {
      // Fallback if no SSO URL is configured.
      router.go(Routes.login);
    }
  }
}
