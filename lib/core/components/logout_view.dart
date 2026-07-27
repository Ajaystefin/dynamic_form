import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";

/// SSO Logout View
/// Displays a logout confirmation screen when SSO is enabled
/// Shows a "Login" button that redirects to the splash page
class LogoutView extends StatelessWidget {
  /// Creates a [LogoutView].
  const LogoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.2,
          top: MediaQuery.of(context).size.height * 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "common.components.logoutView.loggedOut".tr(),
              style: const TextStyle(
                fontSize: 24,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(),
            Text(
              "common.components.logoutView.message".tr(),
              style: AppStyle.boldLabel,
            ),
            const Gap(),
            Text(
              "common.components.logoutView.guide".tr(),
            ),
            const Gap(),
            Semantics(
              button: true,
              label: "common.components.logoutView.actionButton".tr(),
              child: InkWell(
                onTap: () {
                  router.go(Routes.splash);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "common.components.logoutView.actionButton".tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_outlined,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
