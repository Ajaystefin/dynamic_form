import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the security held by information.
class SecurityHeldBy extends StatelessWidget {
  /// Creates a security held by widget.
  const SecurityHeldBy({
    required this.viewModel,
    super.key,
  });

  /// View model containing security held by data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: !viewModel.isFIFlow,
      label: "security.createSecurity.securityHeldBy".tr(),
      child: CustomDropdown<Reference>(
        isEnabled: !viewModel.isCmoUpdate(),
        validationMessage:
            viewModel.isFIFlow ? null : "validation.emptyField".tr(),
        items: viewModel.securityHeldAsList,
        selectedItems: viewModel.security.securityHeldAs == null
            ? []
            : [
                viewModel.securityHeldAsList.firstWhere(
                  (item) => item.id == viewModel.security.securityHeldAs?.id,
                  orElse: () => viewModel.securityHeldAsList.first,
                ),
              ],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.security.securityHeldAs = selectedValue.first;
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
