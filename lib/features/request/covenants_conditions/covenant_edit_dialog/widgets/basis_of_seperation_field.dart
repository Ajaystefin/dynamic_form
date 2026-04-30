import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class SeperationBasisField extends StatelessWidget {
  const SeperationBasisField({
    required this.viewModel,
    super.key,
    this.isEnabled = true,
  });
  final CovenantEditDialogViewModel viewModel;
  final bool isEnabled;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.basisOfSeperation".tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled && !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.basisOfSeperation".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel
                .referenceData[ReferenceDataKeys.covenantBasicSeperation] ??
            [],
        onSelected: viewModel.onBasisOfPreparationSelected,
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        selectedItems: viewModel.selectedBasisOfPreperation != null
            ? [viewModel.selectedBasisOfPreperation]
            : [],
      ),
    );
  }
}
