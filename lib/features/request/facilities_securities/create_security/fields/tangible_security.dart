import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the tangible security selection.
class TangibleSecurity extends StatelessWidget {
  /// Creates a tangible security widget.
  const TangibleSecurity({
    required this.viewModel,
    super.key,
  });

  /// View model containing tangible security data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Prefer the stored boolean; if null, fall back to the securityType rule.
    final bool isTangible = viewModel.security.isTangibleSecurity ??
        (viewModel.security.securityType?.reference1 ==
            ServerConstants.tangibleSecurityReference);
    // Assumes yesAndNo is a 2-item list: [Yes, No].
    final options = viewModel.yesAndNo ?? const [];

    final Reference? selectedValue = isTangible
        ? (options.isNotEmpty ? options.first : null) // Yes
        : (options.length > 1 ? options[1] : null); // No

    return LabelWidget(
      label: "security.createSecurity.tangibleSecurity".tr(),
      child: CustomRadioButton<Reference?>(
        validator: (value) {
          if ((viewModel.yesAndNo ?? []).contains(value)) {
            return null;
          }
          return "security.createSecurity.selectTangibleSecurity".tr();
        },
        isEnabled: !viewModel.isCmoUpdate() && false,
        options: viewModel.yesAndNo ?? [],
        selectedValue: selectedValue,
        onChanged: (value) {
          viewModel.security.isTangibleSecurity = value == options.first;
          // viewModel.security.isTangibleSecurity;
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
