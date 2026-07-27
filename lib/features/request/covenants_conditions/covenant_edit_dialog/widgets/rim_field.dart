import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Customer RIM to be tested field for the covenant edit dialog.
class CustomerRimToBeTested extends StatelessWidget {
  /// Creates a customer RIM to be tested field.
  const CustomerRimToBeTested({required this.viewModel, super.key});

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.rim".tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomDropdown<Customer>(
        isEnabled: !viewModel.isReadOnly,
        hintText: "common.selectValue".tr(),
        semanticLabel: "covenantsConditions.covenantEditDialog.rim".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        key: ValueKey(
          "${viewModel.customersList?.length ?? 0}-"
          "${viewModel.selectedGeneralCovenantSubType?.id ?? 0}",
        ),
        items: List<Customer>.of(viewModel.customersList ?? const []),
        onSelected: (selectedValue) {
          viewModel.onCustomerRimSelection(selectedValue.first);
        },
        dropdownBuilder: (context, item) => dropdownBuilderWidget(
          text: item?.customerRimNo?.toString(),
        ),
        itemBuilder: (context, item, {isDisabled, isSelected}) =>
            dropdownItemBuildWidget(
          item.customerRimNo?.toString() ?? "",
          isSelected: isSelected ?? false,
        ),
        selectedItems: viewModel.selectedCustomerRim?.customerRimNo != null
            ? [viewModel.selectedCustomerRim]
            : [],
      ),
    );
  }
}
