import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// Trade licence number field for the customer information screen.
class TradeLicenceNoField extends StatelessWidget {
  /// Creates a trade licence number field.
  const TradeLicenceNoField({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        (viewModel.customerInformation?.tradeLicenseNumber ?? "").trim();

    /// Rule:
    /// - If page is not editable => readOnly
    /// - If trade license came from backend => readOnly
    /// - If trade license came from draft => editable
    /// - If empty => editable
    final bool readOnly = !viewModel.canEdit ||
        viewModel.tradeLicenseSource == TradeLicenseSource.backend;

    return LabelWidget(
      label: "customerInformation.customerInformation.tradeLicenseNo".tr(),
      child: CustomTextField(
        key: const ValueKey("tradeLicenseNumber"),
        semanticLabel:
            "customerInformation.customerInformation.tradeLicenseNo".tr(),
        onSaved: (value) {
          if (!readOnly) {
            viewModel.customerInformation?.tradeLicenseNumber = value?.trim();
          }
        },
        onChanged: (value) {
          if (!readOnly) {
            viewModel.customerInformation?.tradeLicenseNumber = value.trim();
          }
        },
        maxLength: 15,
        initialValue: initialValue,
        filled: readOnly,
        readOnly: readOnly,
      ),
    );
  }
}
