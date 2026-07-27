import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Customer name field for the condition edit dialog.
class CustomerNameField extends StatelessWidget {
  /// Creates a customer name field.
  const CustomerNameField({required this.viewModel, super.key});

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final Customer? selected = viewModel.selectedCustomer;
    final String tooltipText = (selected?.concatCustomerFullName ?? "").trim();

    return CustomTooltip(
      message: tooltipText,
      isRichMessage: true,
      showTooltip: tooltipText.isNotEmpty,
      child: LabelWidget(
        isEnabled: viewModel.canEdit,
        label: "covenantsConditions.covenantEditDialog.customerName".tr(),
        isRequired:
            !Utils.checkBusinessSegment(BusinessSegment.financialInstitution),
        child: CustomDropdown<Customer>(
          semanticLabel:
              "covenantsConditions.covenantEditDialog.customerName".tr(),
          validationMessage: "common.validation.emptyField".tr(),
          isEnabled: !viewModel.isUpdateCondition,
          items: viewModel.customerList,
          onSelected: (selectedValue) {
            viewModel.selectedCustomer = selectedValue.first;
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
          selectedItems: viewModel.selectedCustomer != null
              ? [viewModel.selectedCustomer]
              : null,
        ),
      ),
    );
  }
}
