import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class ActionWidgets extends StatelessWidget {
  final CreateSecurityViewModel viewModel;

  const ActionWidgets({
    super.key,
    required this.viewModel,
  });

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
          onPressed: () => viewModel.onSaveButtonPress(false),
          label: "security.createSecurity.save".tr(),
        ),
        CustomButton(
          onPressed: () => viewModel.onSaveButtonPress(true),
          label: "security.createSecurity.saveAndContinue".tr(),
        ),
        CustomButton(
          onPressed: viewModel.onCancelButtonPress,
          label: "security.createSecurity.cancel".tr(),
        ),
      ],
    );
  }
}
