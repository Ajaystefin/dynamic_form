import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class IsSecurityExpiryOpenEnded extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const IsSecurityExpiryOpenEnded({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.isSecurityExpiryOpenEnded'.tr(),
      isRequired: true,
      child: CustomRadioButton<Reference?>(
        validator: (value) {
          if ((viewModel.yesAndNo ?? []).contains(value)) {
            return null;
          }
          return "security.createSecurity.isSecurityExpiryOpenEnded".tr();
        },
        options: viewModel.yesAndNo ?? [],
        selectedValue: (viewModel.security.isSecurityExpiryOpenEnded ?? false)
            ? (viewModel.yesAndNo?.first)
            : viewModel.yesAndNo?.last,
        onChanged: (value) {
          viewModel.changeSecurityExpiryOpenEndedValue(value);
        },
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item?.name ?? ''),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
