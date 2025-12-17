import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class GeneralField extends StatelessWidget {
  const GeneralField({super.key, required this.viewModel});
  final CovenantEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.generalSpecific".tr(),
      child: CustomDropdown<Reference>(
          isEnabled: !viewModel.isReadOnly,
          hintText: "common.selectValue".tr(),
          semanticLabel:
              "covenantsConditions.covenantEditDialog.generalSpecific".tr(),
          validationMessage: "common.validation.emptyField".tr(),
          items: viewModel
                  .referenceData[ReferenceDataKeys.covenantGeneralSpecific] ??
              [],
          onSelected: (selectedValue) {
            viewModel.onGeneralFieldChanged(selectedValue.first, context);
          },
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(text: item?.name, showToolTip: false),
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(item.name,
                isListTile: true, isSelected: isSelected);
          },
          selectedItems: viewModel.generalField?.id != null
              ? [viewModel.generalField!]
              : []),
    );
  }
}
