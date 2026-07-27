import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing limit controlling security details.
class LimitControllingSecurity extends StatelessWidget {
  /// Creates a limit controlling security widget.
  const LimitControllingSecurity({
    required this.viewModel,
    super.key,
  });

  /// View model containing limit controlling security data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.limitControllingSecurity".tr(),
      child: CustomRadioButton<Reference?>(
        //     validator: (value) {
        //       if ((viewModel.yesAndNo ?? []).contains(value)) {
        //         return null;
        //       }
        //       return
        // "security.createSecurity.selectLimitControllingSecurity".tr();
        //     },
        //     itemBuilder: (context, item, {bool? isSelected,bool? isEnabled})
        //      =>  Text(item?.name ?? ''),
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
        itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
            Text(item?.name ?? ""),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
