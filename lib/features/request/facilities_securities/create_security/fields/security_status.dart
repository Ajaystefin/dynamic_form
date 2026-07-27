import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the security status.
class SecurityStatus extends StatelessWidget {
  /// Creates a security status widget.
  const SecurityStatus({
    required this.viewModel,
    super.key,
  });

  /// View model containing security status data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.securityStatus".tr(),
      exponent: "#",
      isRequired: !viewModel.isFIFlow,
      child: CustomDropdown<Reference>(
        ignoreProvider: (viewModel.isCmoUpdate() && viewModel.canEdit) ||
            Utils.checkApplicationType(ApplicationType.cancellation),
        validationMessage: !viewModel.isFIFlow
            ? "common.validation.emptyRequiredField".tr()
            : null,
        items: viewModel.securityStatusList,
        selectedItems: viewModel.securityStatusList
            .where((r) => r.id == viewModel.security.securityStatus?.id)
            .toList(),
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.security.securityStatus = selectedValue.first;
          }
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
