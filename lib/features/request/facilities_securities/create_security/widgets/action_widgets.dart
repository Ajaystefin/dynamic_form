import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

/// Widget containing action controls for the create security screen.
class ActionWidgets extends StatelessWidget {
  /// Creates an action widgets section.
  const ActionWidgets({
    required this.viewModel,
    super.key,
  });

  /// View model containing action-related data and operations.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: context.isMobile ? Axis.vertical : Axis.horizontal,
      alignment: context.isMobile ? WrapAlignment.center : WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        CustomButton(
          onPressed: () => viewModel.onSaveButtonPress(
            saveAndContinue: false,
            securityCode: viewModel.security.securityType?.reference3 ??
                viewModel.security.securityCode,
          ),
          label: "security.createSecurity.save".tr(),
          ignoreProvider: Utils.checkApplicationType(
            ApplicationType.cancellation,
          ),
        ),
        CustomButton(
          onPressed: () => viewModel.onSaveButtonPress(
            saveAndContinue: true,
            securityCode: viewModel.security.securityType?.reference3 ??
                viewModel.security.securityCode,
          ),
          ignoreProvider: Utils.checkApplicationType(
            ApplicationType.cancellation,
          ),
          label: "security.createSecurity.saveAndContinue".tr(),
        ),
        CustomButton(
          onPressed: viewModel.onCancelButtonPress,
          label: "security.createSecurity.cancel".tr(),
          ignoreProvider: Utils.checkApplicationType(
            ApplicationType.cancellation,
          ),
        ),
      ],
    );
  }
}
