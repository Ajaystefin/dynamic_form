import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// SubSubSubTypeCreditField stateless widget
class SubSubSubTypeCreditField extends StatelessWidget {
  /// creates [SubSubSubTypeCreditField] instance
  const SubSubSubTypeCreditField({
    required this.viewModel,
    required this.label,
    super.key,
  });

  /// FileAttachmment view model to handle actions
  final FileAttachmentViewModel viewModel;

  /// label
  final String label;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label.tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        items: viewModel.caSubSubSubTypes,
        selectedItems: viewModel.selectedSubType != null
            ? [viewModel.selectedSubType]
            : [],
        validationMessage: "common.validation.requiredField".tr(),
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(showToolTip: true, text: item?.name ?? ""),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name!.length > 50 ? item.name?.substring(0, 50) : item.name,
            isSelected: isSelected ?? false,
          );
        },
        compareFn: (item1, item2) => item1.id == item2.id,
        onSelected: (selectedValues) {
          if (selectedValues.isNotEmpty) {
            viewModel.updatesubsubsubType(selectedValues.first);
          }
        },
      ),
    );
  }
}
