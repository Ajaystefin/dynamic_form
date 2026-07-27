import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// EntityIdField stateless widget
class EntityIdField extends StatelessWidget {
  /// create [EntityIdField] instance
  const EntityIdField({
    required this.initialValue,
    required this.onSaved,
    super.key,
    this.isRequired = false,
  });

  /// initial value
  final String? initialValue;

  /// onSave callback function
  final Function(String?) onSaved;

  /// whether required or not
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.entityIdField".tr(),
      isRequired: isRequired,
      child: CustomTextField(
        initialValue: initialValue ?? "",
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ],
        onSaved: onSaved,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.entityIdRequired".tr();
          }
          return null;
        },
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
