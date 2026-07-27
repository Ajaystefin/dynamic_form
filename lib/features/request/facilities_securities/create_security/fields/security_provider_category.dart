import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the security provider category.
class SecurityProviderCategory extends StatelessWidget {
  /// Creates a security provider category widget.
  const SecurityProviderCategory({
    required this.viewModel,
    super.key,
  });

  /// View model containing security provider category data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.securityProviderCategory".tr(),
      isRequired: !viewModel.isFIFlow && !viewModel.securityProviderCbdCustomer,
      child: CustomDropdown<Reference>(
        onClear: (clear) {
          viewModel.changeSecurityProviderCategory(null);
        },
        isEnabled: !viewModel.isCmoUpdate(),
        items: viewModel.securityProvidedCategories,
        selectedItems: [
          if (viewModel.security.securityProviderCategory != null)
            Reference(name: viewModel.security.securityProviderCategory)
          else
            null,
        ],
        onSelected: (selectedValue) {
          viewModel.changeSecurityProviderCategory(selectedValue.first);
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        validationMessage:
            (!viewModel.isFIFlow && !viewModel.securityProviderCbdCustomer)
                ? "common.validation.emptyRequiredField".tr()
                : null,
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
