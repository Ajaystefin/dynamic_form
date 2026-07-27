import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the cash collateral selection.
class CashCollateral extends StatelessWidget {
  /// Creates a cash collateral widget.
  const CashCollateral({
    required this.viewModel,
    super.key,
  });

  /// View model containing cash collateral data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Prefer the stored boolean; if null, fall back to the securityType rule.

    // Assumes yesAndNo is a 2-item list: [Yes, No].
    final options = viewModel.yesAndNo ?? const [];

    final Reference? selectedValue =
        (viewModel.security.isCashCollateral ?? false)
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
        itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
            Text(item?.name ?? ""),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
