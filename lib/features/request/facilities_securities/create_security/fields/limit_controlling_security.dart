import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class LimitControllingSecurity extends StatelessWidget {
  const LimitControllingSecurity({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.limitControllingSecurity".tr(),
      isRequired: false,
      showLabel: true,
      child: CustomRadioButton<Reference?>(
        //     validator: (value) {
        //       if ((viewModel.yesAndNo ?? []).contains(value)) {
        //         return null;
        //       }
        //       return
        // "security.createSecurity.selectLimitControllingSecurity".tr();
        //     },
        //     itemBuilder: (context, item, isSelected, isEnabled) =>
        //         Text(item?.name ?? ''),
        //     isEnabled: !viewModel.isCmoUpdate(),
        //     options: viewModel.yesAndNo ?? [],

        // selectedValue: viewModel.security.isLimitCtrlSecurity ??
        // (viewModel.isLimitControllingSecurity
        //     // If getter says NO, pick NO from yesAndNo
        //     ? viewModel.yesAndNo?.firstWhere(
        //         (r) => r.id == ServerConstants.optionNOid,
        //       )
        //     // Else pick YES from yesAndNo
        //     : viewModel.yesAndNo?.firstWhere(
        //         (r) => r.id == ServerConstants.optionYESid,
        //       )),
        //     onChanged: (value) {
        //       viewModel.changeLimitControllingSecurityValue(value);
        //     },
        validator: (value) {
          if ((viewModel.yesAndNo ?? []).contains(value)) {
            return null;
          }
          return "security.createSecurity.selectLimitControllingSecurity".tr();
        },
        isEnabled: !viewModel.isCmoUpdate(),
        options: viewModel.yesAndNo ?? [],
        selectedValue: (viewModel.security.isLimitCtrlSecurity ?? false)
            ? viewModel.yesAndNo?.first
            : viewModel.yesAndNo?.last,
        onChanged: (value) {
          viewModel.changeLimitControllingSecurityValue(value);
        },
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item?.name ?? ""),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
