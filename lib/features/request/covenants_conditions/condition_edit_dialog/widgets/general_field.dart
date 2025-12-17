import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart'
    show CustomDropdown;
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class GeneralField extends StatelessWidget {
  const GeneralField({
    super.key,
    required this.viewModel,
    required this.state,
  });
  final ConditionEditDialogViewModel viewModel;
  final ConditionEditDialogState state;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: !viewModel.isViewOnlyMode,
      isRequired:
          Utils.checkBusinessSegment(BusinessSegment.financialInstitution)
              ? false
              : true,
      label: "covenantsConditions.covenantEditDialog.generalSpecific".tr(),
      child: CustomDropdown<Reference>(
          isLoading: state.fieldStatus == LoadingStatus.loading,
          semanticLabel:
              "covenantsConditions.covenantEditDialog.generalSpecific".tr(),
          validationMessage: "common.validation.emptyField".tr(),
          items:
              viewModel.referenceData[ReferenceDataKeys.conditionGeneral] ?? [],
          onSelected: (selectedValue) {
            viewModel.onGeneralFieldChanged(selectedValue.first, context);
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
          selectedItems: viewModel.generalField != null
              ? [viewModel.generalField!]
              : null),
    );
  }
}
