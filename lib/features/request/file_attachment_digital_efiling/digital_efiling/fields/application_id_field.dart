import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/scale.dart";

/// ApplicationIdField stateless widget

class ApplicationIdField extends StatelessWidget {
  /// Creates [ApplicationIdField] instance

  const ApplicationIdField({
    required this.controller,
    required this.onSaved,
    super.key,
    this.readOnly,
  });

  /// TextEditor Controller
  final TextEditingController controller;

  /// onSave callback function
  final Function(String?) onSaved;

  /// is read only or not
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.applicationId".tr(),
      child: CustomTextField(
        controller: controller,
        readOnly: readOnly ?? false,
        maxLength: 30,
        width: 250.w,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        ],
        onSaved: onSaved,
        // validator: (value) {
        //   if (value == null || value.trim().isEmpty) {
        //     return "common.validation.applicationIdRequired".tr();
        //   }
        //   return null;
        // },
        filled: readOnly ?? false,
        fillColor: AppColors.tableCellColorGroupedRow,
        searchDebounce: const Duration(milliseconds: 800),
        onSearchChanged: (String query) async {
          // Simulate API call or search operation
          // await Future.delayed(const Duration(seconds: 2));
          logger.i("Search query: $query");
          await onSaved(query);
          // Your actual search logic here
          // e.g., await viewModel.searchItems(query);
        },
      ),
    );
  }
}
