import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

class SubmissionTimeField extends StatelessWidget {
  const SubmissionTimeField({
    required this.viewModel,
    super.key,
    this.isEnabled = true,
    this.row,
  });
  final CovenantEditDialogViewModel viewModel;
  final bool isEnabled;
  final Covenant? row;
  @override
  Widget build(BuildContext context) {
    final List<Reference> items =
        viewModel.referenceData[ReferenceDataKeys.covenantSubmissionTime] ?? [];

    final Reference? rowSelected = (row?.timeForSubmition != null)
        ? items.firstWhere(
            (r) => r.id == row!.timeForSubmition,
            orElse: Reference.new,
          )
        : null;

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.timeForSubmission".tr(),
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled && !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.timeForSubmission".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items:
            viewModel.referenceData[ReferenceDataKeys.covenantSubmissionTime] ??
                [],
        onSelected: (selectedValue) {
          // viewModel.onTimeForSubmissionSelected(selectedValue);

          if (row == null) {
            viewModel.onTimeForSubmissionSelected(selectedValue);
          } else {
            viewModel.onRowTimeForSubmissionSelected(row!, selectedValue);
          }
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        // selectedItems: viewModel.selectedTimeForSubmission?.id != null
        //     ? [viewModel.selectedTimeForSubmission!]
        //     : []

        selectedItems: row == null
            ? (viewModel.selectedTimeForSubmission?.id != null
                ? [viewModel.selectedTimeForSubmission]
                : const [])
            : (rowSelected?.id != null ? [rowSelected] : const []),
      ),
    );
  }
}
