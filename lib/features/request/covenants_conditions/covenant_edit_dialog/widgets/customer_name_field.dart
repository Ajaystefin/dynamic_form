import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class CustomerNameField extends StatelessWidget {
  const CustomerNameField({
    super.key,
    required this.viewModel,
    this.isEnabled = true,
    this.forceShowSelectedCustomer = false,
  });

  final CovenantEditDialogViewModel viewModel;
  final bool isEnabled;
  final bool forceShowSelectedCustomer;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'covenantsConditions.covenantEditDialog.customerName'.tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomDropdown<Customer>(
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled && !viewModel.isReadOnly,
        semanticLabel:
            'covenantsConditions.covenantEditDialog.customerName'.tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.customersList,
        onSelected: (selectedValue) {
          viewModel.onCustomerSelection(selectedValue.first);
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.displayName, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.displayName,
              isListTile: true, isSelected: isSelected);
        },
        selectedItems:
            viewModel.getSelectedCustomerForDropdown(forceShowSelectedCustomer),
      ),
    );
  }
}
