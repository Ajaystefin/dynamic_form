import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class LimitControllingSecurity extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const LimitControllingSecurity({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.limitControllingSecurity'.tr(),
      isRequired: false,
      showLabel: true,
      child: CustomRadioButton<Reference?>(
        validator: (value) {
          if ((viewModel.yesAndNo ?? []).contains(value)) {
            return null;
          }
          return "security.createSecurity.selectLimitControllingSecurity".tr();
        },
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item?.name ?? ''),
        options: viewModel.yesAndNo ?? [],
        selectedValue: viewModel.security.isLimitCtrlSecurity ??
            (viewModel.yesAndNo?.first),
        onChanged: (value) {
          viewModel.changeLimitControllingSecurityValue(value);
        },
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
