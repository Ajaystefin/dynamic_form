import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/file_attachment/tooltip_helper.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// DocumentNameField stateless widget
class DocumentNameField extends StatelessWidget {
  /// Creates [DocumentNameField] instance
  const DocumentNameField({
    required this.initialValue,
    required this.onSaved,
    this.documentTypeId,
    this.subSubTypeId,
    super.key,
    this.isRequired = false,
  });

  /// initial value
  final String? initialValue;

  /// documment type id
  final int? documentTypeId;

  /// Sub type id
  final int? subSubTypeId;

  /// onSave callback function
  final Function(String?) onSaved;

  /// whether required or not
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.documentName".tr(),
      isRequired: isRequired,
      infoContent:
          TooltipHelper.getDocumentNameTooltip(documentTypeId, subSubTypeId),
      child: CustomTextField(
        initialValue: initialValue ?? "",
        maxLength: 100,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
        ],
        onSaved: onSaved,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.documentNameRequired".tr();
          }
          return null;
        },
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
