import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";

/// Input field for entering the application reference number.
class ApplicationRefNoField extends StatelessWidget {
  /// Creates an [ApplicationRefNoField].
  const ApplicationRefNoField({
    required this.viewModel,
    super.key,
  });

  /// View model used to manage advanced search values.
  final AdvancedSearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "dashboard.advancedSearch.applicationRefNo".tr(),
      child: CustomTextField(
        initialValue: viewModel.applicationRefNo,
        semanticLabel: "dashboard.advancedSearch.applicationRefNo".tr(),
        inputFormatters: [
          LengthLimitingTextInputFormatter(30),
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        ],
        validator: (value) {
          return CustomValidator.requiredCustomField(
            value,
            "dashboard.advancedSearch.applicationRefNo".tr(),
          );
        },
        onChanged: (value) {
          viewModel.applicationRefNo = value;
        },
      ),
    );
  }
}
