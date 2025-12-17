import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class StatusField extends StatelessWidget {
  const StatusField({super.key, required this.viewModel});
  final ConditionEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: !viewModel.isViewOnlyMode,
      isRequired:
          Utils.checkBusinessSegment(BusinessSegment.financialInstitution)
              ? false
              : true,
      label: "covenantsConditions.covenantEditDialog.status".tr(),
      child: CustomDropdown<Reference>(
          semanticLabel: "covenantsConditions.covenantEditDialog.status".tr(),
          isEnabled: viewModel.isUpdateCondition,
          validationMessage: viewModel.isUpdateCondition
              ? "common.validation.emptyField".tr()
              : null,
          hintText: viewModel.isUpdateCondition
              ? null
              : "covenantsConditions.covenantEditDialog.new".tr(),
          items:
              viewModel.referenceData[ReferenceDataKeys.conditionStatus]?.where(
            (element) {
              return element.id != ServerConstants.conditionStatusNewId;
            },
          ).toList(),
          onSelected: (selectedValue) {
            viewModel.onStatusFieldChanged(selectedValue.first);
          },
          dropdownBuilder: (context, item) => Text(
                item?.name ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          itemBuilder: (context, item, isDisabled, isSelected) => ListTile(
                dense: true,
                title: Text(
                  item.name ?? "",
                ),
              ),
          selectedItems: viewModel.selectedStatus == null
              ? null
              : [viewModel.selectedStatus]),
    );
  }
}
