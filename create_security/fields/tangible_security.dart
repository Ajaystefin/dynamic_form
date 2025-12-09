import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class TangibleSecurity extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const TangibleSecurity({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.tangibleSecurity'.tr(),
      child: CustomRadioButton(
        validator: (value) {
          if ((viewModel.yesAndNo ?? []).contains(value)) {
            return null;
          }
          return "security.createSecurity.selectTangibleSecurity".tr();
        },
        isEnabled: false,
        options: viewModel.yesAndNo ?? [],
        selectedValue: // viewModel.security.isTangibleSecurity ??
            viewModel.security.securityType?.reference1 ==
                    ServerConstants.tangibleSecurityReference
                ? viewModel.yesAndNo?.first
                : viewModel.yesAndNo?[1],
        onChanged: (value) {
          viewModel.security.isTangibleSecurity = value;
        },
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item.name ?? ''),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
