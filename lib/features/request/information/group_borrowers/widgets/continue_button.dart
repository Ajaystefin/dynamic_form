import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";

class ContinueButton extends StatelessWidget {
  const ContinueButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Continue Button at the bottom.
    return Align(
      alignment: Alignment.centerRight,
      child: CustomButton(
        label: "requestInformation.groupBorrowers.continue".tr(),
        onPressed: () {
          if (context.mounted) {
            router.go(Routes.applicationBorrowers);
          }
        },
      ),
    );
  }
}
