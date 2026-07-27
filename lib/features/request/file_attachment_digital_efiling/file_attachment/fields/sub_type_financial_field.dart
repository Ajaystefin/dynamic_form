import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// SubTypeFinancialField stateless widget

class SubTypeFinancialField extends StatelessWidget {
  /// Creates [SubTypeFinancialField] instance

  const SubTypeFinancialField({
    required this.viewModel,
    super.key,
  });

  /// FileAttachmment view model to handle actions
  final FileAttachmentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.typeOfFinancialStatements".tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        items: viewModel.fstSubTypes,
        selectedItems: viewModel.selectedSubType != null
            ? [viewModel.selectedSubType]
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
            viewModel.updateSubType(selectedValues.first);
          }
        },
      ),
    );
  }
}
