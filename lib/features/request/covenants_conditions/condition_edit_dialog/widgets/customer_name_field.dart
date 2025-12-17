import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class CustomerNameField extends StatelessWidget {
  const CustomerNameField({super.key, required this.viewModel});
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        isEnabled: !viewModel.isViewOnlyMode,
        label: 'covenantsConditions.covenantEditDialog.customerName'.tr(),
        isRequired:
            Utils.checkBusinessSegment(BusinessSegment.financialInstitution)
                ? false
                : true,
        child: CustomDropdown<Customer>(
            semanticLabel:
                'covenantsConditions.covenantEditDialog.customerName'.tr(),
            validationMessage: "common.validation.emptyField".tr(),
            isEnabled: !viewModel.isUpdateCondition,
            items: Globals.request?.customers ?? [],
            onSelected: (selectedValue) {
              viewModel.selectedCustomer = selectedValue.first;
            },
            dropdownBuilder: (context, item) => dropdownBuilderWidget(
                text: item?.displayName, showToolTip: false),
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownItemBuildWidget(item.displayName,
                  isListTile: true, isSelected: isSelected);
            },
            selectedItems: viewModel.selectedCustomer != null
                ? [viewModel.selectedCustomer!]
                : null));
  }
}
