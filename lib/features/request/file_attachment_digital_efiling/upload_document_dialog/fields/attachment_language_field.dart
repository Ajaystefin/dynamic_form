import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart';

class AttachmentLanguageField extends StatelessWidget {
  final UploadDocumentDialogViewModel viewModel;
  final String label;
  const AttachmentLanguageField(
      {super.key, required this.viewModel, required this.label});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: label.tr(),
        isRequired: true,
        showLabel: true,
        child: CustomDropdown<Reference>(
          hintText: "common.selectValue".tr(),
          items: viewModel.languages,
          selectedItems: viewModel.selectedLanguageType != null
              ? [viewModel.selectedLanguageType]
              : [],
          validationMessage: "common.validation.requiredField".tr(),
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(showToolTip: true, text: item?.name ?? ""),
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(item.name,
                isListTile: true, isSelected: isSelected);
          },
          compareFn: (item1, item2) => item1.id == item2.id,
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.updateLanguageType(selectedValue.first);
            }
          },
        ));
  }
}
