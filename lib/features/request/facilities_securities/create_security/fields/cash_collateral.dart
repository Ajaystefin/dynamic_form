import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class CashCollateral extends StatelessWidget {
  const CashCollateral({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Prefer the stored boolean; if null, fall back to the securityType rule.
    final bool isCashCollateral = viewModel.security.isCashCollateral ??
        (viewModel.security.securityType?.reference2 ==
            ServerConstants.cashCollateralReference);

    // Assumes yesAndNo is a 2-item list: [Yes, No].
    final options = viewModel.yesAndNo ?? const [];

    final selectedValue = (isCashCollateral)
        ? (options.isNotEmpty ? options.first : null) // Yes
        : (options.length > 1 ? options[1] : null); // No

    return LabelWidget(
      label: "security.createSecurity.cashCollateral".tr(),
      child: CustomRadioButton<Reference?>(
        options: viewModel.yesAndNo ?? [],
        isEnabled: !viewModel.isCmoUpdate() && false,
        selectedValue: selectedValue,
        onChanged: (value) {
          viewModel.changeCashCollateralValue(value);
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
