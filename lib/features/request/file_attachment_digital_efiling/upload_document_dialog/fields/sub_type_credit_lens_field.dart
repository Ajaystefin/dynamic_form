import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// SubTypeCreditLensField stateless widget
class SubTypeCreditLensField extends StatelessWidget {
  /// Creates [SubTypeCreditLensField] instance
  const SubTypeCreditLensField({
    required this.viewModel,
    required this.label,
    super.key,
  });

  /// UploadDocumentDialogViewModel view model to handle actions
  final UploadDocumentDialogViewModel viewModel;

  /// Label
  final String label;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label.tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        items: viewModel.clSubTypes,
        selectedItems: viewModel.selectedSubTypeCreditLens != null
            ? [viewModel.selectedSubTypeCreditLens]
            : [],
        validationMessage: "common.validation.requiredField".tr(),
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(showToolTip: true, text: item?.name ?? ""),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        compareFn: (item1, item2) => item1.id == item2.id,
        onSelected: (selectedValues) {
          if (selectedValues.isNotEmpty) {
            viewModel.updateSubTypeCreditLens(selectedValues.first);
          }
        },
      ),
    );
  }
}
