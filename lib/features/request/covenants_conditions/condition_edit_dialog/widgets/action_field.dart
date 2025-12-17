import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart'
    show CustomDropdown;
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ActionField extends StatelessWidget {
  const ActionField({super.key, required this.viewModel});
  final ConditionEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: !viewModel.isViewOnlyMode,
      label: "covenantsConditions.covenantEditDialog.action".tr(),
      isRequired:
          Utils.checkBusinessSegment(BusinessSegment.financialInstitution)
              ? false
              : true,
      child: CustomDropdown<Reference>(
          isEnabled: viewModel.isUpdateCondition,
          semanticLabel: "covenantsConditions.covenantEditDialog.action".tr(),
          validationMessage: "common.validation.emptyField".tr(),
          items: viewModel.getActionvalues(),
          onSelected: (selectedValue) {
            viewModel.onActionFieldChange(selectedValue.first);
          },
          dropdownBuilder: (context, item) => Text(item?.name ?? ""),
          itemBuilder: (context, item, isDisabled, isSelected) => ListTile(
                dense: true,
                title: Text(
                  item.name ?? "",
                ),
              ),
          selectedItems: viewModel.selectedAction != null
              ? [viewModel.selectedAction!]
              : null),
    );
  }
}
