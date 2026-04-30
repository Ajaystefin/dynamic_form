import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

class SessionConflictDialog extends StatelessWidget {
  const SessionConflictDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "common.components.sessionConflict.content".tr(),
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Gap(),
        const Divider(),
        Align(
          alignment: Alignment.center,
          child: CustomButton(
            backgroundColor: AppColors.dialogTitleColor,
            textColor: AppColors.white,
            label: "common.components.sessionConflict.loginButton".tr(),
            onPressed: () async {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              await AuthRepository.instance.clearCacheAndStopSession();
              if (context.mounted) {
                router.go(Routes.splash);
              }
            },
          ),
        ),
      ],
    );
  }
}
