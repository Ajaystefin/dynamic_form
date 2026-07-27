import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Customer name field for the covenant edit dialog.
class CustomerNameField extends StatelessWidget {
  /// Creates a customer name field.
  const CustomerNameField({
    required this.viewModel,
    super.key,
    this.isEnabled = true,
    this.forceShowSelectedCustomer = false,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Whether the customer dropdown is enabled.
  final bool isEnabled;

  /// Whether to force showing the selected customer.
  final bool forceShowSelectedCustomer;

  @override
  Widget build(BuildContext context) {
    final List<Customer> selected = viewModel.getSelectedCustomerForDropdown(
      forceShow: forceShowSelectedCustomer,
    );

    final String tooltipText = selected.isEmpty
        ? ""
        : selected
            .map((c) => c.concatCustomerFullName.trim())
            .where((s) => s.isNotEmpty)
            .join(", ");

    final bool shouldShowTooltip = tooltipText.trim().isNotEmpty &&
        (!viewModel.isNewCovenant || selected.isNotEmpty);

    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.customerName".tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomTooltip(
        message: tooltipText,
        isRichMessage: true,
        showTooltip: shouldShowTooltip,
        child: CustomDropdown<Customer>(
          hintText: "common.selectValue".tr(),
          isEnabled: isEnabled && !viewModel.isReadOnly,
          semanticLabel:
              "covenantsConditions.covenantEditDialog.customerName".tr(),
          validationMessage: "common.validation.emptyField".tr(),
          items: viewModel.customerList,
          onSelected: (selectedValue) {
            viewModel.onCustomerSelection(selectedValue.first);
          },
          dropdownBuilder: (context, item) => dropdownBuilderWidget(
            text: item?.concatCustomerFullName,
          ),
          itemBuilder: (context, item, {isDisabled, isSelected}) {
            return dropdownItemBuildWidget(
              item.concatCustomerFullName,
              isSelected: isSelected ?? false,
            );
          },
          selectedItems: viewModel.getSelectedCustomerForDropdown(
            forceShow: forceShowSelectedCustomer,
          ),
        ),
      ),
    );
  }
}
